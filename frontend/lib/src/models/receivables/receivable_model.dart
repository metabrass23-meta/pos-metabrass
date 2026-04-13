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
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? relatedSaleId;

  Receivable({
    required this.id,
    required this.debtorName,
    required this.debtorPhone,
    required this.amountGiven,
    required this.reasonOrItem,
    required this.dateLent,
    required this.expectedReturnDate,
    this.amountReturned = 0.0,
    required this.balanceRemaining,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.relatedSaleId,
  });

  factory Receivable.fromJson(Map<String, dynamic> json) {
    return Receivable(
      id: json['id']?.toString() ?? '',
      debtorName: json['debtor_name'] ?? '',
      debtorPhone: json['debtor_phone'] ?? '',
      amountGiven: double.tryParse(json['amount_given'].toString()) ?? 0.0,
      reasonOrItem: json['reason_or_item'] ?? '',
      dateLent: DateTime.tryParse(json['date_lent'].toString()) ?? DateTime.now(),
      expectedReturnDate: DateTime.tryParse(json['expected_return_date'].toString()) ?? DateTime.now(),
      amountReturned: double.tryParse(json['amount_returned'].toString()) ?? 0.0,
      balanceRemaining: double.tryParse(json['balance_remaining'].toString()) ?? 0.0,
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      createdBy: json['created_by_email'] ?? json['created_by'],
      relatedSaleId: json['related_sale_id']?.toString() ?? json['related_sale']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debtor_name': debtorName,
      'debtor_phone': debtorPhone,
      'amount_given': amountGiven,
      'reason_or_item': reasonOrItem,
      'date_lent': dateLent.toIso8601String().split('T')[0],
      'expected_return_date': expectedReturnDate.toIso8601String().split('T')[0],
      'amount_returned': amountReturned,
      'notes': notes,
      'is_active': isActive,
      'related_sale': relatedSaleId,
    };
  }

  Receivable copyWith({
    String? id,
    String? debtorName,
    String? debtorPhone,
    double? amountGiven,
    String? reasonOrItem,
    DateTime? dateLent,
    DateTime? expectedReturnDate,
    double? amountReturned,
    double? balanceRemaining,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? relatedSaleId,
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
      balanceRemaining: balanceRemaining ?? this.balanceRemaining,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      relatedSaleId: relatedSaleId ?? this.relatedSaleId,
    );
  }

  String get statusText {
    if (balanceRemaining <= 0) return 'Fully Paid';
    if (expectedReturnDate.isBefore(DateTime.now().subtract(const Duration(days: 1))) && balanceRemaining > 0) return 'Overdue';
    if (amountReturned > 0 && balanceRemaining > 0) return 'Partially Paid';
    return 'Pending';
  }

  Color get statusColor {
    if (balanceRemaining <= 0) return Colors.green;
    if (expectedReturnDate.isBefore(DateTime.now().subtract(const Duration(days: 1))) && balanceRemaining > 0) return Colors.red;
    if (amountReturned > 0 && balanceRemaining > 0) return Colors.orange;
    return Colors.blue;
  }

  bool get isOverdue => expectedReturnDate.isBefore(DateTime.now().subtract(const Duration(days: 1))) && balanceRemaining > 0;
  bool get isFullyPaid => balanceRemaining <= 0;
  bool get isPartiallyPaid => amountReturned > 0 && balanceRemaining > 0;

  String get formattedDateLent => '${dateLent.day}/${dateLent.month}/${dateLent.year}';
  String get formattedExpectedReturnDate => '${expectedReturnDate.day}/${expectedReturnDate.month}/${expectedReturnDate.year}';
  
  bool get isFromSale => relatedSaleId != null || reasonOrItem.startsWith('Sale #');

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(expectedReturnDate).inDays;
  }

  double get returnPercentage => amountGiven > 0 ? (amountReturned / amountGiven) * 100 : 0;
}
