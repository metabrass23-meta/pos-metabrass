import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/product/product_model.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class FilterProductsDialog extends StatefulWidget {
  const FilterProductsDialog({super.key});

  @override
  State<FilterProductsDialog> createState() => _FilterProductsDialogState();
}

class _FilterProductsDialogState extends State<FilterProductsDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Filter controllers
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedColor;
  String? _selectedFabric;
  String? _selectedStockLevel;
  String _selectedSortBy = 'name';
  String _selectedSortOrder = 'asc';

  // Predefined options
  final List<String> _sortByOptions = ['name', 'price', 'quantity', 'created_at', 'updated_at'];
  final List<String> _sortOrderOptions = ['asc', 'desc'];
  final List<String> _stockLevelOptions = ['HIGH_STOCK', 'MEDIUM_STOCK', 'LOW_STOCK', 'OUT_OF_STOCK'];

  @override
  void initState() {
    super.initState();

    // Initialize with current filters
    final currentFilters = context.read<ProductProvider>().currentFilters;
    _selectedCategoryId = currentFilters.categoryId;
    _selectedColor = currentFilters.color;
    _selectedFabric = currentFilters.fabric;
    _selectedStockLevel = currentFilters.stockLevel;
    _selectedSortBy = currentFilters.sortBy;
    _selectedSortOrder = currentFilters.sortOrder;

    if (currentFilters.minPrice != null) {
      _minPriceController.text = currentFilters.minPrice.toString();
    }
    if (currentFilters.maxPrice != null) {
      _maxPriceController.text = currentFilters.maxPrice.toString();
    }

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _handleApplyFilters() {
    final provider = context.read<ProductProvider>();

    // Validate price range
    final minPrice = _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null;
    final maxPrice = _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null;

    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      _showErrorSnackbar('Minimum price cannot be greater than maximum price');
      return;
    }

    final filters = ProductFilters(
      categoryId: _selectedCategoryId,
      color: _selectedColor,
      fabric: _selectedFabric,
      stockLevel: _selectedStockLevel,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: _selectedSortBy,
      sortOrder: _selectedSortOrder,
    );

    provider.applyFilters(filters);
    _showSuccessSnackbar('Filters applied successfully');
    Navigator.of(context).pop();
  }

  void _handleClearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedColor = null;
      _selectedFabric = null;
      _selectedStockLevel = null;
      _selectedSortBy = 'name';
      _selectedSortOrder = 'asc';
      _minPriceController.clear();
      _maxPriceController.clear();
    });

    context.read<ProductProvider>().clearFilters();
    _showSuccessSnackbar('Filters cleared');
    Navigator.of(context).pop();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: ResponsiveBreakpoints.responsive(context, tablet: 85.w, small: 90.w, medium: 70.w, large: 60.w, ultrawide: 50.w),
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 85.h),
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
                    Flexible(child: _buildContent()),
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
        gradient: const LinearGradient(colors: [AppTheme.accentGold, Color(0xFFD4AF37)]),
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
            child: Icon(Icons.filter_alt_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter & Sort Products',
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
                    'Refine your product list with advanced filters',
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
              onTap: _handleCancel,
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

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Filter
            _buildFilterSection(title: 'Product Category', icon: Icons.category_outlined, child: _buildCategoryFilter()),

            SizedBox(height: context.cardPadding),

            // Color and Fabric Filters
            _buildFilterSection(title: 'Product Attributes', icon: Icons.palette_outlined, child: _buildAttributeFilters()),

            SizedBox(height: context.cardPadding),

            // Stock Level Filter
            _buildFilterSection(title: 'Stock Level', icon: Icons.inventory_rounded, child: _buildStockLevelFilter()),

            SizedBox(height: context.cardPadding),

            // Price Range Filter
            _buildFilterSection(title: 'Price Range (PKR)', icon: Icons.attach_money_rounded, child: _buildPriceRangeFilter()),

            SizedBox(height: context.cardPadding),

            // Sort Options
            _buildFilterSection(title: 'Sort Options', icon: Icons.sort_rounded, child: _buildSortOptionsFilter()),

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
    );
  }

  Widget _buildFilterSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Wrap(
          spacing: context.smallPadding,
          runSpacing: context.smallPadding / 2,
          children: [
            _buildFilterChip(
              label: 'All Categories',
              isSelected: _selectedCategoryId == null,
              onTap: () => setState(() => _selectedCategoryId = null),
            ),
            ...provider.categories
                .where((category) => category.isActive)
                .map(
                  (category) => _buildFilterChip(
                    label: category.name,
                    isSelected: _selectedCategoryId == category.id,
                    onTap: () => setState(() => _selectedCategoryId = category.id),
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildAttributeFilters() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Filter
            Text(
              'Color',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
            ),
            SizedBox(height: context.smallPadding),
            Wrap(
              spacing: context.smallPadding,
              runSpacing: context.smallPadding / 2,
              children: [
                _buildFilterChip(label: 'All Colors', isSelected: _selectedColor == null, onTap: () => setState(() => _selectedColor = null)),
                ...provider.availableColors.map(
                  (color) => _buildFilterChip(label: color, isSelected: _selectedColor == color, onTap: () => setState(() => _selectedColor = color)),
                ),
              ],
            ),
            SizedBox(height: context.cardPadding),

            // Fabric Filter
            Text(
              'Fabric',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
            ),
            SizedBox(height: context.smallPadding),
            Wrap(
              spacing: context.smallPadding,
              runSpacing: context.smallPadding / 2,
              children: [
                _buildFilterChip(label: 'All Fabrics', isSelected: _selectedFabric == null, onTap: () => setState(() => _selectedFabric = null)),
                ...provider.availableFabrics.map(
                  (fabric) =>
                      _buildFilterChip(label: fabric, isSelected: _selectedFabric == fabric, onTap: () => setState(() => _selectedFabric = fabric)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStockLevelFilter() {
    return Wrap(
      spacing: context.smallPadding,
      runSpacing: context.smallPadding / 2,
      children: [
        _buildFilterChip(label: 'All Stock Levels', isSelected: _selectedStockLevel == null, onTap: () => setState(() => _selectedStockLevel = null)),
        _buildFilterChip(
          label: 'In Stock (High)',
          isSelected: _selectedStockLevel == 'HIGH_STOCK',
          onTap: () => setState(() => _selectedStockLevel = 'HIGH_STOCK'),
        ),
        _buildFilterChip(
          label: 'Medium Stock',
          isSelected: _selectedStockLevel == 'MEDIUM_STOCK',
          onTap: () => setState(() => _selectedStockLevel = 'MEDIUM_STOCK'),
        ),
        _buildFilterChip(
          label: 'Low Stock',
          isSelected: _selectedStockLevel == 'LOW_STOCK',
          onTap: () => setState(() => _selectedStockLevel = 'LOW_STOCK'),
        ),
        _buildFilterChip(
          label: 'Out of Stock',
          isSelected: _selectedStockLevel == 'OUT_OF_STOCK',
          onTap: () => setState(() => _selectedStockLevel = 'OUT_OF_STOCK'),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: PremiumTextField(
                label: 'Min Price',
                hint: '0',
                controller: _minPriceController,
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: PremiumTextField(
                label: 'Max Price',
                hint: 'No limit',
                controller: _maxPriceController,
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptionsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort By
        Text(
          'Sort By',
          style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
        ),
        SizedBox(height: context.smallPadding),
        Wrap(
          spacing: context.smallPadding,
          runSpacing: context.smallPadding / 2,
          children: [
            _buildFilterChip(label: 'Name', isSelected: _selectedSortBy == 'name', onTap: () => setState(() => _selectedSortBy = 'name')),
            _buildFilterChip(label: 'Price', isSelected: _selectedSortBy == 'price', onTap: () => setState(() => _selectedSortBy = 'price')),
            _buildFilterChip(label: 'Quantity', isSelected: _selectedSortBy == 'quantity', onTap: () => setState(() => _selectedSortBy = 'quantity')),
            _buildFilterChip(
              label: 'Date Created',
              isSelected: _selectedSortBy == 'created_at',
              onTap: () => setState(() => _selectedSortBy = 'created_at'),
            ),
            _buildFilterChip(
              label: 'Date Updated',
              isSelected: _selectedSortBy == 'updated_at',
              onTap: () => setState(() => _selectedSortBy = 'updated_at'),
            ),
          ],
        ),
        SizedBox(height: context.cardPadding),

        // Sort Order
        Text(
          'Sort Order',
          style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
        ),
        SizedBox(height: context.smallPadding),
        Wrap(
          spacing: context.smallPadding,
          runSpacing: context.smallPadding / 2,
          children: [
            _buildFilterChip(label: 'Ascending', isSelected: _selectedSortOrder == 'asc', onTap: () => setState(() => _selectedSortOrder = 'asc')),
            _buildFilterChip(label: 'Descending', isSelected: _selectedSortOrder == 'desc', onTap: () => setState(() => _selectedSortOrder = 'desc')),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.borderRadius('small')),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2, vertical: context.smallPadding),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMaroon.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(color: isSelected ? AppTheme.primaryMaroon : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: context.subtitleFontSize,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryMaroon : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumButton(
          text: 'Apply Filters',
          onPressed: _handleApplyFilters,
          height: context.buttonHeight,
          icon: Icons.filter_alt_rounded,
          backgroundColor: AppTheme.accentGold,
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Clear All Filters',
          onPressed: _handleClearFilters,
          height: context.buttonHeight,
          icon: Icons.clear_all_rounded,
          isOutlined: true,
          backgroundColor: Colors.red[600],
          textColor: Colors.red[600],
        ),
        SizedBox(height: context.smallPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleCancel,
          height: context.buttonHeight,
          isOutlined: true,
          backgroundColor: Colors.grey[600],
          textColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            height: context.buttonHeight / 1.5,
            isOutlined: true,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Clear All',
            onPressed: _handleClearFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.clear_all_rounded,
            isOutlined: true,
            backgroundColor: Colors.red[600],
            textColor: Colors.red[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Apply Filters',
            onPressed: _handleApplyFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.filter_alt_rounded,
            backgroundColor: AppTheme.accentGold,
          ),
        ),
      ],
    );
  }
}
