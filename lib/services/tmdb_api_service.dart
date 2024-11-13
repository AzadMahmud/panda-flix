import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBApiService {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = '6cd81d0c326e278d7d01ed6038f45212';

  Future<List<dynamic>> fetchPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<dynamic>> fetchTopRatedMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load top-rated movies');
    }
  }

  Future<List<dynamic>> fetchPopularTVShows({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular TV shows');
    }
  }

  Future<List<dynamic>> fetchTopRatedTVShows({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/top_rated?api_key=$_apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load top-rated TV shows');
    }
  }

  // Consolidated method for fetching details (works for both movies and TV shows)
  Future<Map<String, dynamic>> fetchItemDetails(int id, bool isMovie) async {
    final endpoint = isMovie
        ? '$_baseUrl/movie/$id?api_key=$_apiKey&append_to_response=credits,reviews,similar,videos'
        : '$_baseUrl/tv/$id?api_key=$_apiKey&append_to_response=credits,reviews,similar,videos';
    
    final response = await http.get(Uri.parse(endpoint));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load details');
    }
  }
  
  Future<List<dynamic>> fetchTrendingItems() async {
    final response = await http.get(Uri.parse('$_baseUrl/trending/all/day?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load trending items');
    }
  }
  Future<void> addToWatchlist(String sessionId, int accountId, int itemId, bool isMovie) async {
    await http.post(
      Uri.parse('https://api.themoviedb.org/3/account/$accountId/watchlist?api_key=$_apiKey&session_id=$sessionId'),
      body: jsonEncode({
        'media_type': isMovie ? 'movie' : 'tv',
        'media_id': itemId,
        'watchlist': true,
      }),
    );
  }

  Future<void> rateItem(String sessionId, int itemId, bool isMovie, double rating) async {
    final endpoint = isMovie ? 'movie' : 'tv';
    await http.post(
      Uri.parse('https://api.themoviedb.org/3/$endpoint/$itemId/rating?api_key=$_apiKey&session_id=$sessionId'),
      body: jsonEncode({'value': rating}),
    );
  }

}
