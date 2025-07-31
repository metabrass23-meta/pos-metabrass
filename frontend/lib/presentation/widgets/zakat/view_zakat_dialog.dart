import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/zakat_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class ViewZakatDetailsDialog extends StatefulWidget {
  final Zakat zakat;

  const ViewZakatDetailsDialog({super.key, required this.zakat});

  @override
  State<ViewZakatDetailsDialog> createState() => _ViewZakatDetailsDialogState();
}

class _ViewZakatDetailsDialogState extends State<ViewZakatDetailsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.7 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: context.dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 90.w,
                    small: 85.w,
                    medium: 75.w,
                    large: 65.w,
                    ultrawide: 55.w,
                  ),
                  maxHeight: 85.h,
                ),
                margin: EdgeInsets.all(context.mainPadding),
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
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Flexible(
          child: SingleChildScrollView(
            child: _buildContent(isCompact: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Flexible(
          child: SingleChildScrollView(
            child: _buildContent(isCompact: true),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Flexible(
          child: SingleChildScrollView(
            child: _buildContent(isCompact: false),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
              Icons.account_balance_wallet_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('large'),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zakat Details',
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
                    'View complete zakat contribution information',
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
            padding: EdgeInsets.symmetric(
              horizontal: context.cardPadding,
              vertical: context.cardPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              widget.zakat.id,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
          SizedBox(width: context.smallPadding),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleClose,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.pureWhite,
                  size: context.iconSize('medium'),
                ),
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
          // Name Information Card (if available)
          if (widget.zakat.name != null) ...[
            _buildNameInfoCard(isCompact),
            SizedBox(height: context.cardPadding),
          ],

          // Amount Details Card
          _buildAmountDetailsCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Date and Time Information Card
          _buildDateTimeInfoCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Description Card
          _buildDescriptionCard(isCompact),
          SizedBox(height: context.cardPadding),

          // Zakat Type and Statistics Card
          _buildZakatStatsCard(isCompact),
          SizedBox(height: context.mainPadding),

          // Close Button
          Align(
            alignment: Alignment.centerRight,
            child: PremiumButton(
              text: 'Close',
              onPressed: _handleClose,
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

  Widget _buildNameInfoCard(bool isCompact) {
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
              Icon(
                Icons.person_outline,
                color: Colors.blue,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Contributor Information',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.pureWhite,
                    size: context.iconSize('small'),
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Text(
                  widget.zakat.name!,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize * 1.1,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[700],
                  ),
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
              Icon(
                Icons.attach_money_rounded,
                color: Colors.green,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Zakat Amount',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.mainPadding),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.green[700],
                  size: context.iconSize('xl'),
                ),
                SizedBox(height: context.smallPadding),
                Text(
                  'Contribution Amount',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: context.smallPadding),
                Text(
                  'PKR ${widget.zakat.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.green[700],
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
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.purple),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Date',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.smallPadding / 2),
              Text(
                widget.zakat.formattedDate,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              SizedBox(height: context.smallPadding / 2),
              Text(
                widget.zakat.relativeDate,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.cardPadding),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: context.iconSize('small'), color: Colors.orange),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Time',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.smallPadding / 2),
              Text(
                widget.zakat.formattedTime,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
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
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.purple),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Date',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  widget.zakat.formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  widget.zakat.relativeDate,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: context.iconSize('small'), color: Colors.orange),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Time',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  widget.zakat.formattedTime,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
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

  Widget _buildDescriptionCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Colors.grey[700],
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Description & Purpose',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
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
              widget.zakat.description,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: AppTheme.charcoalGray,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatStatsCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Zakat Record Information',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildZakatStatsCompact(),
            small: _buildZakatStatsCompact(),
            medium: _buildZakatStatsExpanded(),
            large: _buildZakatStatsExpanded(),
            ultrawide: _buildZakatStatsExpanded(),
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: Colors.green[700],
                  size: context.iconSize('small'),
                ),
                SizedBox(width: context.smallPadding),
                Text(
                  'Zakat Contribution Verified',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatStatsCompact() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Record Type:',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                color: Colors.grey[700],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                'Zakat',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryMaroon,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.cardPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Record Status:',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                color: Colors.grey[700],
              ),
            ),
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
                'Completed',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZakatStatsExpanded() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Type:',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: context.smallPadding / 2),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  'Zakat',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Status:',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
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
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}