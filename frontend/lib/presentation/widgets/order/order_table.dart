import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/theme/app_theme.dart';
import 'order_table_helpers.dart';

class EnhancedOrderTable extends StatefulWidget {
  final Function(OrderModel) onEdit;
  final Function(OrderModel) onDelete;
  final Function(OrderModel) onView;

  const EnhancedOrderTable({super.key, required this.onEdit, required this.onDelete, required this.onView});

  @override
  State<EnhancedOrderTable> createState() => _EnhancedOrderTableState();
}

class _EnhancedOrderTableState extends State<EnhancedOrderTable> {
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _contentHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late OrderTableHelpers _helpers;

  @override
  void initState() {
    super.initState();
    _helpers = OrderTableHelpers(onEdit: widget.onEdit, onDelete: widget.onDelete, onView: widget.onView);

    // Synchronize horizontal scrolling between header and content
    _headerHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients && _contentHorizontalController.hasClients) {
        _contentHorizontalController.jumpTo(_headerHorizontalController.offset);
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
      child: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }

          if (provider.errorMessage != null) {
            return _helpers.buildErrorState(context, provider);
          }

          // Check if there are no orders at all vs no search results
          if (provider.orders.isEmpty) {
            // If there's a search query but no results, show "no search results" state
            if (provider.searchQuery.isNotEmpty) {
              return _helpers.buildNoSearchResultsState(context, provider);
            }
            // If no orders at all, show the regular empty state
            return _helpers.buildEmptyState(context);
          }

          return Scrollbar(
            controller: _headerHorizontalController,
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

                // Table Content with Synchronized Scroll
                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _contentHorizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        width: _getTableWidth(context),
                        child: ListView.builder(
                          controller: _verticalController,
                          itemCount: provider.orders.length,
                          itemBuilder: (context, index) {
                            final order = provider.orders[index];
                            return _buildTableRow(context, order, index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Pagination Controls
                if (provider.paginationInfo != null && provider.paginationInfo!.totalPages > 1) _buildPaginationControls(context, provider),
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
        width: ResponsiveBreakpoints.responsive(context, tablet: 3.w, small: 6.w, medium: 3.w, large: 4.w, ultrawide: 3.w),
        height: ResponsiveBreakpoints.responsive(context, tablet: 3.w, small: 6.w, medium: 3.w, large: 4.w, ultrawide: 3.w),
        child: const CircularProgressIndicator(color: AppTheme.primaryMaroon, strokeWidth: 3),
      ),
    );
  }

  // Fixed: Table width to match vendor table dimensions with proper calculation
  double _getTableWidth(BuildContext context) {
    final columnWidths = _getColumnWidths(context);
    final totalWidth = columnWidths.reduce((a, b) => a + b);

    // Ensure minimum width for proper display
    final minWidth = ResponsiveBreakpoints.responsive(context, tablet: 1280.0, small: 1380.0, medium: 1480.0, large: 1580.0, ultrawide: 1680.0);

    // Return the larger of calculated width or minimum width
    return totalWidth > minWidth ? totalWidth : minWidth;
  }

  // Fixed: Column widths that properly handle all columns including Actions
  List<double> _getColumnWidths(BuildContext context) {
    if (context.shouldShowCompactLayout) {
      return [
        100.0, // Order ID
        180.0, // Customer Name
        200.0, // Description
        150.0, // Total Amount
        120.0, // Status
        140.0, // Delivery Date
        280.0, // Actions
      ];
    } else {
      return [
        120.0, // Order ID
        200.0, // Customer Name
        250.0, // Description
        180.0, // Total Amount
        140.0, // Status
        160.0, // Delivery Date
        320.0, // Actions
      ];
    }
  }

  // Fixed: Show all columns in table header with consistent widths and constraints
  Widget _buildTableHeader(BuildContext context) {
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        // Order ID
        Container(
          width: columnWidths[0],
          constraints: BoxConstraints(maxWidth: columnWidths[0]),
          child: _buildSortableHeaderCell(context, 'Order ID', 'id'),
        ),

        // Customer Name
        Container(
          width: columnWidths[1],
          constraints: BoxConstraints(maxWidth: columnWidths[1]),
          child: _buildSortableHeaderCell(context, 'Customer', 'customer_name'),
        ),

        // Description
        Container(
          width: columnWidths[2],
          constraints: BoxConstraints(maxWidth: columnWidths[2]),
          child: _buildHeaderCell(context, 'Description'),
        ),

        // Total Amount
        Container(
          width: columnWidths[3],
          constraints: BoxConstraints(maxWidth: columnWidths[3]),
          child: _buildSortableHeaderCell(context, 'Amount', 'total_amount'),
        ),

        // Status
        Container(
          width: columnWidths[4],
          constraints: BoxConstraints(maxWidth: columnWidths[4]),
          child: _buildHeaderCell(context, 'Status'),
        ),

        // Delivery Date
        Container(
          width: columnWidths[5],
          constraints: BoxConstraints(maxWidth: columnWidths[5]),
          child: _buildSortableHeaderCell(context, 'Delivery', 'expected_delivery_date'),
        ),

        // Actions - Consistent width with row and constraints
        Container(
          width: columnWidths[6],
          constraints: BoxConstraints(maxWidth: columnWidths[6]),
          child: _buildHeaderCell(context, 'Actions'),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray, letterSpacing: 0.2),
    );
  }

