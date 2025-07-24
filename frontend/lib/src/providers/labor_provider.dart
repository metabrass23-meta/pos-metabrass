import 'package:flutter/material.dart';

class Labor {
  final String id;
  final String name;
  final String cnic;
  final String phoneNumber;
  final String caste;
  final String designation;
  final DateTime joiningDate;
  final double salary;
  final String area;
  final String city;
  final String gender;
  final int age;
  final double advancePayment;

  Labor({
    required this.id,
    required this.name,
    required this.cnic,
    required this.phoneNumber,
    required this.caste,
    required this.designation,
    required this.joiningDate,
    required this.salary,
    required this.area,
    required this.city,
    required this.gender,
    required this.age,
    required this.advancePayment,
  });

  Labor copyWith({
    String? id,
    String? name,
    String? cnic,
    String? phoneNumber,
    String? caste,
    String? designation,
    DateTime? joiningDate,
    double? salary,
    String? area,
    String? city,
    String? gender,
    int? age,
    double? advancePayment,
  }) {
    return Labor(
      id: id ?? this.id,
      name: name ?? this.name,
      cnic: cnic ?? this.cnic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      caste: caste ?? this.caste,
      designation: designation ?? this.designation,
      joiningDate: joiningDate ?? this.joiningDate,
      salary: salary ?? this.salary,
      area: area ?? this.area,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      advancePayment: advancePayment ?? this.advancePayment,
    );
  }
}

class LaborProvider extends ChangeNotifier {
  List<Labor> _labors = [];
  List<Labor> _filteredLabors = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Labor> get labors => _filteredLabors;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  LaborProvider() {
    _initializeLabors();
  }

  void _initializeLabors() {
    _labors = [
      Labor(
        id: 'LAB001',
        name: 'Ahmed Khan',
        cnic: '42101-1234567-1',
        phoneNumber: '+923001234567',
        caste: 'Pathan',
        designation: 'Tailor',
        joiningDate: DateTime.now().subtract(const Duration(days: 30)),
        salary: 35000.0,
        area: 'Gulshan',
        city: 'Karachi',
        gender: 'Male',
        age: 30,
        advancePayment: 5000.0,
      ),
      Labor(
        id: 'LAB002',
        name: 'Fatima Ali',
        cnic: '42101-7654321-2',
        phoneNumber: '+923009876543',
        caste: 'Siddiqui',
        designation: 'Embroiderer',
        joiningDate: DateTime.now().subtract(const Duration(days: 25)),
        salary: 28000.0,
        area: 'Clifton',
        city: 'Karachi',
        gender: 'Female',
        age: 28,
        advancePayment: 0.0,
      ),
    ];

    _filteredLabors = List.from(_labors);
  }

  void searchLabors(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredLabors = List.from(_labors);
    } else {
      _filteredLabors = _labors
          .where((labor) =>
      labor.name.toLowerCase().contains(query.toLowerCase()) ||
          labor.cnic.toLowerCase().contains(query.toLowerCase()) ||
          labor.id.toLowerCase().contains(query.toLowerCase()) ||
          labor.designation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addLabor({
    required String name,
    required String cnic,
    required String phoneNumber,
    required String caste,
    required String designation,
    required DateTime joiningDate,
    required double salary,
    required String area,
    required String city,
    required String gender,
    required int age,
    required double advancePayment,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newLabor = Labor(
      id: 'LAB${(_labors.length + 1).toString().padLeft(3, '0')}',
      name: name,
      cnic: cnic,
      phoneNumber: phoneNumber,
      caste: caste,
      designation: designation,
      joiningDate: joiningDate,
      salary: salary,
      area: area,
      city: city,
      gender: gender,
      age: age,
      advancePayment: advancePayment,
    );

    _labors.add(newLabor);
    searchLabors(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateLabor({
    required String id,
    required String name,
    required String cnic,
    required String phoneNumber,
    required String caste,
    required String designation,
    required DateTime joiningDate,
    required double salary,
    required String area,
    required String city,
    required String gender,
    required int age,
    required double advancePayment,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _labors.indexWhere((labor) => labor.id == id);
    if (index != -1) {
      _labors[index] = _labors[index].copyWith(
        name: name,
        cnic: cnic,
        phoneNumber: phoneNumber,
        caste: caste,
        designation: designation,
        joiningDate: joiningDate,
        salary: salary,
        area: area,
        city: city,
        gender: gender,
        age: age,
        advancePayment: advancePayment,
      );
      searchLabors(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteLabor(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _labors.removeWhere((labor) => labor.id == id);
    searchLabors(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Labor? getLaborById(String id) {
    try {
      return _labors.firstWhere((labor) => labor.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> get laborStats => {
    'total': _labors.length,
    'recentlyJoined': _labors
        .where((labor) =>
    DateTime.now().difference(labor.joiningDate).inDays <= 30)
        .length,
    'withAdvance': _labors.where((labor) => labor.advancePayment > 0).length,
    'averageSalary':
    _labors.isNotEmpty
        ? (_labors.fold<double>(
        0, (sum, labor) => sum + labor.salary) /
        _labors.length)
        .toStringAsFixed(2)
        : '0.00',
  };
}