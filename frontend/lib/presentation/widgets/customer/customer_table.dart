import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/models/customer/customer_model.dart';
import '../../../src/theme/app_theme.dart';

class EnhancedCustomerTable extends StatefulWidget {
  final Function(Customer) onEdit;
  final Function(Customer) onDelete;
  final Function(Customer) onView;

  const EnhancedCustomerTable({super.key, required this.onEdit, required this.onDelete, required this.onView});

  @override
  State<EnhancedCustomerTable> createState() => _EnhancedCustomerTableState();
}

class _EnhancedCustomerTableState extends State<EnhancedCustomerTable> {
  // 1. Define separate controllers
  late ScrollController _headerHorizontalController;
  late ScrollController _contentHorizontalController;
  late ScrollController _verticalController;

  @override
  void initState() {
    super.initState();
    // 2. Initialize ALL controllers immediately to fix LateInitializationError
    _headerHorizontalController = ScrollController();
    _contentHorizontalController = ScrollController();
    _verticalController = ScrollController();

    // 3. Link the header and content scrolling (Two-way sync)
    _headerHorizontalController.addListener(() {
      if (_contentHorizontalController.hasClients &&
          _headerHorizontalController.offset != _contentHorizontalController.offset) {
        _contentHorizontalController.jumpTo(_headerHorizontalController.offset);
      }
    });

    _contentHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _contentHorizontalController.offset != _headerHorizontalController.offset) {
        _headerHorizontalController.jumpTo(_contentHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerHorizontalController.dispose();
    _contentHorizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: context.shadowBlur(), offset: Offset(0, context.smallPadding))],
      ),
      child: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: SizedBox(
                width: ResponsiveBreakpoints.responsive(context, tablet: 3.w, small: 6.w, medium: 3.w, large: 4.w, ultrawide: 3.w),
                height: ResponsiveBreakpoints.responsive(context, tablet: 3.w, small: 6.w, medium: 3.w, large: 4.w, ultrawide: 3.w),
                child: const CircularProgressIndicator(color: AppTheme.primaryMaroon, strokeWidth: 3),
              ),
            );
          }

          if (provider.customers.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // --- Table Header (Horizontal Scroll Only) ---
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.borderRadius('large')),
                    topRight: Radius.circular(context.borderRadius('large')),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: _headerHorizontalController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    width: _getTableWidth(context),
                    padding: EdgeInsets.symmetric(vertical: context.cardPadding * 0.85, horizontal: context.cardPadding / 2),
                    child: _buildTableHeader(context),
                  ),
                ),
              ),

              // --- Table Content (Vertical + Horizontal Scroll) ---
              Expanded(
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: Scrollbar(
                      controller: _contentHorizontalController,
                      thumbVisibility: true,
                      notificationPredicate: (notification) => notification.depth == 1,
                      child: SingleChildScrollView(
                        controller: _contentHorizontalController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: Container(
                          width: _getTableWidth(context),
                          // Use Column instead of ListView for smoother scrolling inside nested views
                          child: Column(
                            children: provider.customers.asMap().entries.map((entry) {
                              return _buildTableRow(context, entry.value, entry.key);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination Controls
              if (provider.paginationInfo != null && provider.paginationInfo!.totalPages > 1) _buildPaginationControls(context, provider),
            ],
          );
        },
      ),
    );
  }

  double _getTableWidth(BuildContext context) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: 1680.0,
      small: 1780.0,
      medium: 1880.0,
      large: 1980.0,
      ultrawide: 2080.0,
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        Container(width: columnWidths[0], child: _buildSortableHeaderCell(context, 'Name', 'name')),
        Container(width: columnWidths[1], child: _buildHeaderCell(context, 'Phone')),
        Container(width: columnWidths[2], child: _buildHeaderCell(context, 'Email')),
        Container(width: columnWidths[3], child: _buildHeaderCell(context, 'Type')),
        Container(width: columnWidths[4], child: _buildHeaderCell(context, 'Status')),
        Container(width: columnWidths[5], child: _buildHeaderCell(context, 'City')),
        Container(width: columnWidths[6], child: _buildHeaderCell(context, 'Total Sales')),
        Container(width: columnWidths[7], child: _buildSortableHeaderCell(context, 'Last Purchase', 'last_order_date')),
        Container(width: columnWidths[8], child: _buildSortableHeaderCell(context, 'Customer Since', 'created_at')),
        Container(width: columnWidths[9], child: _buildHeaderCell(context, 'Actions')),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context) {
    return [
      180.0, // Name
      160.0, // Phone
      220.0, // Email
      110.0, // Customer Type
      110.0, // Status
      130.0, // City
      110.0, // Total Sales
      130.0, // Last Purchase
      130.0, // Customer Since
      250.0, // Actions
    ];
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray, letterSpacing: 0.2),
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
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: isCurrentSort ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  isCurrentSort ? (provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.sort,
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
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
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
              style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
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
              style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
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
              style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Customer Type
          Container(
            width: columnWidths[3],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: customer.customerType == 'BUSINESS' ? AppTheme.primaryMaroon.withOpacity(0.1) : AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: customer.customerType == 'BUSINESS' ? AppTheme.primaryMaroon.withOpacity(0.3) : AppTheme.accentGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                customer.customerTypeDisplay,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: customer.customerType == 'BUSINESS' ? AppTheme.primaryMaroon : AppTheme.accentGold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Status
          Container(
            width: columnWidths[4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(customer.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(customer.status).withOpacity(0.3), width: 1),
              ),
              child: Text(
                customer.statusDisplay,
                style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: _getStatusColor(customer.status)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // City
          Container(
            width: columnWidths[5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              customer.city ?? 'N/A',
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: customer.city != null ? AppTheme.charcoalGray : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Total Sales
          Container(
            width: columnWidths[6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: customer.totalSalesCount > 0 ? AppTheme.primaryMaroon : Colors.grey[400]),
                SizedBox(width: 4),
                Text(
                  '${customer.totalSalesCount}',
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: customer.totalSalesCount > 0 ? AppTheme.primaryMaroon : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Last Purchase
          Container(
            width: columnWidths[7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.lastPurchase != null ? 'PKR ${customer.lastPurchase!.toStringAsFixed(0)}' : 'No purchases',
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: customer.lastPurchase != null ? AppTheme.charcoalGray : Colors.grey[500],
                    fontStyle: customer.lastPurchase == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                if (customer.lastPurchaseDate != null) ...[
                  Text(
                    _formatDate(customer.lastPurchaseDate!),
                    style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),

          // Customer Since
          Container(
            width: columnWidths[8],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(customer.createdAt),
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
                Text(
                  customer.relativeCreatedAt,
                  style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            width: columnWidths[9],
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
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.visibility_outlined, color: Colors.purple, size: context.iconSize('small')),
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
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.edit_outlined, color: Colors.blue, size: context.iconSize('small')),
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
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.delete_outline, color: Colors.red, size: context.iconSize('small')),
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
            style: TextStyle(fontSize: context.subtitleFontSize, color: Colors.grey[600]),
          ),

          const Spacer(),

          // Pagination controls
          Row(
            children: [
              // Previous button
              IconButton(
                onPressed: pagination.hasPrevious ? provider.loadPreviousPage : null,
                icon: Icon(Icons.chevron_left, color: pagination.hasPrevious ? AppTheme.primaryMaroon : Colors.grey[400]),
              ),

              // Page info
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.smallPadding),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  '${pagination.currentPage} of ${pagination.totalPages}',
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                ),
              ),

              // Next button
              IconButton(
                onPressed: pagination.hasNext ? provider.loadNextPage : null,
                icon: Icon(Icons.chevron_right, color: pagination.hasNext ? AppTheme.primaryMaroon : Colors.grey[400]),
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
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.people_outlined, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Customers Found',
            style: TextStyle(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              'Start by adding your first customer to manage your client relationships effectively',
              style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return AppTheme.accentGold;
      case 'REGULAR':
        return AppTheme.primaryMaroon;
      case 'VIP':
        return AppTheme.secondaryMaroon;
      case 'INACTIVE':
        return Colors.grey[600]!;
      default:
        return AppTheme.charcoalGray;
    }
  }
}