import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/sales/sale_model.dart'; // Ensure ReceiptModel is defined here
import '../utils/storage_service.dart';

class ReceiptService {
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  // ✅ CRITICAL FIX: Get Token & Use Correct Header Format
  Future<Options> _getAuthOptions() async {
    final token = await _storageService.getToken() ?? '';
    if (token.isEmpty) {
      debugPrint('⚠️ [ReceiptService] Warning: No Auth Token found!');
    }
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $token', // Fixed: "Token" instead of "Bearer"
      },
      validateStatus: (status) => status! < 500,
    );
  }

  String _getUrl(String endpoint) {
    return '${ApiConfig.baseUrl}$endpoint';
  }

  /// Create a new receipt for a payment
  Future<ApiResponse<ReceiptModel>> createReceipt({
    required String saleId,
    required String paymentId,
    String? notes,
  }) async {
    final url = _getUrl(ApiConfig.createReceipt);
    debugPrint('🚀 [ReceiptService] POST $url');

    try {
      final response = await _dio.post(
        url,
        options: await _getAuthOptions(),
        data: {
          'sale': saleId,
          'payment': paymentId,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [ReceiptService] Receipt Created');
        return ApiResponse<ReceiptModel>.fromJson(
          response.data,
              (data) => ReceiptModel.fromJson(data),
        );
      } else {
        debugPrint('❌ [ReceiptService] Failed: ${response.data}');
        return ApiResponse<ReceiptModel>(
          success: false,
          message: response.data['message'] ?? response.data['detail'] ?? 'Failed to create receipt',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      debugPrint('🛑 [ReceiptService] Error: $e');
      return ApiResponse<ReceiptModel>(
        success: false,
        message: 'Error creating receipt: $e',
      );
    }
  }

  /// Get receipt details by ID
  Future<ApiResponse<ReceiptModel>> getReceipt(String id) async {
    final url = _getUrl(ApiConfig.getReceiptById(id));
    debugPrint('🚀 [ReceiptService] GET $url');

    try {
      final response = await _dio.get(url, options: await _getAuthOptions());

      if (response.statusCode == 200) {
        return ApiResponse<ReceiptModel>.fromJson(
          response.data,
              (data) => ReceiptModel.fromJson(data),
        );
      } else {
        return ApiResponse<ReceiptModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get receipt',
        );
      }
    } catch (e) {
      return ApiResponse<ReceiptModel>(
        success: false,
        message: 'Error getting receipt: $e',
      );
    }
  }

  /// Update receipt details
  Future<ApiResponse<ReceiptModel>> updateReceipt({
    required String id,
    String? notes,
    String? status,
  }) async {
    final url = _getUrl(ApiConfig.updateReceipt(id));

    try {
      final response = await _dio.put(
        url,
        options: await _getAuthOptions(),
        data: {
          if (notes != null) 'notes': notes,
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse<ReceiptModel>.fromJson(
          response.data,
              (data) => ReceiptModel.fromJson(data),
        );
      } else {
        return ApiResponse<ReceiptModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update receipt',
        );
      }
    } catch (e) {
      return ApiResponse<ReceiptModel>(
        success: false,
        message: 'Error updating receipt: $e',
      );
    }
  }

  /// List receipts with filtering and pagination
  /// ✅ FIXED: Returns List<ReceiptModel> instead of Map to prevent crash
  Future<ApiResponse<List<ReceiptModel>>> listReceipts({
    String? saleId,
    String? paymentId,
    String? status,
    String? dateFrom,
    String? dateTo,
    bool? showInactive,
    int? page,
    int? pageSize,
  }) async {
    final url = _getUrl(ApiConfig.receipts);
    debugPrint('🚀 [ReceiptService] GET List $url');

    try {
      final response = await _dio.get(
        url,
        options: await _getAuthOptions(),
        queryParameters: {
          if (saleId != null) 'sale_id': saleId,
          if (paymentId != null) 'payment_id': paymentId,
          if (status != null) 'status': status,
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          if (showInactive != null) 'show_inactive': showInactive.toString(),
          if (page != null) 'page': page,
          if (pageSize != null) 'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        // ✅ SAFE PARSING: Handles both List [...] and Pagination {results: [...]}
        List<dynamic> listData;
        if (response.data is Map<String, dynamic> && response.data.containsKey('results')) {
          listData = response.data['results'];
        } else if (response.data is List) {
          listData = response.data;
        } else {
          listData = [];
        }

        final receipts = listData.map((json) => ReceiptModel.fromJson(json)).toList();
        debugPrint('✅ [ReceiptService] Loaded ${receipts.length} receipts');

        return ApiResponse<List<ReceiptModel>>(
          success: true,
          data: receipts,
          message: 'Receipts list loaded',
        );
      } else {
        debugPrint('❌ [ReceiptService] Failed: ${response.data}');
        return ApiResponse<List<ReceiptModel>>(
          success: false,
          data: [],
          message: response.data['message'] ?? 'Failed to list receipts',
        );
      }
    } catch (e) {
      debugPrint('🛑 [ReceiptService] Exception: $e');
      return ApiResponse<List<ReceiptModel>>(
        success: false,
        data: [],
        message: 'Error listing receipts: $e',
      );
    }
  }

  /// Delete a receipt
  Future<ApiResponse<bool>> deleteReceipt(String id) async {
    final url = _getUrl(ApiConfig.deleteReceipt(id));

    try {
      final response = await _dio.delete(
        url,
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return ApiResponse<bool>(success: true, data: true, message: 'Deleted');
      } else {
        return ApiResponse<bool>(
          success: false,
          data: false,
          message: response.data['message'] ?? 'Failed to delete',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(success: false, data: false, message: 'Error: $e');
    }
  }

  /// Generate PDF for receipt
  Future<ApiResponse<Map<String, dynamic>>> generateReceiptPdf(String id) async {
    final url = _getUrl(ApiConfig.generateReceiptPdf(id));

    try {
      final response = await _dio.post(
        url,
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
              (data) => data as Map<String, dynamic>,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to generate PDF',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}