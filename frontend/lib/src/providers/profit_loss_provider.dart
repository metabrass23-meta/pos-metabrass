import 'package:flutter/material.dart';

class ProfitLossData {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalSalesIncome;
  final double laborPayments;
  final double vendorPayments;
  final double otherExpenses;
  final double zakatAmount;
  final String periodType; // 'daily', 'weekly', 'monthly', 'yearly', 'custom'

  ProfitLossData({
    required this.periodStart,
    required this.periodEnd,
    required this.totalSalesIncome,
    required this.laborPayments,
    required this.vendorPayments,
    required this.otherExpenses,
    required this.zakatAmount,
    required this.periodType,
  });

  // Calculated Properties
  double get totalExpenses => laborPayments + vendorPayments + otherExpenses + zakatAmount;
  double get netProfit => totalSalesIncome - totalExpenses;
  double get profitMargin => totalSalesIncome > 0 ? (netProfit / totalSalesIncome) * 100 : 0.0;
  bool get isProfitable => netProfit > 0;

  // Formatted Strings
  String get formattedPeriod {
    switch (periodType) {
      case 'daily':
        return '${periodStart.day}/${periodStart.month}/${periodStart.year}';
      case 'weekly':
        return '${periodStart.day}/${periodStart.month} - ${periodEnd.day}/${periodEnd.month}/${periodEnd.year}';
      case 'monthly':
        return _getMonthName(periodStart.month) + ' ${periodStart.year}';
      case 'yearly':
        return '${periodStart.year}';
      case 'custom':
        return '${periodStart.day}/${periodStart.month}/${periodStart.year} - ${periodEnd.day}/${periodEnd.month}/${periodEnd.year}';
      default:
        return 'Unknown Period';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String get formattedTotalIncome => 'PKR ${totalSalesIncome.toStringAsFixed(0)}';
  String get formattedTotalExpenses => 'PKR ${totalExpenses.toStringAsFixed(0)}';
  String get formattedNetProfit => 'PKR ${netProfit.toStringAsFixed(0)}';
  String get formattedProfitMargin => '${profitMargin.toStringAsFixed(1)}%';

  // Expense Breakdown Percentages
  double get laborPercentage => totalExpenses > 0 ? (laborPayments / totalExpenses) * 100 : 0.0;
  double get vendorPercentage => totalExpenses > 0 ? (vendorPayments / totalExpenses) * 100 : 0.0;
  double get otherExpensesPercentage => totalExpenses > 0 ? (otherExpenses / totalExpenses) * 100 : 0.0;
  double get zakatPercentage => totalExpenses > 0 ? (zakatAmount / totalExpenses) * 100 : 0.0;

  // Revenue vs Expense Percentages
  double get expenseToRevenueRatio => totalSalesIncome > 0 ? (totalExpenses / totalSalesIncome) * 100 : 0.0;
  double get profitToRevenueRatio => totalSalesIncome > 0 ? (netProfit / totalSalesIncome) * 100 : 0.0;
}

class ProfitLossProvider extends ChangeNotifier {
  List<ProfitLossData> _profitLossHistory = [];
  ProfitLossData? _currentProfitLoss;
  bool _isLoading = false;
  String _selectedPeriodType = 'monthly';
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _customEndDate = DateTime.now();

  // Available period types
  final List<String> _availablePeriodTypes = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
    'custom',
  ];

  // Getters
  List<ProfitLossData> get profitLossHistory => _profitLossHistory;
  ProfitLossData? get currentProfitLoss => _currentProfitLoss;
  bool get isLoading => _isLoading;
  String get selectedPeriodType => _selectedPeriodType;
  DateTime get customStartDate => _customStartDate;
  DateTime get customEndDate => _customEndDate;
  List<String> get availablePeriodTypes => _availablePeriodTypes;

  // Initialize with sample data
  ProfitLossProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();

    _profitLossHistory = [
      // Current Month
      ProfitLossData(
        periodStart: DateTime(now.year, now.month, 1),
        periodEnd: now,
        totalSalesIncome: 450000.0,
        laborPayments: 85000.0,
        vendorPayments: 120000.0,
        otherExpenses: 45000.0,
        zakatAmount: 7500.0,
        periodType: 'monthly',
      ),

      // Previous Month
      ProfitLossData(
        periodStart: DateTime(now.year, now.month - 1, 1),
        periodEnd: DateTime(now.year, now.month, 0),
        totalSalesIncome: 380000.0,
        laborPayments: 75000.0,
        vendorPayments: 95000.0,
        otherExpenses: 38000.0,
        zakatAmount: 6000.0,
        periodType: 'monthly',
      ),

      // Two Months Ago
      ProfitLossData(
        periodStart: DateTime(now.year, now.month - 2, 1),
        periodEnd: DateTime(now.year, now.month - 1, 0),
        totalSalesIncome: 520000.0,
        laborPayments: 95000.0,
        vendorPayments: 140000.0,
        otherExpenses: 52000.0,
        zakatAmount: 8500.0,
        periodType: 'monthly',
      ),

      // Three Months Ago
      ProfitLossData(
        periodStart: DateTime(now.year, now.month - 3, 1),
        periodEnd: DateTime(now.year, now.month - 2, 0),
        totalSalesIncome: 420000.0,
        laborPayments: 82000.0,
        vendorPayments: 108000.0,
        otherExpenses: 41000.0,
        zakatAmount: 7000.0,
        periodType: 'monthly',
      ),

      // This Year (Annual)
      ProfitLossData(
        periodStart: DateTime(now.year, 1, 1),
        periodEnd: now,
        totalSalesIncome: 1770000.0,
        laborPayments: 337000.0,
        vendorPayments: 463000.0,
        otherExpenses: 176000.0,
        zakatAmount: 29000.0,
        periodType: 'yearly',
      ),

      // Last Year (Annual)
      ProfitLossData(
        periodStart: DateTime(now.year - 1, 1, 1),
        periodEnd: DateTime(now.year - 1, 12, 31),
        totalSalesIncome: 2100000.0,
        laborPayments: 395000.0,
        vendorPayments: 580000.0,
        otherExpenses: 205000.0,
        zakatAmount: 35000.0,
        periodType: 'yearly',
      ),
    ];

    _currentProfitLoss = _profitLossHistory.first;
  }

