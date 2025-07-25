import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/customer/add_customer_dialog.dart';
import '../../widgets/customer/customer_table.dart';
import '../../widgets/customer/delete_customer_dialog.dart';
import '../../widgets/customer/edit_customer_dialog.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddCustomerDialog(),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditCustomerDialog(customer: customer),
    );
  }

  void _showDeleteCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteCustomerDialog(customer: customer),
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
        padding: EdgeInsets.all(context.mainPadding),
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
            Consumer<CustomerProvider>(
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
              child: CustomerTable(
                onEdit: _showEditCustomerDialog,
                onDelete: _showDeleteCustomerDialog,
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
                'Customer Management',
                style: GoogleFonts.playfairDisplay(
                  fontSize: context.headerFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoalGray,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: context.cardPadding / 4),
              Text(
                'Manage your customer relationships',
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
          'Customer Management',
          style: GoogleFonts.playfairDisplay(
            fontSize: context.headerFontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Manage your customers',
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
          'Customers',
          style: GoogleFonts.playfairDisplay(
            fontSize: context.headerFontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Manage customers',
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
          onTap: _showAddCustomerDialog,
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
                  context.isTablet ? 'Add' : 'Add Customer',
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

  Widget _buildDesktopStatsRow(CustomerProvider provider) {
    final stats = provider.customerStats;
    return Row(
      children: [
        Expanded(
            child: _buildStatsCard('Total Customers', stats['total'].toString(),
                Icons.people_rounded, Colors.blue)),
        SizedBox(width: context.cardPadding),
        Expanded(
            child: _buildStatsCard('New This Month',
                stats['newThisMonth'].toString(), Icons.person_add_rounded, Colors.green)),
        SizedBox(width: context.cardPadding),
        Expanded(
            child: _buildStatsCard('Avg Purchase', 'PKR ${stats['averagePurchase']}',
                Icons.shopping_cart_rounded, Colors.purple)),
        SizedBox(width: context.cardPadding),
        Expanded(
            child: _buildStatsCard('Recent Buyers', stats['recentBuyers'].toString(),
                Icons.shopping_bag_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildMobileStatsGrid(CustomerProvider provider) {
    final stats = provider.customerStats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatsCard('Total', stats['total'].toString(),
                    Icons.people_rounded, Colors.blue)),
            SizedBox(width: context.cardPadding),
            Expanded(
                child: _buildStatsCard('New', stats['newThisMonth'].toString(),
                    Icons.person_add_rounded, Colors.green)),
          ],
        ),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(
                child: _buildStatsCard('Avg Purchase', 'PKR ${stats['averagePurchase']}',
                    Icons.shopping_cart_rounded, Colors.purple)),
            SizedBox(width: context.cardPadding),
            Expanded(
                child: _buildStatsCard('Recent', stats['recentBuyers'].toString(),
                    Icons.shopping_bag_rounded, Colors.orange)),
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
      child: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return TextField(
            controller: _searchController,
            onChanged: provider.searchCustomers,
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              color: AppTheme.charcoalGray,
            ),
            decoration: InputDecoration(
              hintText: context.isTablet
                  ? 'Search customers...'
                  : 'Search customers by name, ID, phone, or email...',
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
                  provider.searchCustomers('');
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