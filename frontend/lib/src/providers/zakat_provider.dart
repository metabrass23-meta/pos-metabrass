import 'package:flutter/material.dart';

class Zakat {
  final String id;
  final String? name;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final double amount;

  Zakat({
    required this.id,
    this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.amount,
  });

  // Formatted date for display
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formatted time for display
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Relative date (e.g., "Today", "Yesterday", "2 days ago")
  String get relativeDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(recordDate).inDays;

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

  // Combined date and time for sorting
  DateTime get dateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // Copy method for updates
  Zakat copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    double? amount,
  }) {
    return Zakat(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      amount: amount ?? this.amount,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'amount': amount,
    };
  }

  // Create from JSON
  factory Zakat.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return Zakat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      amount: json['amount'].toDouble(),
    );
  }
}

class ZakatProvider extends ChangeNotifier {
  List<Zakat> _zakatRecords = [];
  List<Zakat> _filteredRecords = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Zakat> get zakatRecords => _filteredRecords;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Initialize with sample data
  ZakatProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _zakatRecords = [
      Zakat(
        id: 'ZKT001',
        name: 'Muhammad Ali',
        description: 'Annual zakat for wealth',
        date: DateTime.now().subtract(const Duration(days: 30)),
        time: const TimeOfDay(hour: 14, minute: 30),
        amount: 25000.0,
      ),
      Zakat(
        id: 'ZKT002',
        name: null,
        description: 'Zakat al-Fitr for family',
        date: DateTime.now().subtract(const Duration(days: 60)),
        time: const TimeOfDay(hour: 9, minute: 15),
        amount: 5000.0,
      ),
      Zakat(
        id: 'ZKT003',
        name: 'Fatima Khan',
        description: 'Zakat on gold jewelry',
        date: DateTime.now().subtract(const Duration(days: 90)),
        time: const TimeOfDay(hour: 16, minute: 45),
        amount: 15000.0,
      ),
      Zakat(
        id: 'ZKT004',
        name: 'Ahmed Hassan',
        description: 'Business income zakat',
        date: DateTime.now().subtract(const Duration(days: 120)),
        time: const TimeOfDay(hour: 11, minute: 20),
        amount: 35000.0,
      ),
      Zakat(
        id: 'ZKT005',
        name: null,
        description: 'Sadaqah contribution',
        date: DateTime.now().subtract(const Duration(days: 10)),
        time: const TimeOfDay(hour: 18, minute: 30),
        amount: 8000.0,
      ),
    ];
    _filteredRecords = List.from(_zakatRecords);
    _sortRecords();
  }

  // Sort records by date and time (newest first)
  void _sortRecords() {
    _filteredRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Generate new ID
  String _generateId() {
    final maxId = _zakatRecords.isEmpty
        ? 0
        : _zakatRecords
        .map((z) => int.tryParse(z.id.replaceAll('ZKT', '')) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return 'ZKT${(maxId + 1).toString().padLeft(3, '0')}';
  }

  // Add new zakat record
  Future<void> addZakat({
    String? name,
    required String description,
    required DateTime date,
    required TimeOfDay time,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final newZakat = Zakat(
      id: _generateId(),
      name: name,
      description: description,
      date: date,
      time: time,
      amount: amount,
    );

    _zakatRecords.add(newZakat);
    _applyFilters();
    _sortRecords();

    _isLoading = false;
    notifyListeners();
  }

  // Update existing zakat record
  Future<void> updateZakat({
    required String id,
    String? name,
    required String description,
    required DateTime date,
    required TimeOfDay time,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _zakatRecords.indexWhere((z) => z.id == id);
    if (index != -1) {
      _zakatRecords[index] = _zakatRecords[index].copyWith(
        name: name,
        description: description,
        date: date,
        time: time,
        amount: amount,
      );
      _applyFilters();
      _sortRecords();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Delete zakat record
  Future<void> deleteZakat(String id) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    _zakatRecords.removeWhere((z) => z.id == id);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Search zakat records
  void searchZakat(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Apply search filters
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredRecords = List.from(_zakatRecords);
    } else {
      _filteredRecords = _zakatRecords.where((zakat) {
        return zakat.id.toLowerCase().contains(_searchQuery) ||
            (zakat.name?.toLowerCase().contains(_searchQuery) ?? false) ||
            zakat.description.toLowerCase().contains(_searchQuery) ||
            zakat.amount.toString().contains(_searchQuery);
      }).toList();
    }
    _sortRecords();
  }

  // Get statistics
  Map<String, dynamic> get zakatStats {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    final totalRecords = _zakatRecords.length;
    final totalAmount = _zakatRecords.fold<double>(
      0.0,
          (sum, zakat) => sum + zakat.amount,
    );

    final thisYearRecords = _zakatRecords.where((zakat) {
      return zakat.date.year == currentYear;
    }).length;

    final thisMonthRecords = _zakatRecords.where((zakat) {
      return zakat.date.year == currentYear && zakat.date.month == currentMonth;
    }).length;

    return {
      'total': totalRecords,
      'totalAmount': totalAmount.toStringAsFixed(0),
      'thisYear': thisYearRecords,
      'thisMonth': thisMonthRecords,
    };
  }

  // Get records by year
  List<Zakat> getRecordsByYear(int year) {
    return _zakatRecords.where((zakat) => zakat.date.year == year).toList();
  }

  // Get records by month
  List<Zakat> getRecordsByMonth(int year, int month) {
    return _zakatRecords
        .where((zakat) => zakat.date.year == year && zakat.date.month == month)
        .toList();
  }

  // Get total amount by year
  double getTotalAmountByYear(int year) {
    return _zakatRecords
        .where((zakat) => zakat.date.year == year)
        .fold<double>(0.0, (sum, zakat) => sum + zakat.amount);
  }

  // Get total amount by month
  double getTotalAmountByMonth(int year, int month) {
    return _zakatRecords
        .where((zakat) => zakat.date.year == year && zakat.date.month == month)
        .fold<double>(0.0, (sum, zakat) => sum + zakat.amount);
  }

  // Export data (placeholder for future implementation)
  Future<void> exportData() async {
    // Implementation for exporting zakat records
    // This could export to CSV, PDF, etc.
  }

  // Import data (placeholder for future implementation)
  Future<void> importData(List<Map<String, dynamic>> data) async {
    // Implementation for importing zakat records
    // This could import from CSV, JSON, etc.
  }

  // Clear all records (for testing purposes)
  void clearAllRecords() {
    _zakatRecords.clear();
    _filteredRecords.clear();
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
    _sortRecords();

    _isLoading = false;
    notifyListeners();
  }
}