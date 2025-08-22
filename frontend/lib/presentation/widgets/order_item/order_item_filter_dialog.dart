import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/order_item_provider.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/models/product/product_model.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';
import '../globals/custom_date_picker.dart';
import '../globals/drop_down.dart';

// Custom date picker widget for the filter dialog using Syncfusion
class PremiumDatePicker extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;
  final Key? dateKey; // Add key for forcing rebuilds

  const PremiumDatePicker({
    super.key,
    required this.label,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.dateKey,
  });

  @override
  State<PremiumDatePicker> createState() => _PremiumDatePickerState();
}

class _PremiumDatePickerState extends State<PremiumDatePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null
          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
          : '',
    );
  }

  @override
  void didUpdateWidget(PremiumDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      _selectedDate = widget.initialDate;
      _controller.text = _selectedDate != null
          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Use the custom Syncfusion date picker
        await context.showSyncfusionDateTimePicker(
          initialDate: _selectedDate ?? DateTime.now(),
          initialTime: const TimeOfDay(hour: 0, minute: 0),
          onDateTimeSelected: (date, time) {
            // For filter purposes, we only need the date part
            setState(() {
              _selectedDate = date;
              _controller.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
            });
            widget.onDateSelected(date);
          },
          title: 'Select ${widget.label}',
          minDate: widget.firstDate,
          maxDate: widget.lastDate,
          showTimeInline: false, // Only show date picker for filters
        );
      },
      child: PremiumTextField(
        label: widget.label,
        hint: 'Select date',
        controller: _controller,
        prefixIcon: Icons.calendar_today_outlined,
        enabled: false,
      ),
    );
  }
}

class OrderItemFilterDialog extends StatefulWidget {
  const OrderItemFilterDialog({super.key});

  @override
  State<OrderItemFilterDialog> createState() => _OrderItemFilterDialogState();
}

