import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';
import 'api_client.dart';

class ReceiptService {
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Create a new receipt for a payment
  Future<ApiResponse<ReceiptModel>> createReceipt({required String saleId, required String paymentId, String? notes}) async {
    try {
      final response = await _apiClient.post(ApiConfig.createReceipt, data: {'sale': saleId, 'payment': paymentId, 'notes': notes});

      DebugHelper.printApiResponse('POST Create Receipt', response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<ReceiptModel>.fromJson(response.data, (data) => ReceiptModel.fromJson(data));
      } else {
        return ApiResponse<ReceiptModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to create receipt',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Create receipt DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<ReceiptModel>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Create receipt', e);
      return ApiResponse<ReceiptModel>(success: false, message: 'An unexpected error occurred while creating receipt');
    }
  }

  /// Get receipt details by ID
  Future<ApiResponse<ReceiptModel>> getReceipt(String id) async {
    try {
      final response = await _apiClient.get(ApiConfig.getReceiptById(id));

      DebugHelper.printApiResponse('GET Receipt', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<ReceiptModel>.fromJson(response.data, (data) => ReceiptModel.fromJson(data));
      } else {
        return ApiResponse<ReceiptModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get receipt',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get receipt DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<ReceiptModel>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get receipt', e);
      return ApiResponse<ReceiptModel>(success: false, message: 'An unexpected error occurred while getting receipt');
    }
  }

  /// Update receipt details
  Future<ApiResponse<ReceiptModel>> updateReceipt({required String id, String? notes, String? status}) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.updateReceipt(id),
        data: {if (notes != null) 'notes': notes, if (status != null) 'status': status},
      );

      DebugHelper.printApiResponse('PUT Update Receipt', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<ReceiptModel>.fromJson(response.data, (data) => ReceiptModel.fromJson(data));
      } else {
        return ApiResponse<ReceiptModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update receipt',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update receipt DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<ReceiptModel>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Update receipt', e);
      return ApiResponse<ReceiptModel>(success: false, message: 'An unexpected error occurred while updating receipt');
    }
  }

  /// List receipts with filtering and pagination
  Future<ApiResponse<Map<String, dynamic>>> listReceipts({
    String? saleId,
    String? paymentId,
    String? status,
    String? dateFrom,
    String? dateTo,
    bool? showInactive,
    int? page,
    int? pageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (saleId != null) queryParams['sale_id'] = saleId;
      if (paymentId != null) queryParams['payment_id'] = paymentId;
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;
      if (showInactive != null) queryParams['show_inactive'] = showInactive.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['page_size'] = pageSize.toString();

      final response = await _apiClient.get(ApiConfig.receipts, queryParameters: queryParams);

      DebugHelper.printApiResponse('GET List Receipts', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(response.data, (data) => data as Map<String, dynamic>);
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to list receipts',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('List receipts DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('List receipts', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while listing receipts');
    }
  }

  /// Delete a receipt
  Future<ApiResponse<bool>> deleteReceipt(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.deleteReceipt(id));

      DebugHelper.printApiResponse('DELETE Receipt', response.data);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return ApiResponse<bool>.fromJson(response.data, (data) => true);
      } else {
        return ApiResponse<bool>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete receipt',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete receipt DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<bool>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Delete receipt', e);
      return ApiResponse<bool>(success: false, message: 'An unexpected error occurred while deleting receipt');
    }
  }

  /// Generate PDF for receipt
  Future<ApiResponse<Map<String, dynamic>>> generateReceiptPdf(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.generateReceiptPdf(id));

      DebugHelper.printApiResponse('POST Generate Receipt PDF', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(response.data, (data) => data as Map<String, dynamic>);
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to generate receipt PDF',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Generate receipt PDF DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Generate receipt PDF', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while generating receipt PDF');
    }
  }
}
