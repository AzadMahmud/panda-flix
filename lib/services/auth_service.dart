
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(String email, String password, String username) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final User? user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'watchlist': [],
        'favorites': [],
        'reviews': [],
      });
    }
    return user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
