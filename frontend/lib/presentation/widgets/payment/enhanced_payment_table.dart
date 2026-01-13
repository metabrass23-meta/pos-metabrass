import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/payment/payment_model.dart';
import '../../../src/providers/payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import 'payment_table_helpers.dart';

class EnhancedPaymentTable extends StatefulWidget {
  final Function(PaymentModel) onEdit;
  final Function(PaymentModel) onDelete;
  final Function(PaymentModel) onViewReceipt;

  const EnhancedPaymentTable({super.key, required this.onEdit, required this.onDelete, required this.onViewReceipt});

  @override
  State<EnhancedPaymentTable> createState() => _EnhancedPaymentTableState();
}

class _EnhancedPaymentTableState extends State<EnhancedPaymentTable> {
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _contentHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late PaymentTableHelpers _helpers;

  @override
  void initState() {
    super.initState();
    _helpers = PaymentTableHelpers(onEdit: widget.onEdit, onDelete: widget.onDelete, onViewReceipt: widget.onViewReceipt);

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
      child: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }

          if (provider.errorMessage != null) {
            return _helpers.buildErrorState(context, provider);
          }

          if (provider.payments.isEmpty) {
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
                          itemCount: provider.payments.length,
                          itemBuilder: (context, index) {
                            final payment = provider.payments[index];
                            return _buildTableRow(context, payment, index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
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
    return ResponsiveBreakpoints.responsive(context, tablet: 1580.0, small: 1680.0, medium: 1780.0, large: 1880.0, ultrawide: 1980.0);
  }

  List<double> _getColumnWidths(BuildContext context) {
    if (context.shouldShowCompactLayout) {
      return [
        120.0, // Payment ID
        200.0, // Labor & Details
        160.0, // Amount
        140.0, // Date
        320.0, // Actions
      ];
    } else {
      return [
        120.0, // Payment ID
        180.0, // Labor Name
        200.0, // Labor Details
        200.0, // Description
        140.0, // Amount
        130.0, // Date
        120.0, // Payment Method
        320.0, // Actions
      ];
    }
  }

  Widget _buildTableHeader(BuildContext context) {
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        // Payment ID
        Container(width: columnWidths[0], child: _buildHeaderCell(context, 'Payment ID')),

        // Labor Name
        Container(width: columnWidths[1], child: _buildHeaderCell(context, 'Labor')),

        // Labor Details (responsive)
        if (!context.shouldShowCompactLayout) Container(width: columnWidths[2], child: _buildHeaderCell(context, 'Labor Details')),

        // Description (responsive)
        if (!context.shouldShowCompactLayout) Container(width: columnWidths[3], child: _buildHeaderCell(context, 'Description')),

        // Amount
        Container(width: columnWidths[context.shouldShowCompactLayout ? 2 : 4], child: _buildHeaderCell(context, 'Amount')),

        // Date
        Container(width: columnWidths[context.shouldShowCompactLayout ? 3 : 5], child: _buildHeaderCell(context, 'Date')),

        // Payment Method (hidden on compact layouts)
        if (!context.shouldShowCompactLayout) Container(width: columnWidths[6], child: _buildHeaderCell(context, 'Payment Method')),

        // Actions
        Container(width: columnWidths[context.shouldShowCompactLayout ? 4 : 7], child: _buildHeaderCell(context, 'Actions')),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray, letterSpacing: 0.2),
    );
  }

  Widget _buildTableRow(BuildContext context, PaymentModel payment, int index) {
    final columnWidths = _getColumnWidths(context);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
      child: Row(
        children: [
          // Payment ID Column
          Container(
            width: columnWidths[0],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                payment.id.substring(0, 8),
                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Labor Name Column
          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.laborName ?? 'N/A',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Show labor details on compact layouts
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Row(
                    children: [
                      _helpers.buildLaborAvatar(context, payment),
                      SizedBox(width: context.smallPadding / 2),
                      Expanded(
                        child: Text(
                          payment.laborRole ?? 'N/A',
                          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Show description on compact layouts if available
                  if (payment.description?.isNotEmpty == true) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      'Desc: ${payment.description}',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ],
            ),
          ),

          // Labor Details Column (hidden on compact layouts)
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
                              payment.laborRole ?? 'N/A',
                              style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (payment.laborPhone != null && payment.laborPhone!.isNotEmpty)
                              Text(
                                payment.laborPhone!,
                                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
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

          // Description Column (hidden on compact layouts)
          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[3],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                payment.description?.isNotEmpty == true ? payment.description! : 'No description',
                style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Amount Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 2 : 4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 3),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'PKR ${payment.amountPaid.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w700, color: Colors.green[700]),
                    textAlign: TextAlign.center,
                  ),
                  if (payment.bonus > 0 || payment.deduction > 0) ...[
                    SizedBox(height: 2),
                    Text(
                      'Net: PKR ${payment.netAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Date Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 3 : 5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
                Text(
                  context.shouldShowCompactLayout ? payment.formattedTime : '${payment.formattedTime} • ${payment.formattedDate}',
                  style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Payment Method Column (hidden on compact layouts)
          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[6],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _helpers.buildPaymentMethodBadge(context, payment),
                  SizedBox(height: context.smallPadding / 4),
                  _helpers.buildStatusChip(context, payment),
                ],
              ),
            ),

          // Actions Column
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 4 : 7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: _helpers.buildActionsRow(context, payment),
          ),
        ],
      ),
    );
  }
}
