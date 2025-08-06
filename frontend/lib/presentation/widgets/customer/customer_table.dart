import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/theme/app_theme.dart';

class EnhancedCustomerTable extends StatefulWidget {
  final Function(Customer) onEdit;
  final Function(Customer) onDelete;
  final Function(Customer) onView;

  const EnhancedCustomerTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  State<EnhancedCustomerTable> createState() => _EnhancedCustomerTableState();
}

class _EnhancedCustomerTableState extends State<EnhancedCustomerTable> {
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
      child: Consumer<CustomerProvider>(
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

          if (provider.customers.isEmpty) {
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
                          itemCount: provider.customers.length,
                          itemBuilder: (context, index) {
                            final customer = provider.customers[index];
                            return _buildTableRow(context, customer, index);
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
      tablet: 1480.0, // Adjusted: 1600 - 120 (Customer ID column width)
      small: 1580.0, // Adjusted: 1700 - 120
      medium: 1680.0, // Adjusted: 1800 - 120
      large: 1780.0, // Adjusted: 1900 - 120
      ultrawide: 1880.0, // Adjusted: 2000 - 120
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

        // Phone
        Container(
          width: columnWidths[1],
          child: _buildHeaderCell(context, 'Phone'),
        ),

        // Email
        Container(
          width: columnWidths[2],
          child: _buildHeaderCell(context, 'Email'),
        ),

        // Last Purchase
        Container(
          width: columnWidths[3],
          child: _buildSortableHeaderCell(context, 'Last Purchase', 'last_order_date'),
        ),

        // Customer Since
        Container(
          width: columnWidths[4],
          child: _buildSortableHeaderCell(context, 'Customer Since', 'created_at'),
        ),

        // Actions
        Container(
          width: columnWidths[5],
          child: _buildHeaderCell(context, 'Actions'),
        ),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context) {
    return [
      200.0, // Name (previously columnWidths[1])
      180.0, // Phone (previously columnWidths[2])
      250.0, // Email (previously columnWidths[3])
      150.0, // Last Purchase (previously columnWidths[4])
      150.0, // Customer Since (previously columnWidths[5])
      320.0, // Actions (previously columnWidths[6])
    ];
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
    return Consumer<CustomerProvider>(
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

  Widget _buildTableRow(BuildContext context, Customer customer, int index) {
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
            child: Text(
              customer.name,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoalGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Phone
          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              customer.phone,
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Email
          Container(
            width: columnWidths[2],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              customer.email,
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Last Purchase
          Container(
            width: columnWidths[3],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.lastPurchase != null
                      ? 'PKR ${customer.lastPurchase!.toStringAsFixed(0)}'
                      : 'No purchases',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: customer.lastPurchase != null
                        ? AppTheme.charcoalGray
                        : Colors.grey[500],
                    fontStyle: customer.lastPurchase == null
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                if (customer.lastPurchaseDate != null) ...[
                  Text(
                    _formatDate(customer.lastPurchaseDate!),
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Customer Since
          Container(
            width: columnWidths[4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(customer.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  customer.relativeCreatedAt,
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
            width: columnWidths[5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: _buildActions(context, customer),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Customer customer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onView(customer),
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
            onTap: () => widget.onEdit(customer),
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
            onTap: () => widget.onDelete(customer),
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
      ],
    );
  }

  Widget _buildPaginationControls(BuildContext context, CustomerProvider provider) {
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
            'Showing ${((pagination.currentPage - 1) * pagination.pageSize) + 1}-${pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize} of ${pagination.totalCount} customers',
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
              Icons.people_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Customers Found',
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
              'Start by adding your first customer to manage your client relationships effectively',
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
                  colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
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
                          size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Add First Customer',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}