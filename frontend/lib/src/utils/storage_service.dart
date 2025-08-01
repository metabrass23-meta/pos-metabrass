import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(ApiConfig.tokenKey, token);
  }

  Future<String?> getToken() async {
    await init();
    return _prefs!.getString(ApiConfig.tokenKey);
  }

  Future<void> removeToken() async {
    await init();
    await _prefs!.remove(ApiConfig.tokenKey);
  }

  // User data management
  Future<void> saveUser(UserModel user) async {
    await init();
    await _prefs!.setString(ApiConfig.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    await init();
    final userString = _prefs!.getString(ApiConfig.userKey);
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<void> removeUser() async {
    await init();
    await _prefs!.remove(ApiConfig.userKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }

  // Generic methods for storing any data
  Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await init();
    return _prefs!.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await init();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await init();
    return _prefs!.getInt(key);
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }
}