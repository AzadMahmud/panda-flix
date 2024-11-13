import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  Future<void> signUp(String email, String password) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _user = userCredential.user;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _user = userCredential.user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> addToWatchlist(String itemId, bool isMovie) async {
    if (_user != null) {
      final type = isMovie ? 'movies' : 'tvShows';
      await _firestore.collection('users').doc(_user!.uid).collection('watchlist').doc(itemId).set({
        'itemId': itemId,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(String itemId) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).collection('watchlist').doc(itemId).delete();
      notifyListeners();
    }
  }

  Future<void> markAsFavorite(String itemId, bool isMovie) async {
    if (_user != null) {
      final type = isMovie ? 'movies' : 'tvShows';
      await _firestore.collection('users').doc(_user!.uid).collection('favorites').doc(itemId).set({
        'itemId': itemId,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    }
  }

  Future<void> rateItem(String itemId, double rating) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).collection('ratings').doc(itemId).set({
        'itemId': itemId,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    }
  }
   Future<void> addReview(String movieId, bool isMovie, String reviewContent) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).collection('reviews').add({
        'movieId': movieId,
        'isMovie': isMovie,
        'reviewContent': reviewContent,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    }
  }
}
