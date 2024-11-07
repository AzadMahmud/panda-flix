import 'package:flutter/material.dart';

class WatchlistProvider extends ChangeNotifier {
  final List<int> _watchlist = [];

  List<int> get watchlist => _watchlist;

  void addToWatchlist(int movieId) {
    if (!_watchlist.contains(movieId)) {
      _watchlist.add(movieId);
      notifyListeners();
    }
  }

  void removeFromWatchlist(int movieId) {
    _watchlist.remove(movieId);
    notifyListeners();
  }
}
