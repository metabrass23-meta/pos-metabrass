import 'package:flutter/material.dart';

class Receivable {
  final String id;
  final String debtorName;
  final String debtorPhone;
  final double amountGiven;
  final String reasonOrItem;
  final DateTime dateLent;
  final DateTime expectedReturnDate;
  final double amountReturned;
  final double balanceRemaining;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Receivable({
    required this.id,
    required this.debtorName,
    required this.debtorPhone,
    required this.amountGiven,
    required this.reasonOrItem,
    required this.dateLent,
    required this.expectedReturnDate,
    this.amountReturned = 0.0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : balanceRemaining = amountGiven - amountReturned;

  Receivable copyWith({
    String? id,
    String? debtorName,
    String? debtorPhone,
    double? amountGiven,
    String? reasonOrItem,
    DateTime? dateLent,
    DateTime? expectedReturnDate,
    double? amountReturned,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receivable(
      id: id ?? this.id,
      debtorName: debtorName ?? this.debtorName,
      debtorPhone: debtorPhone ?? this.debtorPhone,
      amountGiven: amountGiven ?? this.amountGiven,
      reasonOrItem: reasonOrItem ?? this.reasonOrItem,
      dateLent: dateLent ?? this.dateLent,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      amountReturned: amountReturned ?? this.amountReturned,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusText {
    if (balanceRemaining <= 0) return 'Fully Paid';
    if (expectedReturnDate.isBefore(DateTime.now()) && balanceRemaining > 0) return 'Overdue';
    if (amountReturned > 0 && balanceRemaining > 0) return 'Partially Paid';
    return 'Pending';
  }

  Color get statusColor {
    if (balanceRemaining <= 0) return Colors.green;
    if (expectedReturnDate.isBefore(DateTime.now()) && balanceRemaining > 0) return Colors.red;
    if (amountReturned > 0 && balanceRemaining > 0) return Colors.orange;
    return Colors.blue;
  }

  bool get isOverdue => expectedReturnDate.isBefore(DateTime.now()) && balanceRemaining > 0;
  bool get isFullyPaid => balanceRemaining <= 0;
  bool get isPartiallyPaid => amountReturned > 0 && balanceRemaining > 0;

  String get formattedDateLent => '${dateLent.day}/${dateLent.month}/${dateLent.year}';
  String get formattedExpectedReturnDate => '${expectedReturnDate.day}/${expectedReturnDate.month}/${expectedReturnDate.year}';

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(expectedReturnDate).inDays;
  }

  double get returnPercentage => amountGiven > 0 ? (amountReturned / amountGiven) * 100 : 0;
}

class ReceivablesProvider extends ChangeNotifier {
  List<Receivable> _receivables = [];
  List<Receivable> _filteredReceivables = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Receivable> get receivables => _filteredReceivables;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  ReceivablesProvider() {
    _initializeReceivables();
  }

  void _initializeReceivables() {
    final now = DateTime.now();
    _receivables = [
      Receivable(
        id: 'REC001',
        debtorName: 'Ahmed Khan',
        debtorPhone: '+923001234567',
        amountGiven: 50000.0,
        reasonOrItem: 'Business loan for shop expansion',
        dateLent: now.subtract(const Duration(days: 45)),
        expectedReturnDate: now.add(const Duration(days: 15)),
        amountReturned: 20000.0,
        notes: 'Agreed to return in installments of 10k per month',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Receivable(
        id: 'REC002',
        debtorName: 'Fatima Ali',
        debtorPhone: '+923009876543',
        amountGiven: 25000.0,
        reasonOrItem: 'Wedding dress order advance',
        dateLent: now.subtract(const Duration(days: 30)),
        expectedReturnDate: now.subtract(const Duration(days: 5)),
        amountReturned: 0.0,
        notes: 'Wedding cancelled, amount to be returned',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Receivable(
        id: 'REC003',
        debtorName: 'Muhammad Hassan',
        debtorPhone: '+923005555555',
        amountGiven: 75000.0,
        reasonOrItem: 'Raw material supply advance',
        dateLent: now.subtract(const Duration(days: 60)),
        expectedReturnDate: now.add(const Duration(days: 30)),
        amountReturned: 40000.0,
        notes: 'Supplier payment for fabric shipment',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Receivable(
        id: 'REC004',
        debtorName: 'Sara Ahmed',
        debtorPhone: '+923007777777',
        amountGiven: 15000.0,
        reasonOrItem: 'Emergency personal loan',
        dateLent: now.subtract(const Duration(days: 20)),
        expectedReturnDate: now.add(const Duration(days: 10)),
        amountReturned: 15000.0,
        notes: 'Family emergency loan, returned with thanks',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Receivable(
        id: 'REC005',
        debtorName: 'Ali Raza',
        debtorPhone: '+923003333333',
        amountGiven: 35000.0,
        reasonOrItem: 'Equipment repair advance',
        dateLent: now.subtract(const Duration(days: 15)),
        expectedReturnDate: now.add(const Duration(days: 45)),
        amountReturned: 10000.0,
        notes: 'Payment for industrial sewing machine repair',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Receivable(
        id: 'REC006',
        debtorName: 'Ayesha Sheikh',
        debtorPhone: '+923008888888',
        amountGiven: 20000.0,
        reasonOrItem: 'Bulk order down payment',
        dateLent: now.subtract(const Duration(days: 25)),
        expectedReturnDate: now.subtract(const Duration(days: 10)),
        amountReturned: 0.0,
        notes: 'Order cancelled due to quality issues',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
    ];

    _filteredReceivables = List.from(_receivables);
  }

  void searchReceivables(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredReceivables = List.from(_receivables);
    } else {
      _filteredReceivables = _receivables
          .where((receivable) =>
      receivable.id.toLowerCase().contains(query.toLowerCase()) ||
          receivable.debtorName.toLowerCase().contains(query.toLowerCase()) ||
          receivable.debtorPhone.toLowerCase().contains(query.toLowerCase()) ||
          receivable.reasonOrItem.toLowerCase().contains(query.toLowerCase()) ||
          receivable.statusText.toLowerCase().contains(query.toLowerCase()) ||
          (receivable.notes?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addReceivable({
    required String debtorName,
    required String debtorPhone,
    required double amountGiven,
    required String reasonOrItem,
    required DateTime dateLent,
    required DateTime expectedReturnDate,
    double amountReturned = 0.0,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newReceivable = Receivable(
      id: 'REC${(_receivables.length + 1).toString().padLeft(3, '0')}',
      debtorName: debtorName,
      debtorPhone: debtorPhone,
      amountGiven: amountGiven,
      reasonOrItem: reasonOrItem,
      dateLent: dateLent,
      expectedReturnDate: expectedReturnDate,
      amountReturned: amountReturned,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _receivables.add(newReceivable);
    searchReceivables(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateReceivable({
    required String id,
    required String debtorName,
    required String debtorPhone,
    required double amountGiven,
    required String reasonOrItem,
    required DateTime dateLent,
    required DateTime expectedReturnDate,
    double amountReturned = 0.0,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _receivables.indexWhere((receivable) => receivable.id == id);
    if (index != -1) {
      _receivables[index] = _receivables[index].copyWith(
        debtorName: debtorName,
        debtorPhone: debtorPhone,
        amountGiven: amountGiven,
        reasonOrItem: reasonOrItem,
        dateLent: dateLent,
        expectedReturnDate: expectedReturnDate,
        amountReturned: amountReturned,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      searchReceivables(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAmountReturned(String id, double amountReturned) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _receivables.indexWhere((receivable) => receivable.id == id);
    if (index != -1) {
      _receivables[index] = _receivables[index].copyWith(
        amountReturned: amountReturned,
        updatedAt: DateTime.now(),
      );
      searchReceivables(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteReceivable(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _receivables.removeWhere((receivable) => receivable.id == id);
    searchReceivables(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Receivable? getReceivableById(String id) {
    try {
      return _receivables.firstWhere((receivable) => receivable.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Receivable> getReceivablesByDebtor(String debtorName) {
    return _receivables.where((receivable) =>
        receivable.debtorName.toLowerCase().contains(debtorName.toLowerCase())).toList();
  }

  Map<String, dynamic> get receivablesStats {
    final totalReceivables = _receivables.length;
    final totalAmountLent = _receivables.fold<double>(0, (sum, receivable) => sum + receivable.amountGiven);
    final totalAmountReturned = _receivables.fold<double>(0, (sum, receivable) => sum + receivable.amountReturned);
    final totalOutstanding = _receivables.fold<double>(0, (sum, receivable) => sum + receivable.balanceRemaining);
    final overdueCount = _receivables.where((receivable) => receivable.isOverdue).length;
    final fullyPaidCount = _receivables.where((receivable) => receivable.isFullyPaid).length;
    final partiallyPaidCount = _receivables.where((receivable) => receivable.isPartiallyPaid).length;

    return {
      'total': totalReceivables,
      'totalAmountLent': totalAmountLent.toStringAsFixed(0),
      'totalAmountReturned': totalAmountReturned.toStringAsFixed(0),
      'totalOutstanding': totalOutstanding.toStringAsFixed(0),
      'overdueCount': overdueCount,
      'fullyPaidCount': fullyPaidCount,
      'partiallyPaidCount': partiallyPaidCount,
      'returnRate': totalAmountLent > 0 ? ((totalAmountReturned / totalAmountLent) * 100).toStringAsFixed(1) : '0.0',
    };
  }

  List<Receivable> get overdueReceivables {
    return _receivables.where((receivable) => receivable.isOverdue).toList();
  }

  List<Receivable> get fullyPaidReceivables {
    return _receivables.where((receivable) => receivable.isFullyPaid).toList();
  }

  List<Receivable> get partiallyPaidReceivables {
    return _receivables.where((receivable) => receivable.isPartiallyPaid).toList();
  }

  List<Receivable> get pendingReceivables {
    return _receivables.where((receivable) =>
    receivable.statusText == 'Pending').toList();
  }

  List<Receivable> get recentReceivables {
    final recent = List<Receivable>.from(_receivables);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(10).toList();
  }

  Map<String, List<Receivable>> get receivablesByStatus {
    final Map<String, List<Receivable>> grouped = {};
    for (final receivable in _receivables) {
      grouped[receivable.statusText] = grouped[receivable.statusText] ?? [];
      grouped[receivable.statusText]!.add(receivable);
    }
    return grouped;
  }

  Map<String, List<Receivable>> get receivablesByDebtor {
    final Map<String, List<Receivable>> grouped = {};
    for (final receivable in _receivables) {
      grouped[receivable.debtorName] = grouped[receivable.debtorName] ?? [];
      grouped[receivable.debtorName]!.add(receivable);
    }
    return grouped;
  }

  List<Map<String, dynamic>> get debtorSummary {
    final grouped = receivablesByDebtor;
    return grouped.entries.map((entry) {
      final debtorReceivables = entry.value;
      final totalLent = debtorReceivables.fold<double>(0, (sum, r) => sum + r.amountGiven);
      final totalReturned = debtorReceivables.fold<double>(0, (sum, r) => sum + r.amountReturned);
      final totalOutstanding = debtorReceivables.fold<double>(0, (sum, r) => sum + r.balanceRemaining);
      final overdueCount = debtorReceivables.where((r) => r.isOverdue).length;

      return {
        'debtorName': entry.key,
        'debtorPhone': debtorReceivables.first.debtorPhone,
        'totalTransactions': debtorReceivables.length,
        'totalLent': totalLent,
        'totalReturned': totalReturned,
        'totalOutstanding': totalOutstanding,
        'overdueCount': overdueCount,
        'returnRate': totalLent > 0 ? (totalReturned / totalLent * 100) : 0,
        'lastTransaction': debtorReceivables.map((r) => r.createdAt).reduce((a, b) => a.isAfter(b) ? a : b),
      };
    }).toList();
  }

  List<Receivable> filterReceivables({
    String? debtorName,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    bool? isOverdue,
  }) {
    return _receivables.where((receivable) {
      if (debtorName != null && !receivable.debtorName.toLowerCase().contains(debtorName.toLowerCase())) return false;
      if (status != null && receivable.statusText != status) return false;
      if (fromDate != null && receivable.dateLent.isBefore(fromDate)) return false;
      if (toDate != null && receivable.dateLent.isAfter(toDate)) return false;
      if (minAmount != null && receivable.amountGiven < minAmount) return false;
      if (maxAmount != null && receivable.amountGiven > maxAmount) return false;
      if (isOverdue != null && receivable.isOverdue != isOverdue) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> exportReceivablesData() {
    return _receivables.map((receivable) => {
      'Receivable ID': receivable.id,
      'Debtor Name': receivable.debtorName,
      'Debtor Phone': receivable.debtorPhone,
      'Amount Given': receivable.amountGiven.toStringAsFixed(2),
      'Amount Returned': receivable.amountReturned.toStringAsFixed(2),
      'Balance Remaining': receivable.balanceRemaining.toStringAsFixed(2),
      'Reason/Item': receivable.reasonOrItem,
      'Date Lent': receivable.formattedDateLent,
      'Expected Return Date': receivable.formattedExpectedReturnDate,
      'Status': receivable.statusText,
      'Days Overdue': receivable.isOverdue ? receivable.daysOverdue.toString() : '0',
      'Return Percentage': '${receivable.returnPercentage.toStringAsFixed(1)}%',
      'Notes': receivable.notes ?? '',
      'Created At': receivable.createdAt.toString().split(' ')[0],
      'Updated At': receivable.updatedAt.toString().split(' ')[0],
    }).toList();
  }

  // Get receivables that need attention (overdue, large amounts, etc.)
  List<Receivable> get receivablesNeedingAttention {
    return _receivables.where((receivable) {
      return receivable.isOverdue ||
          receivable.balanceRemaining > 50000 ||
          receivable.daysOverdue > 30;
    }).toList();
  }

  // Monthly receivables statistics
  Map<int, Map<String, dynamic>> get monthlyReceivablesStats {
    final Map<int, List<Receivable>> receivablesByMonth = {};

    for (final receivable in _receivables) {
      final month = receivable.dateLent.month;
      receivablesByMonth[month] = receivablesByMonth[month] ?? [];
      receivablesByMonth[month]!.add(receivable);
    }

    return receivablesByMonth.map((month, receivables) {
      return MapEntry(month, {
        'month': month,
        'count': receivables.length,
        'totalAmountLent': receivables.fold<double>(0, (sum, r) => sum + r.amountGiven),
        'totalAmountReturned': receivables.fold<double>(0, (sum, r) => sum + r.amountReturned),
        'totalOutstanding': receivables.fold<double>(0, (sum, r) => sum + r.balanceRemaining),
        'overdueCount': receivables.where((r) => r.isOverdue).length,
        'fullyPaidCount': receivables.where((r) => r.isFullyPaid).length,
      });
    });
  }

  // Get top debtors by outstanding amount
  List<Map<String, dynamic>> get topDebtorsByOutstanding {
    final debtorSummaryList = debtorSummary;
    debtorSummaryList.sort((a, b) =>
        (b['totalOutstanding'] as double).compareTo(a['totalOutstanding'] as double));
    return debtorSummaryList.take(10).toList();
  }

  // Get receivables due this week
  List<Receivable> get receivablesDueThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _receivables.where((receivable) {
      return receivable.expectedReturnDate.isAfter(startOfWeek) &&
          receivable.expectedReturnDate.isBefore(endOfWeek) &&
          receivable.balanceRemaining > 0;
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

    for (final receivable in _receivables.where((r) => r.balanceRemaining > 0)) {
      final daysPastDue = now.difference(receivable.expectedReturnDate).inDays;

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