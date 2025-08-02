import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/product/add_product_dialog.dart';
import '../../widgets/product/delete_product_dialog.dart';
import '../../widgets/product/edit_product_dialog.dart';
import '../../widgets/product/product_table.dart';
import '../../widgets/product/view_product_dialog.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddProductDialog(),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditProductDialog(product: product),
    );
  }

  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteProductDialog(product: product),
    );
  }

  void _showViewProductDialog(Product product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ViewProductDetailsDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isMinimumSupported) {
      return _buildUnsupportedScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Padding(
        padding: EdgeInsets.all(context.mainPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveBreakpoints.responsive(
              context,
              tablet: _buildTabletHeader(),
              small: _buildMobileHeader(),
              medium: _buildDesktopHeader(),
              large: _buildDesktopHeader(),
              ultrawide: _buildDesktopHeader(),
            ),
            SizedBox(height: context.mainPadding),
            Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return context.statsCardColumns == 2
                    ? _buildMobileStatsGrid(provider)
                    : _buildDesktopStatsRow(provider);
              },
            ),
            SizedBox(height: context.cardPadding * 0.5),
            _buildSearchSection(),
            SizedBox(height: context.cardPadding * 0.5),
            Expanded(
              child: EnhancedProductTable(
                onEdit: _showEditProductDialog,
                onDelete: _showDeleteProductDialog,
                onView: _showViewProductDialog,
              ),
            ),
          ],
        ),
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
                'This application requires a minimum screen width of 750px for optimal experience. Please use a larger screen or rotate your device.',
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

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products Management',
                style: GoogleFonts.playfairDisplay(
                  fontSize: context.headingFontSize / 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoalGray,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: context.cardPadding / 4),
              Text(
                'Manage product inventory and details with comprehensive tools',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildTabletHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products Management',
          style: GoogleFonts.playfairDisplay(
            fontSize: context.headingFontSize / 1.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Manage product inventory',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: context.cardPadding),
        SizedBox(
          width: double.infinity,
          child: _buildAddButton(),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: GoogleFonts.playfairDisplay(
            fontSize: context.headerFontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Manage inventory',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: context.cardPadding),
        SizedBox(
          width: double.infinity,
          child: _buildAddButton(),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
        ),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddProductDialog,
          borderRadius: BorderRadius.circular(context.borderRadius()),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.cardPadding * 0.5,
              vertical: context.cardPadding / 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: AppTheme.pureWhite,
                  size: context.iconSize('medium'),
                ),
                SizedBox(width: context.smallPadding),
                Text(
                  context.isTablet ? 'Add' : 'Add Product',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.pureWhite,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopStatsRow(ProductProvider provider) {
    final stats = provider.productStats;
    return Row(
      children: [
        Expanded(
            child: _buildStatsCard('Total Products', stats['total'].toString(),
                Icons.inventory_rounded, Colors.blue)),
        SizedBox(width: context.cardPadding),
        Expanded(
            child: _buildStatsCard('In Stock', stats['inStock'].toString(),
                Icons.check_circle_rounded, Colors.green)),
        SizedBox(width: context.cardPadding),
        Expanded(
            child: _buildStatsCard('Total Value', 'PKR ${stats['totalValue']}',
                Icons.attach_money_rounded, Colors.purple)),
        SizedBox(width: context.cardPadding),
        Expanded(
            child: _buildStatsCard('Low Stock', stats['lowStock'].toString(),
                Icons.warning_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildMobileStatsGrid(ProductProvider provider) {
    final stats = provider.productStats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatsCard('Total', stats['total'].toString(),
                    Icons.inventory_rounded, Colors.blue)),
            SizedBox(width: context.cardPadding),
            Expanded(
                child: _buildStatsCard('In Stock', stats['inStock'].toString(),
                    Icons.check_circle_rounded, Colors.green)),
          ],
        ),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(
                child: _buildStatsCard('Value', 'PKR ${stats['totalValue']}',
                    Icons.attach_money_rounded, Colors.purple)),
            SizedBox(width: context.cardPadding),
            Expanded(
                child: _buildStatsCard('Low Stock', stats['lowStock'].toString(),
                    Icons.warning_rounded, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding / 2),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, context.smallPadding),
          ),
        ],
      ),
      child: ResponsiveBreakpoints.responsive(
        context,
        tablet: _buildTabletSearchLayout(),
        small: _buildMobileSearchLayout(),
        medium: _buildDesktopSearchLayout(),
        large: _buildDesktopSearchLayout(),
        ultrawide: _buildDesktopSearchLayout(),
      ),
    );
  }

  Widget _buildDesktopSearchLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildSearchBar(),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 1,
          child: _buildFilterButton(),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          flex: 1,
          child: _buildExportButton(),
        ),
      ],
    );
  }

  Widget _buildTabletSearchLayout() {
    return Column(
      children: [
        _buildSearchBar(),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(child: _buildFilterButton()),
            SizedBox(width: context.cardPadding),
            Expanded(child: _buildExportButton()),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileSearchLayout() {
    return Column(
      children: [
        _buildSearchBar(),
        SizedBox(height: context.smallPadding),
        Row(
          children: [
            Expanded(child: _buildFilterButton()),
            SizedBox(width: context.smallPadding),
            Expanded(child: _buildExportButton()),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: context.buttonHeight / 1.5,
      child: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return TextField(
            controller: _searchController,
            onChanged: provider.searchProducts,
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              color: AppTheme.charcoalGray,
            ),
            decoration: InputDecoration(
              hintText: context.isTablet
                  ? 'Search products...'
                  : 'Search products by ID, name, color, fabric, or pieces...',
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
                  provider.searchProducts('');
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
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: context.buttonHeight / 1.5,
      padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_rounded,
            color: AppTheme.primaryMaroon,
            size: context.iconSize('medium'),
          ),
          if (!context.isTablet) ...[
            SizedBox(width: context.smallPadding),
            Text(
              'Filter',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryMaroon,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      height: context.buttonHeight / 1.5,
      padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_rounded,
            color: AppTheme.accentGold,
            size: context.iconSize('medium'),
          ),
          if (!context.isTablet) ...[
            SizedBox(width: context.smallPadding),
            Text(
              'Export',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.accentGold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: context.statsCardHeight / 1.5,
      padding: EdgeInsets.all(context.cardPadding / 2),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, context.smallPadding),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Icon(
              icon,
              color: color,
              size: context.iconSize('medium'),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveBreakpoints.responsive(
                      context,
                      tablet: 10.8.sp,
                      small: 11.2.sp,
                      medium: 11.5.sp,
                      large: 11.8.sp,
                      ultrawide: 12.2.sp,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}