import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/vendor/vendor_model.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import 'vendor_table_helpers.dart';

class EnhancedVendorTable extends StatefulWidget {
  final Function(VendorModel) onEdit;
  final Function(VendorModel) onDelete;
  final Function(VendorModel) onView;

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
  late VendorTableHelpers _helpers;

  @override
  void initState() {
    super.initState();
    _helpers = VendorTableHelpers(
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onView: widget.onView,
    );
  }

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
            return _buildLoadingState(context);
          }

          if (provider.hasError) {
            return _helpers.buildErrorState(context, provider);
          }

          if (provider.vendors.isEmpty) {
            return _helpers.buildEmptyState(context);
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

  Widget _buildLoadingState(BuildContext context) {
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

  double _getTableWidth(BuildContext context) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: 1280.0,
      small: 1380.0,
      medium: 1480.0,
      large: 1580.0,
      ultrawide: 1680.0,
    );
  }

  List<double> _getColumnWidths(BuildContext context) {
    if (context.shouldShowCompactLayout) {
      return [
        180.0, // Name
        200.0, // Business Name
        140.0, // Phone
        120.0, // Status
        150.0, // Created At
        300.0, // Actions
      ];
    } else {
      return [
        180.0, // Name
        200.0, // Business Name
        160.0, // Phone
        140.0, // City/Area
        120.0, // Status
        150.0, // Created At
        300.0, // Actions
      ];
    }
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

        // Phone
        Container(
          width: columnWidths[2],
          child: _buildHeaderCell(context, 'Phone'),
        ),

        // City/Area (responsive)
        if (!context.shouldShowCompactLayout)
          Container(
            width: columnWidths[3],
            child: _buildHeaderCell(context, 'Location'),
          ),

        // Status
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 3 : 4],
          child: _buildHeaderCell(context, 'Status'),
        ),

        // Created At
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 4 : 5],
          child: _buildSortableHeaderCell(context, 'Created', 'created_at'),
        ),

        // Actions
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 5 : 6],
          child: _buildHeaderCell(context, 'Actions'),
        ),
      ],
    );
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

  Widget _buildTableRow(BuildContext context, VendorModel vendor, int index) {
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
          // Name Column
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
                // Show CNIC on compact layouts
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    vendor.cnic,
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

          // Business Name Column
          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              vendor.businessName,
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Phone Column
          Container(
            width: columnWidths[2],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              vendor.formattedPhone,
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Location (hidden on compact layouts)
          if (!context.shouldShowCompactLayout)
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

          // Status Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 3 : 4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: _helpers.getStatusColor(vendor.statusDisplayName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(
                  color: _helpers.getStatusColor(vendor.statusDisplayName).withOpacity(0.3),
                ),
              ),
              child: Text(
                vendor.statusDisplayName,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: _helpers.getStatusColor(vendor.statusDisplayName),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Created At Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 4 : 5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.formattedCreatedAt,
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

          // Actions Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 5 : 6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: _helpers.buildActionsRow(context, vendor),
          ),
        ],
      ),
    );
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
}