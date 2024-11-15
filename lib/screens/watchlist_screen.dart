import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';

class WatchlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Watchlist')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: authProvider.getWatchlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your watchlist is empty.'));
          }

          final watchlist = snapshot.data!;

          return ListView.builder(
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final item = watchlist[index];
              return ListTile(
                leading: Image.network('https://image.tmdb.org/t/p/w200${item['posterPath']}'),
                title: Text(item['title']),
                subtitle: Text(item['isMovie'] ? 'Movie' : 'TV Show'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => authProvider.removeFromWatchlist(item['movieId']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


