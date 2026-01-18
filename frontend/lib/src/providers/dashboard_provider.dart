import 'package:flutter/material.dart';
import 'package:frontend/src/models/analytics/dashboard_analytics.dart';
import 'package:frontend/src/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  bool _isSidebarExpanded = true;
  int _selectedMenuIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  DashboardAnalyticsModel? _analytics;

  bool get isSidebarExpanded => _isSidebarExpanded;
  int get selectedMenuIndex => _selectedMenuIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardAnalyticsModel? get analytics => _analytics;

  final List<String> _menuTitles = [
    'Dashboard',
    'Categories',
    'Products',
    'Labor',
    'Vendors',
    'Customers',
    'Advance',
    'Payment',
    'Sales',
    'Expenses',
    'Stock',
    'Reports',
    'Settings',
  ];

  String get currentPageTitle => _menuTitles[_selectedMenuIndex];

  void toggleSidebar() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }

  void selectMenu(int index) {
    _selectedMenuIndex = index;
    notifyListeners();
  }

  // Initialize dashboard with real data
  Future<void> initialize() async {
    await loadDashboardAnalytics();
  }

  // Load dashboard analytics from API
  Future<void> loadDashboardAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dashboardService.getDashboardAnalytics();

      if (response.success && response.data != null) {
        _analytics = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard analytics: ${e.toString()}';
      debugPrint('Dashboard analytics error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dashboard Statistics - Now using real data or fallback
  Map<String, dynamic> get dashboardStats {
    if (_analytics == null) {
      // Return default/loading state
      return {
        'totalSales': {
          'value': 'Loading...',
          'change': '0%',
          'isPositive': true,
        },
        'totalOrders': {'value': '0', 'change': '0%', 'isPositive': true},
        'totalProducts': {'value': '0', 'change': '0%', 'isPositive': true},
        'activeVendors': {'value': '0', 'change': '0', 'isPositive': true},
        'activeCustomers': {'value': '0', 'change': '0', 'isPositive': true},
        'pendingOrders': {'value': '0', 'change': '0%', 'isPositive': false},
        'pendingReturns': {'value': '0', 'change': '0', 'isPositive': false},
      };
    }

    return {
      'totalSales': {
        'value': 'Rs. ${_analytics!.totalSales.toStringAsFixed(0)}',
        'change': '+${_analytics!.profitMargin.toStringAsFixed(1)}%',
        'isPositive': _analytics!.profitMargin > 0,
      },
      'totalOrders': {
        'value': _analytics!.totalOrders.toString(),
        'change': '+${_analytics!.recentOrdersCount}',
        'isPositive': _analytics!.recentOrdersCount > 0,
      },
      'totalProducts': {
        'value': _analytics!.totalProducts.toString(),
        'change': '${_analytics!.lowStockProducts} low stock',
        'isPositive': _analytics!.lowStockProducts < 10,
      },
      'activeVendors': {
        'value': _analytics!.activeVendors.toString(),
        'change': '${_analytics!.totalVendors} total',
        'isPositive': true,
      },
      'activeCustomers': {
        'value': _analytics!.activeCustomers.toString(),
        'change': '${_analytics!.totalCustomers} total',
        'isPositive': true,
      },
      'pendingOrders': {
        'value': _analytics!.pendingOrders.toString(),
        'change': '${((_analytics!.pendingOrders / _analytics!.totalOrders) * 100).toStringAsFixed(1)}%',
        'isPositive': _analytics!.pendingOrders < 5,
      },
      'lowStockProducts': {
        'value': _analytics!.lowStockProducts.toString(),
        'change': '${((_analytics!.lowStockProducts / _analytics!.totalProducts) * 100).toStringAsFixed(1)}%',
        'isPositive': _analytics!.lowStockProducts < 10,
      },
    };
  }

  // Recent Orders from API or mock data
  List<Map<String, dynamic>> get recentOrders {
    if (_analytics == null || _analytics!.recentTransactions.isEmpty) {
      return [
        {
          'id': '#MF001',
          'customer': 'Loading...',
          'type': 'Please wait',
          'amount': 'Rs. 0',
          'status': 'Pending',
          'date': 'Today',
        },
      ];
    }

    return _analytics!.recentTransactions.take(10).map((transaction) {
      return {
        'id': transaction.id,
        'customer': transaction.customer,
        'type': transaction.type,
        'amount': 'Rs. ${transaction.amount.toStringAsFixed(0)}',
        'status': transaction.status,
        'date': _formatDate(transaction.date),
      };
    }).toList();
  }

  // Sales Chart from API
  List<Map<String, double>> get salesChart {
    if (_analytics == null || _analytics!.salesTrend.isEmpty) {
      return [
        {'month': 1, 'sales': 0},
        {'month': 2, 'sales': 0},
        {'month': 3, 'sales': 0},
        {'month': 4, 'sales': 0},
        {'month': 5, 'sales': 0},
        {'month': 6, 'sales': 0},
      ];
    }

    return _analytics!.salesTrend.asMap().entries.map((entry) {
      return {
        'month': (entry.key + 1).toDouble(),
        'sales': entry.value.sales,
      };
    }).toList();
  }

  // Top Products from API
  List<Map<String, dynamic>> get topProducts {
    if (_analytics == null || _analytics!.topSellingProducts.isEmpty) {
      return [];
    }

    return _analytics!.topSellingProducts.map((product) {
      return {
        'name': product.name,
        'quantity': product.quantity,
        'revenue': 'Rs. ${product.revenue.toStringAsFixed(0)}',
      };
    }).toList();
  }

  // Vendor-related data (keep mock for now)
  List<Map<String, dynamic>> get topVendors => [
        {
          'name': 'Ali Textiles & Co.',
          'city': 'Karachi',
          'revenue': 'Rs. 2,50,000',
          'orders': 45,
        },
        {
          'name': 'Khan Fabrics',
          'city': 'Lahore',
          'revenue': 'Rs. 1,85,000',
          'orders': 38,
        },
      ];

  // Customer-related data (keep mock for now)
  List<Map<String, dynamic>> get topCustomers => [
        {
          'name': 'Zara Sheikh',
          'type': 'VIP Customer',
          'totalSpent': 'Rs. 1,20,000',
          'orders': 8,
        },
        {
          'name': 'Aisha Khan',
          'type': 'Premium Customer',
          'totalSpent': 'Rs. 85,000',
          'orders': 5,
        },
      ];

  // Recent activities
  List<Map<String, dynamic>> get recentActivities {
    if (_analytics == null || _analytics!.recentTransactions.isEmpty) {
      return [];
    }

    return _analytics!.recentTransactions.take(5).map((transaction) {
      return {
        'title': 'New ${transaction.type.toLowerCase()}: ${transaction.customer}',
        'subtitle': 'Rs. ${transaction.amount.toStringAsFixed(0)}',
        'time': _formatDate(transaction.date),
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.green,
      };
    }).toList();
  }

  // Performance metrics with real data
  Map<String, dynamic> get performanceMetrics {
    if (_analytics == null) {
      return {
        'revenueTarget': {
          'label': 'Revenue Target',
          'value': 'Rs. 0',
          'percentage': '0%',
          'color': Colors.blue,
        },
      };
    }

    return {
      'revenueTarget': {
        'label': 'Revenue Target',
        'value': 'Rs. ${_analytics!.totalRevenue.toStringAsFixed(0)}',
        'percentage': '${_analytics!.profitMargin.toStringAsFixed(1)}%',
        'color': Colors.blue,
      },
      'customerGrowth': {
        'label': 'Customer Growth',
        'value': _analytics!.totalCustomers.toString(),
        'percentage': '${((_analytics!.activeCustomers / _analytics!.totalCustomers) * 100).toStringAsFixed(0)}%',
        'color': Colors.indigo,
      },
      'vendorPartnerships': {
        'label': 'Vendor Partnerships',
        'value': _analytics!.totalVendors.toString(),
        'percentage': '${((_analytics!.activeVendors / _analytics!.totalVendors) * 100).toStringAsFixed(0)}%',
        'color': Colors.teal,
      },
      'profitMargin': {
        'label': 'Profit Margin',
        'value': '${_analytics!.profitMargin.toStringAsFixed(1)}%',
        'percentage': '${_analytics!.profitMargin.toStringAsFixed(0)}%',
        'color': Colors.orange,
      },
    };
  }

  // Customer statistics with real data
  Map<String, dynamic> get customerStats {
    if (_analytics == null) {
      return {
        'totalCustomers': 0,
        'activeCustomers': 0,
        'newThisMonth': 0,
      };
    }

    return {
      'totalCustomers': _analytics!.totalCustomers,
      'activeCustomers': _analytics!.activeCustomers,
      'totalRevenue': 'Rs. ${_analytics!.totalRevenue.toStringAsFixed(0)}',
    };
  }

  // Vendor statistics with real data
  Map<String, dynamic> get vendorStats {
    if (_analytics == null) {
      return {
        'totalVendors': 0,
        'activeVendors': 0,
      };
    }

    return {
      'totalVendors': _analytics!.totalVendors,
      'activeVendors': _analytics!.activeVendors,
    };
  }

  // Quick actions for dashboard
  List<Map<String, dynamic>> get quickActions => [
        {
          'title': 'New Sale',
          'subtitle': 'Create new order',
          'icon': Icons.add_shopping_cart_rounded,
          'color': Colors.green,
          'index': 8,
        },
        {
          'title': 'Add Product',
          'subtitle': 'Register new item',
          'icon': Icons.inventory_2_rounded,
          'color': Colors.blue,
          'index': 2,
        },
      ];

  // Handle quick actions
  void handleQuickAction(int pageIndex) {
    selectMenu(pageIndex);
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    await loadDashboardAnalytics();
  }

  // Helper method to format dates
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return isoDate;
    }
  }
}