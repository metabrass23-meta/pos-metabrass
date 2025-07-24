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

  // Dashboard Statistics
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
}