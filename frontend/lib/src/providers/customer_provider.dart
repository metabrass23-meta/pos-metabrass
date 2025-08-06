import 'package:flutter/material.dart';
import '../models/customer/customer_api_responses.dart';
import '../models/customer/customer_model.dart';
import '../services/customer_service.dart';

// Compatibility adapter to convert between CustomerModel and your existing Customer class
class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? description;
  final DateTime createdAt;
  final DateTime? lastPurchaseDate;
  final double? lastPurchase;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.description,
    required this.createdAt,
    this.lastPurchaseDate,
    this.lastPurchase,
  });

  // Convert from CustomerModel (API) to Customer (UI)
  factory Customer.fromCustomerModel(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      phone: model.phone,
      email: model.email,
      description: model.notes,
      createdAt: model.createdAt,
      lastPurchaseDate: model.lastOrderDate,
      lastPurchase: null, // This would come from order integration
    );
  }

  // Formatted date for display
  String get formattedCreatedAt {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  // Relative date (e.g., "Today", "Yesterday", "2 days ago")
  String get relativeCreatedAt {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final customerDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final difference = today.difference(customerDate).inDays;

    return _getRelativeDateString(difference);
  }

  String _getRelativeDateString(int difference) {
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? description,
    DateTime? createdAt,
    DateTime? lastPurchaseDate,
    double? lastPurchase,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      lastPurchase: lastPurchase ?? this.lastPurchase,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'lastPurchase': lastPurchase,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      lastPurchaseDate: json['lastPurchaseDate'] != null
          ? DateTime.parse(json['lastPurchaseDate'])
          : null,
      lastPurchase: json['lastPurchase']?.toDouble(),
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  // Pagination
  PaginationInfo? _paginationInfo;
  int _currentPage = 1;
  int _pageSize = 20;
  bool _showInactive = false;

  // Filters
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedCity;
  String? _selectedCountry;
  String? _verificationFilter;

  // Sorting
  String _sortBy = 'created_at'; // 'name', 'created_at', 'updated_at', 'last_order_date', 'status', 'customer_type'
  bool _sortAscending = false;

  // Statistics
  CustomerStatisticsResponse? _customerStatistics;

  // Getters
  List<Customer> get customers => _filteredCustomers;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  PaginationInfo? get paginationInfo => _paginationInfo;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get showInactive => _showInactive;
  String? get selectedStatus => _selectedStatus;
  String? get selectedType => _selectedType;
  String? get selectedCity => _selectedCity;
  String? get selectedCountry => _selectedCountry;
  String? get verificationFilter => _verificationFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  CustomerStatisticsResponse? get customerStatistics => _customerStatistics;

  CustomerProvider() {
    loadCustomers();
    loadCustomerStatistics();
  }

  /// Load customers from API
  Future<void> loadCustomers({
    int? page,
    int? pageSize,
    String? search,
    bool? showInactive,
    String? status,
    String? customerType,
    String? city,
    String? country,
    String? verified,
    bool showLoadingIndicator = true,
  }) async {
    if (showLoadingIndicator) {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final params = CustomerListParams(
        page: page ?? _currentPage,
        pageSize: pageSize ?? _pageSize,
        search: search ?? _searchQuery,
        showInactive: showInactive ?? _showInactive,
        customerType: customerType ?? _selectedType,
        status: status ?? _selectedStatus,
        city: city ?? _selectedCity,
        country: country ?? _selectedCountry,
        verified: verified ?? _verificationFilter,
        sortBy: _sortBy,
        sortOrder: _sortAscending ? 'asc' : 'desc',
      );

      final response = await _customerService.getCustomers(params: params);

      if (response.success && response.data != null) {
        final customersData = response.data!;

        // Convert CustomerModel to Customer for UI compatibility
        _customers = customersData.customers
            .map((customerModel) => Customer.fromCustomerModel(customerModel))
            .toList();

        _filteredCustomers = List.from(_customers);
        _paginationInfo = customersData.pagination;

        // Update pagination state
        _currentPage = params.page;
        _pageSize = params.pageSize;
        _searchQuery = params.search ?? '';
        _showInactive = params.showInactive;
        _selectedStatus = params.status;
        _selectedType = params.customerType;
        _selectedCity = params.city;
        _selectedCountry = params.country;
        _verificationFilter = params.verified;

        _hasError = false;
        _errorMessage = null;
      } else {
        _hasError = true;
        _errorMessage = response.message;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load customer statistics
  Future<void> loadCustomerStatistics() async {
    try {
      final response = await _customerService.getCustomerStatistics();

      if (response.success && response.data != null) {
        _customerStatistics = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load customer statistics: ${e.toString()}');
    }
  }

  /// Refresh customers (pull-to-refresh)
  Future<void> refreshCustomers() async {
    _currentPage = 1; // Reset to first page
    await loadCustomers(page: 1, showLoadingIndicator: false);
    await loadCustomerStatistics();
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (_paginationInfo?.hasNext == true) {
      await loadCustomers(page: _currentPage + 1, showLoadingIndicator: false);
    }
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (_paginationInfo?.hasPrevious == true) {
      await loadCustomers(page: _currentPage - 1, showLoadingIndicator: false);
    }
  }

  /// Search customers
  Future<void> searchCustomers(String query) async {
    _searchQuery = query.toLowerCase();
    _currentPage = 1; // Reset to first page when searching
    await loadCustomers(search: _searchQuery, page: 1);
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadCustomers(search: '', page: 1);
  }

  /// Toggle show inactive customers
  Future<void> toggleShowInactive() async {
    _showInactive = !_showInactive;
    _currentPage = 1;
    await loadCustomers(showInactive: _showInactive, page: 1);
  }

  /// Set status filter
  Future<void> setStatusFilter(String? status) async {
    _selectedStatus = status;
    _currentPage = 1;
    await loadCustomers(status: _selectedStatus, page: 1);
  }

  /// Set customer type filter
  Future<void> setTypeFilter(String? customerType) async {
    _selectedType = customerType;
    _currentPage = 1;
    await loadCustomers(customerType: _selectedType, page: 1);
  }

  /// Set city filter
  Future<void> setCityFilter(String? city) async {
    _selectedCity = city;
    _currentPage = 1;
    await loadCustomers(city: _selectedCity, page: 1);
  }

  /// Set country filter
  Future<void> setCountryFilter(String? country) async {
    _selectedCountry = country;
    _currentPage = 1;
    await loadCustomers(country: _selectedCountry, page: 1);
  }

  /// Set verification filter
  Future<void> setVerificationFilter(String? verified) async {
    _verificationFilter = verified;
    _currentPage = 1;
    await loadCustomers(verified: _verificationFilter, page: 1);
  }

  /// Clear all filters
  Future<void> clearAllFilters() async {
    _selectedStatus = null;
    _selectedType = null;
    _selectedCity = null;
    _selectedCountry = null;
    _verificationFilter = null;
    _searchQuery = '';
    _currentPage = 1;
    await loadCustomers(
      status: null,
      customerType: null,
      city: null,
      country: null,
      verified: null,
      search: '',
      page: 1,
    );
  }

  /// Sort customers
  void setSortBy(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      // Toggle if same field, otherwise default to descending for dates, ascending for text
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortAscending = (sortBy == 'name' || sortBy == 'phone' || sortBy == 'email');
      }
    }

    // Reload with new sorting
    loadCustomers(showLoadingIndicator: false);
  }

  /// Add new customer
  Future<bool> addCustomer({
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
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.createCustomer(
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

      if (response.success && response.data != null) {
        // Add the new customer to local list immediately
        final newCustomer = Customer.fromCustomerModel(response.data!);
        _customers.add(newCustomer);
        _filteredCustomers.add(newCustomer);

        // Also refresh from server to ensure consistency
        await loadCustomers(showLoadingIndicator: false);
        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to create customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing customer
  Future<bool> updateCustomer({
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
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.updateCustomer(
        id: id,
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

      if (response.success && response.data != null) {
        // Update the customer in local list
        final updatedCustomer = Customer.fromCustomerModel(response.data!);
        final index = _customers.indexWhere((customer) => customer.id == id);
        if (index != -1) {
          _customers[index] = updatedCustomer;
        }

        final filteredIndex = _filteredCustomers.indexWhere((customer) => customer.id == id);
        if (filteredIndex != -1) {
          _filteredCustomers[filteredIndex] = updatedCustomer;
        }

        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete customer permanently (hard delete)
  Future<bool> deleteCustomer(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.deleteCustomer(id);

      if (response.success) {
        // Remove customer from local list permanently
        _customers.removeWhere((customer) => customer.id == id);
        _filteredCustomers.removeWhere((customer) => customer.id == id);

        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Soft delete customer (set as inactive)
  Future<bool> softDeleteCustomer(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.softDeleteCustomer(id);

      if (response.success) {
        // Update customer in local list to mark as inactive or remove from list
        if (!_showInactive) {
          _customers.removeWhere((customer) => customer.id == id);
          _filteredCustomers.removeWhere((customer) => customer.id == id);
        }

        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to soft delete customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore customer
  Future<bool> restoreCustomer(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.restoreCustomer(id);

      if (response.success && response.data != null) {
        // Update the customer in local list
        final restoredCustomer = Customer.fromCustomerModel(response.data!);
        final index = _customers.indexWhere((customer) => customer.id == id);
        if (index != -1) {
          _customers[index] = restoredCustomer;
        } else {
          _customers.add(restoredCustomer);
        }

        final filteredIndex = _filteredCustomers.indexWhere((customer) => customer.id == id);
        if (filteredIndex != -1) {
          _filteredCustomers[filteredIndex] = restoredCustomer;
        } else {
          _filteredCustomers.add(restoredCustomer);
        }

        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to restore customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify customer contact
  Future<bool> verifyCustomerContact({
    required String id,
    required String verificationType,
    bool verified = true,
  }) async {
    try {
      final response = await _customerService.verifyCustomerContact(
        id: id,
        verificationType: verificationType,
        verified: verified,
      );

      if (response.success) {
        // Refresh customer data to get updated verification status
        await loadCustomers(showLoadingIndicator: false);
        await loadCustomerStatistics();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to verify customer contact: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update customer activity
  Future<bool> updateCustomerActivity({
    required String id,
    required String activityType,
    String? activityDate,
  }) async {
    try {
      final response = await _customerService.updateCustomerActivity(
        id: id,
        activityType: activityType,
        activityDate: activityDate,
      );

      if (response.success) {
        // Refresh customer data to get updated activity
        await loadCustomers(showLoadingIndicator: false);
        await loadCustomerStatistics();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update customer activity: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Bulk customer actions
  Future<bool> bulkCustomerActions({
    required List<String> customerIds,
    required String action,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.bulkCustomerActions(
        customerIds: customerIds,
        action: action,
      );

      if (response.success) {
        // Refresh customer data to get updated information
        await loadCustomers(showLoadingIndicator: false);
        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to perform bulk action: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Duplicate customer
  Future<bool> duplicateCustomer({
    required String id,
    required String name,
    required String phone,
    String? email,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.duplicateCustomer(
        id: id,
        name: name,
        phone: phone,
        email: email,
      );

      if (response.success && response.data != null) {
        // Add the new customer to local list immediately
        final duplicatedCustomer = Customer.fromCustomerModel(response.data!);
        _customers.add(duplicatedCustomer);
        _filteredCustomers.add(duplicatedCustomer);

        // Also refresh from server to ensure consistency
        await loadCustomers(showLoadingIndicator: false);
        await loadCustomerStatistics();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to duplicate customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Enhanced statistics for dashboard
  Map<String, dynamic> get customerStats {
    if (_customerStatistics == null) {
      return {
        'total': 0,
        'newThisMonth': 0,
        'averagePurchase': 0,
        'recentBuyers': 0,
      };
    }

    return {
      'total': _customerStatistics!.totalCustomers,
      'newThisMonth': _customerStatistics!.newCustomersThisMonth,
      'averagePurchase': 0, // This would come from order integration
      'recentBuyers': _customerStatistics!.recentCustomersThisWeek,
    };
  }

  /// Get customers by status
  List<Customer> getCustomersByStatus(String status) {
    return _customers.where((customer) {
      // This would need to be implemented with actual status from CustomerModel
      return true; // Placeholder
    }).toList();
  }

  /// Get customers by type
  List<Customer> getCustomersByType(String customerType) {
    return _customers.where((customer) {
      // This would need to be implemented with actual type from CustomerModel
      return true; // Placeholder
    }).toList();
  }

  /// Get recently created customers
  List<Customer> getRecentlyCreated({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _customers
        .where((customer) => customer.createdAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Export data (placeholder for future implementation)
  Future<void> exportData() async {
    // Implementation for exporting customer data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Clear all customers cache
  Future<void> clearCache() async {
    await _customerService.clearCache();
  }

  /// Check if has cached data
  Future<bool> hasCachedData() async {
    return await _customerService.hasCachedCustomers();
  }

  /// Set page size
  Future<void> setPageSize(int pageSize) async {
    if (_pageSize != pageSize) {
      _pageSize = pageSize;
      _currentPage = 1; // Reset to first page
      await loadCustomers(pageSize: _pageSize, page: 1);
    }
  }

  /// Load customers by specific segments
  Future<void> loadPakistaniCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.getPakistaniCustomers(
        page: 1,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        _customers = response.data!.customers
            .map((customerModel) => Customer.fromCustomerModel(customerModel))
            .toList();
        _filteredCustomers = List.from(_customers);
        _paginationInfo = response.data!.pagination;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load Pakistani customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInternationalCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.getInternationalCustomers(
        page: 1,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        _customers = response.data!.customers
            .map((customerModel) => Customer.fromCustomerModel(customerModel))
            .toList();
        _filteredCustomers = List.from(_customers);
        _paginationInfo = response.data!.pagination;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load international customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNewCustomers({int days = 30}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _customerService.getNewCustomers(
        days: days,
        page: 1,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        _customers = response.data!.customers
            .map((customerModel) => Customer.fromCustomerModel(customerModel))
            .toList();
        _filteredCustomers = List.from(_customers);
        _paginationInfo = response.data!.pagination;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load new customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}