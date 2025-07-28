import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/image_upload.dart';
import '../globals/text_button.dart';

class PaymentReceiptContent extends StatelessWidget {
  final Payment payment;
  final bool isCompact;
  final VoidCallback onClose;

  const PaymentReceiptContent({
    super.key,
    required this.payment,
    required this.isCompact,
    required this.onClose,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Payment Details Card
          _buildPaymentDetailsCard(context),
          SizedBox(height: context.cardPadding),

          // Date and Time
          _buildDateTimeSection(context),
          SizedBox(height: context.cardPadding),

          // Description Section
          _buildDescriptionSection(context),
          SizedBox(height: context.cardPadding),

          // Payment Method Section
          _buildPaymentMethodSection(context),
          SizedBox(height: context.cardPadding),

          // Amount Breakdown Section
          _buildAmountBreakdownSection(context),
          SizedBox(height: context.cardPadding),

          // Receipt Section
          if (payment.hasReceipt) ...[
            _buildReceiptImageSection(context),
          ] else ...[
            _buildNoReceiptSection(context),
          ],
          SizedBox(height: context.mainPadding),

          // Close Button
          Align(
            alignment: Alignment.centerRight,
            child: PremiumButton(
              text: 'Close',
              onPressed: onClose,
              height: context.buttonHeight / (isCompact ? 1 : 1.5),
              isOutlined: true,
              backgroundColor: Colors.grey[600],
              textColor: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.cardPadding),
          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildPaymentDetailsCompact(context),
            small: _buildPaymentDetailsCompact(context),
            medium: _buildPaymentDetailsExpanded(context),
            large: _buildPaymentDetailsExpanded(context),
            ultrawide: _buildPaymentDetailsExpanded(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCompact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Labor',
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          payment.laborName,
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoalGray,
          ),
        ),
        Text(
          '${payment.laborRole} • ${payment.laborPhone}',
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: context.cardPadding),
        Text(
          'Payment Month',
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          payment.paymentMonth,
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoalGray,
          ),
        ),
        if (payment.isFinalPayment) ...[
          SizedBox(height: context.smallPadding / 2),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              'Final Payment for Month',
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentDetailsExpanded(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Labor',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                payment.laborName,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                '${payment.laborRole} • ${payment.laborPhone}',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Payment Month',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                payment.paymentMonth,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              if (payment.isFinalPayment) ...[
                SizedBox(height: context.smallPadding / 2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallPadding,
                    vertical: context.smallPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Text(
                    'Final Payment',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: _buildDateTimeCompact(context),
      small: _buildDateTimeCompact(context),
      medium: _buildDateTime(context),
      large: _buildDateTime(context),
      ultrawide: _buildDateTime(context),
    );
  }

  Widget _buildDateTimeCompact(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.smallPadding),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.purple),
              SizedBox(width: context.smallPadding),
              Text(
                _formatDate(payment.date),
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.cardPadding),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.smallPadding),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, size: context.iconSize('small'), color: Colors.orange),
              SizedBox(width: context.smallPadding),
              Text(
                payment.timeText,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.purple),
                SizedBox(width: context.smallPadding),
                Text(
                  _formatDate(payment.date),
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: context.iconSize('small'), color: Colors.orange),
                SizedBox(width: context.smallPadding),
                Text(
                  payment.timeText,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: context.captionFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            payment.description,
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w400,
              color: AppTheme.charcoalGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: payment.paymentMethodColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: payment.paymentMethodColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: payment.paymentMethodColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Icon(
              payment.paymentMethodIcon,
              color: payment.paymentMethodColor,
              size: context.iconSize('medium'),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  payment.paymentMethod,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: payment.paymentMethodColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.cardPadding,
              vertical: context.cardPadding / 2,
            ),
            decoration: BoxDecoration(
              color: payment.statusColor,
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              payment.statusText,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBreakdownSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: Colors.green,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Amount Breakdown',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Amount:',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'PKR ${payment.amountPaid.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          if (payment.bonus > 0) ...[
            SizedBox(height: context.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bonus:',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '+PKR ${payment.bonus.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
          if (payment.deduction > 0) ...[
            SizedBox(height: context.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deduction:',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '-PKR ${payment.deduction.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.cardPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Amount:',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                'PKR ${payment.netAmount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImageSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_rounded, color: Colors.green, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Receipt Image',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 25.h,
              small: 30.h,
              medium: 35.h,
              large: 40.h,
              ultrawide: 45.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ResponsiveImageUploadWidget(
              initialImagePath: payment.receiptImagePath,
              onImageChanged: (imagePath) {
                // Handle image change if needed for viewing
              },
              label: 'Payment Receipt',
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReceiptSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.orange,
            size: context.iconSize('xl'),
          ),
          SizedBox(height: context.cardPadding),
          Text(
            'No Receipt Available',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.smallPadding),
          Text(
            isCompact
                ? 'No receipt available. Add one for better records.'
                : 'No receipt image was uploaded for this payment. Consider adding a receipt for better record keeping.',
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              color: Colors.orange[400],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.cardPadding),
          Container(
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 25.h,
              small: 30.h,
              medium: 35.h,
              large: 40.h,
              ultrawide: 45.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ResponsiveImageUploadWidget(
              initialImagePath: null,
              onImageChanged: (imagePath) {
                // Handle new receipt upload
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Receipt uploaded! Please save the payment to update.',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: AppTheme.pureWhite,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                );
              },
              label: 'Add Receipt Image',
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}