  // Calculate profit and loss for a specific period
  Future<void> calculateProfitLoss({
    required DateTime startDate,
    required DateTime endDate,
    required String periodType,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // In a real app, this would fetch data from multiple sources:
    // - Sales data from sales table
    // - Payment data from payments table
    // - Expense data from expenses table
    // - Zakat data from zakat table

    // For demo purposes, we'll use sample calculations
    final profitLossData = _calculateSampleData(startDate, endDate, periodType);

    _currentProfitLoss = profitLossData;

    // Add to history if it's a new calculation
    final existingIndex = _profitLossHistory.indexWhere((p) =>
    p.periodStart == startDate &&
        p.periodEnd == endDate &&
        p.periodType == periodType
    );

    if (existingIndex == -1) {
      _profitLossHistory.insert(0, profitLossData);
      // Keep only last 10 calculations
      if (_profitLossHistory.length > 10) {
        _profitLossHistory = _profitLossHistory.take(10).toList();
      }
    } else {
      _profitLossHistory[existingIndex] = profitLossData;
    }

    _isLoading = false;
    notifyListeners();
  }

  ProfitLossData _calculateSampleData(DateTime startDate, DateTime endDate, String periodType) {
    // Sample calculation logic - in real app, this would query actual database
    final daysDifference = endDate.difference(startDate).inDays + 1;
    final baseDailyIncome = 15000.0;
    final baseDailyExpenses = 8500.0;

    final totalIncome = baseDailyIncome * daysDifference;
    final laborPayments = totalIncome * 0.19; // 19% of income
    final vendorPayments = totalIncome * 0.27; // 27% of income
    final otherExpenses = totalIncome * 0.10; // 10% of income
    final zakatAmount = totalIncome * 0.017; // 1.7% of income

    return ProfitLossData(
      periodStart: startDate,
      periodEnd: endDate,
      totalSalesIncome: totalIncome,
      laborPayments: laborPayments,
      vendorPayments: vendorPayments,
      otherExpenses: otherExpenses,
      zakatAmount: zakatAmount,
      periodType: periodType,
    );
  }

  // Set period type and recalculate
  Future<void> setPeriodType(String periodType) async {
    _selectedPeriodType = periodType;

    DateTime startDate;
    DateTime endDate = DateTime.now();

    switch (periodType) {
      case 'daily':
        startDate = DateTime(endDate.year, endDate.month, endDate.day);
        break;
      case 'weekly':
        startDate = endDate.subtract(Duration(days: endDate.weekday - 1));
        break;
      case 'monthly':
        startDate = DateTime(endDate.year, endDate.month, 1);
        break;
      case 'yearly':
        startDate = DateTime(endDate.year, 1, 1);
        break;
      case 'custom':
        startDate = _customStartDate;
        endDate = _customEndDate;
        break;
      default:
        startDate = DateTime(endDate.year, endDate.month, 1);
    }

    await calculateProfitLoss(
      startDate: startDate,
      endDate: endDate,
      periodType: periodType,
    );
  }

  // Set custom date range
  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    _customStartDate = startDate;
    _customEndDate = endDate;
    notifyListeners();
  }

