import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/advance_payment/advance_payment_model.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import 'advance_payment_table_helpers.dart';

class AdvancePaymentTable extends StatefulWidget {
  final Function(AdvancePayment) onEdit;
  final Function(AdvancePayment) onDelete;
  final Function(AdvancePayment) onView;

  const AdvancePaymentTable({super.key, required this.onEdit, required this.onDelete, required this.onView});

  @override
  State<AdvancePaymentTable> createState() => _AdvancePaymentTableState();
}

class _AdvancePaymentTableState extends State<AdvancePaymentTable> {
  // Separate controllers for synchronized scrolling
  late ScrollController _headerHorizontalController;
  late ScrollController _contentHorizontalController;
  late ScrollController _verticalController;
  late AdvancePaymentTableHelpers _helpers;

  @override
  void initState() {
    super.initState();
    _headerHorizontalController = ScrollController();
    _contentHorizontalController = ScrollController();
    _verticalController = ScrollController();

    _helpers = AdvancePaymentTableHelpers(onEdit: widget.onEdit, onDelete: widget.onDelete, onView: widget.onView);

    // Link the header and content horizontal scrolling (Two-way sync)
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
          child: Consumer<AdvancePaymentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return _buildLoadingState(context);
              }

              if (provider.hasError) {
                return _helpers.buildErrorState(context, provider);
              }

              if (provider.advancePayments.isEmpty) {
                return _helpers.buildEmptyState(context);
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
                            vertical: context.cardPadding * 0.85, 
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
                              itemCount: provider.advancePayments.length,
                              itemBuilder: (context, index) {
                                final payment = provider.advancePayments[index];
                                return _buildTableRow(context, payment, index, tableWidth - context.cardPadding);
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
        width: ResponsiveBreakpoints.responsive(context, tablet: 3.w, small: 6.w, medium: 3.w, large: 4.w, ultrawide: 3.w),
        height: ResponsiveBreakpoints.responsive(context, tablet: 3.w, small: 6.w, medium: 3.w, large: 4.w, ultrawide: 3.w),
        child: const CircularProgressIndicator(color: AppTheme.primaryMaroon, strokeWidth: 3),
      ),
    );
  }

  double _getTableMinWidth(BuildContext context) {
    if (context.shouldShowCompactLayout) return 1500.0;
    return 1900.0; 
  }

  List<double> _getColumnWidths(BuildContext context, double totalWidth) {
    final bool isCompact = context.shouldShowCompactLayout;
    
    final double idWidth = 130.0;
    final double nameWidth = 250.0; 
    final double detailsWidth = 250.0; 
    final double amountWidth = 220.0; 
    final double dateWidth = 240.0; 
    final double receiptWidth = 160.0; 
    final double actionsWidth = 250.0;

    double fixedSum = idWidth + nameWidth + amountWidth + dateWidth + actionsWidth;
    if (!isCompact) {
      fixedSum += detailsWidth + receiptWidth;
    }

    final double descriptionWidth = totalWidth - fixedSum;

    if (isCompact) {
      return [
        idWidth, // 0
        nameWidth, // 1
        amountWidth, // 2
        dateWidth, // 3
        actionsWidth, // 4
        descriptionWidth > 150.0 ? descriptionWidth : 150.0, // Buffer
      ];
    } else {
      return [
        idWidth, // 0
        nameWidth, // 1
        detailsWidth, // 2
        descriptionWidth > 200.0 ? descriptionWidth : 200.0, // 3
        amountWidth, // 4
        dateWidth, // 5
        receiptWidth, // 6
        actionsWidth, // 7
      ];
    }
  }

  Widget _buildTableHeader(BuildContext context, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Row(
      children: [
        Container(width: columnWidths[0], child: _buildSortableHeaderCell(context, l10n.paymentId, 'id', isCenter: true)),
        Container(width: columnWidths[1], child: _buildSortableHeaderCell(context, l10n.laborName, 'labor_name')),
        if (!context.shouldShowCompactLayout) Container(width: columnWidths[2], child: _buildHeaderCell(context, l10n.laborDetails)),
        if (!context.shouldShowCompactLayout) Container(width: columnWidths[3], child: _buildHeaderCell(context, l10n.description)),
        Container(width: columnWidths[context.shouldShowCompactLayout ? 2 : 4], child: _buildSortableHeaderCell(context, l10n.amount, 'amount', isCenter: true)),
        Container(width: columnWidths[context.shouldShowCompactLayout ? 3 : 5], child: _buildSortableHeaderCell(context, l10n.date, 'date')),
        if (!context.shouldShowCompactLayout) Container(width: columnWidths[6], child: _buildHeaderCell(context, l10n.receipt, isCenter: true)),
        Container(width: columnWidths[context.shouldShowCompactLayout ? 4 : 7], child: _buildHeaderCell(context, l10n.actions, isCenter: true)),
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

  Widget _buildSortableHeaderCell(BuildContext context, String title, String sortKey, {bool isCenter = false}) {
    return Consumer<AdvancePaymentProvider>(
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
                    textAlign: isCenter ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: isCurrentSort ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

  Widget _buildTableRow(BuildContext context, AdvancePayment payment, int index, double totalWidth) {
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.cardPadding / 2,
        horizontal: context.cardPadding / 2, // Matched with header
      ),
      child: Row(
        children: [
          Container(
            width: columnWidths[0],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  payment.id.substring(0, 8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.laborName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Row(
                    children: [
                      _helpers.buildLaborAvatar(context, payment),
                      SizedBox(width: context.smallPadding / 2),
                      Expanded(
                        child: Text(
                          payment.laborRole,
                          style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (payment.description.isNotEmpty) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      payment.description,
                      style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ],
            ),
          ),

          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[2],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _helpers.buildLaborAvatar(context, payment),
                      SizedBox(width: context.smallPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.laborRole,
                              style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (payment.laborPhone.isNotEmpty)
                              Text(
                                payment.laborPhone,
                                style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[3],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                payment.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
              ),
            ),

          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 2 : 4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  'PKR ${payment.amount.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w700, color: Colors.orange[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 3 : 5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Row(
              children: [
                Text(
                  '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '(${context.shouldShowCompactLayout ? payment.time : _getRelativeDate(context, payment.date)})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),

          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[6],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Center(child: _helpers.buildReceiptBadge(context, payment)),
            ),

          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 4 : 7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(child: _helpers.buildActionsRow(context, payment)),
          ),
        ],
      ),
    );
  }

  String _getRelativeDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    if (difference < 7) return l10n.daysAgo(difference);
    if (difference < 30) return l10n.weeksAgo((difference / 7).floor());
    if (difference < 365) return l10n.monthsAgo((difference / 30).floor());
    return l10n.yearsAgo((difference / 365).floor());
  }

  Widget _buildPaginationControls(BuildContext context, AdvancePaymentProvider provider) {
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
            l10n.showingAdvancePayments(
              ((pagination.currentPage - 1) * pagination.pageSize) + 1,
              pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize,
              pagination.totalCount,
            ),
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
                  l10n.pageOfPages(pagination.currentPage, pagination.totalPages),
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
