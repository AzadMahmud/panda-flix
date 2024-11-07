import 'package:flutter/material.dart';

class TVShowDetailScreen extends StatelessWidget {
  final int tvShowId;

  TVShowDetailScreen({required this.tvShowId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TV Show Details')),
      body: Center(
        child: Text('Details for TV show ID: $tvShowId'),
      ),
    );
  }
}
