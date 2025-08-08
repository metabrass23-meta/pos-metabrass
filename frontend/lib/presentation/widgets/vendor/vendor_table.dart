import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';

class EnhancedVendorTable extends StatefulWidget {
  final Function(Vendor) onEdit;
  final Function(Vendor) onDelete;
  final Function(Vendor) onView;

  const EnhancedVendorTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  State<EnhancedVendorTable> createState() => _EnhancedVendorTableState();
}

class _EnhancedVendorTableState extends State<EnhancedVendorTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Consumer<VendorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: SizedBox(
                width: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 3.w,
                  small: 6.w,
                  medium: 3.w,
                  large: 4.w,
                  ultrawide: 3.w,
                ),
                height: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 3.w,
                  small: 6.w,
                  medium: 3.w,
                  large: 4.w,
                  ultrawide: 3.w,
                ),
                child: const CircularProgressIndicator(
                  color: AppTheme.primaryMaroon,
                  strokeWidth: 3,
                ),
              ),
            );
          }

          if (provider.vendors.isEmpty) {
            return _buildEmptyState(context);
          }

          return Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            child: Column(
              children: [
                // Table Header with Horizontal Scroll
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(context.borderRadius('large')),
                      topRight: Radius.circular(context.borderRadius('large')),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      width: _getTableWidth(context),
                      padding: EdgeInsets.symmetric(
                          vertical: context.cardPadding * 0.85,
                          horizontal: context.cardPadding / 2),
                      child: _buildTableHeader(context),
                    ),
                  ),
                ),

                // Table Content with Synchronized Scroll
                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        width: _getTableWidth(context),
                        child: ListView.builder(
                          controller: _verticalController,
                          itemCount: provider.vendors.length,
                          itemBuilder: (context, index) {
                            final vendor = provider.vendors[index];
                            return _buildTableRow(context, vendor, index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Pagination Controls
                if (provider.paginationInfo != null &&
                    provider.paginationInfo!.totalPages > 1)
                  _buildPaginationControls(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getTableWidth(BuildContext context) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: 1480.0, // Adjusted for vendor table columns
      small: 1580.0,
      medium: 1680.0,
      large: 1780.0,
      ultrawide: 1880.0,
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        // Name
        Container(
          width: columnWidths[0],
          child: _buildSortableHeaderCell(context, 'Name', 'name'),
        ),

        // Business Name
        Container(
          width: columnWidths[1],
          child: _buildSortableHeaderCell(context, 'Business Name', 'business_name'),
        ),

        // Phone & City (responsive)
        if (!context.shouldShowCompactLayout) ...[
          Container(
            width: columnWidths[2],
            child: _buildHeaderCell(context, 'Phone'),
          ),
          Container(
            width: columnWidths[3],
            child: _buildHeaderCell(context, 'City'),
          ),
        ],

        // Status & Type
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 2 : 4],
          child: _buildHeaderCell(context, 'Status'),
        ),

        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 3 : 5],
          child: _buildHeaderCell(context, 'Type'),
        ),

        // Vendor Since
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 4 : 6],
          child: _buildSortableHeaderCell(context, 'Vendor Since', 'created_at'),
        ),

        // Actions
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 5 : 7],
          child: _buildHeaderCell(context, 'Actions'),
        ),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context) {
    if (context.shouldShowCompactLayout) {
      return [
        180.0, // Name
        200.0, // Business Name
        120.0, // Status
        140.0, // Type
        150.0, // Vendor Since
        350.0, // Actions
      ];
    } else {
      return [
        180.0, // Name
        200.0, // Business Name
        160.0, // Phone
        140.0, // City
        120.0, // Status
        140.0, // Type
        150.0, // Vendor Since
        350.0, // Actions
      ];
    }
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: context.bodyFontSize,
        fontWeight: FontWeight.w600,
        color: AppTheme.charcoalGray,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildSortableHeaderCell(BuildContext context, String title, String sortKey) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        final isCurrentSort = provider.sortBy == sortKey;

        return InkWell(
          onTap: () => provider.setSortBy(sortKey),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: isCurrentSort ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  isCurrentSort
                      ? (provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                      : Icons.sort,
                  size: 16,
                  color: isCurrentSort ? AppTheme.primaryMaroon : Colors.grey[500],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableRow(BuildContext context, Vendor vendor, int index) {
    final columnWidths = _getColumnWidths(context);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven
            ? AppTheme.pureWhite
            : AppTheme.lightGray.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
      child: Row(
        children: [
          // Name
          Container(
            width: columnWidths[0],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Show additional info on compact layouts
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    vendor.phone,
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Business Name
          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.businessName,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Show city info on compact layouts
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    '${vendor.area}, ${vendor.city}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Phone and City (hidden on compact layouts)
          if (!context.shouldShowCompactLayout) ...[
            Container(
              width: columnWidths[2],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Row(
                children: [
                  if (vendor.phoneVerified)
                    Container(
                      margin: EdgeInsets.only(right: context.smallPadding / 2),
                      child: Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: context.iconSize('small'),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      vendor.phone,
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.charcoalGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: columnWidths[3],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.city,
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoalGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    vendor.area,
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

          // Status
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 2 : 4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(vendor.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(
                  color: _getStatusColor(vendor.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                vendor.statusDisplayName,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(vendor.status),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Type
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 3 : 5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Row(
              children: [
                Icon(
                  _getVendorTypeIcon(vendor.vendorType),
                  color: Colors.indigo,
                  size: context.iconSize('small'),
                ),
                SizedBox(width: context.smallPadding / 2),
                Expanded(
                  child: Text(
                    vendor.vendorTypeDisplayName,
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Vendor Since
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 4 : 6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(vendor.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  vendor.relativeCreatedAt,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 5 : 7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: _buildActions(context, vendor),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Vendor vendor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onView(vendor),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                Icons.visibility_outlined,
                color: Colors.purple,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onEdit(vendor),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Delete Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onDelete(vendor),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Quick Actions Dropdown
        PopupMenuButton<String>(
          onSelected: (value) => _handleQuickAction(context, vendor, value),
          itemBuilder: (context) => [
            if (!vendor.phoneVerified)
              PopupMenuItem(
                value: 'verify_phone',
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.green, size: context.iconSize('small')),
                    SizedBox(width: context.smallPadding),
                    Text('Verify Phone', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ],
                ),
              ),
            if (vendor.email != null && vendor.email!.isNotEmpty && !vendor.emailVerified)
              PopupMenuItem(
                value: 'verify_email',
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue, size: context.iconSize('small')),
                    SizedBox(width: context.smallPadding),
                    Text('Verify Email', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'update_order',
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.purple, size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding),
                  Text('Update Order', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'update_contact',
              child: Row(
                children: [
                  Icon(Icons.contact_phone, color: Colors.teal, size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding),
                  Text('Update Contact', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                ],
              ),
            ),
            if (vendor.status == 'ACTIVE')
              PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.power_off, color: Colors.orange, size: context.iconSize('small')),
                    SizedBox(width: context.smallPadding),
                    Text('Deactivate', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ],
                ),
              ),
            if (vendor.status == 'INACTIVE')
              PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.power_settings_new, color: Colors.green, size: context.iconSize('small')),
                    SizedBox(width: context.smallPadding),
                    Text('Activate', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: EdgeInsets.all(context.smallPadding * 0.5),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
              size: context.iconSize('small'),
            ),
          ),
        ),
      ],
    );
  }

  void _handleQuickAction(BuildContext context, Vendor vendor, String action) async {
    final provider = context.read<VendorProvider>();

    switch (action) {
      case 'verify_phone':
        await provider.verifyVendorContact(
          id: vendor.id,
          verificationType: 'phone',
          verified: true,
        );
        break;
      case 'verify_email':
        await provider.verifyVendorContact(
          id: vendor.id,
          verificationType: 'email',
          verified: true,
        );
        break;
      case 'update_order':
        await provider.updateVendorActivity(
          id: vendor.id,
          activityType: 'order',
        );
        break;
      case 'update_contact':
        await provider.updateVendorActivity(
          id: vendor.id,
          activityType: 'contact',
        );
        break;
      case 'activate':
      case 'deactivate':
        await provider.updateVendor(
          id: vendor.id,
          name: vendor.name,
          businessName: vendor.businessName,
          cnic: vendor.cnic,
          phone: vendor.phone,
          email: vendor.email,
          address: vendor.address,
          city: vendor.city,
          area: vendor.area,
          country: vendor.country,
          vendorType: vendor.vendorType,
          status: action == 'activate' ? 'ACTIVE' : 'INACTIVE',
          taxNumber: vendor.taxNumber,
          notes: vendor.notes,
          phoneVerified: vendor.phoneVerified,
          emailVerified: vendor.emailVerified,
        );
        break;
    }
  }

  Widget _buildPaginationControls(BuildContext context, VendorProvider provider) {
    final pagination = provider.paginationInfo!;

    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.borderRadius('large')),
          bottomRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          // Results info
          Text(
            'Showing ${((pagination.currentPage - 1) * pagination.pageSize) + 1}-${pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize} of ${pagination.totalCount} vendors',
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              color: Colors.grey[600],
            ),
          ),

          const Spacer(),

          // Pagination controls
          Row(
            children: [
              // Previous button
              IconButton(
                onPressed: pagination.hasPrevious ? provider.loadPreviousPage : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: pagination.hasPrevious ? AppTheme.primaryMaroon : Colors.grey[400],
                ),
              ),

              // Page info
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  '${pagination.currentPage} of ${pagination.totalPages}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),

              // Next button
              IconButton(
                onPressed: pagination.hasNext ? provider.loadNextPage : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: pagination.hasNext ? AppTheme.primaryMaroon : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(
              context,
              tablet: 15.w,
              small: 20.w,
              medium: 12.w,
              large: 10.w,
              ultrawide: 8.w,
            ),
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 15.w,
              small: 20.w,
              medium: 12.w,
              large: 10.w,
              ultrawide: 8.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(context.borderRadius('xl')),
            ),
            child: Icon(
              Icons.store_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Vendors Found',
            style: GoogleFonts.inter(
              fontSize: context.headerFontSize * 0.8,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(
                context,
                tablet: 80.w,
                small: 70.w,
                medium: 60.w,
                large: 50.w,
                ultrawide: 40.w,
              ),
            ),
            child: Text(
              'Start by adding your first vendor to manage your suppliers effectively',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
              ),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // This will be handled by the parent widget
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.cardPadding * 0.6,
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
                        'Add First Vendor',
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
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.orange;
      case 'SUSPENDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getVendorTypeIcon(String vendorType) {
    switch (vendorType.toUpperCase()) {
      case 'SUPPLIER':
        return Icons.local_shipping;
      case 'DISTRIBUTOR':
        return Icons.store;
      case 'MANUFACTURER':
        return Icons.factory;
      default:
        return Icons.business;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}