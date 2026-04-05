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

  String _handleError(dynamic e) {
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') return 'Permission denied. Please login to continue.';
      if (e.code == 'unavailable') return 'Network unavailable. Check your connection.';
    }
    return 'Something went wrong: ${e.toString()}';
  }

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
      throw Exception(_handleError(e));
    }
  }

  // --- Clients ---
  Stream<List<Client>> getClients({
    String? sortBy = 'name',
    bool descending = false,
    int? limit,
  }) {
    final uid = currentUserId;
    if (uid == null) throw Exception('Please login to continue');
    
    Query query = _db.collection('users').doc(uid).collection('crm');
    
    if (sortBy != null) {
      query = query.orderBy(sortBy, descending: descending);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> addClient(Client client) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      final map = client.toMap();
      map['userId'] = uid;
      await _db.collection('users').doc(uid).collection('crm').add(map);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('crm').doc(client.id).update(client.toMap());
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }
  
  Future<void> deleteClient(String clientId) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('crm').doc(clientId).delete();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- Projects ---
  Stream<List<Project>> getProjects({
    ProjectStatus? status,
    String sortBy = 'createdAt',
    bool descending = true,
    int? limit,
  }) {
    final uid = currentUserId;
    if (uid == null) throw Exception('Please login to continue');
    
    Query query = _db.collection('users').doc(uid).collection('nests');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    
    query = query.orderBy(sortBy, descending: descending);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> addProject(Project project) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      final map = project.toMap();
      map['userId'] = uid;
      await _db.collection('users').doc(uid).collection('nests').add(map);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('nests').doc(project.id).update(project.toMap());
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      // Delete sub-collection tasks first to avoid orphaned documents
      final tasksSnap = await _db.collection('users').doc(uid).collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      final batch = _db.batch();
      for (final doc in tasksSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('users').doc(uid).collection('nests').doc(projectId));
      await batch.commit();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- Tasks ---
  Stream<List<Task>> getTasks(String projectId, {TaskStatus? status}) {
    final uid = currentUserId;
    if (uid == null) throw Exception('Please login to continue');
    
    Query query = _db.collection('users').doc(uid).collection('tasks')
        .where('projectId', isEqualTo: projectId);
        
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    
    return query.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> addTask(Task task) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      
      final map = task.toMap();
      map['userId'] = uid;
      
      // Ensure status is set to active for new tasks if not already
      if (map['status'] == null) {
        map['status'] = TaskStatus.active.name;
      }
      
      await _db.collection('users').doc(uid).collection('tasks').add(map);
      await _db.collection('users').doc(uid).collection('nests').doc(task.projectId).update({
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> toggleTask(String taskId, TaskStatus currentStatus) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      
      final newStatus = currentStatus == TaskStatus.active ? TaskStatus.completed : TaskStatus.active;
      await _db.collection('users').doc(uid).collection('tasks').doc(taskId).update({
        'status': newStatus.name,
        // Keep isCompleted for backward compatibility if needed, but the primary is 'status'
        'isCompleted': newStatus == TaskStatus.completed,
      });
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }


  Future<void> deleteTask(String taskId) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- Invoices ---
  Stream<List<Invoice>> getInvoices({
    String? status,
    String sortBy = 'issueDate',
    bool descending = true,
    int? limit,
  }) {
    final uid = currentUserId;
    if (uid == null) throw Exception('Please login to continue');
    
    Query query = _db.collection('users').doc(uid).collection('finance');
    
    if (status != null && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }
    
    query = query.orderBy(sortBy, descending: descending);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      final map = invoice.toMap();
      map['userId'] = uid;
      await _db.collection('users').doc(uid).collection('finance').add(map);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('finance').doc(invoice.id).update(invoice.toMap());
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('finance').doc(invoiceId).delete();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- Time Tracker ---
  Stream<TimeLog?> getActiveTimeLog() {
    final uid = currentUserId;
    if (uid == null) throw Exception('Please login to continue');
    return _db.collection('users').doc(uid).collection('timelogs')
        .where('isRunning', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty 
            ? null 
            : TimeLog.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id));
  }

  Future<void> startTimeLog(String projectId, String projectTitle) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      final log = {
        'userId': uid,
        'projectId': projectId,
        'projectTitle': projectTitle,
        'startTime': FieldValue.serverTimestamp(),
        'isRunning': true,
        'durationInMinutes': 0,
      };
      await _db.collection('users').doc(uid).collection('timelogs').add(log);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> stopTimeLog(String logId, int duration) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).collection('timelogs').doc(logId).update({
        'endTime': FieldValue.serverTimestamp(),
        'isRunning': false,
        'durationInMinutes': duration,
      });
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- User Profile ---
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Stream<DocumentSnapshot> getUserStream() {
    final uid = currentUserId;
    if (uid == null) throw Exception('Please login to continue');
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> updateAvailability(bool isAvailable) async {
    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('Please login to continue');
      await _db.collection('users').doc(uid).update({'isAvailable': isAvailable});
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
