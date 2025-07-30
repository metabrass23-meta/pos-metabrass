import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/sales/cart_sidebar.dart';
import '../../widgets/sales/checkout_dialog.dart';
import '../../widgets/sales/delete_sales_dialog.dart';
import '../../widgets/sales/product_grid.dart';
import '../../widgets/sales/sales_table.dart';
import '../../widgets/sales/edit_sale_dialog.dart';
import '../../widgets/sales/view_sales_dialog.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerSearchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CheckoutDialog(),
    );
  }

  void _showSalesHistoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildSalesHistoryDialog(),
    );
  }

  void _handleViewSale(Sale sale) {
    Navigator.of(context).pop(); // Close history dialog first
    showDialog(
      context: context,
      builder: (context) => ViewSaleDialog(sale: sale),
    );
  }

  void _handleEditSale(Sale sale) {
    Navigator.of(context).pop(); // Close history dialog first
    showDialog(
      context: context,
      builder: (context) => EditSaleDialog(sale: sale),
    );
  }

  void _handleDeleteSale(Sale sale) {
    Navigator.of(context).pop(); // Close history dialog first
    showDialog(
      context: context,
      builder: (context) => DeleteSaleDialog(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isMinimumSupported) {
      return _buildUnsupportedScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Row(
        children: [
          // Main POS Area
          Expanded(
            flex: context.shouldShowCompactLayout ? 1 : 2,
            child: Column(
              children: [
                _buildPOSHeader(),
                _buildSearchAndFilters(),
                Expanded(
                  child: ProductGrid(
                    searchQuery: _searchController.text,
                    selectedCategory: _selectedCategory,
                  ),
                ),
              ],
            ),
          ),

          // Cart Sidebar
          Container(
            width: ResponsiveBreakpoints.responsive(
              context,
              tablet: 25.w,
              small: 40.w,
              medium: 25.w,
              large: 30.w,
              ultrawide: 25.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: context.shadowBlur(),
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: CartSidebar(
              onCheckout: _showCheckoutDialog,
              customerSearchController: _customerSearchController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedScreen() {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.screen_rotation_outlined,
                size: 15.w,
                color: Colors.grey[400],
              ),
              SizedBox(height: 3.h),
              Text(
                'Screen Too Small',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 6.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoalGray,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'POS System requires a minimum screen width of 750px for optimal experience. Please use a larger screen or rotate your device.',
                style: GoogleFonts.inter(
                  fontSize: 3.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPOSHeader() {
    return Container(
      padding: EdgeInsets.all(context.mainPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.shouldShowCompactLayout ? 'POS System' : 'Point of Sale System',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.charcoalGray,
                    letterSpacing: -0.5,
                  ),
                ),
                if (!context.isTablet) ...[
                  SizedBox(height: context.cardPadding / 4),
                  Text(
                    'Select products and manage sales transactions',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quick Stats
          if (context.shouldShowFullLayout) ...[
            _buildQuickStat('Today Sales', '12', Icons.shopping_cart_rounded, Colors.blue),
            SizedBox(width: context.cardPadding),
            _buildQuickStat('Revenue', 'PKR 125K', Icons.attach_money_rounded, Colors.green),
            SizedBox(width: context.cardPadding),
          ],

          // View History Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showSalesHistoryDialog,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.cardPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  border: Border.all(
                    color: AppTheme.primaryMaroon.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: AppTheme.primaryMaroon,
                      size: context.iconSize('medium'),
                    ),
                    if (!context.isTablet) ...[
                      SizedBox(width: context.smallPadding),
                      Text(
                        'View History',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryMaroon,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: context.cardPadding),

          // Current Time
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.cardPadding,
              vertical: context.cardPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Column(
              children: [
                Text(
                  TimeOfDay.now().format(context),
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  'Current Time',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: context.iconSize('medium'),
          ),
          SizedBox(width: context.smallPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesHistoryDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: ResponsiveBreakpoints.responsive(
          context,
          tablet: 95.w,
          small: 90.w,
          medium: 85.w,
          large: 80.w,
          ultrawide: 75.w,
        ),
        height: ResponsiveBreakpoints.responsive(
          context,
          tablet: 90.h,
          small: 85.h,
          medium: 80.h,
          large: 75.h,
          ultrawide: 70.h,
        ),
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
        child: Column(
          children: [
            // Header
            Container(
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
                      Icons.history_rounded,
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
                          context.shouldShowCompactLayout ? 'Sales History' : 'Sales Transaction History',
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
                            'View and manage all sales transactions',
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

                  // Quick Stats in Header
                  if (context.shouldShowFullLayout)
                    Consumer<SalesProvider>(
                      builder: (context, provider, child) {
                        final stats = provider.salesStats;
                        return Container(
                          padding: EdgeInsets.all(context.smallPadding),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(context.borderRadius()),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${stats['totalSales']} Sales',
                                style: GoogleFonts.inter(
                                  fontSize: context.captionFontSize,
                                  color: AppTheme.pureWhite.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'PKR ${stats['totalRevenue']}',
                                style: GoogleFonts.inter(
                                  fontSize: context.bodyFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.pureWhite,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  SizedBox(width: context.smallPadding),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
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
            ),

            // Search and Filter Bar
            Container(
              padding: EdgeInsets.all(context.cardPadding),
              color: AppTheme.lightGray.withOpacity(0.3),
              child: _buildHistoryFilters(),
            ),

            // Sales Table
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.cardPadding),
                child: SalesTable(
                  onView: _handleViewSale,
                  onEdit: _handleEditSale,
                  onDelete: _handleDeleteSale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryFilters() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            // Search Field
            Expanded(
              flex: 2,
              child: Container(
                height: context.buttonHeight / 1.5,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: context.shadowBlur('light'),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => provider.searchSales(value),
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    color: AppTheme.charcoalGray,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search sales by invoice, customer, phone...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: context.bodyFontSize * 0.9,
                      color: Colors.grey[500],
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[500],
                      size: context.iconSize('medium'),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.cardPadding / 2,
                      vertical: context.cardPadding / 2,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: context.cardPadding),

            // Status Filter
            if (!context.isTablet)
              Container(
                height: context.buttonHeight / 1.5,
                padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'All Status',
                    hint: Text('Status'),
                    onChanged: (value) {
                      // Implement status filtering
                    },
                    items: ['All Status', 'Paid', 'Partial', 'Unpaid'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: context.bodyFontSize,
                            color: AppTheme.charcoalGray,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            if (!context.isTablet) SizedBox(width: context.cardPadding),

            // Export Button
            Container(
              height: context.buttonHeight / 1.5,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.file_download_rounded, color: AppTheme.pureWhite),
                            SizedBox(width: context.smallPadding),
                            Text(
                              'Exporting sales data...',
                              style: GoogleFonts.inter(color: AppTheme.pureWhite),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.borderRadius()),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.cardPadding,
                      vertical: context.cardPadding / 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.file_download_rounded,
                          color: Colors.green,
                          size: context.iconSize('medium'),
                        ),
                        if (!context.isTablet) ...[
                          SizedBox(width: context.smallPadding),
                          Text(
                            'Export',
                            style: GoogleFonts.inter(
                              fontSize: context.bodyFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      color: AppTheme.lightGray.withOpacity(0.3),
      child: ResponsiveBreakpoints.responsive(
        context,
        tablet: _buildCompactSearchAndFilters(),
        small: _buildCompactSearchAndFilters(),
        medium: _buildExpandedSearchAndFilters(),
        large: _buildExpandedSearchAndFilters(),
        ultrawide: _buildExpandedSearchAndFilters(),
      ),
    );
  }

  Widget _buildCompactSearchAndFilters() {
    return Column(
      children: [
        // Search bar
        Container(
          height: context.buttonHeight / 1.5,
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(context.borderRadius()),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: context.shadowBlur('light'),
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              color: AppTheme.charcoalGray,
            ),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: GoogleFonts.inter(
                fontSize: context.bodyFontSize * 0.9,
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[500],
                size: context.iconSize('medium'),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: Icon(
                  Icons.clear_rounded,
                  color: Colors.grey[500],
                  size: context.iconSize('small'),
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.cardPadding / 2,
                vertical: context.cardPadding / 2,
              ),
            ),
          ),
        ),

        SizedBox(height: context.smallPadding),

        // Category filters
        SizedBox(
          height: context.buttonHeight / 1.8,
          child: Consumer<SalesProvider>(
            builder: (context, provider, child) {
              final categories = ['All', ...provider.products.map((p) => p.fabric).toSet().toList()];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;

                  return Container(
                    margin: EdgeInsets.only(right: context.smallPadding),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = category),
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.cardPadding,
                            vertical: context.smallPadding,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryMaroon : AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(context.borderRadius()),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryMaroon : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? AppTheme.pureWhite : AppTheme.charcoalGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedSearchAndFilters() {
    return Row(
      children: [
        // Search bar
        Expanded(
          flex: 2,
          child: Container(
            height: context.buttonHeight / 1.5,
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: context.shadowBlur('light'),
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                color: AppTheme.charcoalGray,
              ),
              decoration: InputDecoration(
                hintText: 'Search products by name, color, fabric...',
                hintStyle: GoogleFonts.inter(
                  fontSize: context.bodyFontSize * 0.9,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey[500],
                  size: context.iconSize('medium'),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey[500],
                    size: context.iconSize('small'),
                  ),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding / 2,
                  vertical: context.cardPadding / 2,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: context.cardPadding),

        // Category dropdown
        Expanded(
          flex: 1,
          child: Container(
            height: context.buttonHeight / 1.5,
            padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Consumer<SalesProvider>(
              builder: (context, provider, child) {
                final categories = ['All', ...provider.products.map((p) => p.fabric).toSet().toList()];
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    onChanged: (value) => setState(() => _selectedCategory = value ?? 'All'),
                    items: categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(width: context.cardPadding),

        // Filter button
        Container(
          height: context.buttonHeight / 1.5,
          padding: EdgeInsets.symmetric(horizontal: context.cardPadding),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius()),
            border: Border.all(
              color: AppTheme.accentGold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: AppTheme.accentGold,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Filter',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}