import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/labor/labor_service.dart';

class Payment {
  final String id;
  final String? laborId;
  final String? vendorId;
  final String? orderId;
  final String? saleId;
  final String? laborName;
  final String? laborPhone;
  final String? laborRole;
  final String? vendorName;
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
  final String payerType;
  final String? payerId;
  final bool isActive;

  Payment({
    required this.id,
    this.laborId,
    this.vendorId,
    this.orderId,
    this.saleId,
    this.laborName,
    this.laborPhone,
    this.laborRole,
    this.vendorName,
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
    required this.payerType,
    this.payerId,
    this.isActive = true,
  });

  Payment copyWith({
    String? id,
    String? laborId,
    String? vendorId,
    String? orderId,
    String? saleId,
    String? laborName,
    String? laborPhone,
    String? laborRole,
    String? vendorName,
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
    String? payerType,
    String? payerId,
    bool? isActive,
  }) {
    return Payment(
      id: id ?? this.id,
      laborId: laborId ?? this.laborId,
      vendorId: vendorId ?? this.vendorId,
      orderId: orderId ?? this.orderId,
      saleId: saleId ?? this.saleId,
      laborName: laborName ?? this.laborName,
      vendorName: vendorName ?? this.vendorName,
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
      payerType: payerType ?? this.payerType,
      payerId: payerId ?? this.payerId,
      isActive: isActive ?? this.isActive,
    );
  }

  String get timeText => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String get dateTimeText => '${date.day}/${date.month}/${date.year} at $timeText';

  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  double get netAmount => amountPaid + bonus - deduction;

  String get displayName {
    if (laborName != null) return laborName!;
    if (vendorName != null) return vendorName!;
    return 'Unknown';
  }

