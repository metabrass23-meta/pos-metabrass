import 'package:flutter/material.dart';

import '../models/product/product_model.dart';
import 'customer_provider.dart';
import 'product_provider.dart';

// Sale Item Model for products in cart
class SaleItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double itemDiscount;
  final double lineTotal;
  final String? customizationNotes;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.itemDiscount,
    required this.lineTotal,
    this.customizationNotes,
  });

  SaleItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? itemDiscount,
    double? lineTotal,
    String? customizationNotes,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      lineTotal: lineTotal ?? this.lineTotal,
      customizationNotes: customizationNotes ?? this.customizationNotes,
    );
  }
}

// Main Sale Model
class Sale {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<SaleItem> items;
  final double subtotal;
  final double overallDiscount;
  final double gstPercentage;
  final double taxPercentage;
  final double grandTotal;
  final double amountPaid;
  final double remainingAmount;
  final String paymentMethod;
  final String? splitPaymentDetails;
  final DateTime dateOfSale;
  final String status;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.overallDiscount,
    required this.gstPercentage,
    required this.taxPercentage,
    required this.grandTotal,
    required this.amountPaid,
    required this.remainingAmount,
    required this.paymentMethod,
    this.splitPaymentDetails,
    required this.dateOfSale,
    required this.status,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Sale copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<SaleItem>? items,
    double? subtotal,
    double? overallDiscount,
    double? gstPercentage,
    double? taxPercentage,
    double? grandTotal,
    double? amountPaid,
    double? remainingAmount,
    String? paymentMethod,
    String? splitPaymentDetails,
    DateTime? dateOfSale,
    String? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      overallDiscount: overallDiscount ?? this.overallDiscount,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      grandTotal: grandTotal ?? this.grandTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      splitPaymentDetails: splitPaymentDetails ?? this.splitPaymentDetails,
      dateOfSale: dateOfSale ?? this.dateOfSale,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  String get formattedInvoiceNumber => 'INV-$invoiceNumber';
  String get dateTimeText => '${dateOfSale.day}/${dateOfSale.month}/${dateOfSale.year}';
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isPaid => status == 'Paid';
  bool get isPartial => status == 'Partial';
  bool get isUnpaid => status == 'Unpaid';

  Color get statusColor {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get paymentStatusText {
    if (remainingAmount <= 0) return 'Fully Paid';
    if (amountPaid > 0) return 'Partially Paid';
    return 'Unpaid';
  }
}

// Audit Log Model
class AuditLog {
  final String id;
  final String saleId;
  final String action;
  final String performedBy;
  final String details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.saleId,
    required this.action,
    required this.performedBy,
    required this.details,
    required this.timestamp,
  });
}

// Additional helper extension for existing Product model
extension ProductSalesExtension on Product {
  bool get isInStock => quantity > 0;
  bool get isLowStock => quantity <= 5;
  String get displayName => name;
  String get category => fabric; // Using fabric as category for now

  Color get stockStatusColor {
    if (quantity <= 0) return Colors.red;
    if (quantity <= 5) return Colors.orange;
    return Colors.green;
  }
}

