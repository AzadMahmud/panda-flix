// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:panda_flix/screens/watchlist.dart';
import 'package:panda_flix/screens/favorites.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text("Favorites"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text("Watchlist"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchlistScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