  Widget _buildSortableHeaderCell(BuildContext context, String title, String sortKey) {
    return Consumer<OrderProvider>(
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

  // Fixed: Show all columns in table rows with proper constraints and error handling
  Widget _buildTableRow(BuildContext context, OrderModel order, int index) {
    try {
      final columnWidths = _getColumnWidths(context);

      return Container(
        decoration: BoxDecoration(
          color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
        ),
        padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
        child: Row(
          children: [
            // Order ID Column
            Container(
              width: columnWidths[0],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[0]),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
                ),
                child: Text(
                  '#${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
                  style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Customer Name Column
            Container(
              width: columnWidths[1],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[1]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName.isNotEmpty ? order.customerName : 'N/A',
                    style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    order.customerPhone.isNotEmpty ? order.customerPhone : 'No phone',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Description Column
            Container(
              width: columnWidths[2],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[2]),
              child: Text(
                order.description.isNotEmpty ? order.description : 'No description',
                style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Total Amount Column
            Container(
              width: columnWidths[3],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[3]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show amount if available, otherwise show item count info
                  if (order.totalAmount > 0) ...[
                    Text(
                      'PKR ${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.remainingAmount > 0) ...[
                      SizedBox(height: context.smallPadding / 4),
                      Text(
                        'Due: PKR ${order.remainingAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.red),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      SizedBox(height: context.smallPadding / 4),
                      Text(
                        'Fully Paid',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.green),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ] else ...[
                    // Show item count information when no amount
                    Builder(
                      builder: (context) {
                        final totalItems = order.orderSummary['total_items'] ?? 0;
                        final totalQuantity = order.orderSummary['total_quantity'] ?? 0;

                        if (totalItems > 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${totalItems} item${totalItems == 1 ? '' : 's'}',
                                style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: Colors.blue[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: context.smallPadding / 4),
                              Text(
                                'Qty: ${totalQuantity}',
                                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.blue[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No items',
                                style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: context.smallPadding / 4),
                              Text(
                                'Add items to see total',
                                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Status Column
            Container(
              width: columnWidths[4],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[4]),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                decoration: BoxDecoration(
                  color: _helpers.getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: _helpers.getStatusColor(order.status).withOpacity(0.3)),
                ),
                child: Text(
                  _helpers.getStatusText(order.status),
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: _helpers.getStatusColor(order.status),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Delivery Date Column
            Container(
              width: columnWidths[5],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[5]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.expectedDeliveryDate != null ? _helpers.formatDate(order.expectedDeliveryDate!) : 'No date',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: order.isOverdue ? Colors.red : AppTheme.charcoalGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (order.isOverdue) ...[
                    Text(
                      'OVERDUE',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.red),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else if (order.daysUntilDelivery != null && order.daysUntilDelivery! <= 3 && order.daysUntilDelivery! >= 0) ...[
                    Text(
                      '${order.daysUntilDelivery} days',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.orange),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions Column - Ensure it gets proper width with constraints
            Container(
              width: columnWidths[6],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[6]),
              child: _helpers.buildActionsRow(context, order),
            ),
          ],
        ),
      );
    } catch (e) {
      // Fallback row in case of error
      return Container(
        padding: EdgeInsets.all(context.cardPadding),
        child: Text(
          'Error displaying order: ${e.toString()}',
          style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: Colors.red),
        ),
      );
    }
  }

  Widget _buildPaginationControls(BuildContext context, OrderProvider provider) {
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
            'Showing ${((pagination.currentPage - 1) * pagination.pageSize) + 1}-${pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize} of ${pagination.totalCount} orders',
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, color: Colors.grey[600]),
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
                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
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
}
