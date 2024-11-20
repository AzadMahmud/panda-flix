import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   List<Map<String, dynamic>> _favoriteMovies = [];

  List<Map<String, dynamic>> get favoriteMovies => _favoriteMovies;
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

  Future<void> addToWatchlist(String movieId, bool isMovie, String title, String posterPath) async {
  if (_user != null) {
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('watchlist')
        .doc(movieId)
        .set({
      'movieId': movieId,
      'isMovie': isMovie,
      'title': title,
      'posterPath': posterPath,
      'timestamp': FieldValue.serverTimestamp(),
    });
    notifyListeners(); // Notify UI changes.
  }
}

  Future<void> removeFromWatchlist(String itemId) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).collection('watchlist').doc(itemId).delete();
      notifyListeners();
    }
  }

   Future<void> markAsFavorite(String movieId, bool isMovie, String title, String posterPath) async {
  if (_user != null) {
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc(movieId)
        .set({
      'movieId': movieId,
      'isMovie': isMovie,
      'title': title,
      'posterPath': posterPath,
      'timestamp': FieldValue.serverTimestamp(),
    });
    notifyListeners(); // Notify UI changes.
  }
}
Future<void> removeFromFavorites(String movieId) async {
  if (_user != null) {
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('favorites')
        .doc(movieId)
        .delete();
    notifyListeners();
  }
}


 Future<void> rateItem(String id, double rating, bool isMovie) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  
  final doc = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('ratings')
      .doc(id);

  await doc.set({
    'id': id,
    'rating': rating,
    'isMovie': isMovie, // Use the parameter here
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<double?> fetchUserRating(String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('ratings')
      .doc(id)
      .get();

  return doc.exists ? (doc['rating'] as double) : null;
}

Future<void> addReview(String id, bool isMovie, String review) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) throw Exception('User not logged in');

  final collection = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('reviews');

  await collection.doc(id).set({
    'id': id,
    'isMovie': isMovie,
    'review': review,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<String?> fetchUserReview(String id) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('reviews')
      .doc(id)
      .get();

  if (doc.exists) {
    final data = doc.data(); // Fetch the document data
    if (data != null && data.containsKey('review')) {
      return data['review'] as String?;
    }
  }

  return null; // Return null if no review exists
}


 Stream<List<Map<String, dynamic>>> getWatchlist() {
  if (_user == null) return Stream.value([]);
  return _firestore
      .collection('users')
      .doc(_user!.uid)
      .collection('watchlist')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
Stream<List<Map<String, dynamic>>> getFavorites() {
  if (_user == null) return Stream.value([]);
  return _firestore
      .collection('users')
      .doc(_user!.uid)
      .collection('favorites')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'movieId': data['movieId'],
            'isMovie': data['isMovie'],
            'title': data['title'],
            'posterPath': data['posterPath'],
          };
        }).toList();
      });
}


}