import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';
import 'api_client.dart';

class UserManagementService {
  static final UserManagementService _instance = UserManagementService._internal();
  factory UserManagementService() => _instance;
  UserManagementService._internal();

  final ApiClient _apiClient = ApiClient();

  // User Management
  Future<ApiResponse<List<UserModel>>> getUsers() async {
    try {
      final response = await _apiClient.get(ApiConfig.userManagement);
      return ApiResponse<List<UserModel>>.fromJson(
        response.data,
        (data) => (data as List).map((e) => UserModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<List<UserModel>>(
        success: false,
        message: apiError.displayMessage,
      );
    }
  }

  Future<ApiResponse<UserModel>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post(ApiConfig.userManagement, data: userData);
      return ApiResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<UserModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    }
  }

  Future<ApiResponse<UserModel>> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put('${ApiConfig.userManagement}$id/', data: userData);
      return ApiResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<UserModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    }
  }

  Future<ApiResponse<void>> deleteUser(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.userManagement}$id/');
      return ApiResponse<void>(success: true, message: 'User deleted successfully');
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(success: false, message: apiError.displayMessage);
    }
  }

  // Role Management
  Future<ApiResponse<List<RoleModel>>> getRoles() async {
    try {
      final response = await _apiClient.get(ApiConfig.roles);
      return ApiResponse<List<RoleModel>>.fromJson(
        response.data,
        (data) => (data as List).map((e) => RoleModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<List<RoleModel>>(
        success: false,
        message: apiError.displayMessage,
      );
    }
  }

  Future<ApiResponse<RoleModel>> createRole(Map<String, dynamic> roleData) async {
    try {
      final response = await _apiClient.post(ApiConfig.roles, data: roleData);
      return ApiResponse<RoleModel>.fromJson(
        response.data,
        (data) => RoleModel.fromJson(data),
      );
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<RoleModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    }
  }

  Future<ApiResponse<void>> updateRolePermissions(int roleId, List<Map<String, dynamic>> permissions) async {
    try {
      await _apiClient.post(ApiConfig.updateRolePermissions(roleId), data: {'permissions': permissions});
      return ApiResponse<void>(success: true, message: 'Permissions updated successfully');
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(success: false, message: apiError.displayMessage);
    }
  }

  Future<ApiResponse<void>> deleteRole(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.roles}$id/');
      return ApiResponse<void>(success: true, message: 'Role deleted successfully');
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(success: false, message: apiError.displayMessage);
    }
  }
}
