import 'package:flutter/material.dart';

class Payable {
  final String id;
  final String creditorName;
  final String creditorPhone;
  final double amountBorrowed;
  final String reasonOrItem;
  final DateTime dateBorrowed;
  final DateTime expectedRepaymentDate;
  final double amountPaid;
  final double balanceRemaining;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payable({
    required this.id,
    required this.creditorName,
    required this.creditorPhone,
    required this.amountBorrowed,
    required this.reasonOrItem,
    required this.dateBorrowed,
    required this.expectedRepaymentDate,
    this.amountPaid = 0.0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : balanceRemaining = amountBorrowed - amountPaid;

  Payable copyWith({
    String? id,
    String? creditorName,
    String? creditorPhone,
    double? amountBorrowed,
    String? reasonOrItem,
    DateTime? dateBorrowed,
    DateTime? expectedRepaymentDate,
    double? amountPaid,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payable(
      id: id ?? this.id,
      creditorName: creditorName ?? this.creditorName,
      creditorPhone: creditorPhone ?? this.creditorPhone,
      amountBorrowed: amountBorrowed ?? this.amountBorrowed,
      reasonOrItem: reasonOrItem ?? this.reasonOrItem,
      dateBorrowed: dateBorrowed ?? this.dateBorrowed,
      expectedRepaymentDate: expectedRepaymentDate ?? this.expectedRepaymentDate,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusText {
    if (balanceRemaining <= 0) return 'Fully Paid';
    if (expectedRepaymentDate.isBefore(DateTime.now()) && balanceRemaining > 0) return 'Overdue';
    if (amountPaid > 0 && balanceRemaining > 0) return 'Partially Paid';
    return 'Pending';
  }

  Color get statusColor {
    if (balanceRemaining <= 0) return Colors.green;
    if (expectedRepaymentDate.isBefore(DateTime.now()) && balanceRemaining > 0) return Colors.red;
    if (amountPaid > 0 && balanceRemaining > 0) return Colors.orange;
    return Colors.blue;
  }

  bool get isOverdue => expectedRepaymentDate.isBefore(DateTime.now()) && balanceRemaining > 0;
  bool get isFullyPaid => balanceRemaining <= 0;
  bool get isPartiallyPaid => amountPaid > 0 && balanceRemaining > 0;

  String get formattedDateBorrowed => '${dateBorrowed.day}/${dateBorrowed.month}/${dateBorrowed.year}';
  String get formattedExpectedRepaymentDate => '${expectedRepaymentDate.day}/${expectedRepaymentDate.month}/${expectedRepaymentDate.year}';

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(expectedRepaymentDate).inDays;
  }

  double get paymentPercentage => amountBorrowed > 0 ? (amountPaid / amountBorrowed) * 100 : 0;
}

class PayablesProvider extends ChangeNotifier {
  List<Payable> _payables = [];
  List<Payable> _filteredPayables = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Payable> get payables => _filteredPayables;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  PayablesProvider() {
    _initializePayables();
  }

  void _initializePayables() {
    final now = DateTime.now();
    _payables = [
      Payable(
        id: 'PAY001',
        creditorName: 'Textile Suppliers Ltd',
        creditorPhone: '+923001234567',
        amountBorrowed: 150000.0,
        reasonOrItem: 'Raw material purchase - Cotton fabric',
        dateBorrowed: now.subtract(const Duration(days: 30)),
        expectedRepaymentDate: now.add(const Duration(days: 15)),
        amountPaid: 75000.0,
        notes: 'Payment terms: 50% advance, balance on delivery',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Payable(
        id: 'PAY002',
        creditorName: 'Muhammad Enterprises',
        creditorPhone: '+923009876543',
        amountBorrowed: 85000.0,
        reasonOrItem: 'Equipment lease advance payment',
        dateBorrowed: now.subtract(const Duration(days: 45)),
        expectedRepaymentDate: now.subtract(const Duration(days: 10)),
        amountPaid: 0.0,
        notes: 'Industrial sewing machine lease - quarterly payment',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
      Payable(
        id: 'PAY003',
        creditorName: 'Ahmed Trading Co.',
        creditorPhone: '+923005555555',
        amountBorrowed: 220000.0,
        reasonOrItem: 'Bulk inventory purchase',
        dateBorrowed: now.subtract(const Duration(days: 20)),
        expectedRepaymentDate: now.add(const Duration(days: 25)),
        amountPaid: 120000.0,
        notes: 'Ready-made garments for retail store',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Payable(
        id: 'PAY004',
        creditorName: 'Fatima Logistics',
        creditorPhone: '+923007777777',
        amountBorrowed: 45000.0,
        reasonOrItem: 'Transportation services advance',
        dateBorrowed: now.subtract(const Duration(days: 15)),
        expectedRepaymentDate: now.add(const Duration(days: 5)),
        amountPaid: 45000.0,
        notes: 'Monthly logistics contract payment',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Payable(
        id: 'PAY005',
        creditorName: 'Steel Works Industries',
        creditorPhone: '+923003333333',
        amountBorrowed: 95000.0,
        reasonOrItem: 'Metal fixtures and fittings',
        dateBorrowed: now.subtract(const Duration(days: 35)),
        expectedRepaymentDate: now.add(const Duration(days: 20)),
        amountPaid: 30000.0,
        notes: 'Store renovation materials',
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      Payable(
        id: 'PAY006',
        creditorName: 'Power Solutions Ltd',
        creditorPhone: '+923008888888',
        amountBorrowed: 65000.0,
        reasonOrItem: 'Electrical work and installation',
        dateBorrowed: now.subtract(const Duration(days: 25)),
        expectedRepaymentDate: now.subtract(const Duration(days: 5)),
        amountPaid: 0.0,
        notes: 'Complete electrical setup for new outlet',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
    ];

    _filteredPayables = List.from(_payables);
  }

  void searchPayables(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPayables = List.from(_payables);
    } else {
      _filteredPayables = _payables
          .where((payable) =>
      payable.id.toLowerCase().contains(query.toLowerCase()) ||
          payable.creditorName.toLowerCase().contains(query.toLowerCase()) ||
          payable.creditorPhone.toLowerCase().contains(query.toLowerCase()) ||
          payable.reasonOrItem.toLowerCase().contains(query.toLowerCase()) ||
          payable.statusText.toLowerCase().contains(query.toLowerCase()) ||
          (payable.notes?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addPayable({
    required String creditorName,
    required String creditorPhone,
    required double amountBorrowed,
    required String reasonOrItem,
    required DateTime dateBorrowed,
    required DateTime expectedRepaymentDate,
    double amountPaid = 0.0,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newPayable = Payable(
      id: 'PAY${(_payables.length + 1).toString().padLeft(3, '0')}',
      creditorName: creditorName,
      creditorPhone: creditorPhone,
      amountBorrowed: amountBorrowed,
      reasonOrItem: reasonOrItem,
      dateBorrowed: dateBorrowed,
      expectedRepaymentDate: expectedRepaymentDate,
      amountPaid: amountPaid,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _payables.add(newPayable);
    searchPayables(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePayable({
    required String id,
    required String creditorName,
    required String creditorPhone,
    required double amountBorrowed,
    required String reasonOrItem,
    required DateTime dateBorrowed,
    required DateTime expectedRepaymentDate,
    double amountPaid = 0.0,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _payables.indexWhere((payable) => payable.id == id);
    if (index != -1) {
      _payables[index] = _payables[index].copyWith(
        creditorName: creditorName,
        creditorPhone: creditorPhone,
        amountBorrowed: amountBorrowed,
        reasonOrItem: reasonOrItem,
        dateBorrowed: dateBorrowed,
        expectedRepaymentDate: expectedRepaymentDate,
        amountPaid: amountPaid,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      searchPayables(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAmountPaid(String id, double amountPaid) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _payables.indexWhere((payable) => payable.id == id);
    if (index != -1) {
      _payables[index] = _payables[index].copyWith(
        amountPaid: amountPaid,
        updatedAt: DateTime.now(),
      );
      searchPayables(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deletePayable(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _payables.removeWhere((payable) => payable.id == id);
    searchPayables(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Payable? getPayableById(String id) {
    try {
      return _payables.firstWhere((payable) => payable.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Payable> getPayablesByCreditor(String creditorName) {
    return _payables.where((payable) =>
        payable.creditorName.toLowerCase().contains(creditorName.toLowerCase())).toList();
  }

  Map<String, dynamic> get payablesStats {
    final totalPayables = _payables.length;
    final totalAmountBorrowed = _payables.fold<double>(0, (sum, payable) => sum + payable.amountBorrowed);
    final totalAmountPaid = _payables.fold<double>(0, (sum, payable) => sum + payable.amountPaid);
    final totalOutstanding = _payables.fold<double>(0, (sum, payable) => sum + payable.balanceRemaining);
    final overdueCount = _payables.where((payable) => payable.isOverdue).length;
    final fullyPaidCount = _payables.where((payable) => payable.isFullyPaid).length;
    final partiallyPaidCount = _payables.where((payable) => payable.isPartiallyPaid).length;

    return {
      'total': totalPayables,
      'totalAmountBorrowed': totalAmountBorrowed.toStringAsFixed(0),
      'totalAmountPaid': totalAmountPaid.toStringAsFixed(0),
      'totalOutstanding': totalOutstanding.toStringAsFixed(0),
      'overdueCount': overdueCount,
      'fullyPaidCount': fullyPaidCount,
      'partiallyPaidCount': partiallyPaidCount,
      'paymentRate': totalAmountBorrowed > 0 ? ((totalAmountPaid / totalAmountBorrowed) * 100).toStringAsFixed(1) : '0.0',
    };
  }

  List<Payable> get overduePayables {
    return _payables.where((payable) => payable.isOverdue).toList();
  }

  List<Payable> get fullyPaidPayables {
    return _payables.where((payable) => payable.isFullyPaid).toList();
  }

  List<Payable> get partiallyPaidPayables {
    return _payables.where((payable) => payable.isPartiallyPaid).toList();
  }

  List<Payable> get pendingPayables {
    return _payables.where((payable) =>
    payable.statusText == 'Pending').toList();
  }

  List<Payable> get recentPayables {
    final recent = List<Payable>.from(_payables);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(10).toList();
  }

  Map<String, List<Payable>> get payablesByStatus {
    final Map<String, List<Payable>> grouped = {};
    for (final payable in _payables) {
      grouped[payable.statusText] = grouped[payable.statusText] ?? [];
      grouped[payable.statusText]!.add(payable);
    }
    return grouped;
  }

  Map<String, List<Payable>> get payablesByCreditor {
    final Map<String, List<Payable>> grouped = {};
    for (final payable in _payables) {
      grouped[payable.creditorName] = grouped[payable.creditorName] ?? [];
      grouped[payable.creditorName]!.add(payable);
    }
    return grouped;
  }

  List<Map<String, dynamic>> get creditorSummary {
    final grouped = payablesByCreditor;
    return grouped.entries.map((entry) {
      final creditorPayables = entry.value;
      final totalBorrowed = creditorPayables.fold<double>(0, (sum, p) => sum + p.amountBorrowed);
      final totalPaid = creditorPayables.fold<double>(0, (sum, p) => sum + p.amountPaid);
      final totalOutstanding = creditorPayables.fold<double>(0, (sum, p) => sum + p.balanceRemaining);
      final overdueCount = creditorPayables.where((p) => p.isOverdue).length;

      return {
        'creditorName': entry.key,
        'creditorPhone': creditorPayables.first.creditorPhone,
        'totalTransactions': creditorPayables.length,
        'totalBorrowed': totalBorrowed,
        'totalPaid': totalPaid,
        'totalOutstanding': totalOutstanding,
        'overdueCount': overdueCount,
        'paymentRate': totalBorrowed > 0 ? (totalPaid / totalBorrowed * 100) : 0,
        'lastTransaction': creditorPayables.map((p) => p.createdAt).reduce((a, b) => a.isAfter(b) ? a : b),
      };
    }).toList();
  }

  List<Payable> filterPayables({
    String? creditorName,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    bool? isOverdue,
  }) {
    return _payables.where((payable) {
      if (creditorName != null && !payable.creditorName.toLowerCase().contains(creditorName.toLowerCase())) return false;
      if (status != null && payable.statusText != status) return false;
      if (fromDate != null && payable.dateBorrowed.isBefore(fromDate)) return false;
      if (toDate != null && payable.dateBorrowed.isAfter(toDate)) return false;
      if (minAmount != null && payable.amountBorrowed < minAmount) return false;
      if (maxAmount != null && payable.amountBorrowed > maxAmount) return false;
      if (isOverdue != null && payable.isOverdue != isOverdue) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> exportPayablesData() {
    return _payables.map((payable) => {
      'Payable ID': payable.id,
      'Creditor Name': payable.creditorName,
      'Creditor Phone': payable.creditorPhone,
      'Amount Borrowed': payable.amountBorrowed.toStringAsFixed(2),
      'Amount Paid': payable.amountPaid.toStringAsFixed(2),
      'Balance Remaining': payable.balanceRemaining.toStringAsFixed(2),
      'Reason/Item': payable.reasonOrItem,
      'Date Borrowed': payable.formattedDateBorrowed,
      'Expected Repayment Date': payable.formattedExpectedRepaymentDate,
      'Status': payable.statusText,
      'Days Overdue': payable.isOverdue ? payable.daysOverdue.toString() : '0',
      'Payment Percentage': '${payable.paymentPercentage.toStringAsFixed(1)}%',
      'Notes': payable.notes ?? '',
      'Created At': payable.createdAt.toString().split(' ')[0],
      'Updated At': payable.updatedAt.toString().split(' ')[0],
    }).toList();
  }

  // Get payables that need attention (overdue, large amounts, etc.)
  List<Payable> get payablesNeedingAttention {
    return _payables.where((payable) {
      return payable.isOverdue ||
          payable.balanceRemaining > 50000 ||
          payable.daysOverdue > 30;
    }).toList();
  }

  // Monthly payables statistics
  Map<int, Map<String, dynamic>> get monthlyPayablesStats {
    final Map<int, List<Payable>> payablesByMonth = {};

    for (final payable in _payables) {
      final month = payable.dateBorrowed.month;
      payablesByMonth[month] = payablesByMonth[month] ?? [];
      payablesByMonth[month]!.add(payable);
    }

    return payablesByMonth.map((month, payables) {
      return MapEntry(month, {
        'month': month,
        'count': payables.length,
        'totalAmountBorrowed': payables.fold<double>(0, (sum, p) => sum + p.amountBorrowed),
        'totalAmountPaid': payables.fold<double>(0, (sum, p) => sum + p.amountPaid),
        'totalOutstanding': payables.fold<double>(0, (sum, p) => sum + p.balanceRemaining),
        'overdueCount': payables.where((p) => p.isOverdue).length,
        'fullyPaidCount': payables.where((p) => p.isFullyPaid).length,
      });
    });
  }

  // Get top creditors by outstanding amount
  List<Map<String, dynamic>> get topCreditorsByOutstanding {
    final creditorSummaryList = creditorSummary;
    creditorSummaryList.sort((a, b) =>
        (b['totalOutstanding'] as double).compareTo(a['totalOutstanding'] as double));
    return creditorSummaryList.take(10).toList();
  }

  // Get payables due this week
  List<Payable> get payablesDueThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _payables.where((payable) {
      return payable.expectedRepaymentDate.isAfter(startOfWeek) &&
          payable.expectedRepaymentDate.isBefore(endOfWeek) &&
          payable.balanceRemaining > 0;
    }).toList();
  }

  // Get aging analysis
  Map<String, int> get agingAnalysis {
    final now = DateTime.now();
    int current = 0;
    int days1to30 = 0;
    int days31to60 = 0;
    int days61to90 = 0;
    int over90Days = 0;

    for (final payable in _payables.where((p) => p.balanceRemaining > 0)) {
      final daysPastDue = now.difference(payable.expectedRepaymentDate).inDays;

      if (daysPastDue <= 0) {
        current++;
      } else if (daysPastDue <= 30) {
        days1to30++;
      } else if (daysPastDue <= 60) {
        days31to60++;
      } else if (daysPastDue <= 90) {
        days61to90++;
      } else {
        over90Days++;
      }
    }

    return {
      'current': current,
      '1-30 days': days1to30,
      '31-60 days': days31to60,
      '61-90 days': days61to90,
      'over 90 days': over90Days,
    };
  }
}