import 'package:flutter/material.dart';
import 'package:panda_flix/screens/movie_detail_screen.dart';
import 'package:panda_flix/services/tmdb_api_service.dart';

class HomeScreen extends StatelessWidget {
  final TMDBApiService _tmdbApiService = TMDBApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panda-Flix'),
      ),
      body: ListView(
        children: [
          _buildCategorySection(context, 'Popular Movies', fetchPopularMovies: true),
          _buildCategorySection(context, 'Top Rated Movies', fetchTopRatedMovies: true),
          _buildCategorySection(context, 'Popular TV Shows', fetchPopularTVShows: true),
          _buildCategorySection(context, 'Top Rated TV Shows', fetchTopRatedTVShows: true),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, {bool fetchPopularMovies = false, bool fetchTopRatedMovies = false, bool fetchPopularTVShows = false, bool fetchTopRatedTVShows = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<dynamic>>(
            future: fetchPopularMovies
                ? _tmdbApiService.fetchPopularMovies()
                : fetchTopRatedMovies
                    ? _tmdbApiService.fetchTopRatedMovies()
                    : fetchPopularTVShows
                        ? _tmdbApiService.fetchPopularTVShows()
                        : _tmdbApiService.fetchTopRatedTVShows(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading $title'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No $title available'));
              }

              final items = snapshot.data!;
              final isMovie = fetchPopularMovies || fetchTopRatedMovies;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            id: item['id'],
                            isMovie: isMovie,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.network(
                            'https://image.tmdb.org/t/p/w200${item['poster_path']}',
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 5),
                          Text(
                            item['title'] ?? item['name'],
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
