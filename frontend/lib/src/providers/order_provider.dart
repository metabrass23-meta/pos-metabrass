import 'package:flutter/material.dart';

enum OrderStatus { pending, inProgress, completed, cancelled, delivered }

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final double advancePayment;
  final double totalAmount;
  final double remainingAmount;
  final DateTime dateOrdered;
  final DateTime expectedDeliveryDate;
  final String description;
  final String product;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.advancePayment,
    required this.totalAmount,
    required this.remainingAmount,
    required this.dateOrdered,
    required this.expectedDeliveryDate,
    required this.description,
    required this.product,
    required this.status,
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    double? advancePayment,
    double? totalAmount,
    double? remainingAmount,
    DateTime? dateOrdered,
    DateTime? expectedDeliveryDate,
    String? description,
    String? product,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      advancePayment: advancePayment ?? this.advancePayment,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dateOrdered: dateOrdered ?? this.dateOrdered,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      description: description ?? this.description,
      product: product ?? this.product,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.delivered:
        return Colors.purple;
    }
  }

  bool get isOverdue {
    return DateTime.now().isAfter(expectedDeliveryDate) &&
        status != OrderStatus.completed &&
        status != OrderStatus.delivered &&
        status != OrderStatus.cancelled;
  }

  int get daysUntilDelivery {
    return expectedDeliveryDate.difference(DateTime.now()).inDays;
  }
}

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Order> get orders => _filteredOrders;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _initializeOrders();
  }

  void _initializeOrders() {
    final now = DateTime.now();
    _orders = [
      Order(
        id: 'ORD001',
        customerId: 'CUS001',
        customerName: 'Aisha Khan',
        customerPhone: '+923001234567',
        customerEmail: 'aisha.khan@email.com',
        advancePayment: 30000.0,
        totalAmount: 85000.0,
        remainingAmount: 55000.0,
        dateOrdered: now.subtract(const Duration(days: 5)),
        expectedDeliveryDate: now.add(const Duration(days: 15)),
        description: 'Custom bridal dress with heavy embroidery work',
        product: 'Bridal Dress - Red & Gold',
        status: OrderStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Order(
        id: 'ORD002',
        customerId: 'CUS002',
        customerName: 'Fatima Ali',
        customerPhone: '+923009876543',
        customerEmail: 'fatima.ali@email.com',
        advancePayment: 20000.0,
        totalAmount: 45000.0,
        remainingAmount: 25000.0,
        dateOrdered: now.subtract(const Duration(days: 8)),
        expectedDeliveryDate: now.add(const Duration(days: 7)),
        description: 'Party wear lehenga with mirror work',
        product: 'Party Lehenga - Blue',
        status: OrderStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Order(
        id: 'ORD003',
        customerId: 'CUS003',
        customerName: 'Sarah Ahmed',
        customerPhone: '+923005555555',
        customerEmail: 'sarah.ahmed@email.com',
        advancePayment: 25000.0,
        totalAmount: 25000.0,
        remainingAmount: 0.0,
        dateOrdered: now.subtract(const Duration(days: 20)),
        expectedDeliveryDate: now.subtract(const Duration(days: 5)),
        description: 'Formal party dress for engagement',
        product: 'Formal Party Dress - Pink',
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Order(
        id: 'ORD004',
        customerId: 'CUS004',
        customerName: 'Zara Sheikh',
        customerPhone: '+923007777777',
        customerEmail: 'zara.sheikh@email.com',
        advancePayment: 50000.0,
        totalAmount: 120000.0,
        remainingAmount: 70000.0,
        dateOrdered: now.subtract(const Duration(days: 2)),
        expectedDeliveryDate: now.add(const Duration(days: 25)),
        description: 'Complete wedding collection with accessories',
        product: 'Wedding Collection - Maroon & Gold',
        status: OrderStatus.pending,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Order(
        id: 'ORD005',
        customerId: 'CUS006',
        customerName: 'Hina Malik',
        customerPhone: '+923003333333',
        customerEmail: 'hina.malik@email.com',
        advancePayment: 40000.0,
        totalAmount: 95000.0,
        remainingAmount: 55000.0,
        dateOrdered: now.subtract(const Duration(days: 12)),
        expectedDeliveryDate: now.add(const Duration(days: 3)),
        description: 'Corporate event dresses - bulk order',
        product: 'Corporate Formal Wear Set',
        status: OrderStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Order(
        id: 'ORD006',
        customerId: 'CUS001',
        customerName: 'Aisha Khan',
        customerPhone: '+923001234567',
        customerEmail: 'aisha.khan@email.com',
        advancePayment: 15000.0,
        totalAmount: 35000.0,
        remainingAmount: 20000.0,
        dateOrdered: now.subtract(const Duration(days: 30)),
        expectedDeliveryDate: now.subtract(const Duration(days: 10)),
        description: 'Casual summer dress collection',
        product: 'Summer Dress Collection',
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Order(
        id: 'ORD007',
        customerId: 'CUS002',
        customerName: 'Fatima Ali',
        customerPhone: '+923009876543',
        customerEmail: 'fatima.ali@email.com',
        advancePayment: 10000.0,
        totalAmount: 28000.0,
        remainingAmount: 18000.0,
        dateOrdered: now.subtract(const Duration(days: 25)),
        expectedDeliveryDate: now.subtract(const Duration(days: 2)),
        description: 'Traditional embroidered shirt',
        product: 'Embroidered Shirt - Green',
        status: OrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
    ];

    _filteredOrders = List.from(_orders);
  }

  void searchOrders(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredOrders = List.from(_orders);
    } else {
      _filteredOrders = _orders
          .where((order) =>
      order.id.toLowerCase().contains(query.toLowerCase()) ||
          order.customerName.toLowerCase().contains(query.toLowerCase()) ||
          order.customerPhone.toLowerCase().contains(query.toLowerCase()) ||
          order.customerEmail.toLowerCase().contains(query.toLowerCase()) ||
          order.product.toLowerCase().contains(query.toLowerCase()) ||
          order.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required double advancePayment,
    required double totalAmount,
    required DateTime expectedDeliveryDate,
    required String description,
    required String product,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final remainingAmount = totalAmount - advancePayment;
    final newOrder = Order(
      id: 'ORD${(_orders.length + 1).toString().padLeft(3, '0')}',
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      advancePayment: advancePayment,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      dateOrdered: DateTime.now(),
      expectedDeliveryDate: expectedDeliveryDate,
      description: description,
      product: product,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    _orders.add(newOrder);
    searchOrders(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrder({
    required String id,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required double advancePayment,
    required double totalAmount,
    required DateTime expectedDeliveryDate,
    required String description,
    required String product,
    OrderStatus? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _orders.indexWhere((order) => order.id == id);
    if (index != -1) {
      final remainingAmount = totalAmount - advancePayment;
      _orders[index] = _orders[index].copyWith(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        advancePayment: advancePayment,
        totalAmount: totalAmount,
        remainingAmount: remainingAmount,
        expectedDeliveryDate: expectedDeliveryDate,
        description: description,
        product: product,
        status: status,
      );
      searchOrders(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteOrder(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _orders.removeWhere((order) => order.id == id);
    searchOrders(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      searchOrders(_searchQuery);
      notifyListeners();
    }
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Order> getOrdersByCustomerId(String customerId) {
    return _orders.where((order) => order.customerId == customerId).toList();
  }

  Map<String, dynamic> get orderStats {
    final totalOrders = _orders.length;
    final pendingOrders = _orders.where((order) => order.status == OrderStatus.pending).length;
    final inProgressOrders = _orders.where((order) => order.status == OrderStatus.inProgress).length;
    final completedOrders = _orders.where((order) =>
    order.status == OrderStatus.completed || order.status == OrderStatus.delivered).length;
    final cancelledOrders = _orders.where((order) => order.status == OrderStatus.cancelled).length;

    final totalRevenue = _orders
        .where((order) => order.status == OrderStatus.completed || order.status == OrderStatus.delivered)
        .fold<double>(0, (sum, order) => sum + order.totalAmount);

    final totalAdvances = _orders.fold<double>(0, (sum, order) => sum + order.advancePayment);
    final totalRemaining = _orders.fold<double>(0, (sum, order) => sum + order.remainingAmount);

    final overdueOrders = _orders.where((order) => order.isOverdue).length;

    return {
      'total': totalOrders,
      'pending': pendingOrders,
      'inProgress': inProgressOrders,
      'completed': completedOrders,
      'cancelled': cancelledOrders,
      'totalRevenue': totalRevenue.toStringAsFixed(0),
      'totalAdvances': totalAdvances.toStringAsFixed(0),
      'totalRemaining': totalRemaining.toStringAsFixed(0),
      'overdue': overdueOrders,
    };
  }

  List<Order> get pendingOrders => _orders.where((order) => order.status == OrderStatus.pending).toList();
  List<Order> get inProgressOrders => _orders.where((order) => order.status == OrderStatus.inProgress).toList();
  List<Order> get completedOrders => _orders.where((order) =>
  order.status == OrderStatus.completed || order.status == OrderStatus.delivered).toList();
  List<Order> get overdueOrders => _orders.where((order) => order.isOverdue).toList();

  List<Order> get recentOrders {
    final recent = List<Order>.from(_orders);
    recent.sort((a, b) => b.dateOrdered.compareTo(a.dateOrdered));
    return recent.take(10).toList();
  }

  List<Order> get upcomingDeliveries {
    final upcoming = _orders
        .where((order) =>
    order.status != OrderStatus.completed &&
        order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled)
        .toList();
    upcoming.sort((a, b) => a.expectedDeliveryDate.compareTo(b.expectedDeliveryDate));
    return upcoming.take(5).toList();
  }

  Map<String, List<Order>> get ordersByStatus => {
    'pending': pendingOrders,
    'inProgress': inProgressOrders,
    'completed': completedOrders,
    'overdue': overdueOrders,
  };

  Map<String, dynamic> get orderAnalytics {
    final averageOrderValue = _orders.isNotEmpty
        ? _orders.fold<double>(0, (sum, order) => sum + order.totalAmount) / _orders.length
        : 0.0;

    final averageAdvancePercentage = _orders.isNotEmpty
        ? _orders.fold<double>(0, (sum, order) => sum + (order.advancePayment / order.totalAmount * 100)) / _orders.length
        : 0.0;

    final completionRate = _orders.isNotEmpty
        ? (completedOrders.length / _orders.length * 100)
        : 0.0;

    final overdueRate = _orders.isNotEmpty
        ? (overdueOrders.length / _orders.length * 100)
        : 0.0;

    return {
      'averageOrderValue': averageOrderValue,
      'averageAdvancePercentage': averageAdvancePercentage,
      'completionRate': completionRate,
      'overdueRate': overdueRate,
      'totalOrderValue': _orders.fold<double>(0, (sum, order) => sum + order.totalAmount),
      'pendingOrderValue': pendingOrders.fold<double>(0, (sum, order) => sum + order.totalAmount),
    };
  }

  List<Map<String, dynamic>> get monthlyOrderStats {
    final Map<int, List<Order>> ordersByMonth = {};

    for (final order in _orders) {
      final month = order.dateOrdered.month;
      ordersByMonth[month] = ordersByMonth[month] ?? [];
      ordersByMonth[month]!.add(order);
    }

    return ordersByMonth.entries.map((entry) {
      final monthOrders = entry.value;
      return {
        'month': entry.key,
        'count': monthOrders.length,
        'revenue': monthOrders.fold<double>(0, (sum, order) => sum + order.totalAmount),
        'completed': monthOrders.where((order) =>
        order.status == OrderStatus.completed || order.status == OrderStatus.delivered).length,
      };
    }).toList();
  }

  List<Order> filterOrders({
    OrderStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    String? customerId,
    bool? isOverdue,
  }) {
    return _orders.where((order) {
      if (status != null && order.status != status) return false;
      if (fromDate != null && order.dateOrdered.isBefore(fromDate)) return false;
      if (toDate != null && order.dateOrdered.isAfter(toDate)) return false;
      if (minAmount != null && order.totalAmount < minAmount) return false;
      if (maxAmount != null && order.totalAmount > maxAmount) return false;
      if (customerId != null && order.customerId != customerId) return false;
      if (isOverdue != null && order.isOverdue != isOverdue) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> exportOrderData() {
    return _orders.map((order) => {
      'Order ID': order.id,
      'Customer Name': order.customerName,
      'Customer Phone': order.customerPhone,
      'Customer Email': order.customerEmail,
      'Product': order.product,
      'Total Amount': order.totalAmount.toStringAsFixed(2),
      'Advance Payment': order.advancePayment.toStringAsFixed(2),
      'Remaining Amount': order.remainingAmount.toStringAsFixed(2),
      'Date Ordered': order.dateOrdered.toString().split(' ')[0],
      'Expected Delivery': order.expectedDeliveryDate.toString().split(' ')[0],
      'Status': order.statusText,
      'Description': order.description,
      'Days Until Delivery': order.daysUntilDelivery.toString(),
      'Is Overdue': order.isOverdue ? 'Yes' : 'No',
    }).toList();
  }

  double getTotalRevenueByCustomer(String customerId) {
    return _orders
        .where((order) => order.customerId == customerId)
        .fold<double>(0, (sum, order) => sum + order.totalAmount);
  }

  int getOrderCountByCustomer(String customerId) {
    return _orders.where((order) => order.customerId == customerId).length;
  }

  List<Order> getTopOrdersByValue({int limit = 5}) {
    final sortedOrders = List<Order>.from(_orders);
    sortedOrders.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return sortedOrders.take(limit).toList();
  }

  Future<void> addPayment(String orderId, double amount) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      final newAdvancePayment = order.advancePayment + amount;
      final newRemainingAmount = order.totalAmount - newAdvancePayment;

      _orders[index] = order.copyWith(
        advancePayment: newAdvancePayment,
        remainingAmount: newRemainingAmount,
      );

      // If fully paid, mark as completed
      if (newRemainingAmount <= 0) {
        _orders[index] = _orders[index].copyWith(status: OrderStatus.completed);
      }

      searchOrders(_searchQuery);
      notifyListeners();
    }
  }

  // Get orders that need attention (overdue or due soon)
  List<Order> get ordersNeedingAttention {
    final now = DateTime.now();
    return _orders.where((order) {
      if (order.isOverdue) return true;
      if (order.status == OrderStatus.pending || order.status == OrderStatus.inProgress) {
        final daysUntilDelivery = order.expectedDeliveryDate.difference(now).inDays;
        return daysUntilDelivery <= 3; // Due within 3 days
      }
      return false;
    }).toList();
  }

  // Get financial summary
  Map<String, dynamic> get financialSummary {
    final totalOrderValue = _orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final totalAdvancesReceived = _orders.fold<double>(0, (sum, order) => sum + order.advancePayment);
    final totalRemainingDue = _orders.fold<double>(0, (sum, order) => sum + order.remainingAmount);
    final completedOrderValue = completedOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);

    return {
      'totalOrderValue': totalOrderValue,
      'totalAdvancesReceived': totalAdvancesReceived,
      'totalRemainingDue': totalRemainingDue,
      'completedOrderValue': completedOrderValue,
      'cashFlowPercentage': totalOrderValue > 0 ? (totalAdvancesReceived / totalOrderValue * 100) : 0,
    };
  }

  // Get customer order summary
  Map<String, dynamic> getCustomerOrderSummary(String customerId) {
    final customerOrders = getOrdersByCustomerId(customerId);
    final totalOrders = customerOrders.length;
    final totalValue = customerOrders.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final totalPaid = customerOrders.fold<double>(0, (sum, order) => sum + order.advancePayment);
    final totalRemaining = customerOrders.fold<double>(0, (sum, order) => sum + order.remainingAmount);

    return {
      'totalOrders': totalOrders,
      'totalValue': totalValue,
      'totalPaid': totalPaid,
      'totalRemaining': totalRemaining,
      'averageOrderValue': totalOrders > 0 ? totalValue / totalOrders : 0,
      'lastOrderDate': customerOrders.isNotEmpty
          ? customerOrders.map((o) => o.dateOrdered).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }
}