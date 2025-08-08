import 'package:flutter/material.dart';

// Enhanced Vendor model with all features from Customer
class Vendor {
  final String id;
  final String name;
  final String businessName;
  final String cnic;
  final String phone;
  final String? email;
  final String? address;
  final String city;
  final String area;
  final String? country;
  final String status; // 'ACTIVE', 'INACTIVE', 'SUSPENDED'
  final String vendorType; // 'SUPPLIER', 'DISTRIBUTOR', 'MANUFACTURER'
  final String? taxNumber;
  final String? notes;
  final bool phoneVerified;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastOrderDate;
  final DateTime? lastContactDate;
  final double? totalOrders;
  final bool isActive;

  Vendor({
    required this.id,
    required this.name,
    required this.businessName,
    required this.cnic,
    required this.phone,
    this.email,
    this.address,
    required this.city,
    required this.area,
    this.country = 'Pakistan',
    this.status = 'ACTIVE',
    this.vendorType = 'SUPPLIER',
    this.taxNumber,
    this.notes,
    this.phoneVerified = false,
    this.emailVerified = false,
    required this.createdAt,
    this.lastOrderDate,
    this.lastContactDate,
    this.totalOrders,
    this.isActive = true,
  });

  Vendor copyWith({
    String? id,
    String? name,
    String? businessName,
    String? cnic,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? area,
    String? country,
    String? status,
    String? vendorType,
    String? taxNumber,
    String? notes,
    bool? phoneVerified,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastOrderDate,
    DateTime? lastContactDate,
    double? totalOrders,
    bool? isActive,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      country: country ?? this.country,
      status: status ?? this.status,
      vendorType: vendorType ?? this.vendorType,
      taxNumber: taxNumber ?? this.taxNumber,
      notes: notes ?? this.notes,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      totalOrders: totalOrders ?? this.totalOrders,
      isActive: isActive ?? this.isActive,
    );
  }

  // Formatted date for display
  String get formattedCreatedAt {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  // Relative date (e.g., "Today", "Yesterday", "2 days ago")
  String get relativeCreatedAt {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final vendorDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final difference = today.difference(vendorDate).inDays;

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

  // Display names for status and type
  String get statusDisplayName {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'INACTIVE':
        return 'Inactive';
      case 'SUSPENDED':
        return 'Suspended';
      default:
        return status;
    }
  }

  String get vendorTypeDisplayName {
    switch (vendorType.toUpperCase()) {
      case 'SUPPLIER':
        return 'Supplier';
      case 'DISTRIBUTOR':
        return 'Distributor';
      case 'MANUFACTURER':
        return 'Manufacturer';
      default:
        return vendorType;
    }
  }

  // Get initials for profile display
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.length == 1) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'VE';
  }

  // Display name with business name
  String get displayName {
    return '$name ($businessName)';
  }

  // Formatted last order date
  String? get formattedLastOrderDate {
    if (lastOrderDate == null) return null;
    return '${lastOrderDate!.day.toString().padLeft(2, '0')}/${lastOrderDate!.month.toString().padLeft(2, '0')}/${lastOrderDate!.year}';
  }

  // Formatted last contact date
  String? get formattedLastContactDate {
    if (lastContactDate == null) return null;
    return '${lastContactDate!.day.toString().padLeft(2, '0')}/${lastContactDate!.month.toString().padLeft(2, '0')}/${lastContactDate!.year}';
  }

  // Vendor age in days
  int get vendorAgeDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'businessName': businessName,
      'cnic': cnic,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'area': area,
      'country': country,
      'status': status,
      'vendorType': vendorType,
      'taxNumber': taxNumber,
      'notes': notes,
      'phoneVerified': phoneVerified,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastOrderDate': lastOrderDate?.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
      'totalOrders': totalOrders,
      'isActive': isActive,
    };
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      businessName: json['businessName'],
      cnic: json['cnic'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      area: json['area'],
      country: json['country'] ?? 'Pakistan',
      status: json['status'] ?? 'ACTIVE',
      vendorType: json['vendorType'] ?? 'SUPPLIER',
      taxNumber: json['taxNumber'],
      notes: json['notes'],
      phoneVerified: json['phoneVerified'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : null,
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'])
          : null,
      totalOrders: json['totalOrders']?.toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }
}