  // Get comparison with previous period
  Map<String, dynamic> getPeriodComparison() {
    if (_profitLossHistory.length < 2) return {};

    final current = _profitLossHistory[0];
    final previous = _profitLossHistory[1];

    final incomeChange = current.totalSalesIncome - previous.totalSalesIncome;
    final expenseChange = current.totalExpenses - previous.totalExpenses;
    final profitChange = current.netProfit - previous.netProfit;

    final incomeChangePercent = previous.totalSalesIncome > 0
        ? (incomeChange / previous.totalSalesIncome) * 100
        : 0.0;
    final expenseChangePercent = previous.totalExpenses > 0
        ? (expenseChange / previous.totalExpenses) * 100
        : 0.0;
    final profitChangePercent = previous.netProfit != 0
        ? (profitChange / previous.netProfit.abs()) * 100
        : 0.0;

    return {
      'incomeChange': incomeChange,
      'expenseChange': expenseChange,
      'profitChange': profitChange,
      'incomeChangePercent': incomeChangePercent,
      'expenseChangePercent': expenseChangePercent,
      'profitChangePercent': profitChangePercent,
      'isIncomeUp': incomeChange > 0,
      'isExpenseUp': expenseChange > 0,
      'isProfitUp': profitChange > 0,
    };
  }

  // Get expense breakdown for charts
  List<Map<String, dynamic>> getExpenseBreakdown() {
    if (_currentProfitLoss == null) return [];

    return [
      {
        'category': 'Labor Payments',
        'amount': _currentProfitLoss!.laborPayments,
        'percentage': _currentProfitLoss!.laborPercentage,
        'color': Colors.blue,
      },
      {
        'category': 'Vendor Payments',
        'amount': _currentProfitLoss!.vendorPayments,
        'percentage': _currentProfitLoss!.vendorPercentage,
        'color': Colors.orange,
      },
      {
        'category': 'Other Expenses',
        'amount': _currentProfitLoss!.otherExpenses,
        'percentage': _currentProfitLoss!.otherExpensesPercentage,
        'color': Colors.red,
      },
      {
        'category': 'Zakat',
        'amount': _currentProfitLoss!.zakatAmount,
        'percentage': _currentProfitLoss!.zakatPercentage,
        'color': Colors.green,
      },
    ];
  }

  // Get profit trend over time
  List<Map<String, dynamic>> getProfitTrend() {
    return _profitLossHistory.map((data) => {
      'period': data.formattedPeriod,
      'profit': data.netProfit,
      'income': data.totalSalesIncome,
      'expenses': data.totalExpenses,
      'date': data.periodStart,
    }).toList();
  }

  // Export data (placeholder for future implementation)
  Future<void> exportProfitLossReport() async {
    // Implementation for exporting P&L report
    // This could export to PDF, Excel, etc.
  }

  // Refresh data (for pull-to-refresh functionality)
  Future<void> refreshData() async {
    if (_currentProfitLoss != null) {
      await calculateProfitLoss(
        startDate: _currentProfitLoss!.periodStart,
        endDate: _currentProfitLoss!.periodEnd,
        periodType: _currentProfitLoss!.periodType,
      );
    }
  }

  // Get key performance indicators
  Map<String, dynamic> getKPIs() {
    if (_currentProfitLoss == null) return {};

    return {
      'profitMargin': _currentProfitLoss!.profitMargin,
      'expenseRatio': _currentProfitLoss!.expenseToRevenueRatio,
      'isProfitable': _currentProfitLoss!.isProfitable,
      'totalTransactions': _profitLossHistory.length,
      'averageProfit': _profitLossHistory.isEmpty
          ? 0.0
          : _profitLossHistory.map((p) => p.netProfit).reduce((a, b) => a + b) / _profitLossHistory.length,
    };
  }
}