import 'package:flutter/material.dart';

class Payment {
  final String id;
  final String laborId;
  final String laborName;
  final String laborPhone;
  final String laborRole;
  final double amountPaid;
  final double bonus;
  final double deduction;
  final String paymentMonth;
  final bool isFinalPayment;
  final String paymentMethod;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String? receiptImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.laborId,
    required this.laborName,
    required this.laborPhone,
    required this.laborRole,
    required this.amountPaid,
    this.bonus = 0.0,
    this.deduction = 0.0,
    required this.paymentMonth,
    this.isFinalPayment = false,
    required this.paymentMethod,
    required this.description,
    required this.date,
    required this.time,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Payment copyWith({
    String? id,
    String? laborId,
    String? laborName,
    String? laborPhone,
    String? laborRole,
    double? amountPaid,
    double? bonus,
    double? deduction,
    String? paymentMonth,
    bool? isFinalPayment,
    String? paymentMethod,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      laborId: laborId ?? this.laborId,
      laborName: laborName ?? this.laborName,
      laborPhone: laborPhone ?? this.laborPhone,
      laborRole: laborRole ?? this.laborRole,
      amountPaid: amountPaid ?? this.amountPaid,
      bonus: bonus ?? this.bonus,
      deduction: deduction ?? this.deduction,
      paymentMonth: paymentMonth ?? this.paymentMonth,
      isFinalPayment: isFinalPayment ?? this.isFinalPayment,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeText => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String get dateTimeText => '${date.day}/${date.month}/${date.year} at $timeText';

  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  double get netAmount => amountPaid + bonus - deduction;

  Color get paymentMethodColor {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank':
      case 'bank transfer':
        return Colors.blue;
      case 'jazzcash':
      case 'easypaisa':
        return Colors.purple;
      case 'sadapay':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get paymentMethodIcon {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
      case 'bank transfer':
        return Icons.account_balance_rounded;
      case 'jazzcash':
      case 'easypaisa':
      case 'sadapay':
        return Icons.phone_android_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String get statusText {
    if (isFinalPayment) return 'Final Payment';
    if (bonus > 0) return 'With Bonus';
    if (deduction > 0) return 'With Deduction';
    return 'Regular Payment';
  }

  Color get statusColor {
    if (isFinalPayment) return Colors.green;
    if (bonus > 0) return Colors.blue;
    if (deduction > 0) return Colors.orange;
    return Colors.grey;
  }
}

// Labor model for dropdown selection
class PaymentLabor {
  final String id;
  final String name;
  final String phone;
  final String role;
  final double monthlySalary;
  final double totalAdvancesTaken;
  final double totalPaymentsMade;

  PaymentLabor({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.monthlySalary,
    required this.totalAdvancesTaken,
    required this.totalPaymentsMade,
  });

  double get remainingAmount => monthlySalary - totalAdvancesTaken - totalPaymentsMade;
}

class PaymentProvider extends ChangeNotifier {
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  List<PaymentLabor> _laborers = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Payment> get payments => _filteredPayments;
  List<PaymentLabor> get laborers => _laborers;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Payment methods
  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'JazzCash',
    'EasyPaisa',
    'SadaPay',
    'Check',
    'Other',
  ];

  PaymentProvider() {
    _initializeLaborers();
    _initializePayments();
  }

  void _initializeLaborers() {
    _laborers = [
      PaymentLabor(
        id: 'LAB001',
        name: 'Ahmed Ali',
        phone: '+923001234567',
        role: 'Tailor',
        monthlySalary: 45000.0,
        totalAdvancesTaken: 15000.0,
        totalPaymentsMade: 20000.0,
      ),
      PaymentLabor(
        id: 'LAB002',
        name: 'Muhammad Hassan',
        phone: '+923009876543',
        role: 'Embroidery Worker',
        monthlySalary: 40000.0,
        totalAdvancesTaken: 8000.0,
        totalPaymentsMade: 25000.0,
      ),
      PaymentLabor(
        id: 'LAB003',
        name: 'Fatima Sheikh',
        phone: '+923005555555',
        role: 'Designer',
        monthlySalary: 55000.0,
        totalAdvancesTaken: 20000.0,
        totalPaymentsMade: 30000.0,
      ),
      PaymentLabor(
        id: 'LAB004',
        name: 'Ali Raza',
        phone: '+923007777777',
        role: 'Cutting Master',
        monthlySalary: 50000.0,
        totalAdvancesTaken: 12000.0,
        totalPaymentsMade: 35000.0,
      ),
      PaymentLabor(
        id: 'LAB005',
        name: 'Ayesha Khan',
        phone: '+923003333333',
        role: 'Finishing Worker',
        monthlySalary: 35000.0,
        totalAdvancesTaken: 5000.0,
        totalPaymentsMade: 28000.0,
      ),
    ];
  }

  void _initializePayments() {
    final now = DateTime.now();
    _payments = [
      Payment(
        id: 'PAY001',
        laborId: 'LAB001',
        laborName: 'Ahmed Ali',
        laborPhone: '+923001234567',
        laborRole: 'Tailor',
        amountPaid: 25000.0,
        bonus: 2000.0,
        deduction: 0.0,
        paymentMonth: 'July 2025',
        isFinalPayment: true,
        paymentMethod: 'Cash',
        description: 'Final payment for July with performance bonus',
        date: now.subtract(const Duration(days: 2)),
        time: const TimeOfDay(hour: 14, minute: 30),
        receiptImagePath: 'payment_receipt_001.jpg',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Payment(
        id: 'PAY002',
        laborId: 'LAB002',
        laborName: 'Muhammad Hassan',
        laborPhone: '+923009876543',
        laborRole: 'Embroidery Worker',
        amountPaid: 15000.0,
        bonus: 0.0,
        deduction: 500.0,
        paymentMonth: 'July 2025',
        isFinalPayment: false,
        paymentMethod: 'JazzCash',
        description: 'Partial payment for July, late arrival deduction',
        date: now.subtract(const Duration(days: 5)),
        time: const TimeOfDay(hour: 10, minute: 15),
        receiptImagePath: 'payment_receipt_002.jpg',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Payment(
        id: 'PAY003',
        laborId: 'LAB003',
        laborName: 'Fatima Sheikh',
        laborPhone: '+923005555555',
        laborRole: 'Designer',
        amountPaid: 30000.0,
        bonus: 3000.0,
        deduction: 0.0,
        paymentMonth: 'July 2025',
        isFinalPayment: false,
        paymentMethod: 'Bank Transfer',
        description: 'Monthly payment with design excellence bonus',
        date: now.subtract(const Duration(days: 8)),
        time: const TimeOfDay(hour: 16, minute: 45),
        receiptImagePath: 'payment_receipt_003.jpg',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Payment(
        id: 'PAY004',
        laborId: 'LAB004',
        laborName: 'Ali Raza',
        laborPhone: '+923007777777',
        laborRole: 'Cutting Master',
        amountPaid: 20000.0,
        bonus: 0.0,
        deduction: 0.0,
        paymentMonth: 'July 2025',
        isFinalPayment: false,
        paymentMethod: 'EasyPaisa',
        description: 'Regular monthly payment installment',
        date: now.subtract(const Duration(days: 10)),
        time: const TimeOfDay(hour: 11, minute: 20),
        receiptImagePath: null,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Payment(
        id: 'PAY005',
        laborId: 'LAB005',
        laborName: 'Ayesha Khan',
        laborPhone: '+923003333333',
        laborRole: 'Finishing Worker',
        amountPaid: 18000.0,
        bonus: 1000.0,
        deduction: 0.0,
        paymentMonth: 'July 2025',
        isFinalPayment: false,
        paymentMethod: 'Cash',
        description: 'Payment with quality work bonus',
        date: now.subtract(const Duration(days: 15)),
        time: const TimeOfDay(hour: 9, minute: 0),
        receiptImagePath: 'payment_receipt_005.jpg',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
    ];

    _filteredPayments = List.from(_payments);
  }

  void searchPayments(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPayments = List.from(_payments);
    } else {
      _filteredPayments = _payments
          .where((payment) =>
      payment.id.toLowerCase().contains(query.toLowerCase()) ||
          payment.laborName.toLowerCase().contains(query.toLowerCase()) ||
          payment.laborPhone.toLowerCase().contains(query.toLowerCase()) ||
          payment.laborRole.toLowerCase().contains(query.toLowerCase()) ||
          payment.paymentMethod.toLowerCase().contains(query.toLowerCase()) ||
          payment.paymentMonth.toLowerCase().contains(query.toLowerCase()) ||
          payment.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addPayment({
    required String laborId,
    required double amountPaid,
    double bonus = 0.0,
    double deduction = 0.0,
    required String paymentMonth,
    bool isFinalPayment = false,
    required String paymentMethod,
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

    final newPayment = Payment(
      id: 'PAY${(_payments.length + 1).toString().padLeft(3, '0')}',
      laborId: laborId,
      laborName: labor.name,
      laborPhone: labor.phone,
      laborRole: labor.role,
      amountPaid: amountPaid,
      bonus: bonus,
      deduction: deduction,
      paymentMonth: paymentMonth,
      isFinalPayment: isFinalPayment,
      paymentMethod: paymentMethod,
      description: description,
      date: date,
      time: time,
      receiptImagePath: receiptImagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _payments.add(newPayment);

    // Update labor's total payments
    final laborIndex = _laborers.indexWhere((l) => l.id == laborId);
    if (laborIndex != -1) {
      _laborers[laborIndex] = PaymentLabor(
        id: labor.id,
        name: labor.name,
        phone: labor.phone,
        role: labor.role,
        monthlySalary: labor.monthlySalary,
        totalAdvancesTaken: labor.totalAdvancesTaken,
        totalPaymentsMade: labor.totalPaymentsMade + (amountPaid + bonus - deduction),
      );
    }

    searchPayments(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePayment({
    required String id,
    required String laborId,
    required double amountPaid,
    double bonus = 0.0,
    double deduction = 0.0,
    required String paymentMonth,
    bool isFinalPayment = false,
    required String paymentMethod,
    required String description,
    required DateTime date,
    required TimeOfDay time,
    String? receiptImagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _payments.indexWhere((payment) => payment.id == id);
    if (index != -1) {
      final labor = _laborers.firstWhere((l) => l.id == laborId);

      _payments[index] = _payments[index].copyWith(
        laborId: laborId,
        laborName: labor.name,
        laborPhone: labor.phone,
        laborRole: labor.role,
        amountPaid: amountPaid,
        bonus: bonus,
        deduction: deduction,
        paymentMonth: paymentMonth,
        isFinalPayment: isFinalPayment,
        paymentMethod: paymentMethod,
        description: description,
        date: date,
        time: time,
        receiptImagePath: receiptImagePath,
        updatedAt: DateTime.now(),
      );
      searchPayments(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deletePayment(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _payments.removeWhere((payment) => payment.id == id);
    searchPayments(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Payment> getPaymentsByLaborId(String laborId) {
    return _payments.where((payment) => payment.laborId == laborId).toList();
  }

  PaymentLabor? getLaborById(String laborId) {
    try {
      return _laborers.firstWhere((labor) => labor.id == laborId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> get paymentStats {
    final totalPayments = _payments.length;
    final totalAmount = _payments.fold<double>(0, (sum, payment) => sum + payment.netAmount);
    final totalBonus = _payments.fold<double>(0, (sum, payment) => sum + payment.bonus);
    final totalDeductions = _payments.fold<double>(0, (sum, payment) => sum + payment.deduction);
    final paymentsWithReceipts = _payments.where((payment) => payment.hasReceipt).length;
    final finalPayments = _payments.where((payment) => payment.isFinalPayment).length;

    final thisMonthPayments = _payments.where((payment) {
      final now = DateTime.now();
      return payment.date.month == now.month && payment.date.year == now.year;
    }).length;

    return {
      'total': totalPayments,
      'totalAmount': totalAmount.toStringAsFixed(0),
      'totalBonus': totalBonus.toStringAsFixed(0),
      'totalDeductions': totalDeductions.toStringAsFixed(0),
      'withReceipts': paymentsWithReceipts,
      'finalPayments': finalPayments,
      'thisMonth': thisMonthPayments,
    };
  }

  List<Payment> get recentPayments {
    final recent = List<Payment>.from(_payments);
    recent.sort((a, b) => b.date.compareTo(a.date));
    return recent.take(10).toList();
  }

  List<Payment> get paymentsWithBonuses {
    return _payments.where((payment) => payment.bonus > 0).toList();
  }

  List<Payment> get paymentsWithDeductions {
    return _payments.where((payment) => payment.deduction > 0).toList();
  }

  List<Payment> get paymentsWithoutReceipts {
    return _payments.where((payment) => !payment.hasReceipt).toList();
  }

  Map<String, dynamic> get financialSummary {
    final totalPaymentsMade = _payments.fold<double>(0, (sum, payment) => sum + payment.netAmount);
    final totalSalaryBudget = _laborers.fold<double>(0, (sum, labor) => sum + labor.monthlySalary);
    final totalRemainingBudget = _laborers.fold<double>(0, (sum, labor) => sum + labor.remainingAmount);
    final paymentPercentage = totalSalaryBudget > 0 ? (totalPaymentsMade / totalSalaryBudget * 100) : 0;

    return {
      'totalPaymentsMade': totalPaymentsMade,
      'totalSalaryBudget': totalSalaryBudget,
      'totalRemainingBudget': totalRemainingBudget,
      'paymentPercentage': paymentPercentage,
    };
  }

  List<Map<String, dynamic>> getLaborPaymentSummary() {
    return _laborers.map((labor) {
      final laborPayments = getPaymentsByLaborId(labor.id);
      final totalPaymentsMade = laborPayments.fold<double>(0, (sum, payment) => sum + payment.netAmount);
      final paymentsCount = laborPayments.length;
      final lastPaymentDate = laborPayments.isNotEmpty
          ? laborPayments.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      return {
        'labor': labor,
        'totalPaymentsMade': totalPaymentsMade,
        'paymentsCount': paymentsCount,
        'remainingAmount': labor.remainingAmount,
        'lastPaymentDate': lastPaymentDate,
        'paymentPercentage': labor.monthlySalary > 0 ? (totalPaymentsMade / labor.monthlySalary * 100) : 0,
      };
    }).toList();
  }

  List<Payment> filterPayments({
    String? laborId,
    String? paymentMethod,
    String? paymentMonth,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    bool? hasReceipt,
    bool? isFinalPayment,
  }) {
    return _payments.where((payment) {
      if (laborId != null && payment.laborId != laborId) return false;
      if (paymentMethod != null && payment.paymentMethod != paymentMethod) return false;
      if (paymentMonth != null && payment.paymentMonth != paymentMonth) return false;
      if (fromDate != null && payment.date.isBefore(fromDate)) return false;
      if (toDate != null && payment.date.isAfter(toDate)) return false;
      if (minAmount != null && payment.netAmount < minAmount) return false;
      if (maxAmount != null && payment.netAmount > maxAmount) return false;
      if (hasReceipt != null && payment.hasReceipt != hasReceipt) return false;
      if (isFinalPayment != null && payment.isFinalPayment != isFinalPayment) return false;
      return true;
    }).toList();
  }

  Map<String, List<Payment>> get paymentsByMethod {
    final Map<String, List<Payment>> grouped = {};
    for (final payment in _payments) {
      grouped[payment.paymentMethod] = grouped[payment.paymentMethod] ?? [];
      grouped[payment.paymentMethod]!.add(payment);
    }
    return grouped;
  }

  Map<String, List<Payment>> get paymentsByMonth {
    final Map<String, List<Payment>> grouped = {};
    for (final payment in _payments) {
      grouped[payment.paymentMonth] = grouped[payment.paymentMonth] ?? [];
      grouped[payment.paymentMonth]!.add(payment);
    }
    return grouped;
  }

  List<Map<String, dynamic>> exportPaymentData() {
    return _payments.map((payment) => {
      'Payment ID': payment.id,
      'Labor Name': payment.laborName,
      'Labor Phone': payment.laborPhone,
      'Labor Role': payment.laborRole,
      'Amount Paid': payment.amountPaid.toStringAsFixed(2),
      'Bonus': payment.bonus.toStringAsFixed(2),
      'Deduction': payment.deduction.toStringAsFixed(2),
      'Net Amount': payment.netAmount.toStringAsFixed(2),
      'Payment Month': payment.paymentMonth,
      'Payment Method': payment.paymentMethod,
      'Is Final Payment': payment.isFinalPayment ? 'Yes' : 'No',
      'Description': payment.description,
      'Date': payment.date.toString().split(' ')[0],
      'Time': payment.timeText,
      'Has Receipt': payment.hasReceipt ? 'Yes' : 'No',
      'Status': payment.statusText,
    }).toList();
  }

  // Get payments that need attention (no receipt, high amounts, etc.)
  List<Payment> get paymentsNeedingAttention {
    return _payments.where((payment) {
      return !payment.hasReceipt || payment.netAmount > 30000 || payment.deduction > 0;
    }).toList();
  }

  // Monthly payment statistics
  Map<int, Map<String, dynamic>> get monthlyPaymentStats {
    final Map<int, List<Payment>> paymentsByMonth = {};

    for (final payment in _payments) {
      final month = payment.date.month;
      paymentsByMonth[month] = paymentsByMonth[month] ?? [];
      paymentsByMonth[month]!.add(payment);
    }

    return paymentsByMonth.map((month, payments) {
      return MapEntry(month, {
        'month': month,
        'count': payments.length,
        'totalAmount': payments.fold<double>(0, (sum, payment) => sum + payment.netAmount),
        'totalBonus': payments.fold<double>(0, (sum, payment) => sum + payment.bonus),
        'totalDeductions': payments.fold<double>(0, (sum, payment) => sum + payment.deduction),
        'withReceipts': payments.where((p) => p.hasReceipt).length,
        'finalPayments': payments.where((p) => p.isFinalPayment).length,
      });
    });
  }
}