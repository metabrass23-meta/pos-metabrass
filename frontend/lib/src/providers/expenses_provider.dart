import 'package:flutter/material.dart';

class Expense {
  final String id;
  final String expense;
  final String description;
  final double amount;
  final String withdrawalBy;
  final DateTime date;
  final TimeOfDay time;

  Expense({
    required this.id,
    required this.expense,
    required this.description,
    required this.amount,
    required this.withdrawalBy,
    required this.date,
    required this.time,
  });

  // Formatted date for display
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formatted time for display
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Relative date (e.g., "Today", "Yesterday", "2 days ago")
  String get relativeDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(recordDate).inDays;

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

  // Combined date and time for sorting
  DateTime get dateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Get color for person
  Color get personColor {
    switch (withdrawalBy) {
      case 'Parveez Maqbool':
        return Colors.blue;
      case 'Zain Maqbool':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Copy method for updates
  Expense copyWith({
    String? id,
    String? expense,
    String? description,
    double? amount,
    String? withdrawalBy,
    DateTime? date,
    TimeOfDay? time,
  }) {
    return Expense(
      id: id ?? this.id,
      expense: expense ?? this.expense,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      withdrawalBy: withdrawalBy ?? this.withdrawalBy,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense': expense,
      'description': description,
      'amount': amount,
      'withdrawalBy': withdrawalBy,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
    };
  }

  // Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return Expense(
      id: json['id'],
      expense: json['expense'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      withdrawalBy: json['withdrawalBy'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}

class ExpensesProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Available persons for withdrawal
  final List<String> _availablePersons = [
    'Parveez Maqbool',
    'Zain Maqbool',
  ];

  // Getters
  List<Expense> get expenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get availablePersons => _availablePersons;

  // Initialize with sample data
  ExpensesProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _expenses = [
      Expense(
        id: 'EXP001',
        expense: 'Office Supplies',
        description: 'Purchased stationery and printing materials for office use',
        amount: 8500.0,
        withdrawalBy: 'Parveez Maqbool',
        date: DateTime.now().subtract(const Duration(days: 2)),
        time: const TimeOfDay(hour: 10, minute: 30),
      ),
      Expense(
        id: 'EXP002',
        expense: 'Internet Bill',
        description: 'Monthly internet service payment for office connectivity',
        amount: 12000.0,
        withdrawalBy: 'Zain Maqbool',
        date: DateTime.now().subtract(const Duration(days: 5)),
        time: const TimeOfDay(hour: 14, minute: 15),
      ),
      Expense(
        id: 'EXP003',
        expense: 'Transportation',
        description: 'Fuel and maintenance costs for delivery vehicle',
        amount: 15000.0,
        withdrawalBy: 'Parveez Maqbool',
        date: DateTime.now().subtract(const Duration(days: 7)),
        time: const TimeOfDay(hour: 9, minute: 45),
      ),
      Expense(
        id: 'EXP004',
        expense: 'Marketing',
        description: 'Social media advertising and promotional materials',
        amount: 25000.0,
        withdrawalBy: 'Zain Maqbool',
        date: DateTime.now().subtract(const Duration(days: 10)),
        time: const TimeOfDay(hour: 16, minute: 20),
      ),
      Expense(
        id: 'EXP005',
        expense: 'Equipment',
        description: 'New computer monitor and accessories for office setup',
        amount: 45000.0,
        withdrawalBy: 'Parveez Maqbool',
        date: DateTime.now().subtract(const Duration(days: 15)),
        time: const TimeOfDay(hour: 11, minute: 0),
      ),
      Expense(
        id: 'EXP006',
        expense: 'Utilities',
        description: 'Electricity bill payment for office premises',
        amount: 18000.0,
        withdrawalBy: 'Zain Maqbool',
        date: DateTime.now().subtract(const Duration(days: 20)),
        time: const TimeOfDay(hour: 13, minute: 30),
      ),
      Expense(
        id: 'EXP007',
        expense: 'Maintenance',
        description: 'Office air conditioning repair and servicing',
        amount: 7500.0,
        withdrawalBy: 'Parveez Maqbool',
        date: DateTime.now().subtract(const Duration(days: 25)),
        time: const TimeOfDay(hour: 15, minute: 45),
      ),
      Expense(
        id: 'EXP008',
        expense: 'Travel',
        description: 'Business trip expenses for client meeting in Lahore',
        amount: 35000.0,
        withdrawalBy: 'Zain Maqbool',
        date: DateTime.now().subtract(const Duration(days: 30)),
        time: const TimeOfDay(hour: 8, minute: 15),
      ),
    ];
    _filteredExpenses = List.from(_expenses);
    _sortExpenses();
  }

  // Sort expenses by date and time (newest first)
  void _sortExpenses() {
    _filteredExpenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Generate new ID
  String _generateId() {
    final maxId = _expenses.isEmpty
        ? 0
        : _expenses
        .map((e) => int.tryParse(e.id.replaceAll('EXP', '')) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return 'EXP${(maxId + 1).toString().padLeft(3, '0')}';
  }

  // Add new expense
  Future<void> addExpense({
    required String expense,
    required String description,
    required double amount,
    required String withdrawalBy,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final newExpense = Expense(
      id: _generateId(),
      expense: expense,
      description: description,
      amount: amount,
      withdrawalBy: withdrawalBy,
      date: date,
      time: time,
    );

    _expenses.add(newExpense);
    _applyFilters();
    _sortExpenses();

    _isLoading = false;
    notifyListeners();
  }

  // Update existing expense
  Future<void> updateExpense({
    required String id,
    required String expense,
    required String description,
    required double amount,
    required String withdrawalBy,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = _expenses[index].copyWith(
        expense: expense,
        description: description,
        amount: amount,
        withdrawalBy: withdrawalBy,
        date: date,
        time: time,
      );
      _applyFilters();
      _sortExpenses();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    _expenses.removeWhere((e) => e.id == id);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Search expenses
  void searchExpenses(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Apply search filters
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredExpenses = List.from(_expenses);
    } else {
      _filteredExpenses = _expenses.where((expense) {
        return expense.id.toLowerCase().contains(_searchQuery) ||
            expense.expense.toLowerCase().contains(_searchQuery) ||
            expense.description.toLowerCase().contains(_searchQuery) ||
            expense.withdrawalBy.toLowerCase().contains(_searchQuery) ||
            expense.amount.toString().contains(_searchQuery);
      }).toList();
    }
    _sortExpenses();
  }

  // Get statistics
  Map<String, dynamic> get expenseStats {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    final totalExpenses = _expenses.length;
    final totalAmount = _expenses.fold<double>(
      0.0,
          (sum, expense) => sum + expense.amount,
    );

    final thisMonthExpenses = _expenses.where((expense) {
      return expense.date.year == currentYear && expense.date.month == currentMonth;
    }).length;

    final thisWeekExpenses = _expenses.where((expense) {
      return expense.date.isAfter(currentWeekStart.subtract(const Duration(days: 1)));
    }).length;

    return {
      'total': totalExpenses,
      'totalAmount': totalAmount.toStringAsFixed(0),
      'thisMonth': thisMonthExpenses,
      'thisWeek': thisWeekExpenses,
    };
  }

  // Get expenses by person
  List<Expense> getExpensesByPerson(String person) {
    return _expenses.where((expense) => expense.withdrawalBy == person).toList();
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total amount by person
  double getTotalAmountByPerson(String person) {
    return _expenses
        .where((expense) => expense.withdrawalBy == person)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total amount by month
  double getTotalAmountByMonth(int year, int month) {
    return _expenses
        .where((expense) => expense.date.year == year && expense.date.month == month)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total amount by year
  double getTotalAmountByYear(int year) {
    return _expenses
        .where((expense) => expense.date.year == year)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses by category/type
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.expense.toLowerCase() == category.toLowerCase()).toList();
  }

  // Get expense categories with counts
  Map<String, int> getExpenseCategories() {
    final categories = <String, int>{};
    for (final expense in _expenses) {
      categories[expense.expense] = (categories[expense.expense] ?? 0) + 1;
    }
    return categories;
  }

  // Export data (placeholder for future implementation)
  Future<void> exportData() async {
    // Implementation for exporting expense records
    // This could export to CSV, PDF, etc.
  }

  // Import data (placeholder for future implementation)
  Future<void> importData(List<Map<String, dynamic>> data) async {
    // Implementation for importing expense records
    // This could import from CSV, JSON, etc.
  }

  // Clear all records (for testing purposes)
  void clearAllRecords() {
    _expenses.clear();
    _filteredExpenses.clear();
    notifyListeners();
  }

  // Refresh data (for pull-to-refresh functionality)
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // In a real app, this would fetch data from an API
    _applyFilters();
    _sortExpenses();

    _isLoading = false;
    notifyListeners();
  }

  // Get monthly expense trend
  Map<String, double> getMonthlyExpenseTrend(int year) {
    final monthlyTotals = <String, double>{};
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    for (int i = 1; i <= 12; i++) {
      final monthExpenses = _expenses.where((expense) {
        return expense.date.year == year && expense.date.month == i;
      });
      final total = monthExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      monthlyTotals[months[i - 1]] = total;
    }

    return monthlyTotals;
  }

  // Get person-wise expense distribution
  Map<String, double> getPersonWiseExpenseDistribution() {
    final personTotals = <String, double>{};
    for (final person in _availablePersons) {
      personTotals[person] = getTotalAmountByPerson(person);
    }
    return personTotals;
  }
}