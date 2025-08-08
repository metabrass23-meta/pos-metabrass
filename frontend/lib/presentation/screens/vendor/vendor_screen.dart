import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/vendor/add_vendor_dialog.dart';
import '../../widgets/vendor/delete_vendor_dialog.dart';
import '../../widgets/vendor/edit_vendor_dialog.dart';
import '../../widgets/vendor/vendor_filter_dialog.dart';
import '../../widgets/vendor/vendor_table.dart';
import '../../widgets/vendor/view_vendor_dialog.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().refreshVendors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddVendorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EnhancedAddVendorDialog(),
    );
  }

  void _showEditVendorDialog(Vendor vendor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedEditVendorDialog(vendor: vendor),
    );
  }

  void _showDeleteVendorDialog(Vendor vendor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedDeleteVendorDialog(vendor: vendor),
    );
  }

  void _showViewVendorDialog(Vendor vendor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ViewVendorDetailsDialog(vendor: vendor),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const VendorFilterDialog(),
    );
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<VendorProvider>();
    await provider.refreshVendors();

    if (provider.hasError) {
      _showErrorSnackbar(provider.errorMessage ?? 'Failed to refresh vendors');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
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
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _handleExport() async {
    try {
      final provider = context.read<VendorProvider>();
      await provider.exportData();

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
                'Vendor data exported successfully',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.pureWhite,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to export data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isMinimumSupported) {
      return _buildUnsupportedScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Consumer<VendorProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.primaryMaroon,
            child: Padding(
              padding: EdgeInsets.all(context.mainPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Responsive Header Section
                  ResponsiveBreakpoints.responsive(
                    context,
                    tablet: _buildTabletHeader(),
                    small: _buildMobileHeader(),
                    medium: _buildDesktopHeader(),
                    large: _buildDesktopHeader(),
                    ultrawide: _buildDesktopHeader(),
                  ),

                  SizedBox(height: context.mainPadding),

                  // Responsive Stats Cards
                  context.statsCardColumns == 2
                      ? _buildMobileStatsGrid(provider)
                      : _buildDesktopStatsRow(provider),

                  SizedBox(height: context.cardPadding * 0.5),

                  // Responsive Search Section
                  _buildSearchSection(provider),

                  SizedBox(height: context.cardPadding * 0.5),

                  // Active Filters Display
                  _buildActiveFilters(provider),

                  // Enhanced Vendor Table with View functionality
                  Expanded(
                    child: EnhancedVendorTable(
                      onEdit: _showEditVendorDialog,
                      onDelete: _showDeleteVendorDialog,
                      onView: _showViewVendorDialog,
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
        // Page Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendor Management',
                style: GoogleFonts.playfairDisplay(
                  fontSize: context.headingFontSize / 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoalGray,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: context.cardPadding / 4),
              Text(
                'Organize and manage your supplier relationships with comprehensive tools',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Add Vendor Button
        _buildAddButton(),
      ],
    );
  }

  Widget _buildTabletHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title
        Text(
          'Vendor Management',
          style: GoogleFonts.playfairDisplay(
            fontSize: context.headingFontSize / 1.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Organize and manage supplier relationships',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: context.cardPadding),

        // Add Vendor Button (full width on tablet)
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
        // Compact Page Title
        Text(
          'Vendors',
          style: GoogleFonts.playfairDisplay(
            fontSize: context.headerFontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Manage supplier relationships',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: context.cardPadding),

        // Add Vendor Button (full width)
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
          onTap: _showAddVendorDialog,
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
                  context.isTablet ? 'Add' : 'Add Vendor',
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

  Widget _buildDesktopStatsRow(VendorProvider provider) {
    final stats = provider.vendorStats;
    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
              'Total Vendors',
              stats['total'].toString(),
              Icons.store_rounded,
              Colors.blue
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildStatsCard(
              'Active Vendors',
              stats['active'].toString(),
              Icons.check_circle_rounded,
              Colors.green
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildStatsCard(
              'Avg Order Value',
              'PKR ${stats['averageOrderValue']?.toStringAsFixed(0) ?? '0'}',
              Icons.trending_up_rounded,
              Colors.purple
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildStatsCard(
              'Cities Covered',
              stats['uniqueCities'].toString(),
              Icons.location_city_rounded,
              Colors.orange
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStatsGrid(VendorProvider provider) {
    final stats = provider.vendorStats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                  'Total',
                  stats['total'].toString(),
                  Icons.store_rounded,
                  Colors.blue
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: _buildStatsCard(
                  'Active',
                  stats['active'].toString(),
                  Icons.check_circle_rounded,
                  Colors.green
              ),
            ),
          ],
        ),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                  'Avg Order',
                  'PKR ${stats['averageOrderValue']?.toStringAsFixed(0) ?? '0'}',
                  Icons.trending_up_rounded,
                  Colors.purple
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: _buildStatsCard(
                  'Cities',
                  stats['uniqueCities'].toString(),
                  Icons.location_city_rounded,
                  Colors.orange
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection(VendorProvider provider) {
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
        tablet: _buildTabletSearchLayout(provider),
        small: _buildMobileSearchLayout(provider),
        medium: _buildDesktopSearchLayout(provider),
        large: _buildDesktopSearchLayout(provider),
        ultrawide: _buildDesktopSearchLayout(provider),
      ),
    );
  }

  Widget _buildDesktopSearchLayout(VendorProvider provider) {
    return Row(
      children: [
        // Search Bar
        Expanded(
          flex: 3,
          child: _buildSearchBar(provider),
        ),

        SizedBox(width: context.cardPadding),

        // Show Inactive Toggle
        Expanded(
          flex: 1,
          child: _buildShowInactiveToggle(provider),
        ),

        SizedBox(width: context.smallPadding),

        // Filter Button
        Expanded(
          flex: 1,
          child: _buildFilterButton(provider),
        ),

        SizedBox(width: context.smallPadding),

        // Export Button
        Expanded(
          flex: 1,
          child: _buildExportButton(),
        ),
      ],
    );
  }

  Widget _buildTabletSearchLayout(VendorProvider provider) {
    return Column(
      children: [
        _buildSearchBar(provider),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(child: _buildShowInactiveToggle(provider)),
            SizedBox(width: context.cardPadding),
            Expanded(child: _buildFilterButton(provider)),
            SizedBox(width: context.cardPadding),
            Expanded(child: _buildExportButton()),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileSearchLayout(VendorProvider provider) {
    return Column(
      children: [
        _buildSearchBar(provider),
        SizedBox(height: context.smallPadding),
        Row(
          children: [
            Expanded(child: _buildShowInactiveToggle(provider)),
            SizedBox(width: context.smallPadding),
            Expanded(child: _buildFilterButton(provider)),
            SizedBox(width: context.smallPadding),
            Expanded(child: _buildExportButton()),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(VendorProvider provider) {
    return SizedBox(
      height: context.buttonHeight / 1.5,
      child: TextField(
        controller: _searchController,
        onChanged: provider.searchVendors,
        style: GoogleFonts.inter(
          fontSize: context.bodyFontSize,
          color: AppTheme.charcoalGray,
        ),
        decoration: InputDecoration(
          hintText: context.isTablet
              ? 'Search vendors...'
              : 'Search vendors by name, business, CNIC, or phone...',
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
              provider.clearSearch();
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
    );
  }

  Widget _buildShowInactiveToggle(VendorProvider provider) {
    return Container(
      height: context.buttonHeight / 1.5,
      padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
      decoration: BoxDecoration(
        color: provider.showInactive ? AppTheme.primaryMaroon.withOpacity(0.1) : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: provider.showInactive ? AppTheme.primaryMaroon.withOpacity(0.3) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: provider.toggleShowInactive,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.showInactive ? Icons.visibility : Icons.visibility_off,
              color: provider.showInactive ? AppTheme.primaryMaroon : Colors.grey[600],
              size: context.iconSize('medium'),
            ),
            if (!context.isTablet) ...[
              SizedBox(width: context.smallPadding),
              Text(
                provider.showInactive ? 'Hide Inactive' : 'Show Inactive',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: provider.showInactive ? AppTheme.primaryMaroon : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(VendorProvider provider) {
    final hasActiveFilters = provider.selectedStatus != null ||
        provider.selectedType != null ||
        provider.selectedCity != null ||
        provider.selectedArea != null ||
        provider.selectedCountry != null ||
        provider.verificationFilter != null;

    return Container(
      height: context.buttonHeight / 1.5,
      padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
      decoration: BoxDecoration(
        color: hasActiveFilters ? AppTheme.accentGold.withOpacity(0.1) : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: hasActiveFilters ? AppTheme.accentGold.withOpacity(0.3) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: _showFilterDialog,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters ? Icons.filter_alt : Icons.filter_list_rounded,
              color: hasActiveFilters ? AppTheme.accentGold : AppTheme.primaryMaroon,
              size: context.iconSize('medium'),
            ),
            if (!context.isTablet) ...[
              SizedBox(width: context.smallPadding),
              Text(
                hasActiveFilters ? 'Filters (${_getActiveFilterCount(provider)})' : 'Filter',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: hasActiveFilters ? AppTheme.accentGold : AppTheme.primaryMaroon,
                ),
              ),
            ],
          ],
        ),
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
      child: InkWell(
        onTap: _handleExport,
        borderRadius: BorderRadius.circular(context.borderRadius()),
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
      ),
    );
  }

  Widget _buildActiveFilters(VendorProvider provider) {
    final activeFilters = <String>[];

    if (provider.selectedStatus != null) {
      activeFilters.add('Status: ${provider.selectedStatus}');
    }
    if (provider.selectedType != null) {
      activeFilters.add('Type: ${provider.selectedType}');
    }
    if (provider.selectedCity != null) {
      activeFilters.add('City: ${provider.selectedCity}');
    }
    if (provider.selectedArea != null) {
      activeFilters.add('Area: ${provider.selectedArea}');
    }
    if (provider.selectedCountry != null) {
      activeFilters.add('Country: ${provider.selectedCountry}');
    }
    if (provider.verificationFilter != null) {
      activeFilters.add('Verified: ${provider.verificationFilter}');
    }

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: context.cardPadding * 0.5),
      child: Wrap(
        spacing: context.smallPadding,
        runSpacing: context.smallPadding / 2,
        children: [
          ...activeFilters.map((filter) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              border: Border.all(
                color: AppTheme.primaryMaroon.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
                SizedBox(width: context.smallPadding / 2),
                InkWell(
                  onTap: () => _clearSpecificFilter(filter, provider),
                  child: Icon(
                    Icons.close,
                    size: context.iconSize('small'),
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ],
            ),
          )),

          // Clear All Filters Button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: provider.clearAllFilters,
              child: Text(
                'Clear All',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSpecificFilter(String filterText, VendorProvider provider) {
    if (filterText.startsWith('Status:')) {
      provider.setStatusFilter(null);
    } else if (filterText.startsWith('Type:')) {
      provider.setTypeFilter(null);
    } else if (filterText.startsWith('City:')) {
      provider.setCityFilter(null);
    } else if (filterText.startsWith('Area:')) {
      provider.setAreaFilter(null);
    } else if (filterText.startsWith('Country:')) {
      provider.setCountryFilter(null);
    } else if (filterText.startsWith('Verified:')) {
      provider.setVerificationFilter(null);
    }
  }

  int _getActiveFilterCount(VendorProvider provider) {
    int count = 0;
    if (provider.selectedStatus != null) count++;
    if (provider.selectedType != null) count++;
    if (provider.selectedCity != null) count++;
    if (provider.selectedArea != null) count++;
    if (provider.selectedCountry != null) count++;
    if (provider.verificationFilter != null) count++;
    return count;
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