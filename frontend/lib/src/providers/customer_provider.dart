import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String description;
  final double? lastPurchase;
  final DateTime? lastPurchaseDate;
  final DateTime createdAt;
  final bool isActive; // Added for soft delete functionality

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.description,
    this.lastPurchase,
    this.lastPurchaseDate,
    required this.createdAt,
    this.isActive = true, // Default to active
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? description,
    double? lastPurchase,
    DateTime? lastPurchaseDate,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Formatted date for display
  String get formattedCreatedAt {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  String get formattedLastPurchaseDate {
    if (lastPurchaseDate == null) return 'N/A';
    return '${lastPurchaseDate!.day.toString().padLeft(2, '0')}/${lastPurchaseDate!.month.toString().padLeft(2, '0')}/${lastPurchaseDate!.year}';
  }

  // Relative date (e.g., "Today", "Yesterday", "2 days ago")
  String get relativeCreatedAt {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final difference = today.difference(recordDate).inDays;

    return _getRelativeDateString(difference);
  }

  String get relativeLastPurchaseDate {
    if (lastPurchaseDate == null) return 'N/A';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(lastPurchaseDate!.year, lastPurchaseDate!.month, lastPurchaseDate!.day);
    final difference = today.difference(recordDate).inDays;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'description': description,
      'lastPurchase': lastPurchase,
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      lastPurchase: json['lastPurchase']?.toDouble(),
      lastPurchaseDate: json['lastPurchaseDate'] != null
          ? DateTime.parse(json['lastPurchaseDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  List<Customer> _allCustomers = []; // All customers including inactive
  List<Customer> _customers = []; // Active customers only
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;
  bool _showInactive = false; // Toggle to show inactive customers

  // Getters
  List<Customer> get customers => _filteredCustomers;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  bool get showInactive => _showInactive;

  CustomerProvider() {
    _initializeCustomers();
  }

  void _initializeCustomers() {
    _allCustomers = [
      Customer(
        id: 'CUS001',
        name: 'Aisha Khan',
        phone: '+923001234567',
        email: 'aisha.khan@email.com',
        description: 'Premium customer, prefers bridal wear',
        lastPurchase: 85000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        isActive: true,
      ),
      Customer(
        id: 'CUS002',
        name: 'Fatima Ali',
        phone: '+923009876543',
        email: 'fatima.ali@email.com',
        description: 'Regular customer, casual and formal wear',
        lastPurchase: 45000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 8)),
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
        isActive: true,
      ),
      Customer(
        id: 'CUS003',
        name: 'Sarah Ahmed',
        phone: '+923005555555',
        email: 'sarah.ahmed@email.com',
        description: 'Occasional buyer, party dresses',
        lastPurchase: 25000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        isActive: true,
      ),
      Customer(
        id: 'CUS004',
        name: 'Zara Sheikh',
        phone: '+923007777777',
        email: 'zara.sheikh@email.com',
        description: 'VIP customer, wedding collections',
        lastPurchase: 120000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        isActive: true,
      ),
      Customer(
        id: 'CUS005',
        name: 'Mehwish Qureshi',
        phone: '+923002222222',
        email: 'mehwish.q@email.com',
        description: 'New customer, interested in casual wear',
        lastPurchase: null,
        lastPurchaseDate: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isActive: true,
      ),
      Customer(
        id: 'CUS006',
        name: 'Hina Malik',
        phone: '+923003333333',
        email: 'hina.malik@email.com',
        description: 'Corporate client, bulk orders',
        lastPurchase: 95000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 20)),
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        isActive: true,
      ),
      // Add some inactive customers for testing
      Customer(
        id: 'CUS007',
        name: 'Inactive Customer',
        phone: '+923004444444',
        email: 'inactive@email.com',
        description: 'This customer has been deactivated',
        lastPurchase: 15000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        isActive: false,
      ),
    ];

    _updateCustomersList();
  }

  void _updateCustomersList() {
    _customers = _showInactive
        ? _allCustomers
        : _allCustomers.where((customer) => customer.isActive).toList();
    searchCustomers(_searchQuery);
  }

  /// Toggle show inactive customers
  void toggleShowInactive() {
    _showInactive = !_showInactive;
    _updateCustomersList();
    notifyListeners();
  }

  void searchCustomers(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers
          .where((customer) =>
      customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone.toLowerCase().contains(query.toLowerCase()) ||
          customer.email.toLowerCase().contains(query.toLowerCase()) ||
          customer.id.toLowerCase().contains(query.toLowerCase()) ||
          customer.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<bool> addCustomer({
    required String name,
    required String phone,
    required String email,
    required String description,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final newCustomer = Customer(
        id: 'CUS${(_allCustomers.length + 1).toString().padLeft(3, '0')}',
        name: name,
        phone: phone,
        email: email,
        description: description,
        lastPurchase: null,
        lastPurchaseDate: null,
        createdAt: DateTime.now(),
        isActive: true,
      );

      _allCustomers.add(newCustomer);
      _updateCustomersList();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to add customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String description,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _allCustomers.indexWhere((customer) => customer.id == id);
      if (index != -1) {
        _allCustomers[index] = _allCustomers[index].copyWith(
          name: name,
          phone: phone,
          email: email,
          description: description,
        );
        _updateCustomersList();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hard delete - permanently removes customer
  Future<bool> deleteCustomer(String id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _allCustomers.removeWhere((customer) => customer.id == id);
      _updateCustomersList();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Soft delete - marks customer as inactive
  Future<bool> softDeleteCustomer(String id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _allCustomers.indexWhere((customer) => customer.id == id);
      if (index != -1) {
        _allCustomers[index] = _allCustomers[index].copyWith(isActive: false);
        _updateCustomersList();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to deactivate customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore customer - reactivates a soft-deleted customer
  Future<bool> restoreCustomer(String id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _allCustomers.indexWhere((customer) => customer.id == id);
      if (index != -1) {
        _allCustomers[index] = _allCustomers[index].copyWith(isActive: true);
        _updateCustomersList();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to restore customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _allCustomers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update customer's last purchase
  Future<void> updateLastPurchase(String customerId, double amount) async {
    final index = _allCustomers.indexWhere((customer) => customer.id == customerId);
    if (index != -1) {
      _allCustomers[index] = _allCustomers[index].copyWith(
        lastPurchase: amount,
        lastPurchaseDate: DateTime.now(),
      );
      _updateCustomersList();
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  Map<String, dynamic> get customerStats {
    final activeCustomers = _allCustomers.where((customer) => customer.isActive).toList();
    final totalCustomers = activeCustomers.length;

    final newThisMonth = activeCustomers
        .where((customer) =>
    DateTime.now().difference(customer.createdAt).inDays <= 30)
        .length;

    final customersWithPurchases = activeCustomers.where((customer) => customer.lastPurchase != null).toList();
    final averagePurchase = customersWithPurchases.isNotEmpty
        ? (customersWithPurchases.fold<double>(0, (sum, customer) => sum + (customer.lastPurchase ?? 0)) / customersWithPurchases.length).toStringAsFixed(0)
        : '0';

    final recentBuyers = activeCustomers
        .where((customer) =>
    customer.lastPurchaseDate != null &&
        DateTime.now().difference(customer.lastPurchaseDate!).inDays <= 30)
        .length;

    return {
      'total': totalCustomers,
      'newThisMonth': newThisMonth,
      'averagePurchase': averagePurchase,
      'recentBuyers': recentBuyers,
      'inactive': _allCustomers.where((customer) => !customer.isActive).length,
    };
  }

  /// Get top customers by purchase amount
  List<Customer> get topCustomers {
    final activeCustomersWithPurchases = _allCustomers
        .where((customer) => customer.isActive && customer.lastPurchase != null)
        .toList();

    activeCustomersWithPurchases.sort((a, b) => (b.lastPurchase ?? 0).compareTo(a.lastPurchase ?? 0));

    return activeCustomersWithPurchases.take(5).toList();
  }

  /// Get recent customers (last 30 days)
  List<Customer> get recentCustomers {
    return _allCustomers
        .where((customer) =>
    customer.isActive &&
        DateTime.now().difference(customer.createdAt).inDays <= 30)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get customers by purchase activity
  Map<String, List<Customer>> get customersByActivity {
    final now = DateTime.now();
    final activeCustomers = <Customer>[];
    final inactiveCustomers = <Customer>[];
    final newCustomers = <Customer>[];

    for (final customer in _allCustomers.where((c) => c.isActive)) {
      final daysSinceCreated = now.difference(customer.createdAt).inDays;
      final daysSinceLastPurchase = customer.lastPurchaseDate != null
          ? now.difference(customer.lastPurchaseDate!).inDays
          : null;

      if (daysSinceCreated <= 30) {
        newCustomers.add(customer);
      } else if (daysSinceLastPurchase != null && daysSinceLastPurchase <= 60) {
        activeCustomers.add(customer);
      } else {
        inactiveCustomers.add(customer);
      }
    }

    return {
      'active': activeCustomers,
      'inactive': inactiveCustomers,
      'new': newCustomers,
    };
  }

  /// Get customer analytics
  Map<String, dynamic> get customerAnalytics {
    final activeCustomers = _allCustomers.where((customer) => customer.isActive).toList();

    final totalRevenue = activeCustomers
        .where((customer) => customer.lastPurchase != null)
        .fold<double>(0, (sum, customer) => sum + (customer.lastPurchase ?? 0));

    final averageOrderValue = activeCustomers.where((customer) => customer.lastPurchase != null).isNotEmpty
        ? totalRevenue / activeCustomers.where((customer) => customer.lastPurchase != null).length
        : 0.0;

    final conversionRate = activeCustomers.isNotEmpty
        ? (activeCustomers.where((customer) => customer.lastPurchase != null).length / activeCustomers.length) * 100
        : 0.0;

    return {
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'conversionRate': conversionRate,
      'totalCustomers': activeCustomers.length,
      'payingCustomers': activeCustomers.where((customer) => customer.lastPurchase != null).length,
      'inactiveCustomers': _allCustomers.where((customer) => !customer.isActive).length,
    };
  }

  /// Filter customers by various criteria
  List<Customer> filterCustomers({
    String? searchTerm,
    double? minPurchase,
    double? maxPurchase,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? hasPurchased,
    bool? includeInactive,
  }) {
    final customersToFilter = (includeInactive ?? false) ? _allCustomers : _allCustomers.where((c) => c.isActive).toList();

    return customersToFilter.where((customer) {
      // Search term filter
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final query = searchTerm.toLowerCase();
        if (!customer.name.toLowerCase().contains(query) &&
            !customer.email.toLowerCase().contains(query) &&
            !customer.phone.toLowerCase().contains(query) &&
            !customer.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Purchase amount filters
      if (minPurchase != null && (customer.lastPurchase ?? 0) < minPurchase) {
        return false;
      }
      if (maxPurchase != null && (customer.lastPurchase ?? 0) > maxPurchase) {
        return false;
      }

      // Creation date filters
      if (createdAfter != null && customer.createdAt.isBefore(createdAfter)) {
        return false;
      }
      if (createdBefore != null && customer.createdAt.isAfter(createdBefore)) {
        return false;
      }

      // Purchase status filter
      if (hasPurchased != null) {
        if (hasPurchased && customer.lastPurchase == null) {
          return false;
        }
        if (!hasPurchased && customer.lastPurchase != null) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Export customer data (returns formatted data for export)
  List<Map<String, dynamic>> exportCustomerData() {
    final customersToExport = _showInactive ? _allCustomers : _allCustomers.where((c) => c.isActive).toList();

    return customersToExport.map((customer) => {
      'ID': customer.id,
      'Name': customer.name,
      'Phone': customer.phone,
      'Email': customer.email,
      'Description': customer.description,
      'Last Purchase': customer.lastPurchase?.toStringAsFixed(2) ?? 'N/A',
      'Last Purchase Date': customer.lastPurchaseDate?.toString().split(' ')[0] ?? 'N/A',
      'Customer Since': customer.createdAt.toString().split(' ')[0],
      'Status': customer.isActive ? 'Active' : 'Inactive',
    }).toList();
  }

  /// Get inactive customers
  List<Customer> get inactiveCustomers {
    return _allCustomers.where((customer) => !customer.isActive).toList();
  }

  /// Get active customers
  List<Customer> get activeCustomers {
    return _allCustomers.where((customer) => customer.isActive).toList();
  }

  /// Bulk operations
  Future<bool> deleteMultipleCustomers(List<String> ids, {bool permanent = true}) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      for (String id in ids) {
        if (permanent) {
          _allCustomers.removeWhere((customer) => customer.id == id);
        } else {
          final index = _allCustomers.indexWhere((customer) => customer.id == id);
          if (index != -1) {
            _allCustomers[index] = _allCustomers[index].copyWith(isActive: false);
          }
        }
      }

      _updateCustomersList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to delete customers: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore multiple customers
  Future<bool> restoreMultipleCustomers(List<String> ids) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      for (String id in ids) {
        final index = _allCustomers.indexWhere((customer) => customer.id == id);
        if (index != -1) {
          _allCustomers[index] = _allCustomers[index].copyWith(isActive: true);
        }
      }

      _updateCustomersList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to restore customers: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Duplicate customer
  Future<bool> duplicateCustomer(String id) async {
    final originalCustomer = getCustomerById(id);
    if (originalCustomer == null) return false;

    return await addCustomer(
      name: '${originalCustomer.name} (Copy)',
      phone: originalCustomer.phone,
      email: 'copy.${originalCustomer.email}',
      description: originalCustomer.description,
    );
  }

  /// Search customers with advanced filters
  Future<void> searchCustomersAdvanced({
    String? query,
    bool? hasOrders,
    DateTime? createdAfter,
    DateTime? createdBefore,
    double? minPurchase,
    double? maxPurchase,
  }) async {
    _searchQuery = query ?? '';

    List<Customer> filteredList = _customers;

    // Apply text search
    if (query != null && query.isNotEmpty) {
      filteredList = filteredList.where((customer) =>
      customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone.toLowerCase().contains(query.toLowerCase()) ||
          customer.email.toLowerCase().contains(query.toLowerCase()) ||
          customer.id.toLowerCase().contains(query.toLowerCase()) ||
          customer.description.toLowerCase().contains(query.toLowerCase())).toList();
    }

    // Apply purchase filter
    if (hasOrders != null) {
      filteredList = filteredList.where((customer) =>
      hasOrders ? customer.lastPurchase != null : customer.lastPurchase == null).toList();
    }

    // Apply date filters
    if (createdAfter != null) {
      filteredList = filteredList.where((customer) =>
          customer.createdAt.isAfter(createdAfter)).toList();
    }

    if (createdBefore != null) {
      filteredList = filteredList.where((customer) =>
          customer.createdAt.isBefore(createdBefore)).toList();
    }

    // Apply purchase amount filters
    if (minPurchase != null) {
      filteredList = filteredList.where((customer) =>
      (customer.lastPurchase ?? 0) >= minPurchase).toList();
    }

    if (maxPurchase != null) {
      filteredList = filteredList.where((customer) =>
      (customer.lastPurchase ?? 0) <= maxPurchase).toList();
    }

    _filteredCustomers = filteredList;
    notifyListeners();
  }

  /// Get customers created in a specific time period
  List<Customer> getCustomersByDateRange(DateTime startDate, DateTime endDate) {
    return _allCustomers.where((customer) =>
    customer.isActive &&
        customer.createdAt.isAfter(startDate) &&
        customer.createdAt.isBefore(endDate)).toList();
  }

  /// Get customers with purchases in a specific time period
  List<Customer> getCustomersByPurchaseDate(DateTime startDate, DateTime endDate) {
    return _allCustomers.where((customer) =>
    customer.isActive &&
        customer.lastPurchaseDate != null &&
        customer.lastPurchaseDate!.isAfter(startDate) &&
        customer.lastPurchaseDate!.isBefore(endDate)).toList();
  }
}