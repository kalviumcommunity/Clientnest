import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Saves or updates user data in Firestore.
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
        userData['isAvailable'] = true; // Default availability
      }

      await userRef.set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // --- Users Stream ---
  Stream<DocumentSnapshot> getUserStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> updateAvailability(bool isAvailable) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'isAvailable': isAvailable});
  }

  // --- Projects Stream ---
  Stream<List<Map<String, dynamic>>> getProjectsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('projects')
        .where('userId', isEqualTo: uid)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // --- Clients Stream ---
  Stream<List<Map<String, dynamic>>> getClientsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('clients')
        .where('userId', isEqualTo: uid)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // --- Payments Stream ---
  Stream<List<Map<String, dynamic>>> getPaymentsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('payments')
        .where('userId', isEqualTo: uid)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
