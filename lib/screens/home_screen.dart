import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:panda_flix/screens/login_screen.dart';
import 'package:panda_flix/screens/movie_detail_screen.dart';
import 'package:panda_flix/services/tmdb_api_service.dart';
import 'package:provider/provider.dart';
import 'package:panda_flix/providers/auth_providers.dart';
import 'package:panda_flix/screens/favorites_screen.dart';
import 'package:panda_flix/screens/watchlist_screen.dart';

class HomeScreen extends StatelessWidget {
  final TMDBApiService _tmdbApiService = TMDBApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'PandaFlix', 
          style: TextStyle(
            color: Colors.red, 
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: Icon(Icons.account_circle, color: Colors.white),
                color: Colors.grey[900],
                onSelected: (value) async {
                  switch (value) {
                    case 'favorites':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FavoritesScreen()),
                      );
                      break;
                    case 'watchlist':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WatchlistScreen()),
                      );
                      break;
                    case 'signout':
                      await authProvider.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'favorites',
                    child: Text('Favorites', style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem(
                    value: 'watchlist',
                    child: Text('Watchlist', style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem(
                    value: 'signout',
                    child: Text('Sign Out', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildTrendingCarousel(),
        _buildCategorySection(context, 'Popular Movies', fetchPopularMovies: true),
        _buildCategorySection(context, 'Top Rated Movies', fetchTopRatedMovies: true),
        _buildCategorySection(context, 'Upcoming Movies', fetchUpcomingMovies: true),
        _buildCategorySection(context, 'Popular TV Shows', fetchPopularTVShows: true),
        _buildCategorySection(context, 'Top Rated TV Shows', fetchTopRatedTVShows: true),
        _buildCategorySection(context, 'Airing TV Series', fetchOnTheAirTVShows: true),
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
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading trending items', 
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No trending items available', 
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final trendingItems = snapshot.data!;
        return CarouselSlider(
          options: CarouselOptions(
            height: 250,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.9,
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
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${item['backdrop_path']}',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        item['title'] ?? item['name'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Category Section Widget
 Widget _buildCategorySection(BuildContext context, String title,
    {bool fetchPopularMovies = false,
    bool fetchTopRatedMovies = false,
    bool fetchUpcomingMovies = false,
    bool fetchPopularTVShows = false,
    bool fetchTopRatedTVShows = false,
    bool fetchOnTheAirTVShows = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(
        height: 250,
        child: FutureBuilder<List<dynamic>>(
          future: fetchPopularMovies
              ? _tmdbApiService.fetchPopularMovies()
              : fetchTopRatedMovies
                  ? _tmdbApiService.fetchTopRatedMovies()
                  : fetchUpcomingMovies
                      ? _tmdbApiService.fetchUpcomingMovies()
                      : fetchPopularTVShows
                          ? _tmdbApiService.fetchPopularTVShows()
                          : fetchTopRatedTVShows
                              ? _tmdbApiService.fetchTopRatedTVShows()
                              : _tmdbApiService.fetchOnTheAirTVSeries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading $title',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No $title available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final items = snapshot.data!;
            final isMovie = fetchPopularMovies || fetchTopRatedMovies || fetchUpcomingMovies;

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
                  child: Container(
                    width: 150,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w200${item['poster_path']}',
                            width: 150,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          item['title'] ?? item['name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
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