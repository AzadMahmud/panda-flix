// lib/screens/watchlist_screen.dart
import 'package:flutter/material.dart';

class WatchlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch watchlist items from the provider and display them here
    return Scaffold(
      appBar: AppBar(title: Text("Watchlist")),
      body: Center(child: Text("Watchlist items here")),
    );
  }
}


