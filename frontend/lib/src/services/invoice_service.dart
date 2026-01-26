import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/sales/sale_model.dart'; // Ensure InvoiceModel is defined here
import '../utils/storage_service.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  // ✅ CRITICAL FIX: Get Token & Use Correct Header Format ('Token' prefix)
  Future<Options> _getAuthOptions() async {
    final token = await _storageService.getToken() ?? '';
    if (token.isEmpty) {
      debugPrint('⚠️ [InvoiceService] Warning: No Auth Token found!');
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

  /// Create a new invoice for a sale
  Future<ApiResponse<InvoiceModel>> createInvoice({
    required String saleId,
    DateTime? dueDate,
    String? notes,
    String? termsConditions,
  }) async {
    final url = _getUrl(ApiConfig.createInvoice);
    debugPrint('🚀 [InvoiceService] POST $url');

    try {
      final response = await _dio.post(
        url,
        options: await _getAuthOptions(),
        data: {
          'sale': saleId,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          if (notes != null) 'notes': notes,
          if (termsConditions != null) 'terms_conditions': termsConditions,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [InvoiceService] Invoice Created');
        return ApiResponse<InvoiceModel>.fromJson(
          response.data,
              (data) => InvoiceModel.fromJson(data),
        );
      } else {
        debugPrint('❌ [InvoiceService] Failed: ${response.data}');
        return ApiResponse<InvoiceModel>(
          success: false,
          message: response.data['message'] ?? response.data['detail'] ?? 'Failed to create invoice',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      debugPrint('🛑 [InvoiceService] Error: $e');
      return ApiResponse<InvoiceModel>(
        success: false,
        message: 'Error creating invoice: $e',
      );
    }
  }

  /// Get invoice details by ID
  Future<ApiResponse<InvoiceModel>> getInvoice(String id) async {
    final url = _getUrl(ApiConfig.getInvoiceById(id));
    debugPrint('🚀 [InvoiceService] GET $url');

    try {
      final response = await _dio.get(url, options: await _getAuthOptions());

      if (response.statusCode == 200) {
        return ApiResponse<InvoiceModel>.fromJson(
          response.data,
              (data) => InvoiceModel.fromJson(data),
        );
      } else {
        return ApiResponse<InvoiceModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get invoice',
        );
      }
    } catch (e) {
      return ApiResponse<InvoiceModel>(
        success: false,
        message: 'Error getting invoice: $e',
      );
    }
  }

  /// Update invoice details
  Future<ApiResponse<InvoiceModel>> updateInvoice({
    required String id,
    DateTime? dueDate,
    String? notes,
    String? termsConditions,
    String? status,
  }) async {
    final url = _getUrl(ApiConfig.updateInvoice(id));

    try {
      final response = await _dio.put(
        url,
        options: await _getAuthOptions(),
        data: {
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          if (notes != null) 'notes': notes,
          if (termsConditions != null) 'terms_conditions': termsConditions,
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse<InvoiceModel>.fromJson(
          response.data,
              (data) => InvoiceModel.fromJson(data),
        );
      } else {
        return ApiResponse<InvoiceModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update invoice',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse<InvoiceModel>(
        success: false,
        message: 'Error updating invoice: $e',
      );
    }
  }

  /// List invoices with filtering and pagination
  /// ✅ FIXED: Returns List<InvoiceModel> safely to prevent type crashes
  Future<ApiResponse<List<InvoiceModel>>> listInvoices({
    String? status,
    String? customerId,
    String? dateFrom,
    String? dateTo,
    bool? showInactive,
    int? page,
    int? pageSize,
  }) async {
    final url = _getUrl(ApiConfig.invoices);
    debugPrint('🚀 [InvoiceService] GET List $url');

    try {
      final response = await _dio.get(
        url,
        options: await _getAuthOptions(),
        queryParameters: {
          if (status != null) 'status': status,
          if (customerId != null) 'customer_id': customerId,
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          if (showInactive != null) 'show_inactive': showInactive.toString(),
          if (page != null) 'page': page,
          if (pageSize != null) 'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        // ✅ SAFE PARSING logic for both List and Pagination Maps
        List<dynamic> listData = [];

        // Handle pagination structure {"results": [...]} or {"data": [...]}
        if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('results')) {
            listData = response.data['results'];
          } else if (response.data.containsKey('data') && response.data['data'] is List) {
            listData = response.data['data'];
          }
        }
        // Handle direct List structure [...]
        else if (response.data is List) {
          listData = response.data;
        }

        final invoices = listData.map((json) => InvoiceModel.fromJson(json)).toList();
        debugPrint('✅ [InvoiceService] Loaded ${invoices.length} invoices');

        return ApiResponse<List<InvoiceModel>>(
          success: true,
          data: invoices,
          message: 'Invoices list loaded',
        );
      } else {
        debugPrint('❌ [InvoiceService] Failed: ${response.data}');
        return ApiResponse<List<InvoiceModel>>(
          success: false,
          data: [],
          message: response.data['message'] ?? 'Failed to list invoices',
        );
      }
    } catch (e) {
      debugPrint('🛑 [InvoiceService] Exception: $e');
      return ApiResponse<List<InvoiceModel>>(
        success: false,
        data: [],
        message: 'Error listing invoices: $e',
      );
    }
  }

  /// Delete an invoice
  Future<ApiResponse<bool>> deleteInvoice(String id) async {
    final url = _getUrl(ApiConfig.deleteInvoice(id));

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
          message: response.data['message'] ?? 'Failed to delete invoice',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(success: false, data: false, message: 'Error: $e');
    }
  }

  /// Generate PDF for invoice
  Future<ApiResponse<Map<String, dynamic>>> generateInvoicePdf(String id) async {
    final url = _getUrl(ApiConfig.generateInvoicePdf(id));

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