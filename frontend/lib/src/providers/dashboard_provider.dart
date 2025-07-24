import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isSidebarExpanded = true;
  int _selectedMenuIndex = 0;

  bool get isSidebarExpanded => _isSidebarExpanded;
  int get selectedMenuIndex => _selectedMenuIndex;

  final List<String> _menuTitles = [
    'Dashboard',
    'Categories',
    'Products',
    'Labor',
    'Vendors', // Added Vendors to menu titles
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

  // Dashboard Statistics - Updated to include Active Vendors
  Map<String, dynamic> get dashboardStats => {
    'totalSales': {
      'value': '₨ 2,45,000',
      'change': '+12.5%',
      'isPositive': true,
    },
    'totalOrders': {
      'value': '1,247',
      'change': '+8.2%',
      'isPositive': true,
    },
    'totalProducts': {
      'value': '432',
      'change': '+5.1%',
      'isPositive': true,
    },
    'activeVendors': {
      'value': '8',
      'change': '+2',
      'isPositive': true,
    },
    'pendingOrders': {
      'value': '23',
      'change': '-2.3%',
      'isPositive': false,
    },
  };

  List<Map<String, dynamic>> get recentOrders => [
    {
      'id': '#MF001',
      'customer': 'Aisha Khan',
      'type': 'Bridal Dress',
      'amount': '₨ 85,000',
      'status': 'In Progress',
      'date': 'Today',
    },
    {
      'id': '#MF002',
      'customer': 'Fatima Ali',
      'type': 'Groom Sherwani',
      'amount': '₨ 45,000',
      'status': 'Completed',
      'date': 'Yesterday',
    },
    {
      'id': '#MF003',
      'customer': 'Sarah Ahmed',
      'type': 'Party Dress',
      'amount': '₨ 25,000',
      'status': 'Pending',
      'date': '2 days ago',
    },
    {
      'id': '#MF004',
      'customer': 'Zara Sheikh',
      'type': 'Wedding Lehenga',
      'amount': '₨ 120,000',
      'status': 'In Progress',
      'date': '3 days ago',
    },
  ];

  List<Map<String, double>> get salesChart => [
    {'month': 1, 'sales': 180000},
    {'month': 2, 'sales': 195000},
    {'month': 3, 'sales': 220000},
    {'month': 4, 'sales': 245000},
    {'month': 5, 'sales': 210000},
    {'month': 6, 'sales': 275000},
  ];

  // Vendor-related data for dashboard
  List<Map<String, dynamic>> get topVendors => [
    {
      'name': 'Ali Textiles & Co.',
      'city': 'Karachi',
      'revenue': '₨ 2,50,000',
      'orders': 45,
    },
    {
      'name': 'Khan Fabrics',
      'city': 'Lahore',
      'revenue': '₨ 1,85,000',
      'orders': 38,
    },
    {
      'name': 'Hassan Brothers Trading',
      'city': 'Karachi',
      'revenue': '₨ 1,45,000',
      'orders': 32,
    },
    {
      'name': 'Sheikh Embroidery Works',
      'city': 'Islamabad',
      'revenue': '₨ 98,000',
      'orders': 25,
    },
  ];

  // Recent activities including vendor activities
  List<Map<String, dynamic>> get recentActivities => [
    {
      'title': 'New vendor registered: Ali Textiles',
      'subtitle': 'Muhammad Ali - Fabric Supplier',
      'time': '30 minutes ago',
      'icon': Icons.store_rounded,
      'color': Colors.teal,
    },
    {
      'title': 'New order received from Aisha Khan',
      'subtitle': 'Bridal Dress - ₨ 85,000',
      'time': '2 hours ago',
      'icon': Icons.shopping_bag_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Payment completed for order #MF002',
      'subtitle': 'Fatima Ali - ₨ 45,000',
      'time': '3 hours ago',
      'icon': Icons.payment_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Vendor delivery received',
      'subtitle': 'Khan Fabrics - Silk Materials',
      'time': '5 hours ago',
      'icon': Icons.local_shipping_rounded,
      'color': Colors.purple,
    },
  ];

  // Performance metrics with vendor data
  Map<String, dynamic> get performanceMetrics => {
    'revenueTarget': {
      'label': 'Revenue Target',
      'value': '₨ 3,00,000',
      'percentage': '82%',
      'color': Colors.blue,
    },
    'ordersTarget': {
      'label': 'Orders Target',
      'value': '1,500',
      'percentage': '83%',
      'color': Colors.green,
    },
    'vendorPartnerships': {
      'label': 'Vendor Partnerships',
      'value': '25',
      'percentage': '88%',
      'color': Colors.teal,
    },
    'conversionRate': {
      'label': 'Conversion Rate',
      'value': '65%',
      'percentage': '92%',
      'color': Colors.orange,
    },
  };

  // Vendor statistics summary
  Map<String, dynamic> get vendorStats => {
    'totalVendors': 8,
    'activeVendors': 8,
    'newThisMonth': 2,
    'totalRevenue': '₨ 6,78,000',
    'averageOrderValue': '₨ 35,000',
    'topPerformingCity': 'Karachi',
  };

  // Quick actions for dashboard
  List<Map<String, dynamic>> get quickActions => [
    {
      'title': 'New Sale',
      'subtitle': 'Create new order',
      'icon': Icons.add_shopping_cart_rounded,
      'color': Colors.green,
      'index': 7, // Sales page index
    },
    {
      'title': 'Add Product',
      'subtitle': 'Register new item',
      'icon': Icons.inventory_2_rounded,
      'color': Colors.blue,
      'index': 2, // Products page index
    },
    {
      'title': 'Add Labor',
      'subtitle': 'Register worker',
      'icon': Icons.person_add_rounded,
      'color': Colors.purple,
      'index': 3, // Labor page index
    },
    {
      'title': 'Add Vendor',
      'subtitle': 'Register supplier',
      'icon': Icons.store_rounded,
      'color': Colors.teal,
      'index': 4, // Vendor page index
    },
    {
      'title': 'View Reports',
      'subtitle': 'Analytics & insights',
      'icon': Icons.analytics_rounded,
      'color': Colors.orange,
      'index': 10, // Reports page index
    },
    {
      'title': 'Manage Stock',
      'subtitle': 'Inventory control',
      'icon': Icons.inventory_rounded,
      'color': Colors.red,
      'index': 9, // Stock page index
    },
  ];

  // Handle quick actions
  void handleQuickAction(int pageIndex) {
    selectMenu(pageIndex);
  }

  // Get stats for different time periods
  Map<String, dynamic> getStatsForPeriod(String period) {
    switch (period) {
      case 'today':
        return {
          'sales': '₨ 45,230',
          'orders': 23,
          'vendors': 8,
          'products': 432,
        };
      case 'week':
        return {
          'sales': '₨ 3,24,500',
          'orders': 156,
          'vendors': 8,
          'products': 432,
        };
      case 'month':
        return {
          'sales': '₨ 12,45,000',
          'orders': 672,
          'vendors': 8,
          'products': 432,
        };
      default:
        return {
          'sales': '₨ 2,45,000',
          'orders': 1247,
          'vendors': 8,
          'products': 432,
        };
    }
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}