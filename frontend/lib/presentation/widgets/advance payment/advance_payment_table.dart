import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/theme/app_theme.dart';

class AdvancePaymentTable extends StatelessWidget {
  final Function(AdvancePayment) onEdit;
  final Function(AdvancePayment) onDelete;
  final Function(AdvancePayment) onViewReceipt;

  const AdvancePaymentTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onViewReceipt,
  });

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
      child: Column(
        children: [
          // Responsive Table Header
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.borderRadius('large')),
                topRight: Radius.circular(context.borderRadius('large')),
              ),
            ),
            child: _buildResponsiveHeaderRow(context),
          ),

          // Table Content
          Expanded(
            child: Consumer<AdvancePaymentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: SizedBox(
                      width: ResponsiveBreakpoints.responsive(
                        context,
                        tablet: 8.w,
                        small: 6.w,
                        medium: 5.w,
                        large: 4.w,
                        ultrawide: 3.w,
                      ),
                      height: ResponsiveBreakpoints.responsive(
                        context,
                        tablet: 8.w,
                        small: 6.w,
                        medium: 5.w,
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

                if (provider.advancePayments.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  itemCount: provider.advancePayments.length,
                  itemBuilder: (context, index) {
                    final payment = provider.advancePayments[index];
                    return _buildResponsiveTableRow(context, payment, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeaderRow(BuildContext context) {
    // Define payment table column flexes similar to your existing pattern
    final paymentColumnFlexes = ResponsiveBreakpoints.responsive(
      context,
      tablet: [1, 2, 1, 1, 1, 1, 1, 1],          // Very compressed for tablets
      small: [1, 2, 2, 1, 1, 1, 1, 1],           // Compressed for small screens
      medium: [1, 2, 2, 2, 1, 1, 1, 2],          // Balanced for medium screens
      large: [1, 2, 2, 3, 2, 1, 1, 2],           // More space for description
      ultrawide: [1, 2, 2, 3, 2, 1, 1, 2],       // Extra space for ultrawide
    );

    return Row(
      children: [
        // Payment ID Column
        Expanded(
          flex: paymentColumnFlexes[0],
          child: _buildHeaderCell(context, 'ID'),
        ),

        // Labor Info Column
        Expanded(
          flex: paymentColumnFlexes[1],
          child: _buildHeaderCell(context, context.isTablet ? 'Labor' : 'Labor Details'),
        ),

        // Amount Column
        Expanded(
          flex: paymentColumnFlexes[2],
          child: _buildHeaderCell(context, 'Amount'),
        ),

        // Description Column (hidden on tablets and small screens)
        if (!context.shouldShowCompactLayout) ...[
          Expanded(
            flex: paymentColumnFlexes[3],
            child: _buildHeaderCell(context, 'Description'),
          ),
        ],

        // Date Column (responsive visibility)
        if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
          Expanded(
            flex: paymentColumnFlexes[4],
            child: _buildHeaderCell(context, context.shouldShowFullLayout ? 'Date & Time' : 'Date'),
          ),
        ],

        // Receipt Column (only on large screens)
        if (context.shouldShowFullLayout) ...[
          Expanded(
            flex: paymentColumnFlexes[5],
            child: _buildHeaderCell(context, 'Receipt'),
          ),
        ],

        // Status Column (medium and large screens)
        if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
          Expanded(
            flex: paymentColumnFlexes[6],
            child: _buildHeaderCell(context, 'Status'),
          ),
        ],

        // Actions Column (always visible)
        Expanded(
          flex: paymentColumnFlexes[7],
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

  Widget _buildResponsiveTableRow(BuildContext context, AdvancePayment payment, int index) {
    // Define payment table column flexes similar to your existing pattern
    final paymentColumnFlexes = ResponsiveBreakpoints.responsive(
      context,
      tablet: [1, 2, 1, 1, 1, 1, 1, 1],          // Very compressed for tablets
      small: [1, 2, 2, 1, 1, 1, 1, 1],           // Compressed for small screens
      medium: [1, 2, 2, 2, 1, 1, 1, 2],          // Balanced for medium screens
      large: [1, 2, 2, 3, 2, 1, 1, 2],           // More space for description
      ultrawide: [1, 2, 2, 3, 2, 1, 1, 2],       // Extra space for ultrawide
    );

    return Container(
      padding: EdgeInsets.all(context.cardPadding / 2.5),
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
      child: Row(
        children: [
          // Payment ID Column with responsive styling
          Expanded(
            flex: paymentColumnFlexes[0],
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                payment.id,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryMaroon,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(width: context.smallPadding),

          // Labor Info Column with responsive layout
          Expanded(
            flex: paymentColumnFlexes[1],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.laborName,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Show additional info here on compact layouts
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    payment.laborRole,
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'PKR ${payment.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: context.smallPadding),

          // Amount Column
          Expanded(
            flex: paymentColumnFlexes[2],
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'PKR ${payment.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!context.shouldShowCompactLayout) ...[
                    Text(
                      '${payment.advancePercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(width: context.smallPadding),

          // Description Column (hidden on compact layouts)
          if (!context.shouldShowCompactLayout) ...[
            Expanded(
              flex: paymentColumnFlexes[3],
              child: Text(
                payment.description,
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Date Column (responsive visibility)
          if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
            Expanded(
              flex: paymentColumnFlexes[4],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(payment.date),
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  if (context.shouldShowFullLayout) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      payment.timeText,
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Receipt Column (only on large screens)
          if (context.shouldShowFullLayout) ...[
            Expanded(
              flex: paymentColumnFlexes[5],
              child: Center(
                child: payment.hasReceipt
                    ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallPadding,
                    vertical: context.smallPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_rounded,
                        color: Colors.green,
                        size: context.iconSize('small'),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        'Available',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
                    : Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallPadding,
                    vertical: context.smallPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.red,
                        size: context.iconSize('small'),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        'Missing',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Status Column (medium and large screens)
          if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
            Expanded(
              flex: paymentColumnFlexes[6],
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: payment.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(
                    color: payment.statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: payment.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Expanded(
                      child: Text(
                        payment.statusText,
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w500,
                          color: payment.statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Actions Column with responsive button sizing
          Expanded(
            flex: paymentColumnFlexes[7],
            child: ResponsiveBreakpoints.responsive(
              context,
              tablet: _buildCompactActions(context, payment),
              small: _buildCompactActions(context, payment),
              medium: _buildStandardActions(context, payment),
              large: _buildExpandedActions(context, payment),
              ultrawide: _buildExpandedActions(context, payment),
            ),
          ),
        ],
      ),
    );
  }

  // Compact actions for tablets and small screens
  Widget _buildCompactActions(BuildContext context, AdvancePayment payment) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit(payment);
        } else if (value == 'delete') {
          onDelete(payment);
        } else if (value == 'receipt') {
          onViewReceipt(payment);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Edit',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'receipt',
          child: Row(
            children: [
              Icon(
                payment.hasReceipt ? Icons.visibility_outlined : Icons.add_photo_alternate_outlined,
                color: payment.hasReceipt ? Colors.green : Colors.orange,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                payment.hasReceipt ? 'View Receipt' : 'Add Receipt',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: payment.hasReceipt ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(context.smallPadding),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
        ),
        child: Icon(
          Icons.more_vert,
          size: context.iconSize('small'),
          color: AppTheme.charcoalGray,
        ),
      ),
    );
  }

  // Standard actions for medium screens
  Widget _buildStandardActions(BuildContext context, AdvancePayment payment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onEdit(payment),
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

        SizedBox(width: context.smallPadding),

        // Receipt Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onViewReceipt(payment),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: payment.hasReceipt
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                payment.hasReceipt ? Icons.visibility_outlined : Icons.add_photo_alternate_outlined,
                color: payment.hasReceipt ? Colors.green : Colors.orange,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding),

        // Delete Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDelete(payment),
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

  // Expanded actions for large screens
  Widget _buildExpandedActions(BuildContext context, AdvancePayment payment) {
    return Row(
      children: [
        // Edit Button with label
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onEdit(payment),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Receipt Button with label
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onViewReceipt(payment),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: payment.hasReceipt
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      payment.hasReceipt ? Icons.visibility_outlined : Icons.add_photo_alternate_outlined,
                      color: payment.hasReceipt ? Colors.green : Colors.orange,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      payment.hasReceipt ? 'View' : 'Add',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: payment.hasReceipt ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Delete Button with label
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDelete(payment),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'Delete',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
              tablet: 5.w,
              small: 5.w,
              medium: 5.w,
              large: 5.w,
              ultrawide: 5.w,
            ),
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 5.w,
              small: 5.w,
              medium: 5.w,
              large: 5.w,
              ultrawide: 5.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(context.borderRadius('xl')),
            ),
            child: Icon(
              Icons.payment_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Advance Payment Records Found',
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
              'Start by adding your first advance payment record to track labor payments efficiently',
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
                        'Add First Payment',
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