  Color get paymentMethodColor {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank_transfer':
        return Colors.blue;
      case 'mobile_payment':
        return Colors.purple;
      case 'check':
        return Colors.orange;
      case 'card':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData get paymentMethodIcon {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      case 'mobile_payment':
        return Icons.phone_android_rounded;
      case 'check':
        return Icons.receipt_long_rounded;
      case 'card':
        return Icons.credit_card_rounded;
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

  factory Payment.fromJson(Map<String, dynamic> json) {
    try {
      // Safe date parsing with fallback
      DateTime parseDate;
      try {
        final dateParts = (json['date'] as String).split('-');
        if (dateParts.length == 3) {
          parseDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
        } else {
          parseDate = DateTime.now();
        }
      } catch (e) {
        debugPrint('Error parsing date: $e, using current date');
        parseDate = DateTime.now();
      }

      // Safe time parsing with fallback
      TimeOfDay parseTime;
      try {
        final timeParts = (json['time'] as String).split(':');
        if (timeParts.length == 2) {
          parseTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        } else {
          parseTime = TimeOfDay.now();
        }
      } catch (e) {
        debugPrint('Error parsing time: $e, using current time');
        parseTime = TimeOfDay.now();
      }

      // Safe DateTime parsing with fallback
      DateTime parseCreatedAt;
      try {
        parseCreatedAt = DateTime.parse(json['created_at']);
      } catch (e) {
        debugPrint('Error parsing created_at: $e, using current time');
        parseCreatedAt = DateTime.now();
      }

      DateTime parseUpdatedAt;
      try {
        parseUpdatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now();
      } catch (e) {
        debugPrint('Error parsing updated_at: $e, using current time');
        parseUpdatedAt = DateTime.now();
      }

      return Payment(
        id: json['id'] ?? '',
        laborId: json['labor'],
        vendorId: json['vendor'],
        orderId: json['order'],
        saleId: json['sale'],
        laborName: json['labor_name'],
        laborPhone: json['labor_phone'],
        laborRole: json['labor_role'],
        vendorName: json['vendor_name'],
        amountPaid: double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0.0,
        bonus: double.tryParse(json['bonus']?.toString() ?? '0') ?? 0.0,
        deduction: double.tryParse(json['deduction']?.toString() ?? '0') ?? 0.0,
        paymentMonth: json['payment_month'] ?? '',
        isFinalPayment: json['is_final_payment'] ?? false,
        paymentMethod: json['payment_method'] ?? '',
        description: json['description'] ?? '',
        date: parseDate,
        time: parseTime,
        receiptImagePath: json['receipt_image_path'],
        createdAt: parseCreatedAt,
        updatedAt: parseUpdatedAt,
        payerType: json['payer_type'] ?? '',
        payerId: json['payer_id'],
        isActive: json['is_active'] ?? true,
      );
    } catch (e) {
      debugPrint('Error parsing payment JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labor': laborId,
      'vendor': vendorId,
      'order': orderId,
      'sale': saleId,
      'labor_name': laborName,
      'labor_phone': laborPhone,
      'labor_role': laborRole,
      'vendor_name': vendorName,
      'amount_paid': amountPaid,
      'bonus': bonus,
      'deduction': deduction,
      'payment_month': paymentMonth,
      'is_final_payment': isFinalPayment,
      'payment_method': paymentMethod,
      'description': description,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'receipt_image_path': receiptImagePath,
      'payer_type': payerType,
      'payer_id': payerId,
      'is_active': isActive,
    };
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
  String? _errorMessage;

  // Filter state variables
  String? _selectedLaborId;
  String? _selectedPayerType;
  String? _selectedPaymentMethod;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  DateTime? _paymentMonthFrom;
  DateTime? _paymentMonthTo;
  double? _minAmount;
  double? _maxAmount;
  bool? _hasReceipt;
  bool? _isFinalPayment;
  String _sortBy = 'date';
  bool _sortAscending = false;
  bool _showInactive = true;

  final PaymentService _paymentService = PaymentService();
  final LaborService _laborService = LaborService();

  List<Payment> get payments => _filteredPayments;
  List<Payment> get allPayments => _payments;
  List<PaymentLabor> get laborers => _laborers;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter getters
  String? get selectedLaborId => _selectedLaborId;
  String? get selectedPayerType => _selectedPayerType;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;
  DateTime? get paymentMonthFrom => _paymentMonthFrom;
  DateTime? get paymentMonthTo => _paymentMonthTo;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  bool? get hasReceipt => _hasReceipt;
  bool? get isFinalPayment => _isFinalPayment;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  bool get showInactive => _showInactive;

  // Payment methods
  static const List<String> paymentMethods = ['CASH', 'BANK_TRANSFER', 'MOBILE_PAYMENT', 'CHECK', 'CARD', 'OTHER'];

  // Payer types
  static const List<String> payerTypes = ['LABOR', 'VENDOR', 'CUSTOMER', 'OTHER'];

  PaymentProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([_loadLaborers(), _loadPayments()]);
  }

  Future<void> _loadLaborers() async {
    try {
      final response = await _laborService.getLabors();
      if (response.success && response.data != null) {
        final labors = response.data!.labors;
        debugPrint('Loading ${labors.length} laborers');
        _laborers = labors
            .map(
              (labor) => PaymentLabor(
                id: labor.id,
                name: labor.name,
                phone: labor.phoneNumber,
                role: labor.designation,
                monthlySalary: labor.salary,
                totalAdvancesTaken: labor.totalAdvanceAmount,
                totalPaymentsMade: labor.totalPaymentsAmount,
              ),
            )
            .toList();
        debugPrint('Loaded ${_laborers.length} laborers');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading laborers: $e');
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  Future<void> _loadPayments() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPayments();

      if (response.success && response.data != null) {
        final paymentsData = response.data!;
        if (paymentsData['payments'] != null) {
          final paymentsList = paymentsData['payments'] as List;
          debugPrint('Loading ${paymentsList.length} payments');
          try {
            _payments = paymentsList.map((json) {
              debugPrint('Parsing payment JSON: $json');
              final payment = Payment.fromJson(json);
              debugPrint('Parsed payment: ${payment.id} - ${payment.laborName}');
              return payment;
            }).toList();
            _filteredPayments = List.from(_payments);
            debugPrint('Loaded ${_payments.length} payments, filtered: ${_filteredPayments.length}');
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing payments: $e');
            _setError('Error parsing payment data: $e');
          }
        }
      } else {
        _setError(response.message ?? 'Failed to load payments');
      }
    } catch (e) {
      _setError('An error occurred while loading payments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchPayments(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPayments = List.from(_payments);
    } else {
      _filteredPayments = _payments
          .where(
            (payment) =>
                payment.id.toLowerCase().contains(query.toLowerCase()) ||
                (payment.laborName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (payment.vendorName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (payment.laborPhone?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (payment.laborRole?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                payment.paymentMethod.toLowerCase().contains(query.toLowerCase()) ||
                payment.paymentMonth.toLowerCase().contains(query.toLowerCase()) ||
                payment.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    notifyListeners();
  }

  Future<void> addPayment({
    required String? laborId,
    required String? vendorId,
    required String? orderId,
    required String? saleId,
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
    required String payerType,
    String? payerId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final paymentData = {
        'labor': laborId,
        'vendor': vendorId,
        'order': orderId,
        'sale': saleId,
        'amount_paid': amountPaid,
        'bonus': bonus,
        'deduction': deduction,
        'payment_month': paymentMonth,
        'is_final_payment': isFinalPayment,
        'payment_method': paymentMethod,
        'description': description,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'receipt_image_path': receiptImagePath,
        'payer_type': payerType,
        'payer_id': payerId,
      };

      final response = await _paymentService.createPayment(paymentData);

      if (response.success) {
        await _loadPayments(); // Reload payments
        searchPayments(_searchQuery); // Reapply search filter
      } else {
        _setError(response.message ?? 'Failed to create payment');
      }
    } catch (e) {
      _setError('An error occurred while creating payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePayment({
    required String id,
    required String? laborId,
    required String? vendorId,
    required String? orderId,
    required String? saleId,
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
    required String payerType,
    String? payerId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final paymentData = {
        'labor': laborId,
        'vendor': vendorId,
        'order': orderId,
        'sale': saleId,
        'amount_paid': amountPaid,
        'bonus': bonus,
        'deduction': deduction,
        'payment_month': paymentMonth,
        'is_final_payment': isFinalPayment,
        'payment_method': paymentMethod,
        'description': description,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'receipt_image_path': receiptImagePath,
        'payer_type': payerType,
        'payer_id': payerId,
      };

      final response = await _paymentService.updatePayment(id, paymentData);

      if (response.success) {
        await _loadPayments(); // Reload payments
        searchPayments(_searchQuery); // Reapply search filter
      } else {
        _setError(response.message ?? 'Failed to update payment');
      }
    } catch (e) {
      _setError('An error occurred while updating payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePayment(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.deletePayment(id);

      if (response.success) {
        await _loadPayments(); // Reload payments
        searchPayments(_searchQuery); // Reapply search filter
      } else {
        _setError(response.message ?? 'Failed to delete payment');
      }
    } catch (e) {
      _setError('An error occurred while deleting payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> softDeletePayment(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.softDeletePayment(id);

      if (response.success) {
        await _loadPayments(); // Reload payments
        searchPayments(_searchQuery); // Reapply search filter
      } else {
        _setError(response.message ?? 'Failed to soft delete payment');
      }
    } catch (e) {
      _setError('An error occurred while soft deleting payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restorePayment(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.restorePayment(id);

      if (response.success) {
        await _loadPayments(); // Reload payments
        searchPayments(_searchQuery); // Reapply search filter
      } else {
        _setError(response.message ?? 'Failed to restore payment');
      }
    } catch (e) {
      _setError('An error occurred while restoring payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsFinalPayment(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.markAsFinalPayment(id);

      if (response.success) {
        await _loadPayments(); // Reload payments
        searchPayments(_searchQuery); // Reapply search filter
      } else {
        _setError(response.message ?? 'Failed to mark payment as final');
      }
    } catch (e) {
      _setError('An error occurred while marking payment as final: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Additional payment methods
  Future<void> getPaymentsByVendor(String vendorId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPaymentsByVendor(vendorId);
      if (response.success && response.data != null) {
        // Handle vendor payments response
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to get vendor payments');
      }
    } catch (e) {
      _setError('An error occurred while getting vendor payments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPaymentsByOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPaymentsByOrder(orderId);
      if (response.success && response.data != null) {
        // Handle order payments response
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to get order payments');
      }
    } catch (e) {
      _setError('An error occurred while getting order payments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPaymentsBySale(String saleId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPaymentsBySale(saleId);
      if (response.success && response.data != null) {
        // Handle sale payments response
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to get sale payments');
      }
    } catch (e) {
      _setError('An error occurred while getting sale payments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPaymentsByMethod(String method) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPaymentsByMethod(method);
      if (response.success && response.data != null) {
        // Handle method payments response
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to get payments by method');
      }
    } catch (e) {
      _setError('An error occurred while getting payments by method: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPaymentsWithReceipts() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPaymentsWithReceipts();
      if (response.success && response.data != null) {
        // Handle receipts payments response
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to get payments with receipts');
      }
    } catch (e) {
      _setError('An error occurred while getting payments with receipts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPaymentsWithoutReceipts() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _paymentService.getPaymentsWithoutReceipts();
      if (response.success && response.data != null) {
        // Handle no receipts payments response
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to get payments without receipts');
      }
    } catch (e) {
      _setError('An error occurred while getting payments without receipts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshPayments() async {
    await _loadPayments();
    searchPayments(_searchQuery);
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

  List<Payment> getPaymentsByVendorId(String vendorId) {
    return _payments.where((payment) => payment.vendorId == vendorId).toList();
  }

  List<Payment> getPaymentsByOrderId(String orderId) {
    return _payments.where((payment) => payment.orderId == orderId).toList();
  }

  List<Payment> getPaymentsBySaleId(String saleId) {
    return _payments.where((payment) => payment.saleId == saleId).toList();
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

  List<Payment> filterPayments({
    String? laborId,
    String? vendorId,
    String? orderId,
    String? saleId,
    String? paymentMethod,
    String? paymentMonth,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
    bool? hasReceipt,
    bool? isFinalPayment,
    String? payerType,
  }) {
    return _payments.where((payment) {
      if (laborId != null && payment.laborId != laborId) return false;
      if (vendorId != null && payment.vendorId != vendorId) return false;
      if (orderId != null && payment.orderId != orderId) return false;
      if (saleId != null && payment.saleId != saleId) return false;
      if (paymentMethod != null && payment.paymentMethod != paymentMethod) return false;
      if (paymentMonth != null && payment.paymentMonth != paymentMonth) return false;
      if (fromDate != null && payment.date.isBefore(fromDate)) return false;
      if (toDate != null && payment.date.isAfter(toDate)) return false;
      if (minAmount != null && payment.netAmount < minAmount) return false;
      if (maxAmount != null && payment.netAmount > maxAmount) return false;
      if (hasReceipt != null && payment.hasReceipt != hasReceipt) return false;
      if (isFinalPayment != null && payment.isFinalPayment != isFinalPayment) return false;
      if (payerType != null && payment.payerType != payerType) return false;
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
    return _payments
        .map(
          (payment) => {
            'Payment ID': payment.id,
            'Labor Name': payment.laborName ?? 'N/A',
            'Vendor Name': payment.vendorName ?? 'N/A',
            'Labor Phone': payment.laborPhone ?? 'N/A',
            'Labor Role': payment.laborRole ?? 'N/A',
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
            'Payer Type': payment.payerType,
          },
        )
        .toList();
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

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Filter methods
  Future<void> setLaborFilter(String? laborId) async {
    _selectedLaborId = laborId;
    await _applyFilters();
  }

  Future<void> setPayerTypeFilter(String? payerType) async {
    _selectedPayerType = payerType;
    await _applyFilters();
  }

  Future<void> setPaymentMethodFilter(String? paymentMethod) async {
    _selectedPaymentMethod = paymentMethod;
    await _applyFilters();
  }

  Future<void> setDateRangeFilter(DateTime? dateFrom, DateTime? dateTo) async {
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    await _applyFilters();
  }

  Future<void> setPaymentMonthRangeFilter(DateTime? monthFrom, DateTime? monthTo) async {
    _paymentMonthFrom = monthFrom;
    _paymentMonthTo = monthTo;
    await _applyFilters();
  }

  Future<void> setAmountRangeFilter(double? minAmount, double? maxAmount) async {
    _minAmount = minAmount;
    _maxAmount = maxAmount;
    await _applyFilters();
  }

  Future<void> setReceiptFilter(bool? hasReceipt) async {
    _hasReceipt = hasReceipt;
    await _applyFilters();
  }

  Future<void> setFinalPaymentFilter(bool? isFinalPayment) async {
    _isFinalPayment = isFinalPayment;
    await _applyFilters();
  }

  Future<void> setSortOptions(String sortBy, bool sortAscending) async {
    _sortBy = sortBy;
    _sortAscending = sortAscending;
    await _applyFilters();
  }

  Future<void> setShowInactiveFilter(bool showInactive) async {
    _showInactive = showInactive;
    await _applyFilters();
  }

  Future<void> resetFilters() async {
    _selectedLaborId = null;
    _selectedPayerType = null;
    _selectedPaymentMethod = null;
    _dateFrom = null;
    _dateTo = null;
    _paymentMonthFrom = null;
    _paymentMonthTo = null;
    _minAmount = null;
    _maxAmount = null;
    _hasReceipt = null;
    _isFinalPayment = null;
    _sortBy = 'date';
    _sortAscending = false;
    _showInactive = true;
    await _applyFilters();
  }

  Future<void> _applyFilters() async {
    _filteredPayments = _payments.where((payment) {
      // Labor filter
      if (_selectedLaborId != null && payment.laborId != _selectedLaborId) {
        return false;
      }

      // Payer type filter
      if (_selectedPayerType != null && payment.payerType != _selectedPayerType) {
        return false;
      }

      // Payment method filter
      if (_selectedPaymentMethod != null && payment.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      // Date range filter
      if (_dateFrom != null && payment.date.isBefore(_dateFrom!)) {
        return false;
      }
      if (_dateTo != null && payment.date.isAfter(_dateTo!)) {
        return false;
      }

      // Payment month range filter
      if (_paymentMonthFrom != null || _paymentMonthTo != null) {
        try {
          final paymentDate = DateTime.parse(payment.paymentMonth);
          if (_paymentMonthFrom != null && paymentDate.isBefore(_paymentMonthFrom!)) {
            return false;
          }
          if (_paymentMonthTo != null && paymentDate.isAfter(_paymentMonthTo!)) {
            return false;
          }
        } catch (e) {
          // If parsing fails, skip this filter
        }
      }

      // Amount range filter
      if (_minAmount != null && payment.netAmount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && payment.netAmount > _maxAmount!) {
        return false;
      }

      // Receipt filter
      if (_hasReceipt != null && payment.hasReceipt != _hasReceipt!) {
        return false;
      }

      // Final payment filter
      if (_isFinalPayment != null && payment.isFinalPayment != _isFinalPayment!) {
        return false;
      }

      // Active/inactive filter
      if (!_showInactive && !payment.isActive) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredPayments.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount_paid':
          comparison = a.amountPaid.compareTo(b.amountPaid);
          break;
        case 'payment_month':
          comparison = a.paymentMonth.compareTo(b.paymentMonth);
          break;
        case 'created_at':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'labor_name':
          comparison = (a.laborName ?? '').compareTo(b.laborName ?? '');
          break;
        default:
          comparison = a.date.compareTo(b.date);
      }
      return _sortAscending ? comparison : -comparison;
    });

    notifyListeners();
  }
}
