import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/sales/return_model.dart';
import '../models/api_response.dart';

class ReturnService {
  static final ReturnService _instance = ReturnService._internal();
  factory ReturnService() => _instance;
  ReturnService._internal();

  final Dio _dio = Dio();

  // Return Management
  Future<ApiResponse<List<ReturnModel>>> getReturns({
    String? search,
    String? status,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.returnsEndpoint,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (page != null) 'page': page,
          if (pageSize != null) 'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        final returns = data.map((json) => ReturnModel.fromJson(json)).toList();
        return ApiResponse<List<ReturnModel>>(success: true, data: returns, message: 'Returns loaded successfully');
      } else {
        return ApiResponse<List<ReturnModel>>(success: false, data: null, message: response.data['message'] ?? 'Failed to load returns');
      }
    } catch (e) {
      return ApiResponse<List<ReturnModel>>(success: false, data: null, message: 'Error loading returns: $e');
    }
  }

  Future<ApiResponse<ReturnModel>> getReturn(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.returnsEndpoint}$id/');

      if (response.statusCode == 200) {
        final returnModel = ReturnModel.fromJson(response.data);
        return ApiResponse<ReturnModel>(success: true, data: returnModel, message: 'Return loaded successfully');
      } else {
        return ApiResponse<ReturnModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to load return');
      }
    } catch (e) {
      return ApiResponse<ReturnModel>(success: false, data: null, message: 'Error loading return: $e');
    }
  }

  Future<ApiResponse<ReturnModel>> createReturn({
    required String saleId,
    required String customerId,
    required String reason,
    String? reasonDetails,
    String? notes,
    required List<Map<String, dynamic>> returnItems,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.returnsEndpoint,
        data: {
          'sale': saleId,
          'customer': customerId,
          'reason': reason,
          if (reasonDetails != null) 'reason_details': reasonDetails,
          if (notes != null) 'notes': notes,
          'return_items': returnItems,
        },
      );

      if (response.statusCode == 201) {
        final returnModel = ReturnModel.fromJson(response.data);
        return ApiResponse<ReturnModel>(success: true, data: returnModel, message: 'Return created successfully');
      } else {
        return ApiResponse<ReturnModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to create return');
      }
    } catch (e) {
      return ApiResponse<ReturnModel>(success: false, data: null, message: 'Error creating return: $e');
    }
  }

  Future<ApiResponse<ReturnModel>> updateReturn({required String id, String? reason, String? reasonDetails, String? notes}) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.returnsEndpoint}$id/',
        data: {if (reason != null) 'reason': reason, if (reasonDetails != null) 'reason_details': reasonDetails, if (notes != null) 'notes': notes},
      );

      if (response.statusCode == 200) {
        final returnModel = ReturnModel.fromJson(response.data);
        return ApiResponse<ReturnModel>(success: true, data: returnModel, message: 'Return updated successfully');
      } else {
        return ApiResponse<ReturnModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to update return');
      }
    } catch (e) {
      return ApiResponse<ReturnModel>(success: false, data: null, message: 'Error updating return: $e');
    }
  }

  Future<ApiResponse<bool>> deleteReturn(String id) async {
    try {
      final response = await _dio.delete('${ApiConfig.returnsEndpoint}$id/');

      if (response.statusCode == 204) {
        return ApiResponse<bool>(success: true, data: true, message: 'Return deleted successfully');
      } else {
        return ApiResponse<bool>(success: false, data: false, message: response.data['message'] ?? 'Failed to delete return');
      }
    } catch (e) {
      return ApiResponse<bool>(success: false, data: false, message: 'Error deleting return: $e');
    }
  }

  // Return Workflow
  Future<ApiResponse<ReturnModel>> approveReturn({required String id, String? reason}) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.returnsEndpoint}$id/approve/',
        data: {'action': 'approve', if (reason != null) 'reason': reason},
      );

      if (response.statusCode == 200) {
        final returnModel = ReturnModel.fromJson(response.data);
        return ApiResponse<ReturnModel>(success: true, data: returnModel, message: 'Return approved successfully');
      } else {
        return ApiResponse<ReturnModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to approve return');
      }
    } catch (e) {
      return ApiResponse<ReturnModel>(success: false, data: null, message: 'Error approving return: $e');
    }
  }

  Future<ApiResponse<ReturnModel>> rejectReturn({required String id, required String reason}) async {
    try {
      final response = await _dio.patch('${ApiConfig.returnsEndpoint}$id/approve/', data: {'action': 'reject', 'reason': reason});

      if (response.statusCode == 200) {
        final returnModel = ReturnModel.fromJson(response.data);
        return ApiResponse<ReturnModel>(success: true, data: returnModel, message: 'Return rejected successfully');
      } else {
        return ApiResponse<ReturnModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to reject return');
      }
    } catch (e) {
      return ApiResponse<ReturnModel>(success: false, data: null, message: 'Error rejecting return: $e');
    }
  }

  Future<ApiResponse<ReturnModel>> processReturn({required String id, double? refundAmount, String? refundMethod}) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.returnsEndpoint}$id/process/',
        data: {if (refundAmount != null) 'refund_amount': refundAmount, if (refundMethod != null) 'refund_method': refundMethod},
      );

      if (response.statusCode == 200) {
        final returnModel = ReturnModel.fromJson(response.data);
        return ApiResponse<ReturnModel>(success: true, data: returnModel, message: 'Return processed successfully');
      } else {
        return ApiResponse<ReturnModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to process return');
      }
    } catch (e) {
      return ApiResponse<ReturnModel>(success: false, data: null, message: 'Error processing return: $e');
    }
  }

  // Refund Management
  Future<ApiResponse<List<RefundModel>>> getRefunds({
    String? search,
    String? status,
    String? method,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.returnsEndpoint}refunds/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (method != null && method.isNotEmpty) 'method': method,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (page != null) 'page': page,
          if (pageSize != null) 'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        final refunds = data.map((json) => RefundModel.fromJson(json)).toList();
        return ApiResponse<List<RefundModel>>(success: true, data: refunds, message: 'Refunds loaded successfully');
      } else {
        return ApiResponse<List<RefundModel>>(success: false, data: null, message: response.data['message'] ?? 'Failed to load refunds');
      }
    } catch (e) {
      return ApiResponse<List<RefundModel>>(success: false, data: null, message: 'Error loading refunds: $e');
    }
  }

  Future<ApiResponse<RefundModel>> getRefund(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.returnsEndpoint}refunds/$id/');

      if (response.statusCode == 200) {
        final refundModel = RefundModel.fromJson(response.data);
        return ApiResponse<RefundModel>(success: true, data: refundModel, message: 'Refund loaded successfully');
      } else {
        return ApiResponse<RefundModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to load refund');
      }
    } catch (e) {
      return ApiResponse<RefundModel>(success: false, data: null, message: 'Error loading refund: $e');
    }
  }

  Future<ApiResponse<RefundModel>> createRefund({
    required String returnRequestId,
    required double amount,
    required String method,
    String? notes,
    String? referenceNumber,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.returnsEndpoint}refunds/',
        data: {
          'return_request': returnRequestId,
          'amount': amount,
          'method': method,
          if (notes != null) 'notes': notes,
          if (referenceNumber != null) 'reference_number': referenceNumber,
        },
      );

      if (response.statusCode == 201) {
        final refundModel = RefundModel.fromJson(response.data);
        return ApiResponse<RefundModel>(success: true, data: refundModel, message: 'Refund created successfully');
      } else {
        return ApiResponse<RefundModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to create refund');
      }
    } catch (e) {
      return ApiResponse<RefundModel>(success: false, data: null, message: 'Error creating refund: $e');
    }
  }

  Future<ApiResponse<RefundModel>> updateRefund({required String id, String? method, String? notes, String? referenceNumber}) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.returnsEndpoint}refunds/$id/',
        data: {
          if (method != null) 'method': method,
          if (notes != null) 'notes': notes,
          if (referenceNumber != null) 'reference_number': referenceNumber,
        },
      );

      if (response.statusCode == 200) {
        final refundModel = RefundModel.fromJson(response.data);
        return ApiResponse<RefundModel>(success: true, data: refundModel, message: 'Refund updated successfully');
      } else {
        return ApiResponse<RefundModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to update refund');
      }
    } catch (e) {
      return ApiResponse<RefundModel>(success: false, data: null, message: 'Error updating refund: $e');
    }
  }

  Future<ApiResponse<bool>> deleteRefund(String id) async {
    try {
      final response = await _dio.delete('${ApiConfig.returnsEndpoint}refunds/$id/');

      if (response.statusCode == 204) {
        return ApiResponse<bool>(success: true, data: true, message: 'Refund deleted successfully');
      } else {
        return ApiResponse<bool>(success: false, data: false, message: response.data['message'] ?? 'Failed to delete refund');
      }
    } catch (e) {
      return ApiResponse<bool>(success: false, data: false, message: 'Error deleting refund: $e');
    }
  }

  // Refund Processing
  Future<ApiResponse<RefundModel>> processRefund({required String id, String? referenceNumber, String? notes}) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.returnsEndpoint}refunds/$id/process/',
        data: {if (referenceNumber != null) 'reference_number': referenceNumber, if (notes != null) 'notes': notes},
      );

      if (response.statusCode == 200) {
        final refundModel = RefundModel.fromJson(response.data);
        return ApiResponse<RefundModel>(success: true, data: refundModel, message: 'Refund processed successfully');
      } else {
        return ApiResponse<RefundModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to process refund');
      }
    } catch (e) {
      return ApiResponse<RefundModel>(success: false, data: null, message: 'Error processing refund: $e');
    }
  }

  Future<ApiResponse<RefundModel>> failRefund({required String id, String? notes}) async {
    try {
      final response = await _dio.patch('${ApiConfig.returnsEndpoint}refunds/$id/fail/', data: {if (notes != null) 'notes': notes});

      if (response.statusCode == 200) {
        final refundModel = RefundModel.fromJson(response.data);
        return ApiResponse<RefundModel>(success: true, data: refundModel, message: 'Refund marked as failed');
      } else {
        return ApiResponse<RefundModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to mark refund as failed');
      }
    } catch (e) {
      return ApiResponse<RefundModel>(success: false, data: null, message: 'Error marking refund as failed: $e');
    }
  }

  Future<ApiResponse<RefundModel>> cancelRefund({required String id, String? notes}) async {
    try {
      final response = await _dio.patch('${ApiConfig.returnsEndpoint}refunds/$id/cancel/', data: {if (notes != null) 'notes': notes});

      if (response.statusCode == 200) {
        final refundModel = RefundModel.fromJson(response.data);
        return ApiResponse<RefundModel>(success: true, data: refundModel, message: 'Refund cancelled successfully');
      } else {
        return ApiResponse<RefundModel>(success: false, data: null, message: response.data['message'] ?? 'Failed to cancel refund');
      }
    } catch (e) {
      return ApiResponse<RefundModel>(success: false, data: null, message: 'Error cancelling refund: $e');
    }
  }

  // Statistics and Reports
  Future<ApiResponse<Map<String, dynamic>>> getReturnStatistics() async {
    try {
      final response = await _dio.get('${ApiConfig.returnsEndpoint}statistics/');

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(success: true, data: response.data, message: 'Statistics loaded successfully');
      } else {
        return ApiResponse<Map<String, dynamic>>(success: false, data: null, message: response.data['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(success: false, data: null, message: 'Error loading statistics: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCustomerReturnHistory(String customerId) async {
    try {
      final response = await _dio.get('${ApiConfig.returnsEndpoint}customer/$customerId/history/');

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(success: true, data: response.data, message: 'Customer history loaded successfully');
      } else {
        return ApiResponse<Map<String, dynamic>>(success: false, data: null, message: response.data['message'] ?? 'Failed to load customer history');
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(success: false, data: null, message: 'Error loading customer history: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getSaleReturnDetails(String saleId) async {
    try {
      final response = await _dio.get('${ApiConfig.returnsEndpoint}sale/$saleId/returns/');

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(success: true, data: response.data, message: 'Sale return details loaded successfully');
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          data: null,
          message: response.data['message'] ?? 'Failed to load sale return details',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(success: false, data: null, message: 'Error loading sale return details: $e');
    }
  }
}
