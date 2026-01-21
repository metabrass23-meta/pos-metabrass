import 'package:frontend/src/models/product/product_model.dart';
import 'package:frontend/src/models/vendor/vendor_model.dart';

class PurchaseModel {
  final String? id;
  final String? vendor;
  final VendorModel? vendorDetail;
  final String invoiceNumber;
  final DateTime purchaseDate;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final List<PurchaseItemModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseModel({
    this.id,
    this.vendor,
    this.vendorDetail,
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id']?.toString(),
      vendor: json['vendor']?.toString(),
      vendorDetail: json['vendor_detail'] != null
          ? VendorModel.fromJson(json['vendor_detail'])
          : null,
      invoiceNumber: json['invoice_number'] ?? '',
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : DateTime.now(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0.0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0.0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
      status: json['status'] ?? 'draft',
      items: (json['items'] as List?)
          ?.map((item) => PurchaseItemModel.fromJson(item))
          .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// ✅ FIXED: Now sends full ISO datetime string instead of just date
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vendor': vendor,
      'invoice_number': invoiceNumber,
      /// ✅ FIXED: Send full datetime (YYYY-MM-DDTHH:MM:SS) instead of just date
      'purchase_date': purchaseDate.toIso8601String(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  PurchaseModel copyWith({
    String? id,
    String? vendor,
    String? invoiceNumber,
    DateTime? purchaseDate,
    double? subtotal,
    double? tax,
    double? total,
    String? status,
    List<PurchaseItemModel>? items,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      vendor: vendor ?? this.vendor,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PurchaseItemModel {
  final String? id;
  final String? product;
  final ProductModel? productDetail;
  final double quantity;
  final double unitCost;
  final double totalPrice;

  PurchaseItemModel({
    this.id,
    this.product,
    this.productDetail,
    required this.quantity,
    required this.unitCost,
    required this.totalPrice,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id']?.toString(),
      product: json['product']?.toString(),
      productDetail: json['product_detail'] != null
          ? ProductModel.fromJson(json['product_detail'])
          : null,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0.0') ?? 0.0,
      unitCost: double.tryParse(json['unit_cost']?.toString() ?? '0.0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product': product,
      'quantity': quantity,
      'unit_cost': unitCost,
      'total_price': totalPrice,
    };
  }

  PurchaseItemModel copyWith({
    String? id,
    String? product,
    ProductModel? productDetail,
    double? quantity,
    double? unitCost,
    double? totalPrice,
  }) {
    return PurchaseItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      productDetail: productDetail ?? this.productDetail,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
