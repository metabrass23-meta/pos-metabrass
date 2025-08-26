import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../utils/debug_helper.dart';
import '../utils/storage_service.dart';
import 'api_client.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() => _instance;

  PaymentService._internal();

  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  /// Get list of payments with pagination and filtering
  Future<ApiResponse<Map<String, dynamic>>> getPayments({Map<String, dynamic>? params}) async {
    try {
      final queryParams = params ?? {};

      final response = await _apiClient.get(ApiConfig.payments, queryParameters: queryParams);

      DebugHelper.printApiResponse('GET Payments', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          // Cache payments if successful
          await _cachePayments(responseData['data']);

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payments retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to get payments',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get payments',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get payments DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);

      // Try to return cached data if network error
      if (apiError.type == 'network_error') {
        final cachedPayments = await _getCachedPayments();
        if (cachedPayments.isNotEmpty) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: 'Showing cached data',
            data: {
              'payments': cachedPayments,
              'pagination': {
                'page': 1,
                'page_size': cachedPayments.length,
                'total_count': cachedPayments.length,
                'total_pages': 1,
                'has_next': false,
                'has_previous': false,
              },
            },
          );
        }
      }

      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get payments', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting payments');
    }
  }

  /// Get a specific payment by ID
  Future<ApiResponse<Map<String, dynamic>>> getPaymentById(String id) async {
    try {
      final response = await _apiClient.get(ApiConfig.getPaymentById(id));

      DebugHelper.printApiResponse('GET Payment by ID', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to get payment',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get payment',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get payment by ID DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get payment by ID', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting payment');
    }
  }

  /// Create a new payment
  Future<ApiResponse<Map<String, dynamic>>> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiClient.post(ApiConfig.createPayment, data: paymentData);

      DebugHelper.printApiResponse('CREATE Payment', response.data);

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          // Clear cache to refresh data
          await _clearPaymentCache();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment created successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to create payment',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to create payment',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Create payment DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Create payment', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while creating payment');
    }
  }

  /// Update an existing payment
  Future<ApiResponse<Map<String, dynamic>>> updatePayment(String id, Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiClient.put(ApiConfig.updatePayment(id), data: paymentData);

      DebugHelper.printApiResponse('UPDATE Payment', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          // Clear cache to refresh data
          await _clearPaymentCache();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment updated successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to update payment',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to update payment',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update payment DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Update payment', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while updating payment');
    }
  }

  /// Delete a payment
  Future<ApiResponse<Map<String, dynamic>>> deletePayment(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.deletePayment(id));

      DebugHelper.printApiResponse('DELETE Payment', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          // Clear cache to refresh data
          await _clearPaymentCache();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment deleted successfully',
            data: responseData['data'] ?? {},
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to delete payment',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete payment',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete payment DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Delete payment', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while deleting payment');
    }
  }

  /// Soft delete a payment
  Future<ApiResponse<Map<String, dynamic>>> softDeletePayment(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.softDeletePayment(id));

      DebugHelper.printApiResponse('SOFT DELETE Payment', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          // Clear cache to refresh data
          await _clearPaymentCache();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment soft deleted successfully',
            data: responseData['data'] ?? {},
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to soft delete payment',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to soft delete payment',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Soft delete payment DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Soft delete payment', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while soft deleting payment');
    }
  }

  /// Restore a soft deleted payment
  Future<ApiResponse<Map<String, dynamic>>> restorePayment(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.restorePayment(id));

      DebugHelper.printApiResponse('RESTORE Payment', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          // Clear cache to refresh data
          await _clearPaymentCache();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment restored successfully',
            data: responseData['data'] ?? {},
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to restore payment',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to restore payment',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Restore payment DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Restore payment', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while restoring payment');
    }
  }

  /// Get payment statistics
  Future<ApiResponse<Map<String, dynamic>>> getPaymentStatistics() async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentStatistics);

      DebugHelper.printApiResponse('GET Payment Statistics', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          // Cache statistics
          await _cachePaymentStatistics(responseData['data']);

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment statistics retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to get payment statistics',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get payment statistics',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get payment statistics DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);

      // Try to return cached statistics if network error
      if (apiError.type == 'network_error') {
        final cachedStats = await _getCachedPaymentStatistics();
        if (cachedStats.isNotEmpty) {
          return ApiResponse<Map<String, dynamic>>(success: true, message: 'Showing cached statistics', data: cachedStats);
        }
      }

      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get payment statistics', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting payment statistics');
    }
  }

  /// Mark payment as final
  Future<ApiResponse<Map<String, dynamic>>> markAsFinalPayment(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.markAsFinalPayment(id));

      DebugHelper.printApiResponse('MARK AS FINAL Payment', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          // Clear cache to refresh data
          await _clearPaymentCache();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payment marked as final successfully',
            data: responseData['data'] ?? {},
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to mark payment as final',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to mark payment as final',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Mark as final payment DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Mark as final payment', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while marking payment as final');
    }
  }

  /// Search payments
  Future<ApiResponse<Map<String, dynamic>>> searchPayments(String query) async {
    try {
      final response = await _apiClient.get(ApiConfig.searchPayments, queryParameters: {'q': query});

      DebugHelper.printApiResponse('SEARCH Payments', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payments search completed',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] as String? ?? 'Failed to search payments',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to search payments',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Search payments DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Search payments', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while searching payments');
    }
  }

  /// Get payments by vendor
  Future<ApiResponse<Map<String, dynamic>>> getPaymentsByVendor(String vendorId) async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentsByVendorId(vendorId));

      DebugHelper.printApiResponse('GET Payments by Vendor', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Vendor payments retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] ?? 'Failed to get vendor payments',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get vendor payments',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get vendor payments DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get vendor payments', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting vendor payments');
    }
  }

  /// Get payments by order
  Future<ApiResponse<Map<String, dynamic>>> getPaymentsByOrder(String orderId) async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentsByOrderId(orderId));

      DebugHelper.printApiResponse('GET Payments by Order', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Order payments retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] ?? 'Failed to get order payments',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get order payments',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get order payments DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get order payments', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting order payments');
    }
  }

  /// Get payments by sale
  Future<ApiResponse<Map<String, dynamic>>> getPaymentsBySale(String saleId) async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentsBySaleId(saleId));

      DebugHelper.printApiResponse('GET Payments by Sale', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Sale payments retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] ?? 'Failed to get sale payments',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get sale payments',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get sale payments DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get sale payments', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting sale payments');
    }
  }

  /// Get payments by payment method
  Future<ApiResponse<Map<String, dynamic>>> getPaymentsByMethod(String method) async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentsByMethod(method));

      DebugHelper.printApiResponse('GET Payments by Method', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payments by method retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] ?? 'Failed to get payments by method',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get payments by method',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get payments by method DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get payments by method', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting payments by method');
    }
  }

  /// Get payments with receipts
  Future<ApiResponse<Map<String, dynamic>>> getPaymentsWithReceipts() async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentWithReceipts);

      DebugHelper.printApiResponse('GET Payments with Receipts', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payments with receipts retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] ?? 'Failed to get payments with receipts',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get payments with receipts',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get payments with receipts DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get payments with receipts', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting payments with receipts');
    }
  }

  /// Get payments without receipts
  Future<ApiResponse<Map<String, dynamic>>> getPaymentsWithoutReceipts() async {
    try {
      final response = await _apiClient.get(ApiConfig.paymentWithoutReceipts);

      DebugHelper.printApiResponse('GET Payments without Receipts', response.data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: responseData['message'] as String? ?? 'Payments without receipts retrieved successfully',
            data: responseData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: responseData['message'] ?? 'Failed to get payments without receipts',
            errors: responseData['errors'] as Map<String, dynamic>?,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to get payments without receipts',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get payments without receipts DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get payments without receipts', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while getting payments without receipts');
    }
  }

  // Cache management methods
  Future<void> _cachePayments(dynamic paymentsData) async {
    try {
      // Handle both direct data and nested payments structure
      if (paymentsData is Map<String, dynamic>) {
        if (paymentsData['payments'] != null) {
          await _storageService.saveData(ApiConfig.paymentsCacheKey, paymentsData['payments']);
        } else if (paymentsData is List) {
          await _storageService.saveData(ApiConfig.paymentsCacheKey, paymentsData);
        }
      }
    } catch (e) {
      debugPrint('Error caching payments: $e');
    }
  }

  Future<List<dynamic>> _getCachedPayments() async {
    try {
      final cached = await _storageService.getData(ApiConfig.paymentsCacheKey);
      return cached is List ? cached : [];
    } catch (e) {
      debugPrint('Error getting cached payments: $e');
      return [];
    }
  }

  Future<void> _cachePaymentStatistics(Map<String, dynamic> stats) async {
    try {
      await _storageService.saveData(ApiConfig.paymentStatsCacheKey, stats);
    } catch (e) {
      debugPrint('Error caching payment statistics: $e');
    }
  }

  Future<Map<String, dynamic>> _getCachedPaymentStatistics() async {
    try {
      final cached = await _storageService.getData(ApiConfig.paymentStatsCacheKey);
      return cached is Map<String, dynamic> ? cached : {};
    } catch (e) {
      debugPrint('Error getting cached payment statistics: $e');
      return {};
    }
  }

  Future<void> _clearPaymentCache() async {
    try {
      await _storageService.removeData(ApiConfig.paymentsCacheKey);
      await _storageService.removeData(ApiConfig.paymentStatsCacheKey);
    } catch (e) {
      debugPrint('Error clearing payment cache: $e');
    }
  }
}
