import 'package:flutter/material.dart';

class PrincipalAccount {
  final String id;
  final DateTime date;
  final TimeOfDay time;
  final String sourceModule;
  final String? sourceId;
  final String description;
  final String type; // 'credit' or 'debit'
  final double amount;
  final double balanceAfter;
  final String? handledBy;
  final String? notes;

  PrincipalAccount({
    required this.id,
    required this.date,
    required this.time,
    required this.sourceModule,
    this.sourceId,
    required this.description,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.handledBy,
    this.notes,
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

  // Get color for transaction type
  Color get typeColor {
    return type == 'credit' ? Colors.green : Colors.red;
  }

  // Get icon for transaction type
  IconData get typeIcon {
    return type == 'credit' ? Icons.add_circle_outline : Icons.remove_circle_outline;
  }

  // Get color for source module
  Color get sourceModuleColor {
    switch (sourceModule.toLowerCase()) {
      case 'sales':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'advance_payment':
        return Colors.orange;
      case 'expenses':
        return Colors.red;
      case 'receivables':
        return Colors.purple;
      case 'payables':
        return Colors.brown;
      case 'zakat':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Get formatted source module name
  String get formattedSourceModule {
    switch (sourceModule.toLowerCase()) {
      case 'sales':
        return 'Sales';
      case 'payment':
        return 'Payment';
      case 'advance_payment':
        return 'Advance Payment';
      case 'expenses':
        return 'Expenses';
      case 'receivables':
        return 'Receivables';
      case 'payables':
        return 'Payables';
      case 'zakat':
        return 'Zakat';
      default:
        return sourceModule;
    }
  }

  // Copy method for updates
  PrincipalAccount copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? time,
    String? sourceModule,
    String? sourceId,
    String? description,
    String? type,
    double? amount,
    double? balanceAfter,
    String? handledBy,
    String? notes,
  }) {
    return PrincipalAccount(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      sourceModule: sourceModule ?? this.sourceModule,
      sourceId: sourceId ?? this.sourceId,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      handledBy: handledBy ?? this.handledBy,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'sourceModule': sourceModule,
      'sourceId': sourceId,
      'description': description,
      'type': type,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'handledBy': handledBy,
      'notes': notes,
    };
  }

  // Create from JSON
  factory PrincipalAccount.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return PrincipalAccount(
      id: json['id'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      sourceModule: json['sourceModule'],
      sourceId: json['sourceId'],
      description: json['description'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      balanceAfter: json['balanceAfter'].toDouble(),
      handledBy: json['handledBy'],
      notes: json['notes'],
    );
  }
}

class PrincipalAccountProvider extends ChangeNotifier {
  List<PrincipalAccount> _accounts = [];
  List<PrincipalAccount> _filteredAccounts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  double _currentBalance = 0.0;

  // Available source modules
  final List<String> _availableSourceModules = [
    'sales',
    'payment',
    'advance_payment',
    'expenses',
    'receivables',
    'payables',
    'zakat',
  ];

  // Available transaction types
  final List<String> _availableTransactionTypes = [
    'credit',
    'debit',
  ];

  // Available handlers
  final List<String> _availableHandlers = [
    'Parveez Maqbool',
    'Zain Maqbool',
  ];

  // Getters
  List<PrincipalAccount> get accounts => _filteredAccounts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  double get currentBalance => _currentBalance;
  List<String> get availableSourceModules => _availableSourceModules;
  List<String> get availableTransactionTypes => _availableTransactionTypes;
  List<String> get availableHandlers => _availableHandlers;

  // Initialize with sample data
  PrincipalAccountProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _accounts = [
      PrincipalAccount(
        id: 'PA001',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: const TimeOfDay(hour: 10, minute: 30),
        sourceModule: 'sales',
        sourceId: 'SALE001',
        description: 'Sale to Customer Ahmad - Invoice #SALE001',
        type: 'credit',
        amount: 45000.0,
        balanceAfter: 145000.0,
        handledBy: 'Parveez Maqbool',
        notes: 'Cash payment received for tailoring services',
      ),
      PrincipalAccount(
        id: 'PA002',
        date: DateTime.now().subtract(const Duration(days: 2)),
        time: const TimeOfDay(hour: 14, minute: 15),
        sourceModule: 'expenses',
        sourceId: 'EXP001',
        description: 'Office supplies purchase - Expense #EXP001',
        type: 'debit',
        amount: 8500.0,
        balanceAfter: 100000.0,
        handledBy: 'Zain Maqbool',
        notes: 'Purchased stationery and printing materials',
      ),
      PrincipalAccount(
        id: 'PA003',
        date: DateTime.now().subtract(const Duration(days: 3)),
        time: const TimeOfDay(hour: 11, minute: 45),
        sourceModule: 'advance_payment',
        sourceId: 'ADV001',
        description: 'Advance payment to Tailor Usman',
        type: 'debit',
        amount: 15000.0,
        balanceAfter: 108500.0,
        handledBy: 'Parveez Maqbool',
        notes: 'Advance for upcoming bulk order',
      ),
      PrincipalAccount(
        id: 'PA004',
        date: DateTime.now().subtract(const Duration(days: 4)),
        time: const TimeOfDay(hour: 16, minute: 20),
        sourceModule: 'payment',
        sourceId: 'PAY001',
        description: 'Payment received from Customer Fatima',
        type: 'credit',
        amount: 25000.0,
        balanceAfter: 123500.0,
        handledBy: 'Zain Maqbool',
        notes: 'Outstanding invoice payment cleared',
      ),
      PrincipalAccount(
        id: 'PA005',
        date: DateTime.now().subtract(const Duration(days: 5)),
        time: const TimeOfDay(hour: 9, minute: 0),
        sourceModule: 'receivables',
        sourceId: 'REC001',
        description: 'Receivable adjustment - Customer Ali',
        type: 'credit',
        amount: 12000.0,
        balanceAfter: 98500.0,
        handledBy: 'Parveez Maqbool',
        notes: 'Received pending amount from previous order',
      ),
      PrincipalAccount(
        id: 'PA006',
        date: DateTime.now().subtract(const Duration(days: 6)),
        time: const TimeOfDay(hour: 13, minute: 30),
        sourceModule: 'payables',
        sourceId: 'PAY002',
        description: 'Payment to Supplier - Fabric Purchase',
        type: 'debit',
        amount: 18000.0,
        balanceAfter: 86500.0,
        handledBy: 'Zain Maqbool',
        notes: 'Paid supplier for fabric stock replenishment',
      ),
      PrincipalAccount(
        id: 'PA007',
        date: DateTime.now().subtract(const Duration(days: 7)),
        time: const TimeOfDay(hour: 15, minute: 45),
        sourceModule: 'zakat',
        sourceId: 'ZAK001',
        description: 'Zakat payment for current year',
        type: 'debit',
        amount: 7500.0,
        balanceAfter: 104500.0,
        handledBy: 'Parveez Maqbool',
        notes: 'Annual zakat obligation fulfilled',
      ),
      PrincipalAccount(
        id: 'PA008',
        date: DateTime.now().subtract(const Duration(days: 8)),
        time: const TimeOfDay(hour: 8, minute: 15),
        sourceModule: 'sales',
        sourceId: 'SALE002',
        description: 'Sale to Customer Maria - Wedding Dress',
        type: 'credit',
        amount: 75000.0,
        balanceAfter: 112000.0,
        handledBy: 'Parveez Maqbool',
        notes: 'Premium wedding dress order completed',
      ),
    ];

    _updateCurrentBalance();
    _filteredAccounts = List.from(_accounts);
    _sortAccounts();
  }

  // Update current balance based on latest transaction
  void _updateCurrentBalance() {
    if (_accounts.isNotEmpty) {
      final sortedAccounts = List<PrincipalAccount>.from(_accounts);
      sortedAccounts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _currentBalance = sortedAccounts.first.balanceAfter;
    } else {
      _currentBalance = 0.0;
    }
  }

  // Sort accounts by date and time (newest first)
  void _sortAccounts() {
    _filteredAccounts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Generate new ID
  String _generateId() {
    final maxId = _accounts.isEmpty
        ? 0
        : _accounts
        .map((e) => int.tryParse(e.id.replaceAll('PA', '')) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return 'PA${(maxId + 1).toString().padLeft(3, '0')}';
  }

  // Calculate new balance after transaction
  double _calculateNewBalance(String type, double amount) {
    if (type == 'credit') {
      return _currentBalance + amount;
    } else {
      return _currentBalance - amount;
    }
  }

  // Add new principal account entry
  Future<void> addPrincipalAccount({
    required DateTime date,
    required TimeOfDay time,
    required String sourceModule,
    String? sourceId,
    required String description,
    required String type,
    required double amount,
    String? handledBy,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final newBalance = _calculateNewBalance(type, amount);

    final newAccount = PrincipalAccount(
      id: _generateId(),
      date: date,
      time: time,
      sourceModule: sourceModule,
      sourceId: sourceId,
      description: description,
      type: type,
      amount: amount,
      balanceAfter: newBalance,
      handledBy: handledBy,
      notes: notes,
    );

    _accounts.add(newAccount);
    _currentBalance = newBalance;
    _applyFilters();
    _sortAccounts();

    _isLoading = false;
    notifyListeners();
  }

  // Update existing principal account entry
  Future<void> updatePrincipalAccount({
    required String id,
    required DateTime date,
    required TimeOfDay time,
    required String sourceModule,
    String? sourceId,
    required String description,
    required String type,
    required double amount,
    String? handledBy,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _accounts.indexWhere((e) => e.id == id);
    if (index != -1) {
      final oldAccount = _accounts[index];

      // Recalculate balance - first remove old transaction effect, then add new
      double adjustedBalance = _currentBalance;
      if (oldAccount.type == 'credit') {
        adjustedBalance -= oldAccount.amount;
      } else {
        adjustedBalance += oldAccount.amount;
      }

      final newBalance = type == 'credit'
          ? adjustedBalance + amount
          : adjustedBalance - amount;

      _accounts[index] = _accounts[index].copyWith(
        date: date,
        time: time,
        sourceModule: sourceModule,
        sourceId: sourceId,
        description: description,
        type: type,
        amount: amount,
        balanceAfter: newBalance,
        handledBy: handledBy,
        notes: notes,
      );

      _currentBalance = newBalance;
      _applyFilters();
      _sortAccounts();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Delete principal account entry
  Future<void> deletePrincipalAccount(String id) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final accountToDelete = _accounts.firstWhere((e) => e.id == id);

    // Adjust current balance
    if (accountToDelete.type == 'credit') {
      _currentBalance -= accountToDelete.amount;
    } else {
      _currentBalance += accountToDelete.amount;
    }

    _accounts.removeWhere((e) => e.id == id);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Search accounts
  void searchAccounts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Apply search filters
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredAccounts = List.from(_accounts);
    } else {
      _filteredAccounts = _accounts.where((account) {
        return account.id.toLowerCase().contains(_searchQuery) ||
            account.description.toLowerCase().contains(_searchQuery) ||
            account.sourceModule.toLowerCase().contains(_searchQuery) ||
            account.type.toLowerCase().contains(_searchQuery) ||
            account.amount.toString().contains(_searchQuery) ||
            (account.handledBy?.toLowerCase().contains(_searchQuery) ?? false) ||
            (account.notes?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
    _sortAccounts();
  }

  // Get statistics
  Map<String, dynamic> get accountStats {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    final totalTransactions = _accounts.length;
    final totalCredits = _accounts.where((a) => a.type == 'credit').fold<double>(
      0.0, (sum, account) => sum + account.amount,
    );
    final totalDebits = _accounts.where((a) => a.type == 'debit').fold<double>(
      0.0, (sum, account) => sum + account.amount,
    );

    final thisMonthTransactions = _accounts.where((account) {
      return account.date.year == currentYear && account.date.month == currentMonth;
    }).length;

    final thisWeekTransactions = _accounts.where((account) {
      return account.date.isAfter(currentWeekStart.subtract(const Duration(days: 1)));
    }).length;

    return {
      'total': totalTransactions,
      'currentBalance': _currentBalance.toStringAsFixed(0),
      'totalCredits': totalCredits.toStringAsFixed(0),
      'totalDebits': totalDebits.toStringAsFixed(0),
      'thisMonth': thisMonthTransactions,
      'thisWeek': thisWeekTransactions,
    };
  }

  // Get accounts by source module
  List<PrincipalAccount> getAccountsBySourceModule(String sourceModule) {
    return _accounts.where((account) => account.sourceModule == sourceModule).toList();
  }

  // Get accounts by transaction type
  List<PrincipalAccount> getAccountsByType(String type) {
    return _accounts.where((account) => account.type == type).toList();
  }

  // Get accounts by date range
  List<PrincipalAccount> getAccountsByDateRange(DateTime start, DateTime end) {
    return _accounts.where((account) {
      return account.date.isAfter(start.subtract(const Duration(days: 1))) &&
          account.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total amount by source module
  double getTotalAmountBySourceModule(String sourceModule, String type) {
    return _accounts
        .where((account) => account.sourceModule == sourceModule && account.type == type)
        .fold<double>(0.0, (sum, account) => sum + account.amount);
  }

  // Get balance trend over time
  Map<String, double> getBalanceTrend(int days) {
    final trend = <String, double>{};
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';

      final dayAccounts = _accounts.where((account) {
        return account.date.year == date.year &&
            account.date.month == date.month &&
            account.date.day == date.day;
      }).toList();

      if (dayAccounts.isNotEmpty) {
        dayAccounts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        trend[dateKey] = dayAccounts.first.balanceAfter;
      } else {
        final previousBalance = trend.values.isNotEmpty ? trend.values.last : _currentBalance;
        trend[dateKey] = previousBalance;
      }
    }

    return trend;
  }

  // Get source module distribution
  Map<String, int> getSourceModuleDistribution() {
    final distribution = <String, int>{};
    for (final module in _availableSourceModules) {
      distribution[module] = _accounts.where((a) => a.sourceModule == module).length;
    }
    return distribution;
  }

  // Clear all records (for testing purposes)
  void clearAllRecords() {
    _accounts.clear();
    _filteredAccounts.clear();
    _currentBalance = 0.0;
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
    _sortAccounts();
    _updateCurrentBalance();

    _isLoading = false;
    notifyListeners();
  }
}