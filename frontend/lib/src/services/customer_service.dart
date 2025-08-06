import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/customer/customer_api_responses.dart';
import '../models/customer/customer_model.dart';
import '../utils/storage_service.dart';
import '../utils/debug_helper.dart';
import 'api_client.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  /// Get list of customers with pagination and filtering
  Future<ApiResponse<CustomersListResponse>> getCustomers({
    CustomerListParams? params,
  }) async {
    try {
      final queryParams = params?.toQueryParameters() ?? CustomerListParams().toQueryParameters();

      final response = await _apiClient.get(
        ApiConfig.customers,
        queryParameters: queryParams,
      );

      DebugHelper.printApiResponse('GET Customers', response.data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );

        // Cache customers if successful
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheCustomers(apiResponse.data!.customers);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customers',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customers DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);

      // Try to return cached data if network error
      if (apiError.type == 'network_error') {
        final cachedCustomers = await _getCachedCustomers();
        if (cachedCustomers.isNotEmpty) {
          return ApiResponse<CustomersListResponse>(
            success: true,
            message: 'Showing cached data',
            data: CustomersListResponse(
              customers: cachedCustomers,
              pagination: PaginationInfo(
                currentPage: 1,
                pageSize: cachedCustomers.length,
                totalCount: cachedCustomers.length,
                totalPages: 1,
                hasNext: false,
                hasPrevious: false,
              ),
            ),
          );
        }
      }

      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      DebugHelper.printError('Get customers', e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting customers',
      );
    }
  }

  /// Get a specific customer by ID
  Future<ApiResponse<CustomerModel>> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get(ApiConfig.getCustomerById(id));

      DebugHelper.printApiResponse('GET Customer by ID', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<CustomerModel>.fromJson(
          response.data,
              (data) => CustomerModel.fromJson(data),
        );
      } else {
        return ApiResponse<CustomerModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customer by ID DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get customer by ID error: ${e.toString()}');
      return ApiResponse<CustomerModel>(
        success: false,
        message: 'An unexpected error occurred while getting customer',
      );
    }
  }

  /// Create a new customer
  Future<ApiResponse<CustomerModel>> createCustomer({
    required String name,
    required String phone,
    required String email,
    String? address,
    String? city,
    String? country,
    String? customerType,
    String? businessName,
    String? taxNumber,
    String? notes,
  }) async {
    try {
      final request = CustomerCreateRequest(
        name: name,
        phone: phone,
        email: email,
        address: address,
        city: city,
        country: country,
        customerType: customerType,
        businessName: businessName,
        taxNumber: taxNumber,
        notes: notes,
      );

      DebugHelper.printJson('Create Customer Request', request.toJson());

      final response = await _apiClient.post(
        ApiConfig.createCustomer,
        data: request.toJson(),
      );

      DebugHelper.printApiResponse('POST Create Customer', response.data);

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse<CustomerModel>.fromJson(
          response.data,
              (data) => CustomerModel.fromJson(data),
        );

        // Update cache with new customer
        if (apiResponse.success && apiResponse.data != null) {
          await _addCustomerToCache(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomerModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to create customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      DebugHelper.printError('Create customer DioException', e);
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      DebugHelper.printError('Create customer', e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: 'An unexpected error occurred while creating customer: ${e.toString()}',
      );
    }
  }

  /// Update an existing customer
  Future<ApiResponse<CustomerModel>> updateCustomer({
    required String id,
    required String name,
    required String phone,
    required String email,
    String? address,
    String? city,
    String? country,
    String? customerType,
    String? status,
    String? businessName,
    String? taxNumber,
    String? notes,
    bool? phoneVerified,
    bool? emailVerified,
  }) async {
    try {
      final request = CustomerUpdateRequest(
        name: name,
        phone: phone,
        email: email,
        address: address,
        city: city,
        country: country,
        customerType: customerType,
        status: status,
        businessName: businessName,
        taxNumber: taxNumber,
        notes: notes,
        phoneVerified: phoneVerified,
        emailVerified: emailVerified,
      );

      DebugHelper.printJson('Update Customer Request', request.toJson());

      final response = await _apiClient.put(
        ApiConfig.updateCustomer(id),
        data: request.toJson(),
      );

      DebugHelper.printApiResponse('PUT Update Customer', response.data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CustomerModel>.fromJson(
          response.data,
              (data) => CustomerModel.fromJson(data),
        );

        // Update cache with updated customer
        if (apiResponse.success && apiResponse.data != null) {
          await _updateCustomerInCache(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomerModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update customer DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Update customer error: ${e.toString()}');
      return ApiResponse<CustomerModel>(
        success: false,
        message: 'An unexpected error occurred while updating customer',
      );
    }
  }

  /// Delete a customer permanently (hard delete)
  Future<ApiResponse<void>> deleteCustomer(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.deleteCustomer(id));

      DebugHelper.printApiResponse('DELETE Customer', response.data);

      if (response.statusCode == 200) {
        // Remove from cache
        await _removeCustomerFromCache(id);

        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Customer deleted permanently',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.data['message'] ?? 'Failed to delete customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete customer DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Delete customer error: ${e.toString()}');
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred while deleting customer',
      );
    }
  }

  /// Soft delete a customer (set is_active=False)
  Future<ApiResponse<void>> softDeleteCustomer(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.softDeleteCustomer(id));

      DebugHelper.printApiResponse('POST Soft Delete Customer', response.data);

      if (response.statusCode == 200) {
        // Update cache to mark as inactive
        final cachedCustomers = await _getCachedCustomers();
        final index = cachedCustomers.indexWhere((customer) => customer.id == id);
        if (index != -1) {
          final updatedCustomer = cachedCustomers[index].copyWith(isActive: false);
          cachedCustomers[index] = updatedCustomer;
          await _cacheCustomers(cachedCustomers);
        }

        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Customer soft deleted successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.data['message'] ?? 'Failed to soft delete customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Soft delete customer DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Soft delete customer error: ${e.toString()}');
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred while soft deleting customer',
      );
    }
  }

  /// Restore a soft-deleted customer
  Future<ApiResponse<CustomerModel>> restoreCustomer(String id) async {
    try {
      final response = await _apiClient.post(ApiConfig.restoreCustomer(id));

      DebugHelper.printApiResponse('POST Restore Customer', response.data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CustomerModel>.fromJson(
          response.data,
              (data) => CustomerModel.fromJson(data),
        );

        // Update cache with restored customer
        if (apiResponse.success && apiResponse.data != null) {
          await _updateCustomerInCache(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomerModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to restore customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Restore customer DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Restore customer error: ${e.toString()}');
      return ApiResponse<CustomerModel>(
        success: false,
        message: 'An unexpected error occurred while restoring customer',
      );
    }
  }

  /// Search customers
  Future<ApiResponse<CustomersListResponse>> searchCustomers({
    required String query,
    int page = 1,
    int pageSize = 20,
    bool showInactive = false,
    String? customerType,
    String? status,
    String? city,
    String? country,
  }) async {
    final params = CustomerListParams(
      page: page,
      pageSize: pageSize,
      search: query,
      showInactive: showInactive,
      customerType: customerType,
      status: status,
      city: city,
      country: country,
    );

    return await getCustomers(params: params);
  }

  /// Get customers by status
  Future<ApiResponse<CustomersListResponse>> getCustomersByStatus({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.customersByStatus(status),
        queryParameters: queryParams,
      );

      DebugHelper.printApiResponse('GET Customers by Status', response.data);

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customers by status',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customers by status DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get customers by status error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting customers by status',
      );
    }
  }

  /// Get customer statistics
  Future<ApiResponse<CustomerStatisticsResponse>> getCustomerStatistics() async {
    try {
      final response = await _apiClient.get(ApiConfig.customerStatistics);

      DebugHelper.printApiResponse('GET Customer Statistics', response.data);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CustomerStatisticsResponse>.fromJson(
          response.data,
              (data) => CustomerStatisticsResponse.fromJson(data),
        );

        // Cache statistics if successful
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheCustomerStatistics(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomerStatisticsResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customer statistics',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customer statistics DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);

      // Try to return cached statistics if network error
      if (apiError.type == 'network_error') {
        final cachedStats = await _getCachedCustomerStatistics();
        if (cachedStats != null) {
          return ApiResponse<CustomerStatisticsResponse>(
            success: true,
            message: 'Showing cached statistics',
            data: cachedStats,
          );
        }
      }

      return ApiResponse<CustomerStatisticsResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get customer statistics error: ${e.toString()}');
      return ApiResponse<CustomerStatisticsResponse>(
        success: false,
        message: 'An unexpected error occurred while getting customer statistics',
      );
    }
  }

  /// Update customer contact information
  Future<ApiResponse<CustomerModel>> updateCustomerContact({
    required String id,
    required String phone,
    required String email,
    String? address,
    String? city,
    String? country,
  }) async {
    try {
      final request = CustomerContactUpdateRequest(
        phone: phone,
        email: email,
        address: address,
        city: city,
        country: country,
      );

      final response = await _apiClient.put(
        ApiConfig.updateCustomerContact(id),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CustomerModel>.fromJson(
          response.data,
              (data) => CustomerModel.fromJson(data),
        );

        // Update cache with updated customer
        if (apiResponse.success && apiResponse.data != null) {
          await _updateCustomerInCache(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomerModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to update customer contact',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update customer contact DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Update customer contact error: ${e.toString()}');
      return ApiResponse<CustomerModel>(
        success: false,
        message: 'An unexpected error occurred while updating customer contact',
      );
    }
  }

  /// Verify customer contact (phone or email)
  Future<ApiResponse<void>> verifyCustomerContact({
    required String id,
    required String verificationType, // 'phone' or 'email'
    bool verified = true,
  }) async {
    try {
      final request = CustomerVerificationRequest(
        verificationType: verificationType,
        verified: verified,
      );

      final response = await _apiClient.post(
        ApiConfig.verifyCustomerContact(id),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Customer contact verified successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.data['message'] ?? 'Failed to verify customer contact',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Verify customer contact DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Verify customer contact error: ${e.toString()}');
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred while verifying customer contact',
      );
    }
  }

  /// Update customer activity (last order/contact date)
  Future<ApiResponse<void>> updateCustomerActivity({
    required String id,
    required String activityType, // 'order' or 'contact'
    String? activityDate, // ISO format datetime string
  }) async {
    try {
      final request = CustomerActivityUpdateRequest(
        activityType: activityType,
        activityDate: activityDate,
      );

      final response = await _apiClient.post(
        ApiConfig.updateCustomerActivity(id),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: response.data['message'] ?? 'Customer activity updated successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response.data['message'] ?? 'Failed to update customer activity',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Update customer activity DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<void>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Update customer activity error: ${e.toString()}');
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred while updating customer activity',
      );
    }
  }

  /// Bulk customer actions
  Future<ApiResponse<Map<String, dynamic>>> bulkCustomerActions({
    required List<String> customerIds,
    required String action,
  }) async {
    try {
      final request = CustomerBulkActionRequest(
        customerIds: customerIds,
        action: action,
      );

      final response = await _apiClient.post(
        ApiConfig.bulkCustomerActions,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: response.data['message'] ?? 'Bulk action completed successfully',
          data: response.data['data'] as Map<String, dynamic>?,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data['message'] ?? 'Failed to perform bulk action',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Bulk customer actions DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Bulk customer actions error: ${e.toString()}');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred while performing bulk action',
      );
    }
  }

  /// Duplicate customer
  Future<ApiResponse<CustomerModel>> duplicateCustomer({
    required String id,
    required String name,
    required String phone,
    String? email,
  }) async {
    try {
      final request = CustomerDuplicateRequest(
        name: name,
        phone: phone,
        email: email,
      );

      final response = await _apiClient.post(
        ApiConfig.duplicateCustomer(id),
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse<CustomerModel>.fromJson(
          response.data,
              (data) => CustomerModel.fromJson(data),
        );

        // Update cache with new customer
        if (apiResponse.success && apiResponse.data != null) {
          await _addCustomerToCache(apiResponse.data!);
        }

        return apiResponse;
      } else {
        return ApiResponse<CustomerModel>(
          success: false,
          message: response.data['message'] ?? 'Failed to duplicate customer',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Duplicate customer DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomerModel>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Duplicate customer error: ${e.toString()}');
      return ApiResponse<CustomerModel>(
        success: false,
        message: 'An unexpected error occurred while duplicating customer',
      );
    }
  }

  // Cache management methods
  Future<void> _cacheCustomers(List<CustomerModel> customers) async {
    try {
      final customersJson = customers.map((customer) => customer.toJson()).toList();
      await _storageService.saveData(ApiConfig.customersCacheKey, customersJson);
    } catch (e) {
      debugPrint('Error caching customers: $e');
    }
  }

  Future<List<CustomerModel>> _getCachedCustomers() async {
    try {
      final cachedData = await _storageService.getData(ApiConfig.customersCacheKey);
      if (cachedData != null && cachedData is List) {
        return cachedData
            .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting cached customers: $e');
    }
    return [];
  }

  Future<void> _addCustomerToCache(CustomerModel customer) async {
    try {
      final cachedCustomers = await _getCachedCustomers();
      cachedCustomers.add(customer);
      await _cacheCustomers(cachedCustomers);
    } catch (e) {
      debugPrint('Error adding customer to cache: $e');
    }
  }

  Future<void> _updateCustomerInCache(CustomerModel updatedCustomer) async {
    try {
      final cachedCustomers = await _getCachedCustomers();
      final index = cachedCustomers.indexWhere((customer) => customer.id == updatedCustomer.id);
      if (index != -1) {
        cachedCustomers[index] = updatedCustomer;
        await _cacheCustomers(cachedCustomers);
      }
    } catch (e) {
      debugPrint('Error updating customer in cache: $e');
    }
  }

  Future<void> _removeCustomerFromCache(String customerId) async {
    try {
      final cachedCustomers = await _getCachedCustomers();
      cachedCustomers.removeWhere((customer) => customer.id == customerId);
      await _cacheCustomers(cachedCustomers);
    } catch (e) {
      debugPrint('Error removing customer from cache: $e');
    }
  }

  Future<void> _cacheCustomerStatistics(CustomerStatisticsResponse statistics) async {
    try {
      await _storageService.saveData(ApiConfig.customerStatsCacheKey, statistics.toJson());
    } catch (e) {
      debugPrint('Error caching customer statistics: $e');
    }
  }

  Future<CustomerStatisticsResponse?> _getCachedCustomerStatistics() async {
    try {
      final cachedData = await _storageService.getData(ApiConfig.customerStatsCacheKey);
      if (cachedData != null) {
        return CustomerStatisticsResponse.fromJson(cachedData as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error getting cached customer statistics: $e');
    }
    return null;
  }

  /// Clear customers cache
  Future<void> clearCache() async {
    try {
      await _storageService.removeData(ApiConfig.customersCacheKey);
      await _storageService.removeData(ApiConfig.customerStatsCacheKey);
    } catch (e) {
      debugPrint('Error clearing customers cache: $e');
    }
  }

  /// Get cached customers count
  Future<int> getCachedCustomersCount() async {
    final cachedCustomers = await _getCachedCustomers();
    return cachedCustomers.length;
  }

  /// Check if customers are cached
  Future<bool> hasCachedCustomers() async {
    final count = await getCachedCustomersCount();
    return count > 0;
  }

  /// Check if customer statistics are cached
  Future<bool> hasCachedStatistics() async {
    final stats = await _getCachedCustomerStatistics();
    return stats != null;
  }

  /// Get customers by type
  Future<ApiResponse<CustomersListResponse>> getCustomersByType({
    required String type,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.customersByType(type),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customers by type',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customers by type DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get customers by type error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting customers by type',
      );
    }
  }

  /// Get customers by city
  Future<ApiResponse<CustomersListResponse>> getCustomersByCity({
    required String city,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.customersByCity(city),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customers by city',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customers by city DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get customers by city error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting customers by city',
      );
    }
  }

  /// Get customers by country
  Future<ApiResponse<CustomersListResponse>> getCustomersByCountry({
    required String country,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.customersByCountry(country),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get customers by country',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get customers by country DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get customers by country error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting customers by country',
      );
    }
  }

  /// Get Pakistani customers
  Future<ApiResponse<CustomersListResponse>> getPakistaniCustomers({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.pakistaniCustomers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get Pakistani customers',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get Pakistani customers DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get Pakistani customers error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting Pakistani customers',
      );
    }
  }

  /// Get international customers
  Future<ApiResponse<CustomersListResponse>> getInternationalCustomers({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.internationalCustomers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get international customers',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get international customers DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get international customers error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting international customers',
      );
    }
  }

  /// Get new customers
  Future<ApiResponse<CustomersListResponse>> getNewCustomers({
    int days = 30,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'days': days.toString(),
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.newCustomers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get new customers',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get new customers DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get new customers error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting new customers',
      );
    }
  }

  /// Get recent customers
  Future<ApiResponse<CustomersListResponse>> getRecentCustomers({
    int days = 7,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'days': days.toString(),
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await _apiClient.get(
        ApiConfig.recentCustomers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse<CustomersListResponse>.fromJson(
          response.data,
              (data) => CustomersListResponse.fromJson(data),
        );
      } else {
        return ApiResponse<CustomersListResponse>(
          success: false,
          message: response.data['message'] ?? 'Failed to get recent customers',
          errors: response.data['errors'] as Map<String, dynamic>?,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get recent customers DioException: ${e.toString()}');
      final apiError = ApiError.fromDioError(e);
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: apiError.displayMessage,
        errors: apiError.errors,
      );
    } catch (e) {
      debugPrint('Get recent customers error: ${e.toString()}');
      return ApiResponse<CustomersListResponse>(
        success: false,
        message: 'An unexpected error occurred while getting recent customers',
      );
    }
  }
}