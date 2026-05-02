import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../../src/models/vendor/vendor_model.dart';
import '../../../../../src/providers/vendor_provider.dart';
import '../../../../../src/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../screens/vendor_ledger_screen/vendor_ledger.dart';
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
  late VendorTableHelpers helpers;

  @override
  void initState() {
    super.initState();
    helpers = VendorTableHelpers(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final minTableWidth = _getTableMinWidth(context);
        final tableWidth = constraints.maxWidth > minTableWidth 
            ? constraints.maxWidth 
            : minTableWidth;

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
                return helpers.buildErrorState(context, provider);
              }

              if (provider.vendors.isEmpty) {
                return helpers.buildEmptyState(context);
              }

              return Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(context.borderRadius('large')),
                              topRight: Radius.circular(context.borderRadius('large')),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: context.cardPadding * 0.7,
                            horizontal: context.cardPadding / 2,
                          ),
                          child: _buildTableHeader(context, tableWidth - context.cardPadding),
                        ),

                        // Table Content
                        Expanded(
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              controller: _verticalController,
                              itemCount: provider.vendors.length,
                              itemBuilder: (context, index) {
                                final vendor = provider.vendors[index];
                                return _buildTableRow(context, vendor, index, tableWidth - context.cardPadding);
                              },
                            ),
                          ),
                        ),

                        // Pagination
                        if (provider.paginationInfo != null &&
                            provider.paginationInfo!.totalPages > 1)
                          _buildPaginationControls(context, provider),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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

  double _getTableMinWidth(BuildContext context) {
    if (context.shouldShowCompactLayout) return 1500.0;
    return 2000.0;
  }

  // ✅ REDUCED COLUMN WIDTHS FOR TIGHTER SPACING
  List<double> _getColumnWidths(BuildContext context, double totalWidth) {
    final bool isCompact = context.shouldShowCompactLayout;
    
    // Fixed widths for columns that shouldn't expand much
    final double nameWidth = 250.0; 
    final double phoneWidth = 200.0;
    final double locationWidth = 220.0;
    final double statusWidth = 160.0;
    final double ledgerWidth = 140.0;
    final double dateWidth = 240.0;
    final double actionsWidth = 320.0;

    double fixedSum = nameWidth + phoneWidth + statusWidth + ledgerWidth + dateWidth + actionsWidth;
    if (!isCompact) {
      fixedSum += locationWidth;
    }

    // Business Name column gets the remaining space
    final double businessWidth = totalWidth - fixedSum;

    if (isCompact) {
      return [
        nameWidth, // 0
        businessWidth > 180.0 ? businessWidth : 180.0, // 1
        phoneWidth, // 2
        statusWidth, // 3
        ledgerWidth, // 4
        dateWidth, // 5
        actionsWidth, // 6
      ];
    } else {
      return [
        nameWidth, // 0
        businessWidth > 180.0 ? businessWidth : 180.0, // 1
        phoneWidth, // 2
        locationWidth, // 3
        statusWidth, // 4
        ledgerWidth, // 5
        dateWidth, // 6
        actionsWidth, // 7
      ];
    }
  }

  Widget _buildTableHeader(BuildContext context, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Row(
      children: [
        // Name
        Container(
          width: columnWidths[0],
          child: _buildSortableHeaderCell(context, l10n.name, 'name'),
        ),

        // Business Name
        Container(
          width: columnWidths[1],
          child: _buildSortableHeaderCell(
              context, l10n.businessName, 'business_name'),
        ),

        // Phone
        Container(
          width: columnWidths[2],
          child: _buildHeaderCell(context, l10n.phone),
        ),

        // Location (responsive)
        if (!context.shouldShowCompactLayout)
          Container(
            width: columnWidths[3],
            child: _buildHeaderCell(context, l10n.location),
          ),

        // Status
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 3 : 4],
          child: _buildHeaderCell(context, l10n.status, isCenter: true),
        ),

        // Ledger
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 4 : 5],
          child: _buildHeaderCell(context, 'Ledger', isCenter: true),
        ),

        // Created At
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 5 : 6],
          child: _buildSortableHeaderCell(context, l10n.created, 'created_at'),
        ),

        // Actions
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 6 : 7],
          child: _buildHeaderCell(context, l10n.actions, isCenter: true),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title, {bool isCenter = false}) {
    return Container(
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: context.bodyFontSize,
          fontWeight: FontWeight.w600,
          color: AppTheme.charcoalGray,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSortableHeaderCell(
      BuildContext context, String title, String sortKey, {bool isCenter = false}) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        final isCurrentSort = provider.sortBy == sortKey;

        return InkWell(
          onTap: () => provider.setSortBy(sortKey),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: 4),
            child: Row(
              mainAxisAlignment: isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: isCenter ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: isCurrentSort
                          ? AppTheme.primaryMaroon
                          : AppTheme.charcoalGray,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isCurrentSort
                      ? (provider.sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward)
                      : Icons.sort,
                  size: 14,
                  color: isCurrentSort
                      ? AppTheme.primaryMaroon
                      : Colors.grey[500],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableRow(BuildContext context, VendorModel vendor, int index, double totalWidth) {
    final columnWidths = _getColumnWidths(context, totalWidth);

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
      padding: EdgeInsets.symmetric(
        vertical: context.cardPadding * 1.2,
        horizontal: context.cardPadding / 2, // Matched with header padding
      ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: 2),
                  Text(
                    vendor.cnic ?? 'N/A',
                    style: TextStyle(
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),

          // Phone Column
          Container(
            width: columnWidths[2],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              vendor.formattedPhone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),

          // Location (responsive)
          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[3],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    vendor.area,
                    style: TextStyle(
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
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: helpers
                    .getStatusColor(vendor.statusDisplayName)
                    .withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(
                  color: helpers
                      .getStatusColor(vendor.statusDisplayName)
                      .withOpacity(0.3),
                ),
              ),
              child: Text(
                vendor.statusDisplayName,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: helpers.getStatusColor(vendor.statusDisplayName),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Ledger Button Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 4 : 5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(
              child: Tooltip(
                message: 'View Ledger',
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorLedgerScreen(
                          vendorId: vendor.id,
                          vendorName: vendor.name,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMaroon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppTheme.primaryMaroon,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Created At Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 5 : 6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Row(
              children: [
                Text(
                  vendor.formattedCreatedAt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '(${vendor.relativeCreatedAt})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 6 : 7],
            child: Center(child: helpers.buildActionsRow(context, vendor)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, VendorProvider provider) {
    final l10n = AppLocalizations.of(context)!;
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
          Text(
            '${l10n.showing} ${(pagination.currentPage - 1) * pagination.pageSize + 1}-${(pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize)} ${l10n.outOf} ${pagination.totalCount} ${l10n.vendor}',
            style: TextStyle(
              fontSize: context.subtitleFontSize,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed:
                pagination.hasPrevious ? provider.loadPreviousPage : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: pagination.hasPrevious
                      ? AppTheme.primaryMaroon
                      : Colors.grey[400],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  '${pagination.currentPage} ${l10n.outOf} ${pagination.totalPages}',
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),
              IconButton(
                onPressed: pagination.hasNext ? provider.loadNextPage : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: pagination.hasNext
                      ? AppTheme.primaryMaroon
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
