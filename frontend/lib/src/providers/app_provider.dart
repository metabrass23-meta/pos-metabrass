import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _currentLanguage = 'en';
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    // Simulate app initialization
    await Future.delayed(const Duration(seconds: 3));
    _isInitialized = true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
}