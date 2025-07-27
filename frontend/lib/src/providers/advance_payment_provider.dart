import 'package:flutter/material.dart';

class AdvancePayment {
  final String id;
  final String laborId;
  final String laborName;
  final String laborPhone;
  final String laborRole;
  final double amount;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String? receiptImagePath;
  final double remainingSalary;
  final double totalSalary;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdvancePayment({
    required this.id,
    required this.laborId,
    required this.laborName,
    required this.laborPhone,
    required this.laborRole,
    required this.amount,
    required this.description,
    required this.date,
    required this.time,
    this.receiptImagePath,
    required this.remainingSalary,
    required this.totalSalary,
    required this.createdAt,
    required this.updatedAt,
  });

  AdvancePayment copyWith({
    String? id,
    String? laborId,
    String? laborName,
    String? laborPhone,
    String? laborRole,
    double? amount,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? receiptImagePath,
    double? remainingSalary,
    double? totalSalary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdvancePayment(
      id: id ?? this.id,
      laborId: laborId ?? this.laborId,
      laborName: laborName ?? this.laborName,
      laborPhone: laborPhone ?? this.laborPhone,
      laborRole: laborRole ?? this.laborRole,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      remainingSalary: remainingSalary ?? this.remainingSalary,
      totalSalary: totalSalary ?? this.totalSalary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeText => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String get dateTimeText => '${date.day}/${date.month}/${date.year} at $timeText';

  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  double get advancePercentage => totalSalary > 0 ? (amount / totalSalary * 100) : 0;

  Color get statusColor {
    if (remainingSalary <= 0) return Colors.red;
    if (advancePercentage >= 80) return Colors.orange;
    if (advancePercentage >= 50) return Colors.yellow[700]!;
    return Colors.green;
  }

  String get statusText {
    if (remainingSalary <= 0) return 'Salary Exhausted';
    if (advancePercentage >= 80) return 'High Advance';
    if (advancePercentage >= 50) return 'Medium Advance';
    return 'Low Advance';
  }
}

// Labor model for dropdown selection
class Labor {
  final String id;
  final String name;
  final String phone;
  final String role;
  final double monthlySalary;
  final double totalAdvancesTaken;

  Labor({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.monthlySalary,
    required this.totalAdvancesTaken,
  });

  double get remainingSalary => monthlySalary - totalAdvancesTaken;
}

class AdvancePaymentProvider extends ChangeNotifier {
  List<AdvancePayment> _advancePayments = [];
  List<AdvancePayment> _filteredAdvancePayments = [];
  List<Labor> _laborers = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<AdvancePayment> get advancePayments => _filteredAdvancePayments;
  List<Labor> get laborers => _laborers;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  AdvancePaymentProvider() {
    _initializeLaborers();
    _initializeAdvancePayments();
  }

  void _initializeLaborers() {
    _laborers = [
      Labor(
        id: 'LAB001',
        name: 'Ahmed Ali',
        phone: '+923001234567',
        role: 'Tailor',
        monthlySalary: 45000.0,
        totalAdvancesTaken: 15000.0,
      ),
      Labor(
        id: 'LAB002',
        name: 'Muhammad Hassan',
        phone: '+923009876543',
        role: 'Embroidery Worker',
        monthlySalary: 40000.0,
        totalAdvancesTaken: 8000.0,
      ),
      Labor(
        id: 'LAB003',
        name: 'Fatima Sheikh',
        phone: '+923005555555',
        role: 'Designer',
        monthlySalary: 55000.0,
        totalAdvancesTaken: 20000.0,
      ),
      Labor(
        id: 'LAB004',
        name: 'Ali Raza',
        phone: '+923007777777',
        role: 'Cutting Master',
        monthlySalary: 50000.0,
        totalAdvancesTaken: 12000.0,
      ),
      Labor(
        id: 'LAB005',
        name: 'Ayesha Khan',
        phone: '+923003333333',
        role: 'Finishing Worker',
        monthlySalary: 35000.0,
        totalAdvancesTaken: 5000.0,
      ),
    ];
  }

  void _initializeAdvancePayments() {
    final now = DateTime.now();
    _advancePayments = [
      AdvancePayment(
        id: 'ADV001',
        laborId: 'LAB001',
        laborName: 'Ahmed Ali',
        laborPhone: '+923001234567',
        laborRole: 'Tailor',
        amount: 8000.0,
        description: 'Medical emergency - family expenses',
        date: now.subtract(const Duration(days: 5)),
        time: const TimeOfDay(hour: 14, minute: 30),
        receiptImagePath: 'receipt_001.jpg',
        remainingSalary: 30000.0,
        totalSalary: 45000.0,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      AdvancePayment(
        id: 'ADV002',
        laborId: 'LAB002',
        laborName: 'Muhammad Hassan',
        laborPhone: '+923009876543',
        laborRole: 'Embroidery Worker',
        amount: 5000.0,
        description: 'Children school fees payment',
        date: now.subtract(const Duration(days: 8)),
        time: const TimeOfDay(hour: 10, minute: 15),
        receiptImagePath: 'receipt_002.jpg',
        remainingSalary: 32000.0,
        totalSalary: 40000.0,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      AdvancePayment(
        id: 'ADV003',
        laborId: 'LAB003',
        laborName: 'Fatima Sheikh',
        laborPhone: '+923005555555',
        laborRole: 'Designer',
        amount: 12000.0,
        description: 'House rent advance payment',
        date: now.subtract(const Duration(days: 12)),
        time: const TimeOfDay(hour: 16, minute: 45),
        receiptImagePath: 'receipt_003.jpg',
        remainingSalary: 35000.0,
        totalSalary: 55000.0,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      AdvancePayment(
        id: 'ADV004',
        laborId: 'LAB004',
        laborName: 'Ali Raza',
        laborPhone: '+923007777777',
        laborRole: 'Cutting Master',
        amount: 7000.0,
        description: 'Personal urgent expenses',
        date: now.subtract(const Duration(days: 3)),
        time: const TimeOfDay(hour: 11, minute: 20),
        receiptImagePath: null,
        remainingSalary: 38000.0,
        totalSalary: 50000.0,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      AdvancePayment(
        id: 'ADV005',
        laborId: 'LAB005',
        laborName: 'Ayesha Khan',
        laborPhone: '+923003333333',
        laborRole: 'Finishing Worker',
        amount: 3000.0,
        description: 'Wedding function family expenses',
        date: now.subtract(const Duration(days: 15)),
        time: const TimeOfDay(hour: 9, minute: 0),
        receiptImagePath: 'receipt_005.jpg',
        remainingSalary: 30000.0,
        totalSalary: 35000.0,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      AdvancePayment(
        id: 'ADV006',
        laborId: 'LAB001',
        laborName: 'Ahmed Ali',
        laborPhone: '+923001234567',
        laborRole: 'Tailor',
        amount: 7000.0,
        description: 'Motorcycle repair and maintenance',
        date: now.subtract(const Duration(days: 20)),
        time: const TimeOfDay(hour: 15, minute: 10),
        receiptImagePath: 'receipt_006.jpg',
        remainingSalary: 22000.0,
        totalSalary: 45000.0,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
    ];

    _filteredAdvancePayments = List.from(_advancePayments);
  }

  void searchAdvancePayments(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredAdvancePayments = List.from(_advancePayments);
    } else {
      _filteredAdvancePayments = _advancePayments
          .where((payment) =>
      payment.id.toLowerCase().contains(query.toLowerCase()) ||
          payment.laborName.toLowerCase().contains(query.toLowerCase()) ||
          payment.laborPhone.toLowerCase().contains(query.toLowerCase()) ||
          payment.laborRole.toLowerCase().contains(query.toLowerCase()) ||
          payment.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addAdvancePayment({
    required String laborId,
    required double amount,
    required String description,
    required DateTime date,
    required TimeOfDay time,
    String? receiptImagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // Find labor details
    final labor = _laborers.firstWhere((l) => l.id == laborId);
    final remainingSalary = labor.remainingSalary - amount;

    final newAdvancePayment = AdvancePayment(
      id: 'ADV${(_advancePayments.length + 1).toString().padLeft(3, '0')}',
      laborId: laborId,
      laborName: labor.name,
      laborPhone: labor.phone,
      laborRole: labor.role,
      amount: amount,
      description: description,
      date: date,
      time: time,
      receiptImagePath: receiptImagePath,
      remainingSalary: remainingSalary,
      totalSalary: labor.monthlySalary,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _advancePayments.add(newAdvancePayment);

    // Update labor's total advances
    final laborIndex = _laborers.indexWhere((l) => l.id == laborId);
    if (laborIndex != -1) {
      _laborers[laborIndex] = Labor(
        id: labor.id,
        name: labor.name,
        phone: labor.phone,
        role: labor.role,
        monthlySalary: labor.monthlySalary,
        totalAdvancesTaken: labor.totalAdvancesTaken + amount,
      );
    }

    searchAdvancePayments(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAdvancePayment({
    required String id,
    required String laborId,
    required double amount,
    required String description,
    required DateTime date,
    required TimeOfDay time,
    String? receiptImagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _advancePayments.indexWhere((payment) => payment.id == id);
    if (index != -1) {
      final labor = _laborers.firstWhere((l) => l.id == laborId);
      final remainingSalary = labor.remainingSalary - amount;

      _advancePayments[index] = _advancePayments[index].copyWith(
        laborId: laborId,
        laborName: labor.name,
        laborPhone: labor.phone,
        laborRole: labor.role,
        amount: amount,
        description: description,
        date: date,
        time: time,
        receiptImagePath: receiptImagePath,
        remainingSalary: remainingSalary,
        totalSalary: labor.monthlySalary,
        updatedAt: DateTime.now(),
      );
      searchAdvancePayments(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAdvancePayment(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _advancePayments.removeWhere((payment) => payment.id == id);
    searchAdvancePayments(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  AdvancePayment? getAdvancePaymentById(String id) {
    try {
      return _advancePayments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  List<AdvancePayment> getAdvancePaymentsByLaborId(String laborId) {
    return _advancePayments.where((payment) => payment.laborId == laborId).toList();
  }

  Labor? getLaborById(String laborId) {
    try {
      return _laborers.firstWhere((labor) => labor.id == laborId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> get advancePaymentStats {
    final totalPayments = _advancePayments.length;
    final totalAmount = _advancePayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final paymentsWithReceipts = _advancePayments.where((payment) => payment.hasReceipt).length;
    final paymentsWithoutReceipts = totalPayments - paymentsWithReceipts;
    final averageAmount = totalPayments > 0 ? totalAmount / totalPayments : 0.0;

    final thisMonthPayments = _advancePayments.where((payment) {
      final now = DateTime.now();
      return payment.date.month == now.month && payment.date.year == now.year;
    }).length;

    return {
      'total': totalPayments,
      'totalAmount': totalAmount.toStringAsFixed(0),
      'withReceipts': paymentsWithReceipts,
      'withoutReceipts': paymentsWithoutReceipts,
      'averageAmount': averageAmount.toStringAsFixed(0),
      'thisMonth': thisMonthPayments,
    };
  }

  List<AdvancePayment> get recentAdvancePayments {
    final recent = List<AdvancePayment>.from(_advancePayments);
    recent.sort((a, b) => b.date.compareTo(a.date));
    return recent.take(10).toList();
  }

  List<AdvancePayment> get highAdvancePayments {
    return _advancePayments.where((payment) => payment.advancePercentage >= 50).toList();
  }

  List<AdvancePayment> get paymentsWithoutReceipts {
    return _advancePayments.where((payment) => !payment.hasReceipt).toList();
  }

  Map<String, dynamic> get financialSummary {
    final totalAdvancesPaid = _advancePayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final totalSalaryBudget = _laborers.fold<double>(0, (sum, labor) => sum + labor.monthlySalary);
    final totalRemainingBudget = _laborers.fold<double>(0, (sum, labor) => sum + labor.remainingSalary);
    final advancePercentage = totalSalaryBudget > 0 ? (totalAdvancesPaid / totalSalaryBudget * 100) : 0;

    return {
      'totalAdvancesPaid': totalAdvancesPaid,
      'totalSalaryBudget': totalSalaryBudget,
      'totalRemainingBudget': totalRemainingBudget,
      'advancePercentage': advancePercentage,
    };
  }

  List<Map<String, dynamic>> getLaborAdvanceSummary() {
    return _laborers.map((labor) {
      final laborPayments = getAdvancePaymentsByLaborId(labor.id);
      final totalAdvancesTaken = laborPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
      final paymentsCount = laborPayments.length;
      final lastAdvanceDate = laborPayments.isNotEmpty
          ? laborPayments.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      return {
        'labor': labor,
        'totalAdvancesTaken': totalAdvancesTaken,
        'paymentsCount': paymentsCount,
        'remainingSalary': labor.remainingSalary,
        'lastAdvanceDate': lastAdvanceDate,
        'advancePercentage': labor.monthlySalary > 0 ? (totalAdvancesTaken / labor.monthlySalary * 100) : 0,
      };
    }).toList();
  }

  List<AdvancePayment> filterAdvancePayments({
    String? laborId,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    bool? hasReceipt,
  }) {
    return _advancePayments.where((payment) {
      if (laborId != null && payment.laborId != laborId) return false;
      if (fromDate != null && payment.date.isBefore(fromDate)) return false;
      if (toDate != null && payment.date.isAfter(toDate)) return false;
      if (minAmount != null && payment.amount < minAmount) return false;
      if (maxAmount != null && payment.amount > maxAmount) return false;
      if (hasReceipt != null && payment.hasReceipt != hasReceipt) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> exportAdvancePaymentData() {
    return _advancePayments.map((payment) => {
      'Advance ID': payment.id,
      'Labor Name': payment.laborName,
      'Labor Phone': payment.laborPhone,
      'Labor Role': payment.laborRole,
      'Amount': payment.amount.toStringAsFixed(2),
      'Description': payment.description,
      'Date': payment.date.toString().split(' ')[0],
      'Time': payment.timeText,
      'Has Receipt': payment.hasReceipt ? 'Yes' : 'No',
      'Remaining Salary': payment.remainingSalary.toStringAsFixed(2),
      'Total Salary': payment.totalSalary.toStringAsFixed(2),
      'Advance Percentage': '${payment.advancePercentage.toStringAsFixed(1)}%',
      'Status': payment.statusText,
    }).toList();
  }

  // Get payments that need attention (no receipt, high percentage)
  List<AdvancePayment> get paymentsNeedingAttention {
    return _advancePayments.where((payment) {
      return !payment.hasReceipt || payment.advancePercentage >= 80;
    }).toList();
  }

  // Monthly advance payment statistics
  Map<int, Map<String, dynamic>> get monthlyAdvanceStats {
    final Map<int, List<AdvancePayment>> paymentsByMonth = {};

    for (final payment in _advancePayments) {
      final month = payment.date.month;
      paymentsByMonth[month] = paymentsByMonth[month] ?? [];
      paymentsByMonth[month]!.add(payment);
    }

    return paymentsByMonth.map((month, payments) {
      return MapEntry(month, {
        'month': month,
        'count': payments.length,
        'totalAmount': payments.fold<double>(0, (sum, payment) => sum + payment.amount),
        'withReceipts': payments.where((p) => p.hasReceipt).length,
        'withoutReceipts': payments.where((p) => !p.hasReceipt).length,
      });
    });
  }
}