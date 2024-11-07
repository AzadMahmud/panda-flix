import 'package:flutter/material.dart';
import 'package:panda_flix/services/tmdb_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int id;
  final bool isMovie;

  MovieDetailsScreen({required this.id, required this.isMovie});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TMDBApiService _apiService = TMDBApiService();
  Map<String, dynamic>? movieDetails;
  List<dynamic> reviews = [];
  List<dynamic> videos = [];
  List<dynamic> similarItems = [];

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      movieDetails = await _apiService.fetchItemDetails(widget.id, widget.isMovie);
      reviews = movieDetails?['reviews']['results'] ?? [];
      videos = movieDetails?['videos']['results'] ?? [];
      similarItems = movieDetails?['similar']['results'] ?? [];
      setState(() {});
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.isMovie ? 'Movie Details' : 'TV Show Details'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            if (movieDetails != null) ...[
              Image.network(
                'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}',
                height: 300,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 15),
              Text(
                movieDetails!['title'] ?? movieDetails!['name'],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              _buildRatingSection(),
              SizedBox(height: 15),
              _buildSectionTitle('Overview'),
              Text(
                movieDetails!['overview'] ?? 'No overview available.',
                style: TextStyle(fontSize: 16, color: Colors.grey[300]),
              ),
            ],
            Divider(color: Colors.grey[700], thickness: 0.5),
            _buildSectionTitle('Reviews'),
            ...reviews.map((review) => _buildReviewCard(review)).toList(),
            Divider(color: Colors.grey[700], thickness: 0.5),
            _buildSectionTitle('Trailer'),
            _buildTrailer(videos),
            Divider(color: Colors.grey[700], thickness: 0.5),
            _buildSectionTitle('More Like This'),
            _buildSimilarItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        _buildTag('IMDb Rating', movieDetails!['vote_average'].toString(), Colors.amber),
        SizedBox(width: 10),
        _buildTag('Your Rating', 'N/A', Colors.blueGrey),
      ],
    );
  }

  Widget _buildTag(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amberAccent),
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review['author'] ?? 'Anonymous',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
            ),
            SizedBox(height: 5),
            Text(
              'Rating: ${review['author_details']['rating'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 5),
            Text(
              review['content'] ?? 'No review content available.',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailer(List<dynamic> videos) {
    var trailer = videos.firstWhere(
      (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => null,
    );

    return trailer != null
        ? GestureDetector(
            onTap: () async {
              final youtubeUrl = 'https://www.youtube.com/watch?v=${trailer['key']}';
              if (await canLaunch(youtubeUrl)) {
                await launch(youtubeUrl);
              } else {
                print('Could not launch $youtubeUrl');
              }
            },
            child: Text(
              "Watch Trailer on YouTube",
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          )
        : Text('No trailer available', style: TextStyle(color: Colors.grey[300]));
  }

  Widget _buildSimilarItemsSection() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: similarItems.length,
        itemBuilder: (context, index) {
          final similar = similarItems[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w200${similar['poster_path']}',
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 5),
                Text(
                  similar['title'] ?? similar['name'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}