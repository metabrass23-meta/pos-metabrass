import 'dart:async';
import 'package:flutter/material.dart';
import '../../src/models/analytics/dashboard_analytics.dart';
import '../../src/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  bool _isSidebarExpanded = true;
  int _selectedMenuIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  DashboardAnalyticsModel? _analytics;

  // API call loop prevention & Polling
  Timer? _refreshTimer;
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int MAX_POLLS = 100;
  DateTime? _lastApiCall;
  static const Duration MIN_API_CALL_INTERVAL = Duration(seconds: 5);

  // Retry logic
  int _retryCount = 0;
  static const int MAX_RETRIES = 3;
  static const Duration INITIAL_RETRY_DELAY = Duration(seconds: 2);

  // Getters
  bool get isSidebarExpanded => _isSidebarExpanded;
  int get selectedMenuIndex => _selectedMenuIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardAnalyticsModel? get analytics => _analytics;
  bool get isPolling => _pollingTimer != null && _pollingTimer!.isActive;

  final List<String> _menuTitles = [
    'Dashboard',
    'Sales',
    'Orders',
    'Purchases',
    'Products',
    'Categories',
    'Customers',
    'Vendors',
    'Labor',
    'Receivables',
    'Payables',
    'Advance Payments',
    'Payments',
    'Expenses',
    'Principal Account',
    'Zakat',
    'Profit & Loss',
    'Tax Management',
    'Returns',
    'Invoices',
    'Receipts',
    'Settings',
  ];

  String get currentPageTitle =>
      (_selectedMenuIndex >= 0 && _selectedMenuIndex < _menuTitles.length)
          ? _menuTitles[_selectedMenuIndex]
          : 'Unknown';

  void toggleSidebar() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }

  void selectMenu(int index) {
    _selectedMenuIndex = index;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadDashboardAnalytics();
    startPolling();
  }

  Future<void> loadDashboardAnalytics({bool silent = false}) async {
    if (_lastApiCall != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastApiCall!);
      if (timeSinceLastCall < MIN_API_CALL_INTERVAL) {
        return;
      }
    }

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _lastApiCall = DateTime.now();
      final response = await _dashboardService.getDashboardAnalytics();

      if (response.success && response.data != null) {
        _analytics = response.data!;
        _errorMessage = null;
        _retryCount = 0;
        debugPrint('✅ Dashboard Data Updated: Revenue=${_analytics!.totalRevenue}');
      } else {
        _errorMessage = response.message;
        if (!silent) await _handleRetry();
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard analytics: ${e.toString()}';
      if (!silent) await _handleRetry();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleRetry() async {
    if (_retryCount < MAX_RETRIES) {
      _retryCount++;
      final retryDelay = INITIAL_RETRY_DELAY * _retryCount;
      await Future.delayed(retryDelay);
      await loadDashboardAnalytics();
    } else {
      _retryCount = 0;
    }
  }

  Future<void> refreshData() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(seconds: 1), () async {
      await loadDashboardAnalytics(silent: true);
    });
  }

  void startPolling({Duration interval = const Duration(minutes: 1)}) {
    stopPolling();
    _pollCount = 0;
    _pollingTimer = Timer.periodic(interval, (timer) {
      _pollCount++;
      if (_pollCount > MAX_POLLS) {
        stopPolling();
        return;
      }
      refreshData();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void resetPollCounter() {
    _pollCount = 0;
  }

  // --- STATS DATA MAPPING ---
  Map<String, dynamic> get dashboardStats {
    if (_analytics == null) {
      return {
        'totalSales': {'value': 'Loading...', 'change': '0%', 'isPositive': true},
        'totalOrders': {'value': '0', 'change': '0%', 'isPositive': true},
        'totalProducts': {'value': '0', 'change': '0%', 'isPositive': true},
        'activeVendors': {'value': '0', 'change': '0', 'isPositive': true},
        'activeCustomers': {'value': '0', 'change': '0', 'isPositive': true},
        'pendingOrders': {'value': '0', 'change': '0', 'isPositive': false},
      };
    }

    // Using real data from _analytics
    // Note: Growth metrics are not currently available in the DashboardAnalyticsModel,
    // so we default 'change' to 0% to prevent errors.
    return {
      'totalSales': {
        'value': 'Rs.${_analytics!.totalRevenue.toStringAsFixed(0)}',
        'change': '0%',
        'isPositive': true,
      },
      'totalOrders': {
        'value': '${_analytics!.totalOrders}',
        'change': '0%',
        'isPositive': true,
      },
      'totalProducts': {
        'value': '${_analytics!.totalProducts}',
        'change': '0',
        'isPositive': true,
      },
      'activeVendors': {
        'value': '${_analytics!.activeVendors}',
        'change': '${_analytics!.totalVendors}', // Showing total as context
        'isPositive': true,
      },
      'activeCustomers': {
        'value': '${_analytics!.activeCustomers}',
        'change': '${_analytics!.totalCustomers}', // Showing total as context
        'isPositive': true,
      },
      'pendingOrders': {
        'value': '${_analytics!.pendingOrders}',
        'change': '0',
        'isPositive': false,
      },
    };
  }

  List<Map<String, dynamic>> get recentOrders {
    if (_analytics == null || _analytics!.recentTransactions.isEmpty) {
      return [];
    }

    return _analytics!.recentTransactions.take(5).map((transaction) {
      return {
        'id': transaction.id,
        'customer': transaction.customer,
        'amount': transaction.amount,
        'status': transaction.status,
        'date': transaction.date,
        'type': transaction.type,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get salesChart {
    if (_analytics == null || _analytics!.salesTrend.isEmpty) {
      return [];
    }

    return _analytics!.salesTrend.map((trend) {
      return {
        'month': trend.month,
        'sales': trend.sales,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get quickActions => [
    {
      'title': 'New Sale',
      'subtitle': 'Create new order',
      'icon': Icons.add_shopping_cart_rounded,
      'color': Colors.green,
      'index': 1,
    },
    {
      'title': 'Add Product',
      'subtitle': 'Register new item',
      'icon': Icons.inventory_2_rounded,
      'color': Colors.blue,
      'index': 4,
    },
  ];

  void handleQuickAction(int pageIndex) {
    selectMenu(pageIndex);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }
}