// Pagination info class
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
      pageSize: json['pageSize'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
    );
  }
}

// Vendor statistics class
class VendorStatistics {
  final int totalVendors;
  final int activeVendors;
  final int inactiveVendors;
  final int newVendorsThisMonth;
  final int recentVendorsThisWeek;
  final Map<String, int> vendorsByType;
  final Map<String, int> vendorsByCity;
  final double averageOrderValue;

  VendorStatistics({
    required this.totalVendors,
    required this.activeVendors,
    required this.inactiveVendors,
    required this.newVendorsThisMonth,
    required this.recentVendorsThisWeek,
    required this.vendorsByType,
    required this.vendorsByCity,
    required this.averageOrderValue,
  });

  factory VendorStatistics.fromJson(Map<String, dynamic> json) {
    return VendorStatistics(
      totalVendors: json['totalVendors'],
      activeVendors: json['activeVendors'],
      inactiveVendors: json['inactiveVendors'],
      newVendorsThisMonth: json['newVendorsThisMonth'],
      recentVendorsThisWeek: json['recentVendorsThisWeek'],
      vendorsByType: Map<String, int>.from(json['vendorsByType'] ?? {}),
      vendorsByCity: Map<String, int>.from(json['vendorsByCity'] ?? {}),
      averageOrderValue: json['averageOrderValue']?.toDouble() ?? 0.0,
    );
  }
}

class VendorProvider extends ChangeNotifier {
  List<Vendor> _vendors = [];
  List<Vendor> _filteredVendors = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  // Pagination
  PaginationInfo? _paginationInfo;
  int _currentPage = 1;
  int _pageSize = 20;
  bool _showInactive = false;

  // Filters
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedCity;
  String? _selectedArea;
  String? _selectedCountry;
  String? _verificationFilter;

  // Sorting
  String _sortBy = 'created_at';
  bool _sortAscending = false;

  // Statistics
  VendorStatistics? _vendorStatistics;

  // Getters
  List<Vendor> get vendors => _filteredVendors;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  PaginationInfo? get paginationInfo => _paginationInfo;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get showInactive => _showInactive;
  String? get selectedStatus => _selectedStatus;
  String? get selectedType => _selectedType;
  String? get selectedCity => _selectedCity;
  String? get selectedArea => _selectedArea;
  String? get selectedCountry => _selectedCountry;
  String? get verificationFilter => _verificationFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  VendorStatistics? get vendorStatistics => _vendorStatistics;

  VendorProvider() {
    _initializeVendors();
    _loadVendorStatistics();
  }

