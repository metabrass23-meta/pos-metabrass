import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../src/theme/app_theme.dart';

class OrderSuccessDialog extends StatelessWidget {
  final double totalPrice;
  final double advanceAmount;
  final DateTime deliveryDate;

  const OrderSuccessDialog({
    super.key,
    required this.totalPrice,
    required this.advanceAmount,
    required this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveBreakpoints.responsive(
            context,
            tablet: 85.w,
            small: 75.w,
            medium: 65.w,
            large: 55.w,
            ultrawide: 45.w,
          ),
        ),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(context.borderRadius('large')),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: context.shadowBlur('heavy'),
              offset: Offset(0, context.cardPadding),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuccessHeader(context),
            _buildSuccessContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.greenAccent],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppTheme.pureWhite,
              size: ResponsiveBreakpoints.responsive(
                context,
                tablet: 16.sp,
                small: 14.sp,
                medium: 13.sp,
                large: 12.sp,
                ultrawide: 11.sp,
              ),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Created!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: ResponsiveBreakpoints.responsive(
                      context,
                      tablet: 12.sp,
                      small: 11.sp,
                      medium: 10.sp,
                      large: 9.sp,
                      ultrawide: 8.sp,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                  ),
                ),
                Text(
                  'Custom order created successfully',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveBreakpoints.responsive(
                      context,
                      tablet: 8.sp,
                      small: 7.5.sp,
                      medium: 7.sp,
                      large: 6.5.sp,
                      ultrawide: 6.sp,
                    ),
                    color: AppTheme.pureWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Column(
        children: [
          _buildOrderSummaryCard(context),
          SizedBox(height: context.cardPadding),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            'Order ID:',
            'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
            valueColor: Colors.purple,
          ),
          SizedBox(height: context.smallPadding),
          _buildSummaryRow(
            context,
            'Total Amount:',
            'PKR ${totalPrice.toStringAsFixed(0)}',
            valueColor: Colors.green,
            isHighlight: true,
          ),
          SizedBox(height: context.smallPadding),
          _buildSummaryRow(
            context,
            'Advance Received:',
            'PKR ${advanceAmount.toStringAsFixed(0)}',
            valueColor: Colors.blue,
          ),
          SizedBox(height: context.smallPadding),
          _buildSummaryRow(
            context,
            'Remaining Amount:',
            'PKR ${(totalPrice - advanceAmount).toStringAsFixed(0)}',
            valueColor: Colors.orange,
          ),
          SizedBox(height: context.smallPadding),
          _buildSummaryRow(
            context,
            'Delivery Date:',
            '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      BuildContext context,
      String label,
      String value, {
        Color? valueColor,
        bool isHighlight = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveBreakpoints.responsive(
              context,
              tablet: 8.sp,
              small: 7.5.sp,
              medium: 7.sp,
              large: 6.5.sp,
              ultrawide: 6.sp,
            ),
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
            color: AppTheme.charcoalGray,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: ResponsiveBreakpoints.responsive(
              context,
              tablet: 8.sp,
              small: 7.5.sp,
              medium: 7.sp,
              large: 6.5.sp,
              ultrawide: 6.sp,
            ),
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppTheme.charcoalGray,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            label: 'Print Order',
            icon: Icons.print_rounded,
            color: Colors.blue,
            onTap: () => _handlePrintOrder(context),
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildActionButton(
            context,
            label: 'Done',
            icon: Icons.done_rounded,
            color: Colors.purple,
            onTap: () => _handleDone(context),
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
        bool isPrimary = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(colors: [color, color.withOpacity(0.8)])
            : null,
        border: isPrimary ? null : Border.all(color: color),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.borderRadius()),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: context.cardPadding / 1.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? AppTheme.pureWhite : color,
                  size: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 10.sp,
                    small: 9.sp,
                    medium: 8.sp,
                    large: 7.5.sp,
                    ultrawide: 7.sp,
                  ),
                ),
                SizedBox(width: context.smallPadding),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveBreakpoints.responsive(
                      context,
                      tablet: 8.sp,
                      small: 7.5.sp,
                      medium: 7.sp,
                      large: 6.5.sp,
                      ultrawide: 6.sp,
                    ),
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? AppTheme.pureWhite : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePrintOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Print functionality will be implemented'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleDone(BuildContext context) {
    Navigator.of(context).pop(); // Close success dialog
    Navigator.of(context).pop(); // Close order dialog
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
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
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(context.borderRadius('large')),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: context.shadowBlur('heavy'),
              offset: Offset(0, context.cardPadding),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(context),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (confirmColor ?? AppTheme.primaryMaroon).withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(context.smallPadding),
              decoration: BoxDecoration(
                color: (confirmColor ?? AppTheme.primaryMaroon).withOpacity(0.2),
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
              child: Icon(
                icon,
                color: confirmColor ?? AppTheme.primaryMaroon,
                size: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 14.sp,
                  small: 13.sp,
                  medium: 12.sp,
                  large: 11.sp,
                  ultrawide: 10.sp,
                ),
              ),
            ),
            SizedBox(width: context.cardPadding),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 11.sp,
                  small: 10.sp,
                  medium: 9.sp,
                  large: 8.5.sp,
                  ultrawide: 8.sp,
                ),
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: ResponsiveBreakpoints.responsive(
            context,
            tablet: 9.sp,
            small: 8.5.sp,
            medium: 8.sp,
            large: 7.5.sp,
            ultrawide: 7.sp,
          ),
          color: Colors.grey[700],
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCancel ?? () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.cardPadding / 1.5,
                    ),
                    child: Text(
                      cancelText,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveBreakpoints.responsive(
                          context,
                          tablet: 9.sp,
                          small: 8.5.sp,
                          medium: 8.sp,
                          large: 7.5.sp,
                          ultrawide: 7.sp,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: confirmColor ?? AppTheme.primaryMaroon,
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onConfirm,
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.cardPadding / 1.5,
                    ),
                    child: Text(
                      confirmText,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveBreakpoints.responsive(
                          context,
                          tablet: 9.sp,
                          small: 8.5.sp,
                          medium: 8.sp,
                          large: 7.5.sp,
                          ultrawide: 7.sp,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.pureWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'Processing...',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(context.cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryMaroon,
              strokeWidth: 3,
            ),
            SizedBox(height: context.cardPadding),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 9.sp,
                  small: 8.5.sp,
                  medium: 8.sp,
                  large: 7.5.sp,
                  ultrawide: 7.sp,
                ),
                color: AppTheme.charcoalGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}