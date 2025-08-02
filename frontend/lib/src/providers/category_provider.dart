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

  // Formatted date for display (added from Zakat module)
  String get formattedDateCreated {
    return '${dateCreated.day.toString().padLeft(2, '0')}/${dateCreated.month.toString().padLeft(2, '0')}/${dateCreated.year}';
  }

  String get formattedLastEdited {
    return '${lastEdited.day.toString().padLeft(2, '0')}/${lastEdited.month.toString().padLeft(2, '0')}/${lastEdited.year}';
  }

  // Relative date (e.g., "Today", "Yesterday", "2 days ago") - added from Zakat module
  String get relativeDateCreated {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(dateCreated.year, dateCreated.month, dateCreated.day);
    final difference = today.difference(recordDate).inDays;

    return _getRelativeDateString(difference);
  }

  String get relativeLastEdited {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(lastEdited.year, lastEdited.month, lastEdited.day);
    final difference = today.difference(recordDate).inDays;

    return _getRelativeDateString(difference);
  }

  String _getRelativeDateString(int difference) {
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

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

  // Convert to JSON (added from Zakat module)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
    };
  }

  // Create from JSON (added from Zakat module)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dateCreated: DateTime.parse(json['dateCreated']),
      lastEdited: DateTime.parse(json['lastEdited']),
    );
  }
}

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Additional properties from Zakat module
  String _sortBy = 'dateCreated'; // 'dateCreated', 'lastEdited', 'name', 'id'
  bool _sortAscending = false;

  List<Category> get categories => _filteredCategories;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Additional getters from Zakat module
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

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
      // Added one more category for better demo
      Category(
        id: 'CAT008',
        name: 'Evening Wear',
        description: 'Sophisticated evening attire for special dinners, galas, and formal events',
        dateCreated: DateTime.now().subtract(const Duration(days: 4)),
        lastEdited: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    _filteredCategories = List.from(_categories);
    _sortCategories(); // Added sorting from Zakat module
  }

  // Sort categories (added from Zakat module)
  void _sortCategories() {
    _filteredCategories.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'id':
          comparison = a.id.compareTo(b.id);
          break;
        case 'lastEdited':
          comparison = a.lastEdited.compareTo(b.lastEdited);
          break;
        case 'dateCreated':
        default:
          comparison = a.dateCreated.compareTo(b.dateCreated);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  // Sort functionality (added from Zakat module)
  void setSortBy(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      // Toggle if same field, otherwise default to descending for dates, ascending for text
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortAscending = (sortBy == 'name' || sortBy == 'id');
      }
    }
    _sortCategories();
    notifyListeners();
  }

  // Apply search filters (enhanced from Zakat module)
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredCategories = List.from(_categories);
    } else {
      _filteredCategories = _categories.where((category) {
        return category.name.toLowerCase().contains(_searchQuery) ||
            category.description.toLowerCase().contains(_searchQuery) ||
            category.id.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    _sortCategories();
  }

  void searchCategories(String query) {
    _searchQuery = query.toLowerCase(); // Enhanced to lowercase

    _applyFilters(); // Use the new method
    notifyListeners();
  }

  // Generate new ID (enhanced from Zakat module)
  String _generateId() {
    final maxId = _categories.isEmpty
        ? 0
        : _categories
        .map((c) => int.tryParse(c.id.replaceAll('CAT', '')) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return 'CAT${(maxId + 1).toString().padLeft(3, '0')}';
  }

  Future<void> addCategory(String name, String description) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final newCategory = Category(
      id: _generateId(), // Use the enhanced method
      name: name,
      description: description,
      dateCreated: DateTime.now(),
      lastEdited: DateTime.now(),
    );

    _categories.add(newCategory);
    _applyFilters(); // Use the new method

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
      _applyFilters(); // Use the new method
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
    _applyFilters(); // Use the new method

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

  // Enhanced statistics for dashboard (from Zakat module)
  Map<String, dynamic> get categoryStats {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    final totalCategories = _categories.length;

    final recentlyAdded = _categories.where((cat) =>
    DateTime.now().difference(cat.dateCreated).inDays <= 7
    ).length;

    final recentlyUpdated = _categories.where((cat) =>
    DateTime.now().difference(cat.lastEdited).inDays <= 3
    ).length;

    final thisYearCategories = _categories.where((cat) {
      return cat.dateCreated.year == currentYear;
    }).length;

    final thisMonthCategories = _categories.where((cat) {
      return cat.dateCreated.year == currentYear &&
          cat.dateCreated.month == currentMonth;
    }).length;

    // Most popular could be based on usage, for now using most recently updated
    final mostPopular = _categories.isEmpty
        ? 'N/A'
        : _categories
        .reduce((a, b) => a.lastEdited.isAfter(b.lastEdited) ? a : b)
        .name;

    return {
      'total': totalCategories,
      'recentlyAdded': recentlyAdded,
      'recentlyUpdated': recentlyUpdated,
      'mostPopular': mostPopular,
      'thisYear': thisYearCategories,
      'thisMonth': thisMonthCategories,
    };
  }

  // Additional utility methods from Zakat module

  // Get categories by year
  List<Category> getCategoriesByYear(int year) {
    return _categories.where((cat) => cat.dateCreated.year == year).toList();
  }

  // Get categories by month
  List<Category> getCategoriesByMonth(int year, int month) {
    return _categories
        .where((cat) =>
    cat.dateCreated.year == year && cat.dateCreated.month == month)
        .toList();
  }

  // Get recently updated categories
  List<Category> getRecentlyUpdated({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _categories
        .where((cat) => cat.lastEdited.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
  }

  // Get recently created categories
  List<Category> getRecentlyCreated({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _categories
        .where((cat) => cat.dateCreated.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
  }

  // Export data (placeholder for future implementation)
  Future<void> exportData() async {
    // Implementation for exporting category data
    // This could export to CSV, PDF, etc.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Import data (placeholder for future implementation)
  Future<void> importData(List<Map<String, dynamic>> data) async {
    // Implementation for importing category data
    // This could import from CSV, JSON, etc.
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final importedCategories = data.map((item) => Category.fromJson(item)).toList();
      _categories.addAll(importedCategories);
      _applyFilters();
    } catch (e) {
      // Handle import error
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh data (for pull-to-refresh functionality)
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // In a real app, this would fetch data from an API
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Clear all categories (for testing purposes)
  void clearAllCategories() {
    _categories.clear();
    _filteredCategories.clear();
    notifyListeners();
  }

  // Bulk operations (added from Zakat module)
  Future<void> deleteMultipleCategories(List<String> ids) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _categories.removeWhere((cat) => ids.contains(cat.id));
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Duplicate category (added from Zakat module)
  Future<void> duplicateCategory(String id) async {
    final originalCategory = getCategoryById(id);
    if (originalCategory == null) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final duplicatedCategory = Category(
      id: _generateId(),
      name: '${originalCategory.name} (Copy)',
      description: originalCategory.description,
      dateCreated: DateTime.now(),
      lastEdited: DateTime.now(),
    );

    _categories.add(duplicatedCategory);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }
}