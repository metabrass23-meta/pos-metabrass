import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/payables_provider.dart';
import '../../../src/theme/app_theme.dart';

class PayablesTable extends StatelessWidget {
  final Function(Payable) onEdit;
  final Function(Payable) onDelete;
  final Function(Payable) onViewDetails;

  const PayablesTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
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
          Expanded(
            child: Consumer<PayablesProvider>(
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

                if (provider.payables.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  itemCount: provider.payables.length,
                  itemBuilder: (context, index) {
                    final payable = provider.payables[index];
                    return _buildResponsiveTableRow(context, payable, index);
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
    final payableColumnFlexes = ResponsiveBreakpoints.responsive(
      context,
      tablet: [1, 2, 1, 1, 1, 1, 1, 1],
      small: [1, 2, 2, 1, 1, 1, 1, 1],
      medium: [1, 2, 2, 2, 1, 1, 1, 2],
      large: [1, 2, 2, 3, 2, 1, 1, 2],
      ultrawide: [1, 2, 2, 3, 2, 1, 1, 2],
    );

    return Row(
      children: [
        Expanded(
          flex: payableColumnFlexes[0],
          child: _buildHeaderCell(context, 'ID'),
        ),
        Expanded(
          flex: payableColumnFlexes[1],
          child: _buildHeaderCell(context, context.isTablet ? 'Creditor' : 'Creditor Details'),
        ),
        Expanded(
          flex: payableColumnFlexes[2],
          child: _buildHeaderCell(context, 'Amounts'),
        ),
        if (!context.shouldShowCompactLayout) ...[
          Expanded(
            flex: payableColumnFlexes[3],
            child: _buildHeaderCell(context, 'Reason/Item'),
          ),
        ],
        if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
          Expanded(
            flex: payableColumnFlexes[4],
            child: _buildHeaderCell(context, context.shouldShowFullLayout ? 'Dates' : 'Repayment Date'),
          ),
        ],
        if (context.shouldShowFullLayout) ...[
          Expanded(
            flex: payableColumnFlexes[5],
            child: _buildHeaderCell(context, 'Progress'),
          ),
        ],
        if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
          Expanded(
            flex: payableColumnFlexes[6],
            child: _buildHeaderCell(context, 'Status'),
          ),
        ],
        Expanded(
          flex: payableColumnFlexes[7],
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

  Widget _buildResponsiveTableRow(BuildContext context, Payable payable, int index) {
    final payableColumnFlexes = ResponsiveBreakpoints.responsive(
      context,
      tablet: [1, 2, 1, 1, 1, 1, 1, 1],
      small: [1, 2, 2, 1, 1, 1, 1, 1],
      medium: [1, 2, 2, 2, 1, 1, 1, 2],
      large: [1, 2, 2, 3, 2, 1, 1, 2],
      ultrawide: [1, 2, 2, 3, 2, 1, 1, 2],
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
          Expanded(
            flex: payableColumnFlexes[0],
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
                payable.id,
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

          Expanded(
            flex: payableColumnFlexes[1],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payable.creditorName,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    payable.creditorPhone,
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'PKR ${payable.balanceRemaining.toStringAsFixed(0)} remaining',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: payable.balanceRemaining > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: context.smallPadding),

          Expanded(
            flex: payableColumnFlexes[2],
            child: Container(
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_down_rounded,
                        color: Colors.red,
                        size: context.iconSize('small'),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Expanded(
                        child: Text(
                          'PKR ${payable.amountBorrowed.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: context.subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (!context.shouldShowCompactLayout && payable.amountPaid > 0) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Colors.green,
                          size: context.iconSize('small'),
                        ),
                        SizedBox(width: context.smallPadding / 2),
                        Expanded(
                          child: Text(
                            'PKR ${payable.amountPaid.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(width: context.smallPadding),

          if (!context.shouldShowCompactLayout) ...[
            Expanded(
              flex: payableColumnFlexes[3],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payable.reasonOrItem,
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoalGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (payable.notes != null && payable.notes!.isNotEmpty) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      payable.notes!,
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
            Expanded(
              flex: payableColumnFlexes[4],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payable.formattedExpectedRepaymentDate,
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: payable.isOverdue ? Colors.red : AppTheme.charcoalGray,
                    ),
                  ),
                  if (context.shouldShowFullLayout) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      'Borrowed: ${payable.formattedDateBorrowed}',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                  if (payable.isOverdue) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      '${payable.daysOverdue} days overdue',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          if (context.shouldShowFullLayout) ...[
            Expanded(
              flex: payableColumnFlexes[5],
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: payable.paymentPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      payable.isFullyPaid ? Colors.green : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    '${payable.paymentPercentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: payable.isFullyPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
            Expanded(
              flex: payableColumnFlexes[6],
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: payable.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(
                    color: payable.statusColor.withOpacity(0.3),
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
                        color: payable.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Expanded(
                      child: Text(
                        payable.statusText,
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w500,
                          color: payable.statusColor,
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

          Expanded(
            flex: payableColumnFlexes[7],
            child: ResponsiveBreakpoints.responsive(
              context,
              tablet: _buildCompactActions(context, payable),
              small: _buildCompactActions(context, payable),
              medium: _buildStandardActions(context, payable),
              large: _buildExpandedActions(context, payable),
              ultrawide: _buildExpandedActions(context, payable),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActions(BuildContext context, Payable payable) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit(payable);
        } else if (value == 'delete') {
          onDelete(payable);
        } else if (value == 'details') {
          onViewDetails(payable);
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
          value: 'details',
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: Colors.green,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'View Details',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.green,
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

  Widget _buildStandardActions(BuildContext context, Payable payable) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onEdit(payable),
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onViewDetails(payable),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                Icons.visibility_outlined,
                color: Colors.green,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),
        SizedBox(width: context.smallPadding),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDelete(payable),
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

  Widget _buildExpandedActions(BuildContext context, Payable payable) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onEdit(payable),
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
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onViewDetails(payable),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: Colors.green,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'View',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.smallPadding / 2),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDelete(payable),
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
              Icons.credit_card_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'No Payables Found',
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
              'Start by adding your first payable record to track amounts borrowed from suppliers and creditors',
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
                        'Add First Payable',
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