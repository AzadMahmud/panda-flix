import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tmdbApiKey = 'YOUR_TMDB_API_KEY';
  final String _tmdbBaseUrl = 'https://api.themoviedb.org/3';

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("User profile not found");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<String?> createTMDBSession(String username, String password) async {
    try {
      // Step 1: Get a request token
      final tokenResponse = await http.get(Uri.parse('$_tmdbBaseUrl/authentication/token/new?api_key=$_tmdbApiKey'));
      if (tokenResponse.statusCode != 200) {
        throw Exception("Failed to get request token");
      }
      final requestToken = jsonDecode(tokenResponse.body)['request_token'];

      // Step 2: Validate the request token with the user's TMDB credentials
      final validateResponse = await http.post(
        Uri.parse('$_tmdbBaseUrl/authentication/token/validate_with_login?api_key=$_tmdbApiKey'),
        body: jsonEncode({
          'username': username,
          'password': password,
          'request_token': requestToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (validateResponse.statusCode != 200) {
        throw Exception("Failed to validate request token");
      }

      // Step 3: Create a session with the validated request token
      final sessionResponse = await http.post(
        Uri.parse('$_tmdbBaseUrl/authentication/session/new?api_key=$_tmdbApiKey'),
        body: jsonEncode({'request_token': requestToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (sessionResponse.statusCode == 200) {
        final sessionId = jsonDecode(sessionResponse.body)['session_id'];
        return sessionId;  // Return the session ID
      } else {
        throw Exception("Failed to create session");
      }
    } catch (e) {
      print("Error creating TMDB session: $e");
      return null;
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user?.uid;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
