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
    'Vendors',
    'Customers', // Added Customers to menu titles
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

  // Dashboard Statistics - Updated to include Active Customers
  Map<String, dynamic> get dashboardStats => {
    'totalSales': {
      'value': 'Rs. 2,45,000',
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
    'activeCustomers': {
      'value': '156',
      'change': '+18',
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
      'amount': 'Rs. 85,000',
      'status': 'In Progress',
      'date': 'Today',
    },
    {
      'id': '#MF002',
      'customer': 'Fatima Ali',
      'type': 'Groom Sherwani',
      'amount': 'Rs. 45,000',
      'status': 'Completed',
      'date': 'Yesterday',
    },
    {
      'id': '#MF003',
      'customer': 'Sarah Ahmed',
      'type': 'Party Dress',
      'amount': 'Rs. 25,000',
      'status': 'Pending',
      'date': '2 days ago',
    },
    {
      'id': '#MF004',
      'customer': 'Zara Sheikh',
      'type': 'Wedding Lehenga',
      'amount': 'Rs. 120,000',
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
      'revenue': 'Rs. 2,50,000',
      'orders': 45,
    },
    {
      'name': 'Khan Fabrics',
      'city': 'Lahore',
      'revenue': 'Rs. 1,85,000',
      'orders': 38,
    },
    {
      'name': 'Hassan Brothers Trading',
      'city': 'Karachi',
      'revenue': 'Rs. 1,45,000',
      'orders': 32,
    },
    {
      'name': 'Sheikh Embroidery Works',
      'city': 'Islamabad',
      'revenue': 'Rs. 98,000',
      'orders': 25,
    },
  ];

  // Customer-related data for dashboard
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
    {
      'name': 'Hina Malik',
      'type': 'Corporate Client',
      'totalSpent': 'Rs. 95,000',
      'orders': 6,
    },
    {
      'name': 'Fatima Ali',
      'type': 'Regular Customer',
      'totalSpent': 'Rs. 45,000',
      'orders': 3,
    },
  ];

  // Recent activities including vendor and customer activities
  List<Map<String, dynamic>> get recentActivities => [
    {
      'title': 'New customer registered: Aisha Khan',
      'subtitle': 'Premium customer from Karachi',
      'time': '15 minutes ago',
      'icon': Icons.person_add_rounded,
      'color': Colors.indigo,
    },
    {
      'title': 'New vendor registered: Ali Textiles',
      'subtitle': 'Muhammad Ali - Fabric Supplier',
      'time': '30 minutes ago',
      'icon': Icons.store_rounded,
      'color': Colors.teal,
    },
    {
      'title': 'Customer purchase completed',
      'subtitle': 'Zara Sheikh - Rs. 120,000 Wedding Collection',
      'time': '2 hours ago',
      'icon': Icons.shopping_bag_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Vendor delivery received',
      'subtitle': 'Khan Fabrics - Silk Materials',
      'time': '5 hours ago',
      'icon': Icons.local_shipping_rounded,
      'color': Colors.purple,
    },
  ];

  // Performance metrics with vendor and customer data
  Map<String, dynamic> get performanceMetrics => {
    'revenueTarget': {
      'label': 'Revenue Target',
      'value': 'Rs. 3,00,000',
      'percentage': '82%',
      'color': Colors.blue,
    },
    'customerGrowth': {
      'label': 'Customer Growth',
      'value': '200',
      'percentage': '78%',
      'color': Colors.indigo,
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

  // Customer statistics summary
  Map<String, dynamic> get customerStats => {
    'totalCustomers': 156,
    'activeCustomers': 142,
    'newThisMonth': 18,
    'vipCustomers': 8,
    'totalRevenue': 'Rs. 8,45,000',
    'averageOrderValue': 'Rs. 55,000',
    'topSpendingCity': 'Karachi',
  };

  // Vendor statistics summary
  Map<String, dynamic> get vendorStats => {
    'totalVendors': 8,
    'activeVendors': 8,
    'newThisMonth': 2,
    'totalRevenue': 'Rs. 6,78,000',
    'averageOrderValue': 'Rs. 35,000',
    'topPerformingCity': 'Karachi',
  };

  // Quick actions for dashboard
  List<Map<String, dynamic>> get quickActions => [
    {
      'title': 'New Sale',
      'subtitle': 'Create new order',
      'icon': Icons.add_shopping_cart_rounded,
      'color': Colors.green,
      'index': 8, // Sales page index
    },
    {
      'title': 'Add Product',
      'subtitle': 'Register new item',
      'icon': Icons.inventory_2_rounded,
      'color': Colors.blue,
      'index': 2, // Products page index
    },
    {
      'title': 'Add Customer',
      'subtitle': 'Register client',
      'icon': Icons.person_add_rounded,
      'color': Colors.indigo,
      'index': 5, // Customer page index
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
      'index': 11, // Reports page index
    },
    {
      'title': 'Manage Stock',
      'subtitle': 'Inventory control',
      'icon': Icons.inventory_rounded,
      'color': Colors.red,
      'index': 10, // Stock page index
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
          'sales': 'Rs. 45,230',
          'orders': 23,
          'customers': 156,
          'vendors': 8,
          'products': 432,
        };
      case 'week':
        return {
          'sales': 'Rs. 3,24,500',
          'orders': 156,
          'customers': 156,
          'vendors': 8,
          'products': 432,
        };
      case 'month':
        return {
          'sales': 'Rs. 12,45,000',
          'orders': 672,
          'customers': 156,
          'vendors': 8,
          'products': 432,
        };
      default:
        return {
          'sales': 'Rs. 2,45,000',
          'orders': 1247,
          'customers': 156,
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

  // Customer analytics
  Map<String, dynamic> get customerAnalytics => {
    'totalRevenue': 845000.0,
    'averageOrderValue': 55000.0,
    'conversionRate': 78.0,
    'retentionRate': 85.0,
    'lifetimeValue': 125000.0,
  };

  // Get customer segments
  Map<String, List<Map<String, dynamic>>> get customerSegments => {
    'vip': [
      {'name': 'Zara Sheikh', 'spent': 120000, 'orders': 8},
      {'name': 'Hina Malik', 'spent': 95000, 'orders': 6},
    ],
    'premium': [
      {'name': 'Aisha Khan', 'spent': 85000, 'orders': 5},
      {'name': 'Sarah Ahmed', 'spent': 75000, 'orders': 4},
    ],
    'regular': [
      {'name': 'Fatima Ali', 'spent': 45000, 'orders': 3},
      {'name': 'Mehwish Qureshi', 'spent': 35000, 'orders': 2},
    ],
  };
}