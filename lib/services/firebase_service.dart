import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Guest Login Function
  Future<UserModel?> signInAsGuest() async {
    try {
      // Firebase anonymous login
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        // User ka data Firestore mein save/update karna
        UserModel newUser = UserModel(
          uid: user.uid,
          name: 'Guest User ${user.uid.substring(0, 4)}',
          email: 'guest_${user.uid.substring(0, 8)}@promptmb.app',
        );

        await _firestore.collection('users').doc(user.uid).set(
          newUser.toMap(),
          SetOptions(merge: true), // Agar pehle se hai toh update karo, naya mat banao
        );

        return newUser;
      }
      return null;
    } catch (e) {
      print('Guest login error: $e');
      return null;
    }
  }

  // Current User ka data fetch karna
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }
}