// Sales Provider
class SalesProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<AuditLog> _auditLogs = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Current sale being created
  List<SaleItem> _currentCart = [];
  Customer? _selectedCustomer;
  double _overallDiscount = 0.0;
  double _gstPercentage = 18.0;
  double _taxPercentage = 0.0;
  String _paymentMethod = 'Cash';
  String _notes = '';

  // Wishlist functionality
  List<Product> _wishlist = [];

  // Getters
  List<Sale> get sales => _filteredSales;
  List<Customer> get customers => _customers;
  List<Product> get products => _products;
  List<AuditLog> get auditLogs => _auditLogs;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Current sale getters
  List<SaleItem> get currentCart => _currentCart;
  Customer? get selectedCustomer => _selectedCustomer;
  double get overallDiscount => _overallDiscount;
  double get gstPercentage => _gstPercentage;
  double get taxPercentage => _taxPercentage;
  String get paymentMethod => _paymentMethod;
  String get notes => _notes;
  List<Product> get wishlist => _wishlist;

  SalesProvider() {
    _initializeData();
  }

  void _initializeData() {
    _initializeCustomers();
    _initializeProducts();
    _initializeSales();
  }

  void _initializeCustomers() {
    _customers = [
      Customer(
        id: 'CUS001',
        name: 'Aisha Khan',
        phone: '+923001234567',
        email: 'aisha.khan@email.com',
        description: 'Premium customer, prefers bridal wear',
        lastPurchase: 85000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Customer(
        id: 'CUS002',
        name: 'Fatima Ali',
        phone: '+923009876543',
        email: 'fatima.ali@email.com',
        description: 'Regular customer, casual and formal wear',
        lastPurchase: 45000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 8)),
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      Customer(
        id: 'CUS003',
        name: 'Sarah Ahmed',
        phone: '+923005555555',
        email: 'sarah.ahmed@email.com',
        description: 'Occasional buyer, party dresses',
        lastPurchase: 25000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Customer(
        id: 'CUS004',
        name: 'Zara Sheikh',
        phone: '+923007777777',
        email: 'zara.sheikh@email.com',
        description: 'VIP customer, wedding collections',
        lastPurchase: 120000.0,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Customer(
        id: 'CUS005',
        name: 'Mehwish Qureshi',
        phone: '+923002222222',
        email: 'mehwish.q@email.com',
        description: 'New customer, interested in casual wear',
        lastPurchase: null,
        lastPurchaseDate: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  void _initializeProducts() {
    _products = [
      // Product(
      //   id: 'PRD001',
      //   name: 'Bridal Lehenga Set - Royal Red',
      //   detail: 'Heavy embroidered bridal lehenga with gold work and mirror details',
      //   price: 85000.0,
      //   color: 'Red',
      //   fabric: 'Silk',
      //   pieces: ['Lehenga', 'Blouse', 'Dupatta'],
      //   quantity: 3,
      //   createdAt: DateTime.now().subtract(const Duration(days: 30)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      // ),
      // Product(
      //   id: 'PRD002',
      //   name: 'Party Wear Suit - Blue Elegance',
      //   detail: 'Designer party wear with intricate embroidery and beadwork',
      //   price: 45000.0,
      //   color: 'Blue',
      //   fabric: 'Georgette',
      //   pieces: ['Kurta', 'Palazzo', 'Dupatta'],
      //   quantity: 7,
      //   createdAt: DateTime.now().subtract(const Duration(days: 25)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      // ),
      // Product(
      //   id: 'PRD003',
      //   name: 'Formal Dress - Pink Charm',
      //   detail: 'Elegant formal dress perfect for engagements and parties',
      //   price: 25000.0,
      //   color: 'Pink',
      //   fabric: 'Chiffon',
      //   pieces: ['Shirt', 'Trouser'],
      //   quantity: 12,
      //   createdAt: DateTime.now().subtract(const Duration(days: 20)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      // ),
      // Product(
      //   id: 'PRD004',
      //   name: 'Wedding Collection - Maroon Gold',
      //   detail: 'Complete wedding outfit with traditional embroidery and gold accents',
      //   price: 120000.0,
      //   color: 'Maroon',
      //   fabric: 'Velvet',
      //   pieces: ['Lehenga', 'Blouse', 'Dupatta', 'Jacket'],
      //   quantity: 2,
      //   createdAt: DateTime.now().subtract(const Duration(days: 15)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      // ),
      // Product(
      //   id: 'PRD005',
      //   name: 'Corporate Formal Set',
      //   detail: 'Professional formal wear suitable for office and business events',
      //   price: 18000.0,
      //   color: 'Navy',
      //   fabric: 'Cotton',
      //   pieces: ['Shirt', 'Trouser'],
      //   quantity: 15,
      //   createdAt: DateTime.now().subtract(const Duration(days: 12)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      // ),
      // Product(
      //   id: 'PRD006',
      //   name: 'Summer Collection - Green Fresh',
      //   detail: 'Light and comfortable summer wear with floral prints',
      //   price: 15000.0,
      //   color: 'Green',
      //   fabric: 'Lawn',
      //   pieces: ['Kurta', 'Dupatta'],
      //   quantity: 0,
      //   createdAt: DateTime.now().subtract(const Duration(days: 8)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      // ),
      // Product(
      //   id: 'PRD007',
      //   name: 'Traditional Sharara Set',
      //   detail: 'Traditional sharara with heavy embroidery and mirror work',
      //   price: 55000.0,
      //   color: 'Gold',
      //   fabric: 'Net',
      //   pieces: ['Kurta', 'Sharara', 'Dupatta'],
      //   quantity: 4,
      //   createdAt: DateTime.now().subtract(const Duration(days: 6)),
      //   updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      // ),
    ];
  }

  void _initializeSales() {
    final now = DateTime.now();
    _sales = [
      Sale(
        id: 'SAL001',
        invoiceNumber: '2024001',
        customerId: 'CUS001',
        customerName: 'Ahmed Hassan',
        customerPhone: '+923001234567',
        items: [
          SaleItem(
            productId: 'PRD001',
            productName: 'Lawn Suit - Floral',
            unitPrice: 4500.0,
            quantity: 2,
            itemDiscount: 200.0,
            lineTotal: 8800.0,
          ),
          SaleItem(
            productId: 'PRD002',
            productName: 'Chiffon Dupatta',
            unitPrice: 1200.0,
            quantity: 1,
            itemDiscount: 0.0,
            lineTotal: 1200.0,
          ),
        ],
        subtotal: 10000.0,
        overallDiscount: 500.0,
        gstPercentage: 18.0,
        taxPercentage: 0.0,
        grandTotal: 11210.0,
        amountPaid: 11210.0,
        remainingAmount: 0.0,
        paymentMethod: 'Cash',
        dateOfSale: now.subtract(const Duration(days: 2)),
        status: 'Paid',
        notes: 'Regular customer - priority service',
        createdBy: 'Admin',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Sale(
        id: 'SAL002',
        invoiceNumber: '2024002',
        customerId: 'CUS002',
        customerName: 'Fatima Ali',
        customerPhone: '+923009876543',
        items: [
          SaleItem(
            productId: 'PRD006',
            productName: 'Wedding Dress',
            unitPrice: 25000.0,
            quantity: 1,
            itemDiscount: 2000.0,
            lineTotal: 23000.0,
          ),
        ],
        subtotal: 25000.0,
        overallDiscount: 2000.0,
        gstPercentage: 18.0,
        taxPercentage: 0.0,
        grandTotal: 27140.0,
        amountPaid: 15000.0,
        remainingAmount: 12140.0,
        paymentMethod: 'Split',
        splitPaymentDetails: '{"cash": 10000, "card": 5000}',
        dateOfSale: now.subtract(const Duration(days: 1)),
        status: 'Partial',
        notes: 'Wedding order - delivery scheduled',
        createdBy: 'Admin',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Sale(
        id: 'SAL003',
        invoiceNumber: '2024003',
        customerId: 'CUS003',
        customerName: 'Muhammad Usman',
        customerPhone: '+923005555555',
        items: [
          SaleItem(
            productId: 'PRD003',
            productName: 'Embroidered Shirt',
            unitPrice: 3200.0,
            quantity: 3,
            itemDiscount: 300.0,
            lineTotal: 9300.0,
          ),
          SaleItem(
            productId: 'PRD004',
            productName: 'Cotton Trouser',
            unitPrice: 2800.0,
            quantity: 2,
            itemDiscount: 0.0,
            lineTotal: 5600.0,
          ),
        ],
        subtotal: 14900.0,
        overallDiscount: 900.0,
        gstPercentage: 18.0,
        taxPercentage: 0.0,
        grandTotal: 16520.0,
        amountPaid: 0.0,
        remainingAmount: 16520.0,
        paymentMethod: 'Credit',
        dateOfSale: now,
        status: 'Unpaid',
        notes: 'Corporate order - 30 days credit',
        createdBy: 'Admin',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    _filteredSales = List.from(_sales);
  }

  // Search functionality
  void searchSales(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredSales = List.from(_sales);
    } else {
      _filteredSales = _sales
          .where((sale) =>
      sale.id.toLowerCase().contains(query.toLowerCase()) ||
          sale.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
          sale.customerName.toLowerCase().contains(query.toLowerCase()) ||
          sale.customerPhone.toLowerCase().contains(query.toLowerCase()) ||
          sale.paymentMethod.toLowerCase().contains(query.toLowerCase()) ||
          sale.status.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  // Enhanced cart management with discount support
  void addToCartWithDiscount(Product product, int quantity, double discount, {String? customizationNotes}) {
    final existingItemIndex = _currentCart.indexWhere((item) =>
    item.productId == product.id && item.customizationNotes == customizationNotes);

    if (existingItemIndex != -1) {
      // Update existing item with new discount
      final existingItem = _currentCart[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      final lineTotal = (product.price * newQuantity) - discount;

      _currentCart[existingItemIndex] = existingItem.copyWith(
        quantity: newQuantity,
        itemDiscount: discount,
        lineTotal: lineTotal,
      );
    } else {
      // Add new item with discount
      final lineTotal = (product.price * quantity) - discount;
      _currentCart.add(
        SaleItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: quantity,
          itemDiscount: discount,
          lineTotal: lineTotal,
          customizationNotes: customizationNotes,
        ),
      );
    }

    notifyListeners();
  }

  // Cart management
  void addToCart(Product product, int quantity, {String? customizationNotes}) {
    final existingItemIndex = _currentCart.indexWhere((item) => item.productId == product.id);

    if (existingItemIndex != -1) {
      // Update existing item
      final existingItem = _currentCart[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      final lineTotal = (product.price * newQuantity) - existingItem.itemDiscount;

      _currentCart[existingItemIndex] = existingItem.copyWith(
        quantity: newQuantity,
        lineTotal: lineTotal,
      );
    } else {
      // Add new item
      final lineTotal = product.price * quantity;
      _currentCart.add(
        SaleItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: quantity,
          itemDiscount: 0.0,
          lineTotal: lineTotal,
          customizationNotes: customizationNotes,
        ),
      );
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    _currentCart.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final itemIndex = _currentCart.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      final item = _currentCart[itemIndex];
      final lineTotal = (item.unitPrice * quantity) - item.itemDiscount;
      _currentCart[itemIndex] = item.copyWith(
        quantity: quantity,
        lineTotal: lineTotal,
      );
      notifyListeners();
    }
  }

  void updateCartItemDiscount(String productId, double discount) {
    final itemIndex = _currentCart.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      final item = _currentCart[itemIndex];
      final lineTotal = (item.unitPrice * item.quantity) - discount;
      _currentCart[itemIndex] = item.copyWith(
        itemDiscount: discount,
        lineTotal: lineTotal,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _currentCart.clear();
    _selectedCustomer = null;
    _overallDiscount = 0.0;
    _notes = '';
    notifyListeners();
  }

  // Quick actions for POS
  void quickAddToCart(Product product) {
    addToCart(product, 1);
  }

  void addToCartWithCustomization(
      Product product,
      int quantity,
      {
        double itemDiscount = 0.0,
        String? customizationNotes,
        Map<String, dynamic>? customOptions,
      }
      ) {
    final lineTotal = (product.price * quantity) - itemDiscount;

    // Check if similar item exists (same product + customization)
    final existingIndex = _currentCart.indexWhere((item) =>
    item.productId == product.id &&
        item.customizationNotes == customizationNotes
    );

    if (existingIndex != -1) {
      // Update existing item
      final existing = _currentCart[existingIndex];
      final newQuantity = existing.quantity + quantity;
      final newLineTotal = (product.price * newQuantity) - itemDiscount;

      _currentCart[existingIndex] = existing.copyWith(
        quantity: newQuantity,
        itemDiscount: itemDiscount,
        lineTotal: newLineTotal,
      );
    } else {
      // Add new item
      _currentCart.add(
        SaleItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: quantity,
          itemDiscount: itemDiscount,
          lineTotal: lineTotal,
          customizationNotes: customizationNotes,
        ),
      );
    }

    notifyListeners();
  }

  // Wishlist functionality
  void addToWishlist(Product product) {
    if (!_wishlist.any((p) => p.id == product.id)) {
      _wishlist.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlist.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  void moveWishlistToCart(String productId) {
    final product = _wishlist.firstWhere((p) => p.id == productId);
    addToCart(product, 1);
    removeFromWishlist(productId);
  }

  // Sale calculations
  double get cartSubtotal {
    return _currentCart.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  double get cartSubtotalWithoutDiscounts {
    return _currentCart.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  double get cartTotalItemDiscounts {
    return _currentCart.fold(0.0, (sum, item) => sum + item.itemDiscount);
  }

  double get cartTotalSavings {
    return cartTotalItemDiscounts + _overallDiscount;
  }

  double get cartGstAmount {
    return (cartSubtotal - _overallDiscount) * (_gstPercentage / 100);
  }

  double get cartTaxAmount {
    return (cartSubtotal - _overallDiscount) * (_taxPercentage / 100);
  }

  double get cartGrandTotal {
    return (cartSubtotal - _overallDiscount) + cartGstAmount + cartTaxAmount;
  }

  int get cartTotalItems {
    return _currentCart.fold(0, (sum, item) => sum + item.quantity);
  }

  // Setters for current sale
  void setSelectedCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setOverallDiscount(double discount) {
    _overallDiscount = discount;
    notifyListeners();
  }

  void setGstPercentage(double percentage) {
    _gstPercentage = percentage;
    notifyListeners();
  }

  void setTaxPercentage(double percentage) {
    _taxPercentage = percentage;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  // Customer management integration
  void selectCustomerById(String customerId) {
    final customer = _customers.firstWhere(
          (c) => c.id == customerId,
      orElse: () => throw Exception('Customer not found'),
    );
    setSelectedCustomer(customer);
  }

  void selectWalkInCustomer() {
    setSelectedCustomer(null);
  }

  // Product availability checks
  bool isProductAvailable(String productId, int requestedQuantity) {
    final product = _products.firstWhere(
          (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );
    return product.quantity >= requestedQuantity;
  }

  List<Product> getAvailableProducts() {
    return _products.where((product) => product.quantity > 0).toList();
  }

  List<Product> getLowStockProducts() {
    return _products.where((product) => product.quantity <= 5 && product.quantity > 0).toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.where((product) => product.quantity <= 0).toList();
  }

  // CRUD operations
  Future<void> createSale({
    required double amountPaid,
    String? splitPaymentDetails,
  }) async {
    if (_currentCart.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final invoiceNumber = '2024${(_sales.length + 1).toString().padLeft(3, '0')}';
    final remainingAmount = cartGrandTotal - amountPaid;

    String status;
    if (remainingAmount <= 0) {
      status = 'Paid';
    } else if (amountPaid > 0) {
      status = 'Partial';
    } else {
      status = 'Unpaid';
    }

    final customerName = _selectedCustomer?.name ?? 'Walk-in Customer';
    final customerPhone = _selectedCustomer?.phone ?? 'N/A';
    final customerId = _selectedCustomer?.id ?? 'WALK-IN';

    final newSale = Sale(
      id: 'SAL${(_sales.length + 1).toString().padLeft(3, '0')}',
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      items: List.from(_currentCart),
      subtotal: cartSubtotal,
      overallDiscount: _overallDiscount,
      gstPercentage: _gstPercentage,
      taxPercentage: _taxPercentage,
      grandTotal: cartGrandTotal,
      amountPaid: amountPaid,
      remainingAmount: remainingAmount,
      paymentMethod: _paymentMethod,
      splitPaymentDetails: splitPaymentDetails,
      dateOfSale: now,
      status: status,
      notes: _notes,
      createdBy: 'Admin',
      createdAt: now,
      updatedAt: now,
    );

    _sales.add(newSale);
    _addAuditLog(newSale.id, 'Created', 'Admin', 'Sale created with ${newSale.items.length} items');

    // Update product quantities
    for (final item in _currentCart) {
      updateProductQuantityAfterSale(item.productId, item.quantity);
    }

    clearCart();
    searchSales(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSale(Sale sale, {
    double? amountPaid,
    String? paymentMethod,
    String? status,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _sales.indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      final updatedSale = sale.copyWith(
        amountPaid: amountPaid ?? sale.amountPaid,
        paymentMethod: paymentMethod ?? sale.paymentMethod,
        status: status ?? sale.status,
        notes: notes ?? sale.notes,
        remainingAmount: amountPaid != null ? sale.grandTotal - amountPaid : sale.remainingAmount,
        updatedAt: DateTime.now(),
      );

      _sales[index] = updatedSale;
      _addAuditLog(sale.id, 'Updated', 'Admin', 'Sale details updated');
      searchSales(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSale(String saleId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _sales.removeWhere((sale) => sale.id == saleId);
    _addAuditLog(saleId, 'Deleted', 'Admin', 'Sale record deleted');
    searchSales(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  void _addAuditLog(String saleId, String action, String performedBy, String details) {
    final log = AuditLog(
      id: 'LOG${(_auditLogs.length + 1).toString().padLeft(4, '0')}',
      saleId: saleId,
      action: action,
      performedBy: performedBy,
      details: details,
      timestamp: DateTime.now(),
    );
    _auditLogs.add(log);
  }

  // Custom order integration
  Future<String> createCustomOrder({
    required Customer customer,
    required Product product,
    required int quantity,
    required DateTime deliveryDate,
    required double advancePayment,
    required double totalAmount,
    String? customizationNotes,
    Map<String, dynamic>? customOptions,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // This would integrate with OrderProvider to create a custom order
    // For now, we'll just simulate the process

    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

    // Add audit log
    _addAuditLog(orderId, 'Custom Order Created', 'Admin',
        'Custom order created for ${customer.name} - ${product.name}');

    _isLoading = false;
    notifyListeners();

    return orderId;
  }

  // Enhanced sale creation with custom order support
  Future<String?> createSaleFromOrder({
    required String orderId,
    required double finalPayment,
    String? additionalNotes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // This would fetch the order details and create a sale
    // Implementation would depend on your OrderProvider structure

    _isLoading = false;
    notifyListeners();

    return 'SAL${DateTime.now().millisecondsSinceEpoch}';
  }

  // Inventory integration
  void updateProductQuantityAfterSale(String productId, int quantitySold) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      final product = _products[productIndex];
      final newQuantity = (product.quantity - quantitySold).clamp(0, double.infinity).toInt();

      // This would typically update through ProductProvider
      // For now, we'll just update locally
      _products[productIndex] = product.copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void reserveProductQuantity(String productId, int quantity) {
    // This would reserve quantity for pending orders
    // Implementation depends on your inventory management system
  }

  void releaseProductQuantity(String productId, int quantity) {
    // This would release reserved quantity back to available stock
    // Implementation depends on your inventory management system
  }

  // Bulk operations
  void addMultipleToCart(List<Map<String, dynamic>> items) {
    for (final item in items) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      final discount = item['discount'] as double? ?? 0.0;
      final notes = item['notes'] as String?;

      addToCartWithDiscount(product, quantity, discount, customizationNotes: notes);
    }
  }

  void clearCartItem(String productId, {String? customizationNotes}) {
    _currentCart.removeWhere((item) =>
    item.productId == productId &&
        (customizationNotes == null || item.customizationNotes == customizationNotes)
    );
    notifyListeners();
  }

  // Cart item management
  void duplicateCartItem(String productId) {
    final itemIndex = _currentCart.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      final item = _currentCart[itemIndex];
      _currentCart.add(item.copyWith()); // Creates a duplicate
      notifyListeners();
    }
  }

  void moveCartItemUp(String productId) {
    final itemIndex = _currentCart.indexWhere((item) => item.productId == productId);
    if (itemIndex > 0) {
      final item = _currentCart.removeAt(itemIndex);
      _currentCart.insert(itemIndex - 1, item);
      notifyListeners();
    }
  }

  void moveCartItemDown(String productId) {
    final itemIndex = _currentCart.indexWhere((item) => item.productId == productId);
    if (itemIndex < _currentCart.length - 1) {
      final item = _currentCart.removeAt(itemIndex);
      _currentCart.insert(itemIndex + 1, item);
      notifyListeners();
    }
  }

  // Statistics and Analytics
  Map<String, dynamic> get salesStats {
    final totalSales = _sales.length;
    final totalRevenue = _sales.fold<double>(0, (sum, sale) => sum + sale.grandTotal);
    final totalPaid = _sales.fold<double>(0, (sum, sale) => sum + sale.amountPaid);
    final totalOutstanding = _sales.fold<double>(0, (sum, sale) => sum + sale.remainingAmount);

    final todaySales = _sales.where((sale) {
      final today = DateTime.now();
      return sale.dateOfSale.day == today.day &&
          sale.dateOfSale.month == today.month &&
          sale.dateOfSale.year == today.year;
    }).length;

    final paidSales = _sales.where((sale) => sale.status == 'Paid').length;
    final partialSales = _sales.where((sale) => sale.status == 'Partial').length;
    final unpaidSales = _sales.where((sale) => sale.status == 'Unpaid').length;

    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue.toStringAsFixed(0),
      'totalPaid': totalPaid.toStringAsFixed(0),
      'totalOutstanding': totalOutstanding.toStringAsFixed(0),
      'todaySales': todaySales,
      'paidSales': paidSales,
      'partialSales': partialSales,
      'unpaidSales': unpaidSales,
      'averageSale': totalSales > 0 ? (totalRevenue / totalSales).toStringAsFixed(0) : '0',
    };
  }

  Map<String, dynamic> get todayStats {
    final today = DateTime.now();
    final todaySales = _sales.where((sale) {
      return sale.dateOfSale.day == today.day &&
          sale.dateOfSale.month == today.month &&
          sale.dateOfSale.year == today.year;
    }).toList();

    final todayRevenue = todaySales.fold<double>(0, (sum, sale) => sum + sale.grandTotal);
    final todayItemsSold = todaySales.fold<int>(0, (sum, sale) => sum + sale.totalItems);

    return {
      'salesCount': todaySales.length,
      'revenue': todayRevenue,
      'itemsSold': todayItemsSold,
      'averageSale': todaySales.isNotEmpty ? todayRevenue / todaySales.length : 0.0,
    };
  }

  Map<String, dynamic> get weekStats {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekSales = _sales.where((sale) {
      return sale.dateOfSale.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();

    final weekRevenue = weekSales.fold<double>(0, (sum, sale) => sum + sale.grandTotal);

    return {
      'salesCount': weekSales.length,
      'revenue': weekRevenue,
      'averageDaily': weekSales.isNotEmpty ? weekRevenue / 7 : 0.0,
    };
  }

  List<Map<String, dynamic>> getTopSellingProducts({int limit = 5}) {
    final productSales = <String, Map<String, dynamic>>{};

    for (final sale in _sales) {
      for (final item in sale.items) {
        if (productSales.containsKey(item.productId)) {
          productSales[item.productId]!['quantity'] += item.quantity;
          productSales[item.productId]!['revenue'] += item.lineTotal;
        } else {
          productSales[item.productId] = {
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'revenue': item.lineTotal,
          };
        }
      }
    }

    final sortedProducts = productSales.values.toList();
    sortedProducts.sort((a, b) => b['quantity'].compareTo(a['quantity']));

    return sortedProducts.take(limit).toList();
  }

  List<Map<String, dynamic>> getTopCustomers({int limit = 5}) {
    final customerSales = <String, Map<String, dynamic>>{};

    for (final sale in _sales) {
      if (customerSales.containsKey(sale.customerId)) {
        customerSales[sale.customerId]!['totalPurchases'] += sale.grandTotal;
        customerSales[sale.customerId]!['orderCount'] += 1;
      } else {
        customerSales[sale.customerId] = {
          'customerId': sale.customerId,
          'customerName': sale.customerName,
          'customerPhone': sale.customerPhone,
          'totalPurchases': sale.grandTotal,
          'orderCount': 1,
        };
      }
    }

    final sortedCustomers = customerSales.values.toList();
    sortedCustomers.sort((a, b) => b['totalPurchases'].compareTo(a['totalPurchases']));

    return sortedCustomers.take(limit).toList();
  }

  // Payment method analytics
  Map<String, dynamic> getPaymentMethodStats() {
    final paymentStats = <String, Map<String, dynamic>>{};

    for (final sale in _sales) {
      if (paymentStats.containsKey(sale.paymentMethod)) {
        paymentStats[sale.paymentMethod]!['count'] += 1;
        paymentStats[sale.paymentMethod]!['amount'] += sale.grandTotal;
      } else {
        paymentStats[sale.paymentMethod] = {
          'method': sale.paymentMethod,
          'count': 1,
          'amount': sale.grandTotal,
        };
      }
    }

    return {
      'breakdown': paymentStats,
      'mostUsed': paymentStats.values.isNotEmpty
          ? paymentStats.values.reduce((a, b) => a['count'] > b['count'] ? a : b)['method']
          : 'Cash',
    };
  }

  // Advanced search and filtering
  List<Sale> searchSalesAdvanced({
    String? query,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? statuses,
    List<String>? paymentMethods,
    double? minAmount,
    double? maxAmount,
    String? customerId,
  }) {
    return _sales.where((sale) {
      // Text search
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        final matchesText = sale.id.toLowerCase().contains(searchLower) ||
            sale.invoiceNumber.toLowerCase().contains(searchLower) ||
            sale.customerName.toLowerCase().contains(searchLower) ||
            sale.customerPhone.toLowerCase().contains(searchLower) ||
            sale.notes.toLowerCase().contains(searchLower);
        if (!matchesText) return false;
      }

      // Date range filter
      if (fromDate != null && sale.dateOfSale.isBefore(fromDate)) return false;
      if (toDate != null && sale.dateOfSale.isAfter(toDate)) return false;

      // Status filter
      if (statuses != null && !statuses.contains(sale.status)) return false;

      // Payment method filter
      if (paymentMethods != null && !paymentMethods.contains(sale.paymentMethod)) return false;

      // Amount range filter
      if (minAmount != null && sale.grandTotal < minAmount) return false;
      if (maxAmount != null && sale.grandTotal > maxAmount) return false;

      // Customer filter
      if (customerId != null && sale.customerId != customerId) return false;

      return true;
    }).toList();
  }

  // Export functionality
  List<Map<String, dynamic>> exportSalesData({
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? paymentMethod,
  }) {
    var salesToExport = _sales.where((sale) {
      if (fromDate != null && sale.dateOfSale.isBefore(fromDate)) return false;
      if (toDate != null && sale.dateOfSale.isAfter(toDate)) return false;
      if (customerId != null && sale.customerId != customerId) return false;
      if (paymentMethod != null && sale.paymentMethod != paymentMethod) return false;
      return true;
    }).toList();

    return salesToExport.map((sale) => {
      'Sale ID': sale.id,
      'Invoice Number': sale.formattedInvoiceNumber,
      'Customer Name': sale.customerName,
      'Customer Phone': sale.customerPhone,
      'Items Count': sale.totalItems,
      'Subtotal': sale.subtotal.toStringAsFixed(2),
      'Overall Discount': sale.overallDiscount.toStringAsFixed(2),
      'GST %': sale.gstPercentage.toStringAsFixed(1),
      'Tax %': sale.taxPercentage.toStringAsFixed(1),
      'Grand Total': sale.grandTotal.toStringAsFixed(2),
      'Amount Paid': sale.amountPaid.toStringAsFixed(2),
      'Remaining Amount': sale.remainingAmount.toStringAsFixed(2),
      'Payment Method': sale.paymentMethod,
      'Status': sale.status,
      'Date': sale.dateTimeText,
      'Notes': sale.notes,
      'Created By': sale.createdBy,
    }).toList();
  }

  // Utility methods
  Sale? getSaleById(String id) {
    try {
      return _sales.firstWhere((sale) => sale.id == id);
    } catch (e) {
      return null;
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Sale> getSalesByCustomer(String customerId) {
    return _sales.where((sale) => sale.customerId == customerId).toList();
  }

  List<Sale> getSalesByDateRange(DateTime fromDate, DateTime toDate) {
    return _sales.where((sale) =>
    sale.dateOfSale.isAfter(fromDate.subtract(const Duration(days: 1))) &&
        sale.dateOfSale.isBefore(toDate.add(const Duration(days: 1)))
    ).toList();
  }

  List<AuditLog> getAuditLogsBySale(String saleId) {
    return _auditLogs.where((log) => log.saleId == saleId).toList();
  }

  // Product filtering helpers
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((product) => product.fabric == category).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) =>
    product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.detail.toLowerCase().contains(query.toLowerCase()) ||
        product.color.toLowerCase().contains(query.toLowerCase()) ||
        product.fabric.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Cart validation
  bool get canCheckout {
    return _currentCart.isNotEmpty &&
        _currentCart.every((item) => isProductAvailable(item.productId, item.quantity));
  }

  String? getCheckoutValidationError() {
    if (_currentCart.isEmpty) {
      return 'Cart is empty. Add products to continue.';
    }

    for (final item in _currentCart) {
      final product = getProductById(item.productId);
      if (product == null) {
        return 'Product ${item.productName} not found.';
      }
      if (product.quantity < item.quantity) {
        return 'Insufficient stock for ${item.productName}. Available: ${product.quantity}';
      }
    }

    return null;
  }

  // Quick stats for dashboard
  Map<String, dynamic> get quickStats {
    final today = DateTime.now();
    final todaySales = _sales.where((sale) =>
    sale.dateOfSale.day == today.day &&
        sale.dateOfSale.month == today.month &&
        sale.dateOfSale.year == today.year
    ).length;

    final totalRevenue = _sales.fold<double>(0, (sum, sale) => sum + sale.grandTotal);
    final totalOutstanding = _sales.fold<double>(0, (sum, sale) => sum + sale.remainingAmount);

    return {
      'todaySales': todaySales,
      'totalRevenue': totalRevenue,
      'totalOutstanding': totalOutstanding,
      'lowStockItems': getLowStockProducts().length,
      'outOfStockItems': getOutOfStockProducts().length,
      'cartItems': cartTotalItems,
      'cartValue': cartGrandTotal,
    };
  }
}