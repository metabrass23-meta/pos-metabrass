import 'package:flutter/material.dart';

class Vendor {
  final String id;
  final String name;
  final String businessName;
  final String cnic;
  final String phone;
  final String city;
  final String area;
  final DateTime createdAt;

  Vendor({
    required this.id,
    required this.name,
    required this.businessName,
    required this.cnic,
    required this.phone,
    required this.city,
    required this.area,
    required this.createdAt,
  });

  Vendor copyWith({
    String? id,
    String? name,
    String? businessName,
    String? cnic,
    String? phone,
    String? city,
    String? area,
    DateTime? createdAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class VendorProvider extends ChangeNotifier {
  List<Vendor> _vendors = [];
  List<Vendor> _filteredVendors = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Vendor> get vendors => _filteredVendors;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  VendorProvider() {
    _initializeVendors();
  }

  void _initializeVendors() {
    _vendors = [
      Vendor(
        id: 'VEN001',
        name: 'Muhammad Ali',
        businessName: 'Ali Textiles & Co.',
        cnic: '42101-1234567-1',
        phone: '+923001234567',
        city: 'Karachi',
        area: 'Gulshan',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Vendor(
        id: 'VEN002',
        name: 'Sarah Khan',
        businessName: 'Khan Fabrics',
        cnic: '42101-7654321-2',
        phone: '+923009876543',
        city: 'Lahore',
        area: 'Johar Town',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Vendor(
        id: 'VEN003',
        name: 'Ahmed Hassan',
        businessName: 'Hassan Brothers Trading',
        cnic: '42101-5555555-5',
        phone: '+923001111111',
        city: 'Karachi',
        area: 'Clifton',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Vendor(
        id: 'VEN004',
        name: 'Fatima Sheikh',
        businessName: 'Sheikh Embroidery Works',
        cnic: '42101-9999999-9',
        phone: '+923002222222',
        city: 'Islamabad',
        area: 'F-7',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    _filteredVendors = List.from(_vendors);
  }

  void searchVendors(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredVendors = List.from(_vendors);
    } else {
      _filteredVendors = _vendors
          .where((vendor) =>
      vendor.name.toLowerCase().contains(query.toLowerCase()) ||
          vendor.businessName.toLowerCase().contains(query.toLowerCase()) ||
          vendor.cnic.toLowerCase().contains(query.toLowerCase()) ||
          vendor.id.toLowerCase().contains(query.toLowerCase()) ||
          vendor.city.toLowerCase().contains(query.toLowerCase()) ||
          vendor.area.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> addVendor({
    required String name,
    required String businessName,
    required String cnic,
    required String phone,
    required String city,
    required String area,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final newVendor = Vendor(
      id: 'VEN${(_vendors.length + 1).toString().padLeft(3, '0')}',
      name: name,
      businessName: businessName,
      cnic: cnic,
      phone: phone,
      city: city,
      area: area,
      createdAt: DateTime.now(),
    );

    _vendors.add(newVendor);
    searchVendors(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateVendor({
    required String id,
    required String name,
    required String businessName,
    required String cnic,
    required String phone,
    required String city,
    required String area,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final index = _vendors.indexWhere((vendor) => vendor.id == id);
    if (index != -1) {
      _vendors[index] = _vendors[index].copyWith(
        name: name,
        businessName: businessName,
        cnic: cnic,
        phone: phone,
        city: city,
        area: area,
      );
      searchVendors(_searchQuery);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteVendor(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _vendors.removeWhere((vendor) => vendor.id == id);
    searchVendors(_searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Vendor? getVendorById(String id) {
    try {
      return _vendors.firstWhere((vendor) => vendor.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> get vendorStats {
    final uniqueCities = _vendors.map((vendor) => vendor.city).toSet().length;
    final uniqueAreas = _vendors.map((vendor) => vendor.area).toSet().length;

    return {
      'total': _vendors.length,
      'recentlyAdded': _vendors
          .where((vendor) =>
      DateTime.now().difference(vendor.createdAt).inDays <= 30)
          .length,
      'uniqueCities': uniqueCities,
      'uniqueAreas': uniqueAreas,
    };
  }
}