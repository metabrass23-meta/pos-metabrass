import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/advance_payment/advance_payment_model.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/theme/app_theme.dart';

class AdvancePaymentTableHelpers {
  final Function(AdvancePayment) onEdit;
  final Function(AdvancePayment) onDelete;
  final Function(AdvancePayment) onView;

  AdvancePaymentTableHelpers({required this.onEdit, required this.onDelete, required this.onView});

  /// Build the actions row for each advance payment record in the table
  Widget buildActionsRow(BuildContext context, AdvancePayment payment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onView(payment),
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
            onTap: () => onEdit(payment),
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
            onTap: () => onDelete(payment),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.delete_outline, color: Colors.red, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),
      ],
    );
  }

  /// Show success snackbar
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  /// Build error state widget
  Widget buildErrorState(BuildContext context, AdvancePaymentProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.error_outline, size: context.iconSize('xl'), color: Colors.red[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'Failed to Load Advance Payments',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              provider.errorMessage ?? 'An unexpected error occurred',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Container(
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  provider.clearError();
                  provider.loadAdvancePayments();
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Retry',
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

  /// Build empty state widget
  Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.payment_outlined, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Advance Payment Records Found',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              'Start by adding your first advance payment record to track labor payments effectively',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // This will trigger the add advance payment dialog from parent
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Add First Advance Payment',
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

  /// Get status color based on payment status
  Color getStatusColor(AdvancePayment payment) {
    if (payment.isActive == false) return Colors.red;
    if (payment.amount > payment.totalSalary * 0.5) return Colors.orange;
    return Colors.green; // Active and reasonable amount
  }

  /// Get status text
  String getStatusText(AdvancePayment payment) {
    if (payment.isActive == false) return 'Inactive';
    if (payment.amount > payment.totalSalary * 0.5) return 'High Amount';
    return 'Active';
  }

  /// Get labor initials for avatar
  String getLaborInitials(String laborName) {
    final words = laborName.trim().split(' ');
    if (words.isEmpty) return 'L';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[words.length - 1].substring(0, 1)}'.toUpperCase();
  }

  /// Format currency for display
  String formatCurrency(double amount) {
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  /// Get priority color based on amount
  Color getPriorityColor(double amount) {
    if (amount >= 100000) return Colors.red; // High priority
    if (amount >= 50000) return Colors.orange; // Medium priority
    return Colors.green; // Normal priority
  }

  /// Build status chip
  Widget buildStatusChip(BuildContext context, AdvancePayment payment) {
    final color = getStatusColor(payment);
    final text = getStatusText(payment);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  /// Build labor avatar
  Widget buildLaborAvatar(BuildContext context, AdvancePayment payment) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          getLaborInitials(payment.laborName),
          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.blue),
        ),
      ),
    );
  }

  /// Build receipt badge
  Widget buildReceiptBadge(BuildContext context, AdvancePayment payment) {
    if (payment.hasReceipt) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_rounded, color: Colors.green, size: context.iconSize('small')),
            SizedBox(width: context.smallPadding / 2),
            Text(
              'Available',
              style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.green),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, color: Colors.grey, size: context.iconSize('small')),
            SizedBox(width: context.smallPadding / 2),
            Text(
              'Missing',
              style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }
}


