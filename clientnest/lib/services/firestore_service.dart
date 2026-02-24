import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/invoice_model.dart';
import '../models/time_log_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- Users ---
  Future<void> saveUser(User user) async {
    try {
      final userRef = _db.collection('users').doc(user.uid);
      
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
      };

      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await userRef.set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // --- Clients ---
  Stream<List<Client>> getClients() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _db.collection('clients')
        .where('userId', isEqualTo: uid)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Client.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addClient(Client client) async {
    await _db.collection('clients').add(client.toMap());
  }

  Future<void> updateClient(Client client) async {
    await _db.collection('clients').doc(client.id).update(client.toMap());
  }

  // --- Projects ---
  Stream<List<Project>> getProjects() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _db.collection('projects')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Project.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addProject(Project project) async {
    await _db.collection('projects').add(project.toMap());
  }

  Future<void> updateProject(Project project) async {
    await _db.collection('projects').doc(project.id).update(project.toMap());
  }

  // --- Tasks ---
  Stream<List<Task>> getTasks(String projectId) {
    return _db.collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTask(Task task) async {
    await _db.collection('tasks').add(task.toMap());
    // Update last activity for project
    await _db.collection('projects').doc(task.projectId).update({
      'lastActivity': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    await _db.collection('tasks').doc(taskId).update({'isCompleted': isCompleted});
  }

  // --- Invoices ---
  Stream<List<Invoice>> getInvoices() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _db.collection('invoices')
        .where('userId', isEqualTo: uid)
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Invoice.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _db.collection('invoices').add(invoice.toMap());
  }

  // --- Time Tracker ---
  Stream<TimeLog?> getActiveTimeLog() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);
    return _db.collection('timelogs')
        .where('userId', isEqualTo: uid)
        .where('isRunning', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty 
            ? null 
            : TimeLog.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id));
  }

  Future<void> startTimeLog(String projectId, String projectTitle) async {
    final uid = currentUserId;
    if (uid == null) return;

    final log = {
      'userId': uid,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'startTime': FieldValue.serverTimestamp(),
      'isRunning': true,
      'durationInMinutes': 0,
    };
    await _db.collection('timelogs').add(log);
  }

  Future<void> stopTimeLog(String logId, int duration) async {
    await _db.collection('timelogs').doc(logId).update({
      'endTime': FieldValue.serverTimestamp(),
      'isRunning': false,
      'durationInMinutes': duration,
    });
  }
}
