import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/receivables/receivable_model.dart';
import 'api_client.dart';

class ReceivablesService {
  final ApiClient _apiClient = ApiClient();

  /// Get list of receivables with pagination and filtering
  Future<ApiResponse<List<Receivable>>> getReceivables({
    String? status,
    String? search,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParams = {
        'status': status ?? 'all',
        'search': search ?? '',
        'page': page,
        'page_size': pageSize,
      };

      final response = await _apiClient.get(
        ApiConfig.receivables,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['data']['receivables'] ?? [];
        final receivables = list.map((json) => Receivable.fromJson(json)).toList();

        return ApiResponse<List<Receivable>>(
          success: true,
          message: response.data['message'] ?? 'Receivables retrieved successfully',
          data: receivables,
        );
      } else {
        return ApiResponse<List<Receivable>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get receivables',
          errors: response.data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<List<Receivable>>(
        success: false,
        message: 'Error fetching receivables: $e',
      );
    }
  }

  /// Create a new manual receivable
  Future<ApiResponse<Receivable>> createReceivable(Receivable receivable) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.createReceivable,
        data: receivable.toJson(),
      );

      if (response.statusCode == 201) {
        return ApiResponse<Receivable>(
          success: true,
          message: response.data['message'] ?? 'Receivable created successfully',
          data: Receivable.fromJson(response.data['data']),
        );
      } else {
        return ApiResponse<Receivable>(
          success: false,
          message: response.data['message'] ?? 'Failed to create receivable',
          errors: response.data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<Receivable>(
        success: false,
        message: 'Error creating receivable: $e',
      );
    }
  }

  /// Update an existing receivable
  Future<ApiResponse<Receivable>> updateReceivable(String id, Receivable receivable) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.updateReceivable(id),
        data: receivable.toJson(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<Receivable>(
          success: true,
          message: response.data['message'] ?? 'Receivable updated successfully',
          data: Receivable.fromJson(response.data['data']),
        );
      } else {
        return ApiResponse<Receivable>(
          success: false,
          message: response.data['message'] ?? 'Failed to update receivable',
          errors: response.data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<Receivable>(
        success: false,
        message: 'Error updating receivable: $e',
      );
    }
  }

  /// Delete a receivable
  Future<ApiResponse<void>> deleteReceivable(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.deleteReceivable(id));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Receivable deleted successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete receivable',
          errors: response.data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error deleting receivable: $e',
      );
    }
  }

  /// Record a payment for a receivable
  Future<ApiResponse<Map<String, dynamic>>> recordPayment(String id, double amount, {String? notes}) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.recordReceivablePayment(id),
        data: {
          'payment_amount': amount,
          'payment_notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Payment recorded successfully',
          data: response.data['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to record payment',
          errors: response.data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error recording payment: $e',
      );
    }
  }
}
