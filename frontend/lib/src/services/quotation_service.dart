import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/quotation/quotation_model.dart';
import '../utils/debug_helper.dart';
import 'api_client.dart';

class QuotationService {
  static final QuotationService _instance = QuotationService._internal();
  factory QuotationService() => _instance;
  QuotationService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<QuotationModel>>> getQuotations() async {
    try {
      final response = await _apiClient.get(ApiConfig.quotations);
      if (response.statusCode == 200) {
        dynamic data = response.data;
        List<dynamic> rawList = [];
        if (data is Map && data.containsKey('results')) {
          rawList = data['results'] as List<dynamic>;
        } else if (data is List) {
          rawList = data;
        } else if (data is Map && data.containsKey('data')) {
           rawList = data['data'] as List<dynamic>;
        }
        
        List<QuotationModel> quotations = rawList.map((m) => QuotationModel.fromJson(m as Map<String, dynamic>)).toList();
        return ApiResponse(success: true, message: 'Quotations loaded', data: quotations);
      } else {
        return ApiResponse(success: false, message: 'Failed to load quotations');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse(success: false, message: apiError.displayMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<QuotationModel>> createQuotation(QuotationModel quotation) async {
    try {
      final response = await _apiClient.post(ApiConfig.createQuotation, data: quotation.toJson());
      if (response.statusCode == 201) {
        return ApiResponse(success: true, message: 'Quotation created', data: QuotationModel.fromJson(response.data));
      } else {
        return ApiResponse(success: false, message: 'Failed to create quotation');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse(success: false, message: apiError.displayMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<bool>> convertToSale(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.convertQuotationToSale(id));
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Successfully converted to sale', data: true);
      } else {
        return ApiResponse(success: false, message: response.data['detail'] ?? 'Failed to convert');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse(success: false, message: apiError.displayMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<QuotationModel>> updateQuotationStatus(String id, QuotationStatus status) async {
    try {
      final response = await _apiClient.patch(ApiConfig.updateQuotation(id), data: {'status': status.name.toUpperCase()});
      if (response.statusCode == 200) {
         return ApiResponse(success: true, message: 'Updated', data: QuotationModel.fromJson(response.data));
      } else {
        return ApiResponse(success: false, message: 'Failed to update');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse(success: false, message: apiError.displayMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<bool>> deleteQuotation(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.updateQuotation(id));
      if (response.statusCode == 204 || response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Quotation deleted successfully', data: true);
      } else {
        return ApiResponse(success: false, message: 'Failed to delete quotation');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse(success: false, message: apiError.displayMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<QuotationModel>> updateQuotation(QuotationModel quotation) async {
    try {
      final response = await _apiClient.put(ApiConfig.updateQuotation(quotation.id), data: quotation.toJson());
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Quotation updated', data: QuotationModel.fromJson(response.data));
      } else {
        return ApiResponse(success: false, message: 'Failed to update quotation');
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDioError(e);
      return ApiResponse(success: false, message: apiError.displayMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
