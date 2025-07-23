import 'package:flutter/material.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    _setState(AuthState.loading);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (email.isNotEmpty && password.length >= 6) {
        _setState(AuthState.authenticated);
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    _setState(AuthState.loading);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        _setState(AuthState.authenticated);
      } else {
        throw Exception('Invalid information provided');
      }
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.error);
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _setState(AuthState.unauthenticated);
    _setError(null);
  }

  void clearError() {
    _setError(null);
  }
}