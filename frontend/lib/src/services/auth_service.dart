import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../utils/storage_service.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  /// Register a new user
  Future<ApiResponse<AuthResponse>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirm,
    required bool agreedToTerms,
  }) async {
    try {
      final data = {
        'full_name': fullName,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'agreed_to_terms': agreedToTerms,
      };

      final response = await _apiClient.post(ApiConfig.register, data: data);

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          response.data,
              (data) => AuthResponse.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Store token and user data
          await _storageService.saveToken(apiResponse.data!.token);
          await _storageService.saveUser(apiResponse.data!.user);
        }

        return apiResponse;
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: response.data['message'] ?? 'Registration failed',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Registration DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<AuthResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Registration error: ${e.toString()}');
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'An unexpected error occurred during registration',
      );
    }
  }

  /// Login user
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiClient.post(ApiConfig.login, data: data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          response.data,
              (data) => AuthResponse.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Store token and user data
          await _storageService.saveToken(apiResponse.data!.token);
          await _storageService.saveUser(apiResponse.data!.user);
        }

        return apiResponse;
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: response.data['message'] ?? 'Login failed',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Login DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<AuthResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Login error: ${e.toString()}');
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'An unexpected error occurred during login',
      );
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      // Send logout request to server
      final response = await _apiClient.post(ApiConfig.logout);

      // Clear local storage regardless of server response
      await _storageService.clearAll();

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Logged out successfully',
        );
      } else {
        return ApiResponse<void>(
          success: true, // Still success since we cleared local data
          message: 'Logged out locally',
        );
      }
    } on DioException catch (e) {
      debugPrint('Logout DioException: ${e.toString()}');
      // Clear local storage even if server request fails
      await _storageService.clearAll();
      return ApiResponse<void>(
        success: true,
        message: 'Logged out locally',
      );
    } catch (e) {
      debugPrint('Logout error: ${e.toString()}');
      // Clear local storage even if there's an error
      await _storageService.clearAll();
      return ApiResponse<void>(
        success: true,
        message: 'Logged out locally',
      );
    }
  }

  /// Get user profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.profile);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<UserModel>.fromJson(
          response.data,
              (data) => UserModel.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Update stored user data
          await _storageService.saveUser(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get profile',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get profile DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<UserModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get profile error: ${e.toString()}');
      return ApiResponse<UserModel>(
        success: false,
        message: 'An unexpected error occurred while getting profile',
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile({
    required String fullName,
    required String email,
  }) async {
    try {
      final data = {
        'full_name': fullName,
        'email': email,
      };

      final response = await _apiClient.put(ApiConfig.updateProfile, data: data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<UserModel>.fromJson(
          response.data,
              (data) => UserModel.fromJson(data['data']),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Update stored user data
          await _storageService.saveUser(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update profile',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update profile DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<UserModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Update profile error: ${e.toString()}');
      return ApiResponse<UserModel>(
        success: false,
        message: 'An unexpected error occurred while updating profile',
      );
    }
  }

  /// Change password
  Future<ApiResponse<String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final data = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      };

      final response = await _apiClient.post(ApiConfig.changePassword, data: data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
              (data) => data['token'] as String,
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Update stored token
          await _storageService.saveToken(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<String>(
          success: false,
          message: response.data['message'] ?? 'Failed to change password',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Change password DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<String>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Change password error: ${e.toString()}');
      return ApiResponse<String>(
        success: false,
        message: 'An unexpected error occurred while changing password',
      );
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  /// Get current token from storage
  Future<String?> getCurrentToken() async {
    return await _storageService.getToken();
  }
}