class ApiConfig {
  // Base URL for your Django backend
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // API Endpoints
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';

  // Request timeouts
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
  static const int sendTimeout = 15000; // 15 seconds

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Token key for local storage
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}