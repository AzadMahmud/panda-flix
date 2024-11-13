
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWatchlist(int movieId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'watchlist': FieldValue.arrayUnion([movieId])
      });
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({
        'watchlist': FieldValue.arrayRemove([movieId])
      });
      notifyListeners();
    }
  }

  // Fetch user's watchlist
  Future<List<int>> fetchWatchlist() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return List<int>.from(userDoc['watchlist']);
    }
    return [];
  }
}

