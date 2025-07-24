import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final DateTime dateCreated;
  final DateTime lastEdited;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.dateCreated,
    required this.lastEdited,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dateCreated,
    DateTime? lastEdited,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      lastEdited: lastEdited ?? this.lastEdited,
    );
  }
}

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Category> get categories => _filteredCategories;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    _initializeCategories();
  }

  void _initializeCategories() {
    _categories = [
      Category(
        id: 'CAT001',
        name: 'Bridal Dresses',
        description: 'Elegant bridal wear collection with premium fabrics and intricate designs',
        dateCreated: DateTime.now().subtract(const Duration(days: 30)),
        lastEdited: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Category(
        id: 'CAT002',
        name: 'Groom Sherwanis',
        description: 'Traditional and modern sherwanis for grooms with contemporary styling',
        dateCreated: DateTime.now().subtract(const Duration(days: 25)),
        lastEdited: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Category(
        id: 'CAT003',
        name: 'Party Wear',
        description: 'Stylish party and formal wear for special occasions and celebrations',
        dateCreated: DateTime.now().subtract(const Duration(days: 20)),
        lastEdited: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Category(
        id: 'CAT004',
        name: 'Wedding Suits',
        description: 'Premium wedding suit collection with tailored fits and luxury materials',
        dateCreated: DateTime.now().subtract(const Duration(days: 15)),
        lastEdited: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Category(
        id: 'CAT005',
        name: 'Casual Wear',
        description: 'Comfortable daily wear options with modern designs and quality fabrics',
        dateCreated: DateTime.now().subtract(const Duration(days: 10)),
        lastEdited: DateTime.now(),
      ),
      Category(
        id: 'CAT006',
        name: 'Formal Wear',
        description: 'Professional business attire and formal clothing for corporate events',
        dateCreated: DateTime.now().subtract(const Duration(days: 8)),
        lastEdited: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Category(
        id: 'CAT007',
        name: 'Traditional Wear',
        description: 'Authentic traditional clothing preserving cultural heritage and craftsmanship',
        dateCreated: DateTime.now().subtract(const Duration(days: 6)),
        lastEdited: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    _filteredCategories = List.from(_categories);
  }

  void searchCategories(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredCategories = List.from(_categories);
    } else {
      _filteredCategories = _categories
          .where((category) =>
      category.name.toLowerCase().contains(query.toLowerCase()) ||
          category.description.toLowerCase().contains(query.toLowerCase()) ||
          category.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addCategory(String name, String description) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final newCategory = Category(
      id: 'CAT${(_categories.length + 1).toString().padLeft(3, '0')}',
      name: name,
      description: description,
      dateCreated: DateTime.now(),
      lastEdited: DateTime.now(),
    );

    _categories.add(newCategory);
    searchCategories(_searchQuery); // Refresh filtered list

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCategory(String id, String name, String description) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        name: name,
        description: description,
        lastEdited: DateTime.now(),
      );
      searchCategories(_searchQuery); // Refresh filtered list
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    _categories.removeWhere((cat) => cat.id == id);
    searchCategories(_searchQuery); // Refresh filtered list

    _isLoading = false;
    notifyListeners();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get statistics for dashboard
  Map<String, dynamic> get categoryStats => {
    'total': _categories.length,
    'recentlyAdded': _categories.where((cat) =>
    DateTime.now().difference(cat.dateCreated).inDays <= 7
    ).length,
    'recentlyUpdated': _categories.where((cat) =>
    DateTime.now().difference(cat.lastEdited).inDays <= 3
    ).length,
    'mostPopular': _categories.isNotEmpty ? _categories.first.name : 'N/A',
  };
}