  void _initializeVendors() {
    _vendors = [
      Vendor(
        id: 'VEN001',
        name: 'Muhammad Ali',
        businessName: 'Ali Textiles & Co.',
        cnic: '42101-1234567-1',
        phone: '+923001234567',
        email: 'ali@alitextiles.com',
        address: 'Plot 45, Industrial Area',
        city: 'Karachi',
        area: 'Gulshan',
        country: 'Pakistan',
        status: 'ACTIVE',
        vendorType: 'SUPPLIER',
        taxNumber: 'TAX123456',
        notes: 'Reliable textile supplier with good quality products',
        phoneVerified: true,
        emailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastOrderDate: DateTime.now().subtract(const Duration(days: 5)),
        lastContactDate: DateTime.now().subtract(const Duration(days: 2)),
        totalOrders: 125000.50,
        isActive: true,
      ),
      Vendor(
        id: 'VEN002',
        name: 'Sarah Khan',
        businessName: 'Khan Fabrics',
        cnic: '42101-7654321-2',
        phone: '+923009876543',
        email: 'sarah@khanfabrics.com',
        address: 'Shop 12, Main Market',
        city: 'Lahore',
        area: 'Johar Town',
        country: 'Pakistan',
        status: 'ACTIVE',
        vendorType: 'DISTRIBUTOR',
        taxNumber: 'TAX654321',
        notes: 'Excellent distributor for premium fabrics',
        phoneVerified: true,
        emailVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastOrderDate: DateTime.now().subtract(const Duration(days: 10)),
        lastContactDate: DateTime.now().subtract(const Duration(days: 7)),
        totalOrders: 89750.25,
        isActive: true,
      ),
      Vendor(
        id: 'VEN003',
        name: 'Ahmed Hassan',
        businessName: 'Hassan Brothers Trading',
        cnic: '42101-5555555-5',
        phone: '+923001111111',
        email: 'ahmed@hassantrading.com',
        address: 'Building 7, Commercial Complex',
        city: 'Karachi',
        area: 'Clifton',
        country: 'Pakistan',
        status: 'INACTIVE',
        vendorType: 'MANUFACTURER',
        taxNumber: 'TAX111111',
        notes: 'Manufacturing partner, currently inactive due to expansion',
        phoneVerified: false,
        emailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastOrderDate: DateTime.now().subtract(const Duration(days: 30)),
        lastContactDate: DateTime.now().subtract(const Duration(days: 15)),
        totalOrders: 156200.75,
        isActive: false,
      ),
      Vendor(
        id: 'VEN004',
        name: 'Fatima Sheikh',
        businessName: 'Sheikh Embroidery Works',
        cnic: '42101-9999999-9',
        phone: '+923002222222',
        email: 'fatima@sheikhembroidery.com',
        address: 'House 23, Block C',
        city: 'Islamabad',
        area: 'F-7',
        country: 'Pakistan',
        status: 'ACTIVE',
        vendorType: 'SUPPLIER',
        taxNumber: 'TAX999999',
        notes: 'Specialized in embroidery and decorative work',
        phoneVerified: true,
        emailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastOrderDate: DateTime.now().subtract(const Duration(days: 3)),
        lastContactDate: DateTime.now().subtract(const Duration(days: 1)),
        totalOrders: 67890.00,
        isActive: true,
      ),
    ];

    _filteredVendors = List.from(_vendors);
    _createMockPagination();
  }

  void _createMockPagination() {
    _paginationInfo = PaginationInfo(
      currentPage: _currentPage,
      totalPages: (_vendors.length / _pageSize).ceil(),
      totalCount: _vendors.length,
      pageSize: _pageSize,
      hasNext: _currentPage < (_vendors.length / _pageSize).ceil(),
      hasPrevious: _currentPage > 1,
    );
  }

  void _loadVendorStatistics() {
    final activeCount = _vendors.where((v) => v.status == 'ACTIVE').length;
    final inactiveCount = _vendors.where((v) => v.status == 'INACTIVE').length;
    final newThisMonth = _vendors.where((v) =>
    DateTime.now().difference(v.createdAt).inDays <= 30).length;
    final recentThisWeek = _vendors.where((v) =>
    DateTime.now().difference(v.createdAt).inDays <= 7).length;

    final typeMap = <String, int>{};
    final cityMap = <String, int>{};
    double totalOrderValue = 0.0;

    for (final vendor in _vendors) {
      // Count by type
      typeMap[vendor.vendorType] = (typeMap[vendor.vendorType] ?? 0) + 1;
      // Count by city
      cityMap[vendor.city] = (cityMap[vendor.city] ?? 0) + 1;
      // Sum order values
      if (vendor.totalOrders != null) {
        totalOrderValue += vendor.totalOrders!;
      }
    }

    _vendorStatistics = VendorStatistics(
      totalVendors: _vendors.length,
      activeVendors: activeCount,
      inactiveVendors: inactiveCount,
      newVendorsThisMonth: newThisMonth,
      recentVendorsThisWeek: recentThisWeek,
      vendorsByType: typeMap,
      vendorsByCity: cityMap,
      averageOrderValue: _vendors.isNotEmpty ? totalOrderValue / _vendors.length : 0.0,
    );
  }

