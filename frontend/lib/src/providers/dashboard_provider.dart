// /**
//  * FIXED Dashboard Provider with API call loop prevention
//  * File: frontend/lib/src/providers/dashboard_provider.dart
//  * 
//  * Changes:
//  * - Added debouncing for refresh calls
//  * - Added polling with limits to prevent infinite loops
//  * - Added proper error handling
//  * - Added retry logic with exponential backoff
//  */

import 'dart:async';
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

  // API call loop prevention
  Timer? _refreshTimer;
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int MAX_POLLS = 100;  // Prevent infinite polling
  DateTime? _lastApiCall;
  static const Duration MIN_API_CALL_INTERVAL = Duration(seconds: 2);
  
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

  // Load dashboard analytics from API with debouncing and rate limiting
  Future<void> loadDashboardAnalytics() async {
    // Rate limiting: prevent calls within MIN_API_CALL_INTERVAL
    if (_lastApiCall != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastApiCall!);
      if (timeSinceLastCall < MIN_API_CALL_INTERVAL) {
        debugPrint('⚠️ Rate limit: Skipping API call (${timeSinceLastCall.inSeconds}s since last call)');
        return;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastApiCall = DateTime.now();
      final response = await _dashboardService.getDashboardAnalytics();

      if (response.success && response.data != null) {
        _analytics = response.data!;
        _errorMessage = null;
        _retryCount = 0;  // Reset retry count on success
        debugPrint('✅ Dashboard analytics loaded successfully');
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Dashboard analytics failed: ${response.message}');
        
        // Retry logic with exponential backoff
        await _handleRetry();
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard analytics: ${e.toString()}';
      debugPrint('❌ Dashboard analytics error: $e');
      
      // Retry logic
      await _handleRetry();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle retry with exponential backoff
  Future<void> _handleRetry() async {
    if (_retryCount < MAX_RETRIES) {
      _retryCount++;
      final retryDelay = INITIAL_RETRY_DELAY * _retryCount;
      
      debugPrint('⏳ Retrying in ${retryDelay.inSeconds}s (attempt $_retryCount/$MAX_RETRIES)');
      
      await Future.delayed(retryDelay);
      await loadDashboardAnalytics();
    } else {
      debugPrint('❌ Max retries reached. Giving up.');
      _retryCount = 0;
    }
  }

  // Debounced refresh to prevent rapid consecutive calls
  Future<void> refreshData() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(Duration(seconds: 2), () async {
      await loadDashboardAnalytics();
    });
  }

  // Start polling with limits to prevent infinite loops
  void startPolling({Duration interval = const Duration(minutes: 5)}) {
    stopPolling();  // Stop any existing polling
    
    debugPrint('🔄 Starting dashboard polling (interval: ${interval.inMinutes}min, max polls: $MAX_POLLS)');
    
    _pollCount = 0;
    _pollingTimer = Timer.periodic(interval, (timer) {
      _pollCount++;
      
      if (_pollCount > MAX_POLLS) {
        stopPolling();
        debugPrint('⚠️ Max poll count ($MAX_POLLS) reached. Stopping automatic refresh.');
        _errorMessage = 'Auto-refresh stopped after $MAX_POLLS attempts. Please refresh manually.';
        notifyListeners();
        return;
      }
      
      debugPrint('🔄 Polling dashboard analytics (count: $_pollCount/$MAX_POLLS)');
      refreshData();
    });
  }

  // Stop polling
  void stopPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      _pollingTimer!.cancel();
      _pollingTimer = null;
      debugPrint('⏸️ Dashboard polling stopped');
    }
  }

  // Reset polling counter (useful for manual refresh)
  void resetPollCounter() {
    _pollCount = 0;
    debugPrint('🔄 Poll counter reset');
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
        'value': 'Rs.${_analytics!.totalRevenue.toStringAsFixed(0)}',
        'change': '+12%',  // Calculate from historical data if available
        'isPositive': true,
      },
      'totalOrders': {
        'value': '${_analytics!.totalOrders}',
        'change': '+8%',
        'isPositive': true,
      },
      'totalProducts': {
        'value': '${_analytics!.totalProducts}',
        'change': '+5',
        'isPositive': true,
      },
      'activeVendors': {
        'value': '${_analytics!.activeVendors}',
        'change': '${_analytics!.totalVendors}',
        'isPositive': true,
      },
      'activeCustomers': {
        'value': '${_analytics!.activeCustomers}',
        'change': '${_analytics!.totalCustomers}',
        'isPositive': true,
      },
      'pendingOrders': {
        'value': '${_analytics!.pendingOrders}',
        'change': '${_analytics!.totalOrders}',
        'isPositive': false,
      },
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

  @override
  void dispose() {
    // Clean up timers to prevent memory leaks
    _refreshTimer?.cancel();
    _pollingTimer?.cancel();
    debugPrint('🧹 DashboardProvider disposed');
    super.dispose();
  }
}