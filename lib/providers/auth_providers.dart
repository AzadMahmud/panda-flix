import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _sessionId;

  User? get user => _user;
  String? get sessionId => _sessionId;

  bool get isLoggedIn => _user != null;

  Future<void> signUp(String email, String password, String username) async {
    _user = await _authService.signUpWithEmail(email, password);
    if (_user != null) {
      _sessionId = await _authService.createTMDBSession(username, password);
      if (_sessionId == null) {
        throw Exception("Failed to create TMDB session");
      }
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _sessionId = await _authService.signInWithEmail(email, password);
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _sessionId = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    if (_user != null) {
      return await _authService.getUserProfile(_user!.uid);
    }
    return null;
  }

  Future<void> logout() => signOut(); // Add logout alias
}
