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

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.description,
    this.lastPurchase,
    this.lastPurchaseDate,
    required this.createdAt,
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
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Customer> get customers => _filteredCustomers;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    _initializeCustomers();
  }

  void _initializeCustomers() {
    _customers = [
      Customer(
        id: 'CUS001',
        name: 'Aisha Khan',
        phone: '+923001234567',
        email: 'aisha.khan@email.com',
        description: 'Premium customer, prefers bridal wear',
        lastPurchase: 85000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
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
      ),
    ];

    _filteredCustomers = List.from(_customers);
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

  Future<void> addCustomer({
    required String name,
    required String phone,
    required String email,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newCustomer = Customer(
      id: 'CUS${(_customers.length + 1).toString().padLeft(3, '0')}',
      name: name,
      phone: phone,
      email: email,
      description: description,
      lastPurchase: null,
      lastPurchaseDate: null,
      createdAt: DateTime.now(),
    );

    _customers.add(newCustomer);
    searchCustomers(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _customers.indexWhere((customer) => customer.id == id);
    if (index != -1) {
      _customers[index] = _customers[index].copyWith(
        name: name,
        phone: phone,
        email: email,
        description: description,
      );
      searchCustomers(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCustomer(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _customers.removeWhere((customer) => customer.id == id);
    searchCustomers(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update customer's last purchase
  Future<void> updateLastPurchase(String customerId, double amount) async {
    final index = _customers.indexWhere((customer) => customer.id == customerId);
    if (index != -1) {
      _customers[index] = _customers[index].copyWith(
        lastPurchase: amount,
        lastPurchaseDate: DateTime.now(),
      );
      searchCustomers(_searchQuery);
      notifyListeners();
    }
  }

  Map<String, dynamic> get customerStats {
    final totalCustomers = _customers.length;
    final newThisMonth = _customers
        .where((customer) =>
    DateTime.now().difference(customer.createdAt).inDays <= 30)
        .length;

    final customersWithPurchases = _customers.where((customer) => customer.lastPurchase != null).toList();
    final averagePurchase = customersWithPurchases.isNotEmpty
        ? (customersWithPurchases.fold<double>(0, (sum, customer) => sum + (customer.lastPurchase ?? 0)) / customersWithPurchases.length).toStringAsFixed(0)
        : '0';

    final recentBuyers = _customers
        .where((customer) =>
    customer.lastPurchaseDate != null &&
        DateTime.now().difference(customer.lastPurchaseDate!).inDays <= 30)
        .length;

    return {
      'total': totalCustomers,
      'newThisMonth': newThisMonth,
      'averagePurchase': averagePurchase,
      'recentBuyers': recentBuyers,
    };
  }

  // Get top customers by purchase amount
  List<Customer> get topCustomers {
    final customersWithPurchases = _customers
        .where((customer) => customer.lastPurchase != null)
        .toList();

    customersWithPurchases.sort((a, b) => (b.lastPurchase ?? 0).compareTo(a.lastPurchase ?? 0));

    return customersWithPurchases.take(5).toList();
  }

  // Get recent customers (last 30 days)
  List<Customer> get recentCustomers {
    return _customers
        .where((customer) =>
    DateTime.now().difference(customer.createdAt).inDays <= 30)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get customers by purchase activity
  Map<String, List<Customer>> get customersByActivity {
    final now = DateTime.now();
    final activeCustomers = <Customer>[];
    final inactiveCustomers = <Customer>[];
    final newCustomers = <Customer>[];

    for (final customer in _customers) {
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

  // Get customer analytics
  Map<String, dynamic> get customerAnalytics {
    final totalRevenue = _customers
        .where((customer) => customer.lastPurchase != null)
        .fold<double>(0, (sum, customer) => sum + (customer.lastPurchase ?? 0));

    final averageOrderValue = _customers.where((customer) => customer.lastPurchase != null).isNotEmpty
        ? totalRevenue / _customers.where((customer) => customer.lastPurchase != null).length
        : 0.0;

    final conversionRate = _customers.isNotEmpty
        ? (_customers.where((customer) => customer.lastPurchase != null).length / _customers.length) * 100
        : 0.0;

    return {
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'conversionRate': conversionRate,
      'totalCustomers': _customers.length,
      'payingCustomers': _customers.where((customer) => customer.lastPurchase != null).length,
    };
  }

  // Filter customers by various criteria
  List<Customer> filterCustomers({
    String? searchTerm,
    double? minPurchase,
    double? maxPurchase,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? hasPurchased,
  }) {
    return _customers.where((customer) {
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

  // Export customer data (returns formatted data for export)
  List<Map<String, dynamic>> exportCustomerData() {
    return _customers.map((customer) => {
      'ID': customer.id,
      'Name': customer.name,
      'Phone': customer.phone,
      'Email': customer.email,
      'Description': customer.description,
      'Last Purchase': customer.lastPurchase?.toStringAsFixed(2) ?? 'N/A',
      'Last Purchase Date': customer.lastPurchaseDate?.toString().split(' ')[0] ?? 'N/A',
      'Customer Since': customer.createdAt.toString().split(' ')[0],
    }).toList();
  }
}