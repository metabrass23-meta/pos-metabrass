import 'package:flutter/material.dart';

/// Model for user data.
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}

/// Manages authentication state for the Elegant Bridal POS application.
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  /// Mock login method (replace with real API call in production).
  Future<bool> login(String email, String password) async {
    if (email.isNotEmpty && password.length >= 6) {
      _user = User(name: 'Guest', email: email);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Mock signup method (replace with real API call in production).
  Future<bool> signup(String name, String email, String password) async {
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _user = User(name: name, email: email);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Logs out the user.
  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}