import 'package:flutter/material.dart';

/// Request model for creating a new payment
class CreatePaymentRequest {
  final String? laborId;
  final String? vendorId;
  final String? orderId;
  final String? saleId;
  final String payerType;
  final String? payerId;
  final String? laborName;
  final String? laborPhone;
  final String? laborRole;
  final double amountPaid;
  final double bonus;
  final double deduction;
  final DateTime paymentMonth;
  final bool isFinalPayment;
  final String paymentMethod;
  final String? description;
  final DateTime date;
  final TimeOfDay time;
  final String? receiptImagePath;

  CreatePaymentRequest({
    this.laborId,
    this.vendorId,
    this.orderId,
    this.saleId,
    required this.payerType,
    this.payerId,
    this.laborName,
    this.laborPhone,
    this.laborRole,
    required this.amountPaid,
    this.bonus = 0.0,
    this.deduction = 0.0,
    required this.paymentMonth,
    this.isFinalPayment = false,
    required this.paymentMethod,
    this.description,
    required this.date,
    required this.time,
    this.receiptImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'labor': laborId,
      'vendor': vendorId,
      'order': orderId,
      'sale': saleId,
      'payer_type': payerType,
      'payer_id': payerId,
      'labor_name': laborName,
      'labor_phone': laborPhone,
      'labor_role': laborRole,
      'amount_paid': amountPaid.toString(),
      'bonus': bonus.toString(),
      'deduction': deduction.toString(),
      'payment_month': paymentMonth.toIso8601String(),
      'is_final_payment': isFinalPayment,
      'payment_method': paymentMethod,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      'receipt_image_path': receiptImagePath,
    };
  }
}

/// Request model for updating a payment
class UpdatePaymentRequest {
  final String? laborId;
  final String? vendorId;
  final String? orderId;
  final String? saleId;
  final String? payerType;
  final String? payerId;
  final double? amountPaid;
  final double? bonus;
  final double? deduction;
  final DateTime? paymentMonth;
  final bool? isFinalPayment;
  final String? paymentMethod;
  final String? description;
  final DateTime? date;
  final TimeOfDay? time;
  final String? receiptImagePath;

  UpdatePaymentRequest({
    this.laborId,
    this.vendorId,
    this.orderId,
    this.saleId,
    this.payerType,
    this.payerId,
    this.amountPaid,
    this.bonus,
    this.deduction,
    this.paymentMonth,
    this.isFinalPayment,
    this.paymentMethod,
    this.description,
    this.date,
    this.time,
    this.receiptImagePath,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (laborId != null) data['labor'] = laborId;
    if (vendorId != null) data['vendor'] = vendorId;
    if (orderId != null) data['order'] = orderId;
    if (saleId != null) data['sale'] = saleId;
    if (payerType != null) data['payer_type'] = payerType;
    if (payerId != null) data['payer_id'] = payerId;
    if (amountPaid != null) data['amount_paid'] = amountPaid.toString();
    if (bonus != null) data['bonus'] = bonus.toString();
    if (deduction != null) data['deduction'] = deduction.toString();
    if (paymentMonth != null) data['payment_month'] = paymentMonth!.toIso8601String();
    if (isFinalPayment != null) data['is_final_payment'] = isFinalPayment;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;
    if (description != null) data['description'] = description;
    if (date != null) data['date'] = date!.toIso8601String();
    if (time != null) {
      data['time'] = '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}:00';
    }
    if (receiptImagePath != null) data['receipt_image_path'] = receiptImagePath;
    return data;
  }
}

/// Request model for payment filtering
class PaymentFilterRequest {
  final String? payerType;
  final String? paymentMethod;
  final String? laborId;
  final String? vendorId;
  final String? orderId;
  final String? saleId;
  final bool? isFinalPayment;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? search;
  final int? page;
  final int? pageSize;
  final bool? showInactive;

  PaymentFilterRequest({
    this.payerType,
    this.paymentMethod,
    this.laborId,
    this.vendorId,
    this.orderId,
    this.saleId,
    this.isFinalPayment,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.search,
    this.page,
    this.pageSize,
    this.showInactive,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    if (payerType != null) params['payer_type'] = payerType;
    if (paymentMethod != null) params['payment_method'] = paymentMethod;
    if (laborId != null) params['labor_id'] = laborId;
    if (vendorId != null) params['vendor_id'] = vendorId;
    if (orderId != null) params['order_id'] = orderId;
    if (saleId != null) params['sale_id'] = saleId;
    if (isFinalPayment != null) params['is_final_payment'] = isFinalPayment.toString();
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    if (minAmount != null) params['min_amount'] = minAmount.toString();
    if (maxAmount != null) params['max_amount'] = maxAmount.toString();
    if (search != null) params['search'] = search;
    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['page_size'] = pageSize.toString();
    if (showInactive != null) params['show_inactive'] = showInactive.toString();
    return params;
  }
}

/// Request model for bulk payment actions
class BulkPaymentActionRequest {
  final List<String> paymentIds;
  final String action;
  final Map<String, dynamic>? actionData;

  BulkPaymentActionRequest({required this.paymentIds, required this.action, this.actionData});

  Map<String, dynamic> toJson() {
    return {'payment_ids': paymentIds, 'action': action, 'action_data': actionData};
  }
}

/// Request model for payment statistics
class PaymentStatisticsRequest {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? payerType;
  final String? paymentMethod;
  final String? groupBy;

  PaymentStatisticsRequest({this.startDate, this.endDate, this.payerType, this.paymentMethod, this.groupBy});

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    if (payerType != null) params['payer_type'] = payerType;
    if (paymentMethod != null) params['payment_method'] = paymentMethod;
    if (groupBy != null) params['group_by'] = groupBy;
    return params;
  }
}
