import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves or updates user data in Firestore.
  /// Uses [SetOptions(merge: true)] to prevent overwriting existing fields
  /// while updating login timestamps or other info if needed.
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

      // If the user is new, we might want to set 'createdAt'.
      // However, with merge: true, we can just set it if it doesn't exist using a separate check
      // or just assume the first write is creation.
      // To strictly follow "createdAt (server timestamp)", we can check if doc exists.
      
      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await userRef.set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }
}
