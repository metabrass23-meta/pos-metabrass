import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String detail;
  final double price;
  final String color;
  final String fabric;
  final List<String> pieces;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.detail,
    required this.price,
    required this.color,
    required this.fabric,
    required this.pieces,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? detail,
    double? price,
    String? color,
    String? fabric,
    List<String>? pieces,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      price: price ?? this.price,
      color: color ?? this.color,
      fabric: fabric ?? this.fabric,
      pieces: pieces ?? this.pieces,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get piecesText => pieces.join(', ');

  bool get isLowStock => quantity <= 5;
  bool get isOutOfStock => quantity <= 0;

  Color get stockStatusColor {
    if (isOutOfStock) return Colors.red;
    if (isLowStock) return Colors.orange;
    return Colors.green;
  }

  String get stockStatusText {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Product> get products => _filteredProducts;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Available options for dropdowns
  final List<String> availableColors = [
    'Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Purple', 'Pink', 'Black',
    'White', 'Brown', 'Gray', 'Navy', 'Maroon', 'Gold', 'Silver', 'Beige'
  ];

  final List<String> availableFabrics = [
    'Cotton', 'Silk', 'Chiffon', 'Georgette', 'Net', 'Velvet', 'Satin',
    'Organza', 'Crepe', 'Linen', 'Jacquard', 'Brocade', 'Lawn', 'Khaddar'
  ];

  final List<String> availablePieces = [
    'Blouse', 'Lehenga', 'Dupatta', 'Shirt', 'Trouser', 'Kurta', 'Palazzo',
    'Scarf', 'Veil', 'Jacket', 'Waistcoat', 'Sharara', 'Gharara'
  ];

  ProductProvider() {
    _initializeProducts();
  }

  void _initializeProducts() {
    final now = DateTime.now();
    _products = [
      Product(
        id: 'PRD001',
        name: 'Bridal Lehenga Set - Royal Red',
        detail: 'Heavy embroidered bridal lehenga with gold work and mirror details',
        price: 85000.0,
        color: 'Red',
        fabric: 'Silk',
        pieces: ['Lehenga', 'Blouse', 'Dupatta'],
        quantity: 3,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Product(
        id: 'PRD002',
        name: 'Party Wear Suit - Blue Elegance',
        detail: 'Designer party wear with intricate embroidery and beadwork',
        price: 45000.0,
        color: 'Blue',
        fabric: 'Georgette',
        pieces: ['Kurta', 'Palazzo', 'Dupatta'],
        quantity: 7,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Product(
        id: 'PRD003',
        name: 'Formal Dress - Pink Charm',
        detail: 'Elegant formal dress perfect for engagements and parties',
        price: 25000.0,
        color: 'Pink',
        fabric: 'Chiffon',
        pieces: ['Shirt', 'Trouser'],
        quantity: 12,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Product(
        id: 'PRD004',
        name: 'Wedding Collection - Maroon Gold',
        detail: 'Complete wedding outfit with traditional embroidery and gold accents',
        price: 120000.0,
        color: 'Maroon',
        fabric: 'Velvet',
        pieces: ['Lehenga', 'Blouse', 'Dupatta', 'Jacket'],
        quantity: 2,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Product(
        id: 'PRD005',
        name: 'Corporate Formal Set',
        detail: 'Professional formal wear suitable for office and business events',
        price: 18000.0,
        color: 'Navy',
        fabric: 'Cotton',
        pieces: ['Shirt', 'Trouser'],
        quantity: 15,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Product(
        id: 'PRD006',
        name: 'Summer Collection - Green Fresh',
        detail: 'Light and comfortable summer wear with floral prints',
        price: 15000.0,
        color: 'Green',
        fabric: 'Lawn',
        pieces: ['Kurta', 'Dupatta'],
        quantity: 0,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      Product(
        id: 'PRD007',
        name: 'Traditional Sharara Set',
        detail: 'Traditional sharara with heavy embroidery and mirror work',
        price: 55000.0,
        color: 'Gold',
        fabric: 'Net',
        pieces: ['Kurta', 'Sharara', 'Dupatta'],
        quantity: 4,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    _filteredProducts = List.from(_products);
  }

  void searchProducts(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((product) =>
      product.id.toLowerCase().contains(query.toLowerCase()) ||
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.detail.toLowerCase().contains(query.toLowerCase()) ||
          product.color.toLowerCase().contains(query.toLowerCase()) ||
          product.fabric.toLowerCase().contains(query.toLowerCase()) ||
          product.piecesText.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addProduct({
    required String name,
    required String detail,
    required double price,
    required String color,
    required String fabric,
    required List<String> pieces,
    required int quantity,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newProduct = Product(
      id: 'PRD${(_products.length + 1).toString().padLeft(3, '0')}',
      name: name,
      detail: detail,
      price: price,
      color: color,
      fabric: fabric,
      pieces: pieces,
      quantity: quantity,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _products.add(newProduct);
    searchProducts(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String detail,
    required double price,
    required String color,
    required String fabric,
    required List<String> pieces,
    required int quantity,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _products.indexWhere((product) => product.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        name: name,
        detail: detail,
        price: price,
        color: color,
        fabric: fabric,
        pieces: pieces,
        quantity: quantity,
        updatedAt: DateTime.now(),
      );
      searchProducts(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _products.removeWhere((product) => product.id == id);
    searchProducts(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProductQuantity(String id, int newQuantity) async {
    final index = _products.indexWhere((product) => product.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      searchProducts(_searchQuery);
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> get productStats {
    final totalProducts = _products.length;
    final inStockProducts = _products.where((product) => !product.isOutOfStock).length;
    final lowStockProducts = _products.where((product) => product.isLowStock && !product.isOutOfStock).length;
    final outOfStockProducts = _products.where((product) => product.isOutOfStock).length;

    final totalValue = _products.fold<double>(0, (sum, product) => sum + (product.price * product.quantity));
    final averagePrice = _products.isNotEmpty
        ? _products.fold<double>(0, (sum, product) => sum + product.price) / _products.length
        : 0.0;

    return {
      'total': totalProducts,
      'inStock': inStockProducts,
      'lowStock': lowStockProducts,
      'outOfStock': outOfStockProducts,
      'totalValue': totalValue.toStringAsFixed(0),
      'averagePrice': averagePrice.toStringAsFixed(0),
    };
  }

  List<Product> get inStockProducts => _products.where((product) => !product.isOutOfStock).toList();
  List<Product> get lowStockProducts => _products.where((product) => product.isLowStock && !product.isOutOfStock).toList();
  List<Product> get outOfStockProducts => _products.where((product) => product.isOutOfStock).toList();

  List<Product> get recentProducts {
    final recent = List<Product>.from(_products);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(10).toList();
  }

  List<Product> get topValueProducts {
    final sortedProducts = List<Product>.from(_products);
    sortedProducts.sort((a, b) => b.price.compareTo(a.price));
    return sortedProducts.take(5).toList();
  }

  Map<String, List<Product>> get productsByStatus => {
    'inStock': inStockProducts,
    'lowStock': lowStockProducts,
    'outOfStock': outOfStockProducts,
  };

  Map<String, dynamic> get productAnalytics {
    final totalInventoryValue = _products.fold<double>(0, (sum, product) => sum + (product.price * product.quantity));
    final averageQuantity = _products.isNotEmpty
        ? _products.fold<int>(0, (sum, product) => sum + product.quantity) / _products.length
        : 0.0;

    final stockTurnoverRate = _products.isNotEmpty
        ? (inStockProducts.length / _products.length * 100)
        : 0.0;

    final outOfStockRate = _products.isNotEmpty
        ? (outOfStockProducts.length / _products.length * 100)
        : 0.0;

    return {
      'totalInventoryValue': totalInventoryValue,
      'averageQuantity': averageQuantity,
      'stockTurnoverRate': stockTurnoverRate,
      'outOfStockRate': outOfStockRate,
      'totalProductValue': _products.fold<double>(0, (sum, product) => sum + product.price),
      'lowStockValue': lowStockProducts.fold<double>(0, (sum, product) => sum + (product.price * product.quantity)),
    };
  }

  List<Product> filterProducts({
    String? color,
    String? fabric,
    double? minPrice,
    double? maxPrice,
    int? minQuantity,
    int? maxQuantity,
    bool? isLowStock,
    bool? isOutOfStock,
  }) {
    return _products.where((product) {
      if (color != null && product.color != color) return false;
      if (fabric != null && product.fabric != fabric) return false;
      if (minPrice != null && product.price < minPrice) return false;
      if (maxPrice != null && product.price > maxPrice) return false;
      if (minQuantity != null && product.quantity < minQuantity) return false;
      if (maxQuantity != null && product.quantity > maxQuantity) return false;
      if (isLowStock != null && product.isLowStock != isLowStock) return false;
      if (isOutOfStock != null && product.isOutOfStock != isOutOfStock) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> exportProductData() {
    return _products.map((product) => {
      'Product ID': product.id,
      'Name': product.name,
      'Detail': product.detail,
      'Price': product.price.toStringAsFixed(2),
      'Color': product.color,
      'Fabric': product.fabric,
      'Pieces': product.piecesText,
      'Quantity': product.quantity.toString(),
      'Stock Status': product.stockStatusText,
      'Created Date': product.createdAt.toString().split(' ')[0],
      'Updated Date': product.updatedAt.toString().split(' ')[0],
      'Total Value': (product.price * product.quantity).toStringAsFixed(2),
    }).toList();
  }

  // Get products that need attention (low/out of stock)
  List<Product> get productsNeedingAttention {
    return _products.where((product) => product.isLowStock || product.isOutOfStock).toList();
  }

  // Get inventory summary
  Map<String, dynamic> get inventorySummary {
    final totalProducts = _products.length;
    final totalQuantity = _products.fold<int>(0, (sum, product) => sum + product.quantity);
    final totalValue = _products.fold<double>(0, (sum, product) => sum + (product.price * product.quantity));
    final averageValue = totalProducts > 0 ? totalValue / totalProducts : 0.0;

    return {
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
      'totalValue': totalValue,
      'averageValue': averageValue,
      'stockHealthPercentage': totalProducts > 0 ? (inStockProducts.length / totalProducts * 100) : 0,
    };
  }

  // Get product statistics by category
  Map<String, dynamic> getProductStatsByCategory() {
    final Map<String, int> colorStats = {};
    final Map<String, int> fabricStats = {};
    final Map<String, double> colorValue = {};
    final Map<String, double> fabricValue = {};

    for (final product in _products) {
      // Color statistics
      colorStats[product.color] = (colorStats[product.color] ?? 0) + 1;
      colorValue[product.color] = (colorValue[product.color] ?? 0) + (product.price * product.quantity);

      // Fabric statistics
      fabricStats[product.fabric] = (fabricStats[product.fabric] ?? 0) + 1;
      fabricValue[product.fabric] = (fabricValue[product.fabric] ?? 0) + (product.price * product.quantity);
    }

    return {
      'colorStats': colorStats,
      'fabricStats': fabricStats,
      'colorValue': colorValue,
      'fabricValue': fabricValue,
    };
  }
}