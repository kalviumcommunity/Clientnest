import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

/// Dedicated service for all Project & Task Firestore operations.
/// Uses the flat 'projects' collection with a 'tasks' subcollection.
class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ─── PROJECT METHODS ────────────────────────────────────────────────────────

  /// Creates a new project document under the current user.
  Future<void> createProject(Project project) async {
    try {
      final uid = _uid;
      if (uid == null) throw Exception('User not authenticated');
      await _db.collection('projects').add({
        ...project.toMap(),
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Returns a real-time stream of projects belonging to the current user.
  Stream<List<Project>> getUserProjects() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('projects')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Project.fromMap(doc.data(), doc.id)).toList())
        .handleError((e) {
      throw Exception('Failed to fetch projects: $e');
    });
  }

  /// Deletes a project document and its tasks subcollection.
  Future<void> deleteProject(String projectId) async {
    try {
      final tasksSnap = await _db
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .get();
      final batch = _db.batch();
      for (final doc in tasksSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('projects').doc(projectId));
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Updates an existing project document.
  Future<void> updateProject(Project project) async {
    try {
      await _db.collection('projects').doc(project.id).update({
        ...project.toMap(),
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  // ─── TASK METHODS (subcollection path) ──────────────────────────────────────

  /// Adds a task to the tasks subcollection of a project.
  Future<void> addTask(String projectId, Task task) async {
    try {
      await _db
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .add({
        'title': task.title,
        'isCompleted': task.isCompleted,
        'dueDate': task.dueDate != null
            ? Timestamp.fromDate(task.dueDate!)
            : null,
        'priority': task.priority,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _db.collection('projects').doc(projectId).update({
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Toggles the isCompleted flag of a task.
  Future<void> toggleTaskCompletion(
      String projectId, String taskId, bool isCompleted) async {
    try {
      await _db
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': isCompleted});
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }

  /// Deletes a task document from the subcollection.
  Future<void> deleteTask(String projectId, String taskId) async {
    try {
      await _db
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Returns a real-time stream of tasks for the given project.
  Stream<List<Task>> getProjectTasks(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) {
      throw Exception('Failed to fetch project tasks: $e');
    });
  }

  /// Returns the count of incomplete tasks across all user projects.
  Stream<int> getPendingTasksCount() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length)
        .handleError((e) {
      throw Exception('Failed to fetch pending tasks count: $e');
    });
  }
}
