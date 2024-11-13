import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:panda_flix/screens/movie_detail_screen.dart';
import 'package:panda_flix/services/tmdb_api_service.dart';
import 'package:provider/provider.dart';
import 'package:panda_flix/providers/auth_providers.dart';

class HomeScreen extends StatelessWidget {
  final TMDBApiService _tmdbApiService = TMDBApiService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panda-Flix'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) => IconButton(
              icon: Icon(Icons.logout),
              onPressed: authProvider.isLoggedIn ? () => authProvider.logout() : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildTrendingCarousel(),
          _buildCategorySection(context, 'Popular Movies', fetchPopularMovies: true),
          _buildCategorySection(context, 'Top Rated Movies', fetchTopRatedMovies: true),
          _buildCategorySection(context, 'Popular TV Shows', fetchPopularTVShows: true),
          _buildCategorySection(context, 'Top Rated TV Shows', fetchTopRatedTVShows: true),
        ],
      ),
    );
  }

  // Trending Carousel Widget
  Widget _buildTrendingCarousel() {
    return FutureBuilder<List<dynamic>>(
      future: _tmdbApiService.fetchTrendingItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading trending items'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No trending items available'));
        }

        final trendingItems = snapshot.data!;
        return CarouselSlider(
          options: CarouselOptions(
            height: 250,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
          ),
          items: trendingItems.map((item) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(
                      id: item['id'],
                      isMovie: item['media_type'] == 'movie',
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${item['backdrop_path']}',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      item['title'] ?? item['name'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Category Section Widget (Your original code)
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
  
