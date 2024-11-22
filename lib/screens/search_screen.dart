import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:panda_flix/screens/movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url =
        'https://api.themoviedb.org/3/search/multi?api_key=6cd81d0c326e278d7d01ed6038f45212&query=$query';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['results'];
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(child: Text('No results found'))
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      leading: result['poster_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w92${result['poster_path']}',
                              fit: BoxFit.cover,
                            )
                          : SizedBox.shrink(),
                      title: Text(result['title'] ?? result['name'] ?? ''),
                      subtitle: Text(
                        result['release_date'] ??
                            result['first_air_date'] ??
                            '',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsScreen(
                              id: result['id'],
                              isMovie: result['media_type'] == 'movie',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