class _OrderItemFilterDialogState extends State<OrderItemFilterDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Filter state variables
  OrderModel? _selectedOrder;
  Product? _selectedProduct;
  String _searchQuery = '';
  bool _showInactiveOnly = false;

  // Quantity range filters
  int? _minQuantity;
  int? _maxQuantity;

  // Price range filters
  double? _minPrice;
  double? _maxPrice;

  // Customization filter
  bool _hasCustomization = false;

  // Date range filters
  DateTime? _dateFrom;
  DateTime? _dateTo;

  // Sorting options
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  // Text controllers (only for search and numeric inputs)
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Predefined options
  final List<String> _sortByOptions = ['created_at', 'quantity', 'unit_price', 'line_total', 'product_name', 'updated_at'];

  final List<String> _sortOrderOptions = ['asc', 'desc'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Initialize with current filter values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderItemProvider>();
      _selectedOrder = null; // Will be set from dropdown
      _selectedProduct = null; // Will be set from dropdown
      _searchQuery = provider.searchQuery;

      _searchController.text = _searchQuery;

      // Load orders and products for dropdowns
      _loadDropdownData();
    });

    _animationController.forward();
  }

  void _loadDropdownData() {
    // Load orders and products for dropdowns
    final orderProvider = context.read<OrderProvider>();
    final productProvider = context.read<ProductProvider>();

    if (orderProvider.orders.isEmpty) {
      orderProvider.refreshOrders();
    }

    if (productProvider.products.isEmpty) {
      productProvider.refreshProducts();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _minQuantityController.dispose();
    _maxQuantityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _handleApplyFilters() async {
    final provider = context.read<OrderItemProvider>();

    // Update filters from text controllers
    final search = _searchController.text.trim();

    // Parse numeric values
    final minQuantity = _minQuantityController.text.trim().isEmpty ? null : int.tryParse(_minQuantityController.text.trim());
    final maxQuantity = _maxQuantityController.text.trim().isEmpty ? null : int.tryParse(_maxQuantityController.text.trim());
    final minPrice = _minPriceController.text.trim().isEmpty ? null : double.tryParse(_minPriceController.text.trim());
    final maxPrice = _maxPriceController.text.trim().isEmpty ? null : double.tryParse(_maxPriceController.text.trim());

    // Store filter values for display
    _searchQuery = search;
    _minQuantity = minQuantity;
    _maxQuantity = maxQuantity;
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    // Apply filters using backend integration
    await provider.loadOrderItemsWithFilters(
      orderId: _selectedOrder?.id,
      productId: _selectedProduct?.id,
      refresh: true,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      minPrice: minPrice,
      maxPrice: maxPrice,
      hasCustomization: _hasCustomization,
      showInactive: _showInactiveOnly,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    _handleClose();
  }

  void _handleClearFilters() async {
    final provider = context.read<OrderItemProvider>();

    // Clear all filters
    provider.clearFilters();

    // Reset local state
    _selectedOrder = null;
    _selectedProduct = null;
    _searchQuery = '';
    _showInactiveOnly = false;
    _minQuantity = null;
    _maxQuantity = null;
    _minPrice = null;
    _maxPrice = null;
    _hasCustomization = false;
    _dateFrom = null;
    _dateTo = null;
    _sortBy = 'created_at';
    _sortOrder = 'desc';

    // Clear text controllers
    _searchController.clear();
    _minQuantityController.clear();
    _maxQuantityController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();

    // Refresh data from backend with no filters
    await provider.loadOrderItemsWithFilters(refresh: true);

    _handleClose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  // Helper method to get active filters count
  int get _activeFiltersCount {
    int count = 0;
    if (_selectedOrder != null) count++;
    if (_selectedProduct != null) count++;
    if (_searchQuery.isNotEmpty) count++;
    if (_minQuantity != null) count++;
    if (_maxQuantity != null) count++;
    if (_minPrice != null) count++;
    if (_maxPrice != null) count++;
    if (_hasCustomization) count++;
    if (_showInactiveOnly) count++;
    if (_dateFrom != null) count++;
    if (_dateTo != null) count++;
    if (_sortBy != 'created_at') count++;
    if (_sortOrder != 'desc') count++;
    return count;
  }

  // Helper method to get active filters text
  String get _activeFiltersText {
    final filters = <String>[];
    if (_selectedOrder != null) filters.add('Order: ${_selectedOrder!.customerName}');
    if (_selectedProduct != null) filters.add('Product: ${_selectedProduct!.name}');
    if (_searchQuery.isNotEmpty) filters.add('Search: $_searchQuery');
    if (_minQuantity != null) filters.add('Min Qty: $_minQuantity');
    if (_maxQuantity != null) filters.add('Max Qty: $_maxQuantity');
    if (_minPrice != null) filters.add('Min Price: PKR ${_minPrice!.toStringAsFixed(0)}');
    if (_maxPrice != null) filters.add('Max Price: PKR ${_maxPrice!.toStringAsFixed(0)}');
    if (_hasCustomization) filters.add('Has Customization');
    if (_dateFrom != null) filters.add('From: ${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}');
    if (_dateTo != null) filters.add('To: ${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}');
    if (_showInactiveOnly) filters.add('Show Inactive Only');
    if (_sortBy != 'created_at') filters.add('Sort: $_sortBy');
    if (_sortOrder != 'desc') filters.add('Order: $_sortOrder.toUpperCase()');

    return filters.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: ResponsiveBreakpoints.responsive(context, tablet: 90.w, small: 85.w, medium: 80.w, large: 75.w, ultrawide: 70.w),
                constraints: BoxConstraints(maxWidth: 800, maxHeight: 90.h),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: context.shadowBlur('heavy'), offset: Offset(0, context.cardPadding)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildActiveFiltersDisplay(),
                    Expanded(child: _buildFilterContent()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Icon(Icons.filter_list_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Item Filters',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!context.isTablet) ...[
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    'Customize your order item search and filtering',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.pureWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleClose,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                child: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersDisplay() {
    if (_activeFiltersCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: AppTheme.primaryMaroon.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined, color: AppTheme.primaryMaroon, size: context.iconSize('small')),
          SizedBox(width: context.smallPadding),
          Expanded(
            child: Text(
              'Active Filters: $_activeFiltersText',
              style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.primaryMaroon),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.primaryMaroon, borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Text(
              '$_activeFiltersCount',
              style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Filters Section
              _buildBasicFiltersSection(),
              SizedBox(height: context.cardPadding),

              // Search and Text Filters Section
              _buildSearchSection(),
              SizedBox(height: context.cardPadding),

              // Numeric Range Filters Section
              _buildNumericFiltersSection(),
              SizedBox(height: context.cardPadding),

              // Date and Status Filters Section
              _buildDateStatusFiltersSection(),
              SizedBox(height: context.cardPadding),

              // Sorting Options Section
              _buildSortingSection(),
              SizedBox(height: context.mainPadding),

              // Action Buttons
              ResponsiveBreakpoints.responsive(
                context,
                tablet: _buildCompactButtons(),
                small: _buildCompactButtons(),
                medium: _buildDesktopButtons(),
                large: _buildDesktopButtons(),
                ultrawide: _buildDesktopButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicFiltersSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: Colors.blue, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Basic Filters',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(child: _buildOrderDropdown()),
              SizedBox(width: context.cardPadding),
              Expanded(child: _buildProductDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDropdown() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return _buildSearchableDropdown<OrderModel>(
          label: 'Select Order',
          hint: 'Type customer name to search...',
          value: _selectedOrder,
          items: _getOrderDropdownItems(orderProvider),
          onChanged: (order) {
            setState(() {
              _selectedOrder = order;
            });
          },
          prefixIcon: Icons.receipt_long_outlined,
          searchHint: 'Search by customer name...',
        );
      },
    );
  }

  Widget _buildProductDropdown() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return _buildSearchableDropdown<Product>(
          label: 'Select Product',
          hint: 'Type product name to search...',
          value: _selectedProduct,
          items: _getProductDropdownItems(productProvider),
          onChanged: (product) {
            setState(() {
              _selectedProduct = product;
            });
          },
          prefixIcon: Icons.inventory_2_outlined,
          searchHint: 'Search by product name...',
        );
      },
    );
  }

  Widget _buildSearchableDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownItem<T?>> items,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
    String? searchHint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
        ),
        SizedBox(height: context.smallPadding / 2),
        InkWell(
          onTap: () => _showSearchableDropdown<T>(context, items, value, onChanged, searchHint),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              color: AppTheme.pureWhite,
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: context.iconSize('small'), color: Colors.grey[600]),
                  SizedBox(width: context.smallPadding / 2),
                ],
                Expanded(
                  child: Text(
                    value != null
                        ? items.firstWhere((item) => item.value == value, orElse: () => DropdownItem<T?>(value: null, label: '')).label
                        : hint,
                    style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: value != null ? AppTheme.charcoalGray : Colors.grey[500]),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchableDropdown<T>(
    BuildContext context,
    List<DropdownItem<T?>> items,
    T? currentValue,
    ValueChanged<T?> onChanged,
    String? searchHint,
  ) {
    final searchController = TextEditingController();
    List<DropdownItem<T?>> filteredItems = List.from(items);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius('large'))),
            child: Container(
              width: 400,
              padding: EdgeInsets.all(context.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select ${T == OrderModel ? 'Order' : 'Product'}',
                    style: GoogleFonts.inter(fontSize: context.headerFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                  ),
                  SizedBox(height: context.cardPadding),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: searchHint ?? 'Search...',
                      hintStyle: GoogleFonts.inter(fontSize: context.subtitleFontSize, color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                    ),
                    onChanged: (query) {
                      setState(() {
                        if (query.isEmpty) {
                          filteredItems = List.from(items);
                        } else {
                          filteredItems = items.where((item) => item.label.toLowerCase().contains(query.toLowerCase())).toList();
                        }
                      });
                    },
                  ),
                  SizedBox(height: context.cardPadding),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text(
                            item.label,
                            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            onChanged(item.value);
                            Navigator.of(context).pop();
                          },
                          tileColor: item.value == currentValue ? AppTheme.primaryMaroon.withOpacity(0.1) : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<DropdownItem<OrderModel?>> _getOrderDropdownItems(OrderProvider orderProvider) {
    final orders = orderProvider.orders;
    return [
      DropdownItem<OrderModel?>(value: null, label: 'All Orders'),
      ...orders.map((order) => DropdownItem<OrderModel?>(value: order, label: '${order.customerName} - ${order.id.substring(0, 8)}...')).toList(),
    ];
  }

  List<DropdownItem<Product?>> _getProductDropdownItems(ProductProvider productProvider) {
    final products = productProvider.products;
    return [
      DropdownItem<Product?>(value: null, label: 'All Products'),
      ...products.map((product) => DropdownItem<Product?>(value: product, label: '${product.name} - ${product.id.substring(0, 8)}...')).toList(),
    ];
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search_outlined, color: Colors.green, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Search & Text Filters',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Search Query',
            hint: 'Search in product names, customization notes, or IDs',
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildNumericFiltersSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_outlined, color: Colors.orange, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Numeric Range Filters',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  label: 'Min Quantity',
                  hint: 'Minimum quantity',
                  controller: _minQuantityController,
                  prefixIcon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumTextField(
                  label: 'Max Quantity',
                  hint: 'Maximum quantity',
                  controller: _maxQuantityController,
                  prefixIcon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  label: 'Min Price (PKR)',
                  hint: 'Minimum unit price',
                  controller: _minPriceController,
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumTextField(
                  label: 'Max Price (PKR)',
                  hint: 'Maximum unit price',
                  controller: _maxPriceController,
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateStatusFiltersSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_outlined, color: Colors.purple, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Date & Status Filters',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumDatePicker(
                  key: ValueKey('dateFrom_${_dateFrom?.millisecondsSinceEpoch ?? 'null'}'),
                  label: 'Date From',
                  initialDate: _dateFrom,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  onDateSelected: (date) => setState(() => _dateFrom = date),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumDatePicker(
                  key: ValueKey('dateTo_${_dateTo?.millisecondsSinceEpoch ?? 'null'}'),
                  label: 'Date To',
                  initialDate: _dateTo,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  onDateSelected: (date) => setState(() => _dateTo = date),
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Show Inactive Items',
                    style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500),
                  ),
                  value: _showInactiveOnly,
                  onChanged: (value) => setState(() => _showInactiveOnly = value ?? false),
                  activeColor: Colors.purple,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Has Customization Notes',
                    style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500),
                  ),
                  value: _hasCustomization,
                  onChanged: (value) => setState(() => _hasCustomization = value ?? false),
                  activeColor: Colors.purple,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortingSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.teal.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sort_outlined, color: Colors.teal, size: context.iconSize('medium')),
              SizedBox(width: context.cardPadding),
              Text(
                'Sorting Options',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumDropdownField<String>(
                  label: 'Sort By',
                  hint: 'Select sort field',
                  value: _sortBy,
                  items: _sortByOptions.map((option) {
                    return DropdownItem<String>(value: option, label: _getSortByDisplayName(option));
                  }).toList(),
                  onChanged: (value) => setState(() => _sortBy = value ?? 'created_at'),
                  prefixIcon: Icons.sort_by_alpha_outlined,
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumDropdownField<String>(
                  label: 'Sort Order',
                  hint: 'Select sort order',
                  value: _sortOrder,
                  items: _sortOrderOptions.map((option) {
                    return DropdownItem<String>(value: option, label: option.toUpperCase());
                  }).toList(),
                  onChanged: (value) => setState(() => _sortOrder = value ?? 'desc'),
                  prefixIcon: Icons.arrow_upward_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortByDisplayName(String sortBy) {
    switch (sortBy) {
      case 'created_at':
        return 'Created Date';
      case 'quantity':
        return 'Quantity';
      case 'unit_price':
        return 'Unit Price';
      case 'line_total':
        return 'Line Total';
      case 'product_name':
        return 'Product Name';
      case 'updated_at':
        return 'Updated Date';
      default:
        return sortBy;
    }
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumButton(
          text: 'Apply Filters',
          onPressed: _handleApplyFilters,
          height: context.buttonHeight,
          icon: Icons.check_rounded,
          backgroundColor: Colors.indigo,
        ),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: 'Clear All',
                onPressed: _handleClearFilters,
                isOutlined: true,
                height: context.buttonHeight,
                backgroundColor: Colors.red[600],
                textColor: Colors.red[600],
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: PremiumButton(
                text: 'Cancel',
                onPressed: _handleClose,
                isOutlined: true,
                height: context.buttonHeight,
                backgroundColor: Colors.grey[600],
                textColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Clear All Filters',
            onPressed: _handleClearFilters,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.red[600],
            textColor: Colors.red[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 1,
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleClose,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Apply Filters',
            onPressed: _handleApplyFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.check_rounded,
            backgroundColor: Colors.indigo,
          ),
        ),
      ],
    );
  }
}
