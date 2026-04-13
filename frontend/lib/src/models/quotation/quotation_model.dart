import 'package:flutter/material.dart';

enum QuotationStatus { PENDING, ACCEPTED, REJECTED, EXPIRED }

class QuotationItemModel {
  final String id;
  final String quotationId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  QuotationItemModel({
    required this.id,
    required this.quotationId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory QuotationItemModel.fromJson(Map<String, dynamic> json) {
    return QuotationItemModel(
      id: json['id']?.toString() ?? '',
      quotationId: json['quotation']?.toString() ?? '',
      productId: json['product']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      quantity: (json['quantity'] is double) ? (json['quantity'] as double).toInt() : (json['quantity'] as int? ?? 0),
      unitPrice: _parseDouble(json['unit_price']),
      lineTotal: _parseDouble(json['line_total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'product': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  QuotationItemModel copyWith({
    String? id,
    String? quotationId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? lineTotal,
  }) {
    return QuotationItemModel(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
}

class QuotationModel {
  final String id;
  final String? manualQuotationNumber;
  final String customerId;
  final String customerName;
  final double baseAmount;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;
  final DateTime dateIssued;
  final DateTime expiryDate;
  final String description;
  final String termsConditions;
  final QuotationStatus status;
  final String conversionStatus;
  final List<QuotationItemModel> items;

  QuotationModel({
    required this.id,
    this.manualQuotationNumber,
    required this.customerId,
    required this.customerName,
    required this.baseAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.grandTotal,
    required this.dateIssued,
    required this.expiryDate,
    required this.description,
    required this.termsConditions,
    required this.status,
    required this.conversionStatus,
    required this.items,
  });

  String get quotationNumber {
    if (manualQuotationNumber != null && manualQuotationNumber!.isNotEmpty) {
      return manualQuotationNumber!;
    }
    return "QTN-${id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase()}";
  }

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<QuotationItemModel> parsedItems = itemsList.map((item) => QuotationItemModel.fromJson(item)).toList();

    return QuotationModel(
      id: json['id']?.toString() ?? '',
      manualQuotationNumber: json['quotation_number']?.toString(),
      customerId: json['customer']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      baseAmount: _parseDouble(json['base_amount']),
      discountAmount: _parseDouble(json['discount_amount']),
      taxAmount: _parseDouble(json['tax_amount']),
      grandTotal: _parseDouble(json['grand_total']),
      dateIssued: DateTime.tryParse(json['date_issued']?.toString() ?? '') ?? DateTime.now(),
      expiryDate: DateTime.tryParse(json['expiry_date']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 14)),
      description: json['description']?.toString() ?? '',
      termsConditions: json['terms_conditions']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      conversionStatus: json['conversion_status']?.toString() ?? 'NOT_CONVERTED',
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customerId,
      'quotation_number': manualQuotationNumber,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'date_issued': dateIssued.toIso8601String().split('T')[0],
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      'description': description,
      'terms_conditions': termsConditions,
      'status': status.name.toUpperCase(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static QuotationStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACCEPTED': return QuotationStatus.ACCEPTED;
      case 'REJECTED': return QuotationStatus.REJECTED;
      case 'EXPIRED': return QuotationStatus.EXPIRED;
      default: return QuotationStatus.PENDING;
    }
  }

  QuotationModel copyWith({
    String? id,
    String? manualQuotationNumber,
    String? customerId,
    String? customerName,
    double? baseAmount,
    double? discountAmount,
    double? taxAmount,
    double? grandTotal,
    DateTime? dateIssued,
    DateTime? expiryDate,
    String? description,
    String? termsConditions,
    QuotationStatus? status,
    String? conversionStatus,
    List<QuotationItemModel>? items,
  }) {
    return QuotationModel(
      id: id ?? this.id,
      manualQuotationNumber: manualQuotationNumber ?? this.manualQuotationNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      baseAmount: baseAmount ?? this.baseAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      dateIssued: dateIssued ?? this.dateIssued,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      termsConditions: termsConditions ?? this.termsConditions,
      status: status ?? this.status,
      conversionStatus: conversionStatus ?? this.conversionStatus,
      items: items ?? this.items,
    );
  }
}
