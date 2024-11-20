import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:panda_flix/screens/review_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:panda_flix/services/tmdb_api_service.dart';
import 'package:panda_flix/providers/auth_providers.dart'; 

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
    fetchUserRating();
    fetchUserReview();
  }
String? userReview;

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
  double? userRating;

Future<void> fetchUserRating() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  try {
    final rating = await authProvider.fetchUserRating(widget.id.toString());
    setState(() {
      userRating = rating; // Set the user's rating if it exists
    });
  } catch (e) {
    print('Error fetching user rating: $e');
  }
}
Future<void> fetchUserReview() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  try {
    final review = await authProvider.fetchUserReview(widget.id.toString());
    setState(() {
      userReview = review;
    });
  } catch (e) {
    print('Error fetching user review: $e');
  }
}
  void _addToWatchlist() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  try {
    await authProvider.addToWatchlist(
      widget.id.toString(),
      widget.isMovie,
      movieDetails!['title'] ?? movieDetails!['name'],
      movieDetails!['poster_path'] ?? '',
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to Watchlist')));
  } catch (e) {
    print('Error adding to watchlist: $e');
  }
}
void _markAsFavorite() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  try {
    await authProvider.markAsFavorite(
      widget.id.toString(),
      widget.isMovie,
      movieDetails!['title'] ?? movieDetails!['name'],
      movieDetails!['poster_path'] ?? '',
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked as Favorite')));
  } catch (e) {
    print('Error marking as favorite: $e');
  }
}

void _rateMovie() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  double tempRating = userRating ?? 5.0; // Default or current rating

  final rating = await showDialog<double>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Rate this ${widget.isMovie ? 'Movie' : 'TV Show'}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How would you rate this?',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                RatingBar.builder(
                  initialRating: tempRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 10,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (value) {
                    setState(() {
                      tempRating = value; // Update temporary rating
                    });
                  },
                ),
                SizedBox(height: 8.0),
                Text(
                  '${tempRating.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, tempRating),
            child: Text('Submit'),
          ),
        ],
      );
    },
  );

  if (rating != null) {
    try {
      await authProvider.rateItem(widget.id.toString(), rating, widget.isMovie);

      setState(() {
        userRating = rating; // Update local state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rated successfully')),
      );
    } catch (e) {
      print('Error rating item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to rate item')),
      );
    }
  }
}


 void _addReview() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final review = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReviewPage(
        movieTitle: movieDetails!['title'] ?? movieDetails!['name'],
      ),
    ),
  );

  if (review != null && review.isNotEmpty) {
    try {
      await authProvider.addReview(widget.id.toString(), widget.isMovie, review);
      fetchUserReview(); // Refresh user review
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Review added successfully')));
    } catch (e) {
      print('Error adding review: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add review')));
    }
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
      body: movieDetails == null
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie Poster
                        AspectRatio(
                          aspectRatio: 2/3,
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}',
                            fit: BoxFit.cover,
                          ),
                        ),
                       

                        SizedBox(height: 15),

                        // Movie Title
                        Text(
                          movieDetails!['title'] ?? movieDetails!['name'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        SizedBox(height: 6),

                        // Release Date
                        Text(
                          'Release Date: ${movieDetails!['release_date'] ?? movieDetails!['first_air_date']}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                        ),
                        SizedBox(height: 10),

                        // Rating Section
                        _buildRatingSection(),
                        SizedBox(height: 15),

                        // Action Buttons
                        _buildActionButtons(),

                        // Overview Section
                        SizedBox(height: 20),
                        _buildSectionTitle('Overview'),
                        Text(
                          movieDetails!['overview'] ?? 'No overview available.',
                          style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                        ),
                        SizedBox(height: 20),

                        // Reviews Section
                        _buildSectionTitle('Reviews'),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: _buildHorizontalReviewList(),
                        ),
                       
                        _buildReviewSection(),
                        SizedBox(height: 20),
                        
                        // Trailer Section
                        Divider(color: Colors.grey[700], thickness: 0.5),
                        _buildSectionTitle('Trailer'),
                        _buildTrailer(videos),

                        // Similar Items Section
                        Divider(color: Colors.grey[700], thickness: 0.5),
                        _buildSectionTitle('More Like This'),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                // Similar Items as a separate sliver
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 16.0),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220, // Increased height to accommodate title
                      child: _buildSimilarItemsSection(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButtons() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        ElevatedButton.icon(
          onPressed: _addToWatchlist, // Add watchlist logic
          icon: Icon(Icons.bookmark, size: 18),
          label: Text('Watchlist'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _markAsFavorite, // Add favorite logic
          icon: Icon(Icons.favorite, size: 18),
          label: Text('Favorite'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _rateMovie, // Add rating logic
          icon: Icon(Icons.star, size: 18),
          label: Text('Rate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _addReview, // Add review logic
          icon: Icon(Icons.rate_review, size: 18),
          label: Text('Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildHorizontalReviewList() {
    return reviews.isNotEmpty
        ? SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  width: 250,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['author'] ?? 'Anonymous',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
                      ),
                      SizedBox(height: 5),
                      Text(
                        review['content'] ?? 'No content available.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        : Text('No reviews available.', style: TextStyle(color: Colors.grey[400]));
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
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: similarItems.length,
      itemBuilder: (context, index) {
        final similar = similarItems[index];
        return Container(
          width: 120, // Fixed width for consistency
          margin: EdgeInsets.only(right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w200${similar['poster_path']}',
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 5),
              Text(
                similar['title'] ?? similar['name'],
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      },
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
   Widget _buildRatingSection() {
  return Row(
    children: [
      _buildTag('IMDb Rating', movieDetails!['vote_average'].toString(), Colors.amber),
      SizedBox(width: 10),
      _buildTag(
        'Your Rating',
        userRating != null ? '${userRating!.toStringAsFixed(1)}/10' : 'N/A',
        Colors.blueGrey,
      ),
    ],
  );
}
Widget _buildReviewSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('Your Review'),
      userReview != null
          ? Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                userReview!,
                style: TextStyle(color: Colors.white),
              ),
            )
          : Text(
              "You haven't reviewed this ${widget.isMovie ? 'movie' : 'TV show'} yet.",
              style: TextStyle(color: Colors.grey[400]),
            ),
      SizedBox(height: 20),
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

}