  /// Load vendors with pagination and filters
  Future<void> loadVendors({
    int? page,
    int? pageSize,
    String? search,
    bool? showInactive,
    String? status,
    String? vendorType,
    String? city,
    String? area,
    String? country,
    String? verified,
    bool showLoadingIndicator = true,
  }) async {
    if (showLoadingIndicator) {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

    try {
      // Update parameters
      _currentPage = page ?? _currentPage;
      _pageSize = pageSize ?? _pageSize;
      _searchQuery = search ?? _searchQuery;
      _showInactive = showInactive ?? _showInactive;
      _selectedStatus = status;
      _selectedType = vendorType;
      _selectedCity = city;
      _selectedArea = area;
      _selectedCountry = country;
      _verificationFilter = verified;

      // Apply filters
      _applyFilters();

      _hasError = false;
      _errorMessage = null;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load vendors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<Vendor> filtered = List.from(_vendors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vendor) =>
      vendor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vendor.businessName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vendor.cnic.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vendor.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vendor.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vendor.area.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (vendor.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }

    // Apply status filter
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((vendor) => vendor.status == _selectedStatus).toList();
    }

    // Apply type filter
    if (_selectedType != null && _selectedType!.isNotEmpty) {
      filtered = filtered.where((vendor) => vendor.vendorType == _selectedType).toList();
    }

    // Apply city filter
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filtered = filtered.where((vendor) => vendor.city.toLowerCase() == _selectedCity!.toLowerCase()).toList();
    }

    // Apply area filter
    if (_selectedArea != null && _selectedArea!.isNotEmpty) {
      filtered = filtered.where((vendor) => vendor.area.toLowerCase() == _selectedArea!.toLowerCase()).toList();
    }

    // Apply country filter
    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      filtered = filtered.where((vendor) => vendor.country?.toLowerCase() == _selectedCountry!.toLowerCase()).toList();
    }

    // Apply verification filter
    if (_verificationFilter != null && _verificationFilter!.isNotEmpty) {
      switch (_verificationFilter!.toLowerCase()) {
        case 'phone':
          filtered = filtered.where((vendor) => vendor.phoneVerified).toList();
          break;
        case 'email':
          filtered = filtered.where((vendor) => vendor.emailVerified).toList();
          break;
        case 'both':
          filtered = filtered.where((vendor) => vendor.phoneVerified && vendor.emailVerified).toList();
          break;
        case 'none':
          filtered = filtered.where((vendor) => !vendor.phoneVerified && !vendor.emailVerified).toList();
          break;
      }
    }

    // Apply inactive filter
    if (!_showInactive) {
      filtered = filtered.where((vendor) => vendor.isActive).toList();
    }

    // Apply sorting
    _applySorting(filtered);

