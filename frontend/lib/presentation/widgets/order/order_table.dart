import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
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

          if (provider.orders.isEmpty) {
            if (provider.searchQuery.isNotEmpty) {
              return _helpers.buildNoSearchResultsState(context, provider);
            }
            return _helpers.buildEmptyState(context);
          }

          return Scrollbar(
            controller: _headerHorizontalController,
            thumbVisibility: true,
            child: Column(
              children: [
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

  double _getTableWidth(BuildContext context) {
    final columnWidths = _getColumnWidths(context);
    final totalWidth = columnWidths.reduce((a, b) => a + b);

    final minWidth = ResponsiveBreakpoints.responsive(context, tablet: 1800.0, small: 1900.0, medium: 2000.0, large: 2100.0, ultrawide: 2200.0);

    return totalWidth > minWidth ? totalWidth : minWidth;
  }

  List<double> _getColumnWidths(BuildContext context) {
    if (context.shouldShowCompactLayout) {
      return [
        110.0, // Order ID
        250.0, // Customer
        350.0, // Description
        160.0, // Amount
        140.0, // Status
        160.0, // Delivery
        320.0, // Actions
      ];
    } else {
      return [
        130.0, // Order ID
        350.0, // Customer
        450.0, // Description
        200.0, // Amount
        160.0, // Status
        250.0, // Delivery
        350.0, // Actions
      ];
    }
  }

  Widget _buildTableHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        Container(
          width: columnWidths[0],
          constraints: BoxConstraints(maxWidth: columnWidths[0]),
          child: _buildSortableHeaderCell(context, l10n.orderID, 'id', isCenter: true),
        ),

        Container(
          width: columnWidths[1],
          constraints: BoxConstraints(maxWidth: columnWidths[1]),
          child: _buildSortableHeaderCell(context, l10n.customer, 'customer_name'),
        ),

        Container(
          width: columnWidths[2],
          constraints: BoxConstraints(maxWidth: columnWidths[2]),
          child: _buildHeaderCell(context, l10n.description),
        ),

        Container(
          width: columnWidths[3],
          constraints: BoxConstraints(maxWidth: columnWidths[3]),
          child: _buildSortableHeaderCell(context, l10n.amount, 'total_amount'),
        ),

        Container(
          width: columnWidths[4],
          constraints: BoxConstraints(maxWidth: columnWidths[4]),
          child: _buildHeaderCell(context, l10n.status, isCenter: true),
        ),

        Container(
          width: columnWidths[5],
          constraints: BoxConstraints(maxWidth: columnWidths[5]),
          child: _buildSortableHeaderCell(context, l10n.delivery, 'expected_delivery_date'),
        ),

        Container(
          width: columnWidths[6],
          constraints: BoxConstraints(maxWidth: columnWidths[6]),
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
        style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildSortableHeaderCell(BuildContext context, String title, String sortKey, {bool isCenter = false}) {
    return Consumer<OrderProvider>(
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
                      color: isCurrentSort ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
                      letterSpacing: 0.2,
                    ),
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

  Widget _buildTableRow(BuildContext context, OrderModel order, int index) {
    try {
      final l10n = AppLocalizations.of(context)!;
      final columnWidths = _getColumnWidths(context);

      return Container(
        decoration: BoxDecoration(
          color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
        ),
        padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
        child: Row(
          children: [
            Container(
              width: columnWidths[0],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[0]),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMaroon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
                  ),
                  child: Text(
                    '#${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
                    style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            Container(
              width: columnWidths[1],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[1]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  order.customerName.isNotEmpty ? order.customerName : l10n.notAvailable,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
                SizedBox(height: context.smallPadding / 4),
                Text(
                  order.customerPhone.isNotEmpty ? order.customerPhone : l10n.noPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                ),
                ],
              ),
            ),

            Container(
              width: columnWidths[2],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[2]),
              child: Text(
                order.description.isNotEmpty ? order.description : l10n.noDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
              ),
            ),

            Container(
              width: columnWidths[3],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[3]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.totalAmount > 0) ...[
                    Text(
                      'PKR ${order.totalAmount.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                    ),
                    if (order.remainingAmount > 0) ...[
                      SizedBox(height: context.smallPadding / 4),
                      Text(
                        '${l10n.due}: PKR ${order.remainingAmount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.red),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      SizedBox(height: context.smallPadding / 4),
                      Text(
                        l10n.fullyPaid,
                        style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.green),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ] else ...[
                    Builder(
                      builder: (context) {
                        final totalItems = order.orderSummary['total_items'] ?? 0;
                        final totalQuantity = order.orderSummary['total_quantity'] ?? 0;

                        if (totalItems > 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${totalItems} ${totalItems == 1 ? l10n.item : l10n.items}',
                                style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: Colors.blue[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: context.smallPadding / 4),
                              Text(
                                '${l10n.qty}: ${totalQuantity}',
                                style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.blue[600]),
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
                                l10n.noItems,
                                style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: context.smallPadding / 4),
                              Text(
                                l10n.addItemsToSeeTotal,
                                style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.blue),
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

            Container(
              width: columnWidths[4],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[4]),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  decoration: BoxDecoration(
                    color: _helpers.getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    border: Border.all(color: _helpers.getStatusColor(order.status).withOpacity(0.3)),
                  ),
                  child: Text(
                    _helpers.getStatusText(order.status),
                    style: TextStyle(
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
            ),

            Container(
              width: columnWidths[5],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[5]),
              child: Row(
                children: [
                  Text(
                    order.expectedDeliveryDate != null ? _helpers.formatDate(order.expectedDeliveryDate!) : l10n.noDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: order.isOverdue ? Colors.red : AppTheme.charcoalGray,
                    ),
                  ),
                  if (order.isOverdue || (order.daysUntilDelivery != null && order.daysUntilDelivery! <= 3)) ...[
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.isOverdue ? '(${l10n.overdue})' : '(${order.daysUntilDelivery} ${l10n.days})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: order.isOverdue ? Colors.red : Colors.orange),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              width: columnWidths[6],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              constraints: BoxConstraints(maxWidth: columnWidths[6]),
              child: Center(child: _helpers.buildActionsRow(context, order)),
            ),
          ],
        ),
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      return Container(
        padding: EdgeInsets.all(context.cardPadding),
        child: Text(
          '${l10n.errorDisplayingOrder}: ${e.toString()}',
          style: TextStyle(fontSize: context.bodyFontSize, color: Colors.red),
        ),
      );
    }
  }

  Widget _buildPaginationControls(BuildContext context, OrderProvider provider) {
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
            '${l10n.showing} ${((pagination.currentPage - 1) * pagination.pageSize) + 1}-${pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize} ${l10n.outOf} ${pagination.totalCount} ${l10n.orders}',
            style: TextStyle(fontSize: context.subtitleFontSize, color: Colors.grey[600]),
          ),

          const Spacer(),

          Row(
            children: [
              IconButton(
                onPressed: pagination.hasPrevious ? provider.loadPreviousPage : null,
                icon: Icon(Icons.chevron_left, color: pagination.hasPrevious ? AppTheme.primaryMaroon : Colors.grey[400]),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.smallPadding),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  '${pagination.currentPage} ${l10n.outOf} ${pagination.totalPages}',
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                ),
              ),

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
