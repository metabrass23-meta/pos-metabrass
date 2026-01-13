import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';
import 'api_client.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Create a new invoice for a sale
  Future<ApiResponse<InvoiceModel>> createInvoice({required String saleId, DateTime? dueDate, String? notes, String? termsConditions}) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.createInvoice,
        data: {'sale': saleId, 'due_date': dueDate?.toIso8601String(), 'notes': notes, 'terms_conditions': termsConditions},
      );

      DebugHelper.printApiResponse('POST Create Invoice', response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<InvoiceModel>.fromJson(response.data, (data) => InvoiceModel.fromJson(data));
      } else {
        return ApiResponse<InvoiceModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to create invoice',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Create invoice DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<InvoiceModel>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Create invoice', e);
      return ApiResponse<InvoiceModel>(success: false, message: 'An unexpected error occurred while creating invoice');
    }
  }

  /// Get invoice details by ID
  Future<ApiResponse<InvoiceModel>> getInvoice(String id) async {
    try {
      final response = await _apiClient.get(ApiConfig.getInvoiceById(id));

      DebugHelper.printApiResponse('GET Invoice', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<InvoiceModel>.fromJson(response.data, (data) => InvoiceModel.fromJson(data));
      } else {
        return ApiResponse<InvoiceModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get invoice',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get invoice DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<InvoiceModel>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Get invoice', e);
      return ApiResponse<InvoiceModel>(success: false, message: 'An unexpected error occurred while getting invoice');
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
    try {
      final response = await _apiClient.put(
        ApiConfig.updateInvoice(id),
        data: {
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          if (notes != null) 'notes': notes,
          if (termsConditions != null) 'terms_conditions': termsConditions,
          if (status != null) 'status': status,
        },
      );

      DebugHelper.printApiResponse('PUT Update Invoice', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<InvoiceModel>.fromJson(response.data, (data) => InvoiceModel.fromJson(data));
      } else {
        return ApiResponse<InvoiceModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update invoice',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update invoice DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<InvoiceModel>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Update invoice', e);
      return ApiResponse<InvoiceModel>(success: false, message: 'An unexpected error occurred while updating invoice');
    }
  }

  /// List invoices with filtering and pagination
  Future<ApiResponse<Map<String, dynamic>>> listInvoices({
    String? status,
    String? customerId,
    String? dateFrom,
    String? dateTo,
    bool? showInactive,
    int? page,
    int? pageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (customerId != null) queryParams['customer_id'] = customerId;
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;
      if (showInactive != null) queryParams['show_inactive'] = showInactive.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['page_size'] = pageSize.toString();

      final response = await _apiClient.get(ApiConfig.invoices, queryParameters: queryParams);

      DebugHelper.printApiResponse('GET List Invoices', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(response.data, (data) => data as Map<String, dynamic>);
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to list invoices',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('List invoices DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('List invoices', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while listing invoices');
    }
  }

  /// Delete an invoice
  Future<ApiResponse<bool>> deleteInvoice(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.deleteInvoice(id));

      DebugHelper.printApiResponse('DELETE Invoice', response.data);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return ApiResponse<bool>.fromJson(response.data, (data) => true);
      } else {
        return ApiResponse<bool>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete invoice',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete invoice DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<bool>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Delete invoice', e);
      return ApiResponse<bool>(success: false, message: 'An unexpected error occurred while deleting invoice');
    }
  }

  /// Generate PDF for invoice
  Future<ApiResponse<Map<String, dynamic>>> generateInvoicePdf(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.generateInvoicePdf(id));

      DebugHelper.printApiResponse('POST Generate Invoice PDF', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(response.data, (data) => data as Map<String, dynamic>);
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to generate invoice PDF',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Generate invoice PDF DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: apiError.displayMessage, errors: apiError.errors);
    } catch (e) {
      DebugHelper.printError('Generate invoice PDF', e);
      return ApiResponse<Map<String, dynamic>>(success: false, message: 'An unexpected error occurred while generating invoice PDF');
    }
  }
}