    _filteredVendors = filtered;
    _createMockPagination();
  }

  void _applySorting(List<Vendor> vendors) {
    vendors.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'business_name':
          comparison = a.businessName.compareTo(b.businessName);
          break;
        case 'created_at':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'last_order_date':
          if (a.lastOrderDate == null && b.lastOrderDate == null) return 0;
          if (a.lastOrderDate == null) return 1;
          if (b.lastOrderDate == null) return -1;
          comparison = a.lastOrderDate!.compareTo(b.lastOrderDate!);
          break;
        case 'total_orders':
          final aTotal = a.totalOrders ?? 0.0;
          final bTotal = b.totalOrders ?? 0.0;
          comparison = aTotal.compareTo(bTotal);
          break;
        case 'city':
          comparison = a.city.compareTo(b.city);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'vendor_type':
          comparison = a.vendorType.compareTo(b.vendorType);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  /// Refresh vendors (pull-to-refresh)
  Future<void> refreshVendors() async {
    _currentPage = 1;
    await loadVendors(page: 1, showLoadingIndicator: false);
    _loadVendorStatistics();
    notifyListeners();
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (_paginationInfo?.hasNext == true) {
      await loadVendors(page: _currentPage + 1, showLoadingIndicator: false);
    }
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (_paginationInfo?.hasPrevious == true) {
      await loadVendors(page: _currentPage - 1, showLoadingIndicator: false);
    }
  }

  /// Search vendors
  Future<void> searchVendors(String query) async {
    _searchQuery = query.toLowerCase();
    _currentPage = 1;
    await loadVendors(search: _searchQuery, page: 1);
  }

  /// Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadVendors(search: '', page: 1);
  }

  /// Toggle show inactive vendors
  Future<void> toggleShowInactive() async {
    _showInactive = !_showInactive;
    _currentPage = 1;
    await loadVendors(showInactive: _showInactive, page: 1);
  }

  /// Set status filter
  Future<void> setStatusFilter(String? status) async {
    _selectedStatus = status;
    _currentPage = 1;
    await loadVendors(status: _selectedStatus, page: 1);
  }

  /// Set vendor type filter
  Future<void> setTypeFilter(String? vendorType) async {
    _selectedType = vendorType;
    _currentPage = 1;
    await loadVendors(vendorType: _selectedType, page: 1);
  }

  /// Set city filter
  Future<void> setCityFilter(String? city) async {
    _selectedCity = city;
    _currentPage = 1;
    await loadVendors(city: _selectedCity, page: 1);
  }

  /// Set area filter
  Future<void> setAreaFilter(String? area) async {
    _selectedArea = area;
    _currentPage = 1;
    await loadVendors(area: _selectedArea, page: 1);
  }

  /// Set country filter
  Future<void> setCountryFilter(String? country) async {
    _selectedCountry = country;
    _currentPage = 1;
    await loadVendors(country: _selectedCountry, page: 1);
  }

  /// Set verification filter
  Future<void> setVerificationFilter(String? verified) async {
    _verificationFilter = verified;
    _currentPage = 1;
    await loadVendors(verified: _verificationFilter, page: 1);
  }

  /// Clear all filters
  Future<void> clearAllFilters() async {
    _selectedStatus = null;
    _selectedType = null;
    _selectedCity = null;
    _selectedArea = null;
    _selectedCountry = null;
    _verificationFilter = null;
    _searchQuery = '';
    _currentPage = 1;
    await loadVendors(
      status: null,
      vendorType: null,
      city: null,
      area: null,
      country: null,
      verified: null,
      search: '',
      page: 1,
    );
  }

  /// Sort vendors
  void setSortBy(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortAscending = (sortBy == 'name' || sortBy == 'business_name' || sortBy == 'city');
      }
    }

    loadVendors(showLoadingIndicator: false);
  }

  /// Add new vendor
  Future<bool> addVendor({
    required String name,
    required String businessName,
    required String cnic,
    required String phone,
    String? email,
    String? address,
    required String city,
    required String area,
    String? country,
    String? vendorType,
    String? taxNumber,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final newVendor = Vendor(
        id: 'VEN${(_vendors.length + 1).toString().padLeft(3, '0')}',
        name: name,
        businessName: businessName,
        cnic: cnic,
        phone: phone,
        email: email,
        address: address,
        city: city,
        area: area,
        country: country ?? 'Pakistan',
        vendorType: vendorType ?? 'SUPPLIER',
        taxNumber: taxNumber,
        notes: notes,
        createdAt: DateTime.now(),
      );

      _vendors.add(newVendor);
      _applyFilters();
      _loadVendorStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to create vendor: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing vendor
  Future<bool> updateVendor({
    required String id,
    required String name,
    required String businessName,
    required String cnic,
    required String phone,
    String? email,
    String? address,
    required String city,
    required String area,
    String? country,
    String? vendorType,
    String? status,
    String? taxNumber,
    String? notes,
    bool? phoneVerified,
    bool? emailVerified,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final index = _vendors.indexWhere((vendor) => vendor.id == id);
      if (index != -1) {
        _vendors[index] = _vendors[index].copyWith(
          name: name,
          businessName: businessName,
          cnic: cnic,
          phone: phone,
          email: email,
          address: address,
          city: city,
          area: area,
          country: country,
          vendorType: vendorType,
          status: status,
          taxNumber: taxNumber,
          notes: notes,
          phoneVerified: phoneVerified,
          emailVerified: emailVerified,
        );

        _applyFilters();
        _loadVendorStatistics();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update vendor: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete vendor permanently (hard delete)
  Future<bool> deleteVendor(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _vendors.removeWhere((vendor) => vendor.id == id);
      _applyFilters();
      _loadVendorStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to delete vendor: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Soft delete vendor (set as inactive)
  Future<bool> softDeleteVendor(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _vendors.indexWhere((vendor) => vendor.id == id);
      if (index != -1) {
        _vendors[index] = _vendors[index].copyWith(
          status: 'INACTIVE',
          isActive: false,
        );

        if (!_showInactive) {
          _filteredVendors.removeWhere((vendor) => vendor.id == id);
        } else {
          _applyFilters();
        }
        _loadVendorStatistics();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to deactivate vendor: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore vendor
  Future<bool> restoreVendor(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _vendors.indexWhere((vendor) => vendor.id == id);
      if (index != -1) {
        _vendors[index] = _vendors[index].copyWith(
          status: 'ACTIVE',
          isActive: true,
        );

        _applyFilters();
        _loadVendorStatistics();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to restore vendor: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify vendor contact
  Future<bool> verifyVendorContact({
    required String id,
    required String verificationType,
    bool verified = true,
  }) async {
    try {
      final index = _vendors.indexWhere((vendor) => vendor.id == id);
      if (index != -1) {
        if (verificationType.toLowerCase() == 'phone') {
          _vendors[index] = _vendors[index].copyWith(phoneVerified: verified);
        } else if (verificationType.toLowerCase() == 'email') {
          _vendors[index] = _vendors[index].copyWith(emailVerified: verified);
        }

        _applyFilters();
        _loadVendorStatistics();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to verify vendor contact: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update vendor activity
  Future<bool> updateVendorActivity({
    required String id,
    required String activityType,
    String? activityDate,
  }) async {
    try {
      final index = _vendors.indexWhere((vendor) => vendor.id == id);
      if (index != -1) {
        final date = activityDate != null
            ? DateTime.parse(activityDate)
            : DateTime.now();

        if (activityType.toLowerCase() == 'order') {
          _vendors[index] = _vendors[index].copyWith(lastOrderDate: date);
        } else if (activityType.toLowerCase() == 'contact') {
          _vendors[index] = _vendors[index].copyWith(lastContactDate: date);
        }

        _applyFilters();
        _loadVendorStatistics();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update vendor activity: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Bulk vendor actions
  Future<bool> bulkVendorActions({
    required List<String> vendorIds,
    required String action,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      for (final id in vendorIds) {
        final index = _vendors.indexWhere((vendor) => vendor.id == id);
        if (index != -1) {
          switch (action.toLowerCase()) {
            case 'activate':
              _vendors[index] = _vendors[index].copyWith(
                status: 'ACTIVE',
                isActive: true,
              );
              break;
            case 'deactivate':
              _vendors[index] = _vendors[index].copyWith(
                status: 'INACTIVE',
                isActive: false,
              );
              break;
            case 'delete':
              _vendors.removeAt(index);
              break;
            case 'verify_phone':
              _vendors[index] = _vendors[index].copyWith(phoneVerified: true);
              break;
            case 'verify_email':
              _vendors[index] = _vendors[index].copyWith(emailVerified: true);
              break;
          }
        }
      }

      _applyFilters();
      _loadVendorStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to perform bulk action: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Duplicate vendor
  Future<bool> duplicateVendor({
    required String id,
    required String name,
    required String businessName,
    String? cnic,
    required String phone,
    String? email,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final originalVendor = _vendors.firstWhere((vendor) => vendor.id == id);

      final duplicatedVendor = originalVendor.copyWith(
        id: 'VEN${(_vendors.length + 1).toString().padLeft(3, '0')}',
        name: name,
        businessName: businessName,
        cnic: cnic ?? originalVendor.cnic,
        phone: phone,
        email: email,
        createdAt: DateTime.now(),
        lastOrderDate: null,
        lastContactDate: null,
        totalOrders: null,
        phoneVerified: false,
        emailVerified: false,
      );

      _vendors.add(duplicatedVendor);
      _applyFilters();
      _loadVendorStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to duplicate vendor: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get vendor by ID
  Vendor? getVendorById(String id) {
    try {
      return _vendors.firstWhere((vendor) => vendor.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Enhanced statistics for dashboard
  Map<String, dynamic> get vendorStats {
    if (_vendorStatistics == null) {
      return {
        'total': 0,
        'active': 0,
        'recentlyAdded': 0,
        'uniqueCities': 0,
        'uniqueAreas': 0,
        'averageOrderValue': 0.0,
      };
    }

    final uniqueAreas = _vendors.map((vendor) => vendor.area).toSet().length;

    return {
      'total': _vendorStatistics!.totalVendors,
      'active': _vendorStatistics!.activeVendors,
      'recentlyAdded': _vendorStatistics!.newVendorsThisMonth,
      'uniqueCities': _vendorStatistics!.vendorsByCity.length,
      'uniqueAreas': uniqueAreas,
      'averageOrderValue': _vendorStatistics!.averageOrderValue,
    };
  }

  /// Get vendors by status
  List<Vendor> getVendorsByStatus(String status) {
    return _vendors.where((vendor) => vendor.status == status).toList();
  }

  /// Get vendors by type
  List<Vendor> getVendorsByType(String vendorType) {
    return _vendors.where((vendor) => vendor.vendorType == vendorType).toList();
  }

  /// Get recently created vendors
  List<Vendor> getRecentlyCreated({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _vendors
        .where((vendor) => vendor.createdAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Export data (placeholder for future implementation)
  Future<void> exportData() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Set page size
  Future<void> setPageSize(int pageSize) async {
    if (_pageSize != pageSize) {
      _pageSize = pageSize;
      _currentPage = 1;
      await loadVendors(pageSize: _pageSize, page: 1);
    }
  }

  /// Load vendors by specific segments
  Future<void> loadPakistaniVendors() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final pakistaniVendors = _vendors.where((vendor) =>
      vendor.country?.toLowerCase() == 'pakistan').toList();
      _filteredVendors = pakistaniVendors;
      _createMockPagination();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load Pakistani vendors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInternationalVendors() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final internationalVendors = _vendors.where((vendor) =>
      vendor.country?.toLowerCase() != 'pakistan').toList();
      _filteredVendors = internationalVendors;
      _createMockPagination();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load international vendors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveVendors() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final activeVendors = _vendors.where((vendor) =>
      vendor.status == 'ACTIVE').toList();
      _filteredVendors = activeVendors;
      _createMockPagination();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load active vendors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNewVendors({int days = 30}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final newVendors = _vendors.where((vendor) =>
          vendor.createdAt.isAfter(cutoffDate)).toList();
      _filteredVendors = newVendors;
      _createMockPagination();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load new vendors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}