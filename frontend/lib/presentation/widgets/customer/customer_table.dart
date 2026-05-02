import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/models/customer/customer_model.dart';
import '../../../src/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/customer_ledger_screen/customer_ledger.dart';
import '../../../src/utils/permission_helper.dart';

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
  // Define controllers
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _contentHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Link header and content scrolling
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
          child: Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.customers.isEmpty) {
                return _buildLoadingState(context);
              }

              if (provider.customers.isEmpty) {
                return _buildEmptyState(context);
              }

              return Scrollbar(
                controller: _headerHorizontalController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _headerHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // 1. Table Header
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(context.borderRadius('large')),
                              topRight: Radius.circular(context.borderRadius('large')),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: context.cardPadding * 0.85,
                            horizontal: context.cardPadding / 2,
                          ),
                          child: _buildTableHeader(context, tableWidth - context.cardPadding),
                        ),

                        // 2. Table Content
                        Expanded(
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              controller: _verticalController,
                              itemCount: provider.customers.length,
                              itemBuilder: (context, index) {
                                return _buildTableRow(
                                  context, 
                                  provider.customers[index], 
                                  index, 
                                  tableWidth - context.cardPadding
                                );
                              },
                            ),
                          ),
                        ),

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
        width: 50,
        height: 50,
        child: const CircularProgressIndicator(
          color: AppTheme.primaryMaroon,
          strokeWidth: 3,
        ),
      ),
    );
  }

  double _getTableMinWidth(BuildContext context) {
    return 2000.0; // Minimum width for customer table to remain readable and prevent wrapping
  }

  Widget _buildTableHeader(BuildContext context, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Row(
      children: [
        SizedBox(width: columnWidths[0], child: _buildSortableHeaderCell(context, l10n.name, 'name')),
        SizedBox(width: columnWidths[1], child: _buildHeaderCell(context, l10n.phone)),
        SizedBox(width: columnWidths[2], child: _buildHeaderCell(context, l10n.email)),
        SizedBox(width: columnWidths[3], child: _buildHeaderCell(context, l10n.type)),
        SizedBox(width: columnWidths[4], child: _buildHeaderCell(context, l10n.status, isCenter: true)),
        SizedBox(width: columnWidths[5], child: _buildHeaderCell(context, l10n.city)),
        SizedBox(width: columnWidths[6], child: _buildHeaderCell(context, l10n.totalSales)),
        SizedBox(width: columnWidths[7], child: _buildSortableHeaderCell(context, l10n.lastPurchase, 'last_order_date')),
        SizedBox(width: columnWidths[8], child: _buildSortableHeaderCell(context, l10n.since, 'created_at')),
        SizedBox(width: columnWidths[9], child: _buildHeaderCell(context, l10n.ledger, isCenter: true)),
        SizedBox(width: columnWidths[10], child: _buildHeaderCell(context, l10n.actions, isCenter: true)),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context, double totalWidth) {
    // Fixed widths for columns that shouldn't expand much
    final double phoneWidth = 160.0;
    final double emailWidth = 220.0;
    final double typeWidth = 120.0;
    final double statusWidth = 120.0;
    final double cityWidth = 140.0;
    final double salesWidth = 130.0;
    final double purchaseWidth = 240.0; // Increased
    final double sinceWidth = 220.0; // Increased
    final double ledgerWidth = 100.0; // Increased
    final double actionsWidth = 280.0; // Increased

    final double fixedSum = phoneWidth + emailWidth + typeWidth + statusWidth + cityWidth + salesWidth + purchaseWidth + sinceWidth + ledgerWidth + actionsWidth;
    
    // Name column gets the remaining space
    final double nameWidth = totalWidth - fixedSum;

    return [
      nameWidth > 180.0 ? nameWidth : 180.0, // Name
      phoneWidth,
      emailWidth,
      typeWidth,
      statusWidth,
      cityWidth,
      salesWidth,
      purchaseWidth,
      sinceWidth,
      ledgerWidth,
      actionsWidth,
    ];
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

  Widget _buildSortableHeaderCell(BuildContext context, String title, String sortKey, {bool isCenter = false}) {
    return Consumer<CustomerProvider>(
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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: isCenter ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: isCurrentSort ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
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

  Widget _buildTableRow(BuildContext context, Customer customer, int index, double totalWidth) {
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.cardPadding / 2,
        horizontal: context.cardPadding / 2, // Added to match header
      ),
      child: Row(
        children: [
          // Name
          SizedBox(
            width: columnWidths[0],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                customer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ),
          ),

          // Phone
          SizedBox(
            width: columnWidths[1],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                customer.phone,
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
          ),

          // Email
          SizedBox(
            width: columnWidths[2],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                customer.email,
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
          ),

          // Customer Type
          SizedBox(
            width: columnWidths[3],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: customer.customerType == 'BUSINESS'
                        ? AppTheme.primaryMaroon.withOpacity(0.1)
                        : AppTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: customer.customerType == 'BUSINESS'
                          ? AppTheme.primaryMaroon.withOpacity(0.3)
                          : AppTheme.accentGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    customer.customerTypeDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: customer.customerType == 'BUSINESS'
                          ? AppTheme.primaryMaroon
                          : AppTheme.accentGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // Status
          SizedBox(
            width: columnWidths[4],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customer.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _getStatusColor(customer.status).withOpacity(0.3),
                        width: 1),
                  ),
                  child: Text(
                    customer.statusDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(customer.status),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // City
          SizedBox(
            width: columnWidths[5],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                customer.city ?? 'N/A',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: customer.city != null ? AppTheme.charcoalGray : Colors.grey[500],
                ),
              ),
            ),
          ),

          // Total Sales
          SizedBox(
            width: columnWidths[6],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: customer.totalSalesCount > 0 ? AppTheme.primaryMaroon : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
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
          ),

          // Last Purchase
          SizedBox(
            width: columnWidths[7],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Row(
                children: [
                  Text(
                    customer.lastPurchase != null
                        ? 'PKR ${customer.lastPurchase!.toStringAsFixed(0)}'
                        : '(${customer.totalSalesAmount})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: customer.lastPurchase != null ? AppTheme.charcoalGray : Colors.grey[500],
                      fontStyle: customer.lastPurchase == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  if (customer.lastPurchaseDate != null) ...[
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(customer.lastPurchaseDate!),
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
                ],
              ),
            ),
          ),

          // Customer Since
          SizedBox(
            width: columnWidths[8],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Row(
                children: [
                  Text(
                    _formatDate(customer.createdAt),
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
                      '(${customer.relativeCreatedAt})',
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
          ),

          // Ledger Button Column
          SizedBox(
            width: columnWidths[9],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Center(
                child: Tooltip(
                  message: AppLocalizations.of(context)!.viewLedger,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerLedgerScreen(
                            customerId: customer.id,
                            customerName: customer.name,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    child: Container(
                      padding: EdgeInsets.all(context.smallPadding * 0.5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.blue,
                        size: context.iconSize('small'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: columnWidths[10],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Center(child: _buildActions(context, customer)),
            ),
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
        if (PermissionHelper.canEdit(context, 'Customers'))
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
        if (PermissionHelper.canDelete(context, 'Customers'))
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
          Expanded(
            child: Text(
              'Showing ${((pagination.currentPage - 1) * pagination.pageSize) + 1}-${pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize} of ${pagination.totalCount} customers',
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

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
                  style: TextStyle(
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.people_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No Customers Found',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Text(
                'Start by adding your first customer to manage your client relationships effectively',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return AppTheme.accentGold;
      case 'REGULAR':
        return AppTheme.primaryMaroon;
      case 'VIP':
        return AppTheme.secondaryMaroon;
      case 'INACTIVE':
        return Colors.grey[600]!;
      case 'ACTIVE':
        return Colors.green;
      default:
        return AppTheme.charcoalGray;
    }
  }
}
