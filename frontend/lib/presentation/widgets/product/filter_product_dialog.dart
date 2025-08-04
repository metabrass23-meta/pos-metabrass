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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

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
    final minPrice = _minPriceController.text.isNotEmpty
        ? double.tryParse(_minPriceController.text)
        : null;
    final maxPrice = _maxPriceController.text.isNotEmpty
        ? double.tryParse(_maxPriceController.text)
        : null;

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
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.pureWhite,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
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
          backgroundColor: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 90.w,
                  small: 85.w,
                  medium: 75.w,
                  large: 65.w,
                  ultrawide: 55.w,
                ),
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 90.h,
                ),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: context.shadowBlur('heavy'),
                      offset: Offset(0, context.cardPadding),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildFilterContent(),
                    ],
                  ),
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
        gradient: const LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('large'),
            ),
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
                    'Customize your product view',
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
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.pureWhite,
                  size: context.iconSize('medium'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Filter
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              return DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                  ),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...provider.categories
                      .where((category) => category.isActive)
                      .map((category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  )),
                ],
                onChanged: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
              );
            },
          ),
          SizedBox(height: context.cardPadding),

          // Color and Fabric Row
          Row(
            children: [
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedColor,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        prefixIcon: Icon(Icons.color_lens_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.borderRadius()),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Colors'),
                        ),
                        ...provider.availableColors.map((color) => DropdownMenuItem<String>(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getColorFromName(color),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                              ),
                              SizedBox(width: context.smallPadding),
                              Expanded(child: Text(color)),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedFabric,
                      decoration: InputDecoration(
                        labelText: 'Fabric',
                        prefixIcon: Icon(Icons.texture_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.borderRadius()),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Fabrics'),
                        ),
                        ...provider.availableFabrics.map((fabric) => DropdownMenuItem<String>(
                          value: fabric,
                          child: Text(fabric),
                        )),
                      ],
                      onChanged: (fabric) {
                        setState(() {
                          _selectedFabric = fabric;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Stock Level Filter
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              return DropdownButtonFormField<String>(
                value: _selectedStockLevel,
                decoration: InputDecoration(
                  labelText: 'Stock Level',
                  prefixIcon: Icon(Icons.inventory_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                  ),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Stock Levels'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'HIGH_STOCK',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Text('In Stock (High)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'MEDIUM_STOCK',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Text('Medium Stock'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'LOW_STOCK',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Text('Low Stock'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'OUT_OF_STOCK',
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Text('Out of Stock'),
                      ],
                    ),
                  ),
                ],
                onChanged: (stockLevel) {
                  setState(() {
                    _selectedStockLevel = stockLevel;
                  });
                },
              );
            },
          ),
          SizedBox(height: context.cardPadding),

          // Price Range
          Text(
            'Price Range (PKR)',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
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
          SizedBox(height: context.cardPadding),

          // Sort Options
          Text(
            'Sort Options',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSortBy,
                  decoration: InputDecoration(
                    labelText: 'Sort By',
                    prefixIcon: Icon(Icons.sort_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'price', child: Text('Price')),
                    DropdownMenuItem(value: 'quantity', child: Text('Quantity')),
                    DropdownMenuItem(value: 'created_at', child: Text('Date Created')),
                    DropdownMenuItem(value: 'updated_at', child: Text('Date Updated')),
                  ],
                  onChanged: (sortBy) {
                    setState(() {
                      _selectedSortBy = sortBy!;
                    });
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSortOrder,
                  decoration: InputDecoration(
                    labelText: 'Order',
                    prefixIcon: Icon(Icons.swap_vert_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'asc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 16),
                          SizedBox(width: context.smallPadding / 2),
                          Text('Ascending'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'desc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 16),
                          SizedBox(width: context.smallPadding / 2),
                          Text('Descending'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (sortOrder) {
                    setState(() {
                      _selectedSortOrder = sortOrder!;
                    });
                  },
                ),
              ),
            ],
          ),
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
                backgroundColor: Colors.orange,
                textColor: Colors.orange,
                icon: Icons.clear_all_rounded,
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: PremiumButton(
                text: 'Cancel',
                onPressed: _handleCancel,
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
          child: PremiumButton(
            text: 'Clear All',
            onPressed: _handleClearFilters,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.orange,
            textColor: Colors.orange,
            icon: Icons.clear_all_rounded,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Apply Filters',
            onPressed: _handleApplyFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.filter_alt_rounded,
          ),
        ),
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'navy':
        return Colors.indigo;
      case 'maroon':
        return const Color(0xFF800000);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return Colors.grey[400]!;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return Colors.grey;
    }
  }
}