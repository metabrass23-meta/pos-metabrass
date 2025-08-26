import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/advance_payment/advance_payment_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class ViewAdvancePaymentDialog extends StatefulWidget {
  final AdvancePayment payment;

  const ViewAdvancePaymentDialog({super.key, required this.payment});

  @override
  State<ViewAdvancePaymentDialog> createState() => _ViewAdvancePaymentDialogState();
}

class _ViewAdvancePaymentDialogState extends State<ViewAdvancePaymentDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Container(
          width: context.dialogWidth,
          constraints: BoxConstraints(
            maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 90.w, small: 85.w, medium: 75.w, large: 65.w, ultrawide: 55.w),
            maxHeight: 85.h,
          ),
          margin: EdgeInsets.all(context.mainPadding),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(context.borderRadius('large')),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: context.shadowBlur('heavy'), offset: Offset(0, context.cardPadding)),
            ],
          ),
          child: ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildTabletLayout(),
            small: _buildMobileLayout(),
            medium: _buildDesktopLayout(),
            large: _buildDesktopLayout(),
            ultrawide: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Flexible(child: SingleChildScrollView(child: _buildContent(isCompact: true))),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Flexible(child: SingleChildScrollView(child: _buildContent(isCompact: true))),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Flexible(child: SingleChildScrollView(child: _buildContent(isCompact: false))),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Icon(Icons.payment_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advance Payment Details',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!context.isTablet) ...[
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    'View complete payment information',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.pureWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.cardPadding / 2),
            decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            child: Text(
              widget.payment.id.substring(0, 8),
              style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
            ),
          ),
          SizedBox(width: context.smallPadding),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                child: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({required bool isCompact}) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Labor Information Card
          _buildLaborInfoCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Amount Details Card
          _buildAmountDetailsCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Date and Time Information Card
          _buildDateTimeInfoCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Description Card
          _buildDescriptionCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Receipt Information Card
          if (widget.payment.hasReceipt) ...[_buildReceiptInfoCard(isCompact), SizedBox(height: context.cardPadding)],

          // Salary Information Card
          _buildSalaryInfoCard(isCompact),
          SizedBox(height: context.mainPadding),

          // Close Button
          Align(
            alignment: Alignment.centerRight,
            child: PremiumButton(
              text: 'Close',
              onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildLaborInfoCard(bool isCompact) {
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
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Labor Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.payment.laborName,
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize * 1.1, fontWeight: FontWeight.w700, color: Colors.blue[700]),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  'Role: ${widget.payment.laborRole}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  'Phone: ${widget.payment.laborPhone}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDetailsCard(bool isCompact) {
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
              Icon(Icons.attach_money_rounded, color: Colors.green, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Payment Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: Colors.green[700]),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.mainPadding),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Column(
              children: [
                Text(
                  'Advance Amount',
                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
                SizedBox(height: context.smallPadding),
                Text(
                  widget.payment.formattedAmount,
                  style: GoogleFonts.inter(fontSize: context.headerFontSize, fontWeight: FontWeight.w800, color: Colors.green[700]),
                ),
                SizedBox(height: context.smallPadding),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  decoration: BoxDecoration(
                    color: widget.payment.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Text(
                    widget.payment.statusText,
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: widget.payment.statusColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfoCard(bool isCompact) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: _buildDateTimeInfoCompact(),
      small: _buildDateTimeInfoCompact(),
      medium: _buildDateTimeInfoExpanded(),
      large: _buildDateTimeInfoExpanded(),
      ultrawide: _buildDateTimeInfoExpanded(),
    );
  }

  Widget _buildDateTimeInfoCompact() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.purple),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Date',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: context.smallPadding / 2),
              Text(
                '${widget.payment.date.day}/${widget.payment.date.month}/${widget.payment.date.year}',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
        ),
        SizedBox(height: context.cardPadding),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: context.iconSize('small'), color: Colors.blue),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Time',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: context.smallPadding / 2),
              Text(
                widget.payment.time,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeInfoExpanded() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.purple),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Date',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  '${widget.payment.date.day}/${widget.payment.date.month}/${widget.payment.date.year}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: context.iconSize('small'), color: Colors.blue),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Time',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  widget.payment.time,
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: Colors.grey[700], size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Payment Description',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              widget.payment.description,
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: AppTheme.charcoalGray, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfoCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_rounded, color: Colors.orange, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Receipt Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            child: Row(
              children: [
                Icon(Icons.image, color: Colors.orange, size: context.iconSize('medium')),
                SizedBox(width: context.smallPadding),
                Expanded(
                  child: Text(
                    'Receipt image available',
                    style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: Colors.orange[700]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Text(
                    'View',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryInfoCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.indigo.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.indigo, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Salary Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(context.cardPadding),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Salary',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                      ),
                      SizedBox(height: context.smallPadding / 2),
                      Text(
                        widget.payment.formattedTotalSalary,
                        style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: Colors.indigo[700]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(context.cardPadding),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  child: Column(
                    children: [
                      Text(
                        'Remaining',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                      ),
                      SizedBox(height: context.smallPadding / 2),
                      Text(
                        widget.payment.formattedRemainingSalary,
                        style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: Colors.red[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record Created:',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatDateTime(widget.payment.createdAt),
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  child: Text(
                    'Advance Payment',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}


