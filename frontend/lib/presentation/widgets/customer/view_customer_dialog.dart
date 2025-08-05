import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';

class ViewCustomerDetailsDialog extends StatefulWidget {
  final Customer customer;

  const ViewCustomerDetailsDialog({super.key, required this.customer});

  @override
  State<ViewCustomerDetailsDialog> createState() => _ViewCustomerDetailsDialogState();
}

class _ViewCustomerDetailsDialogState extends State<ViewCustomerDetailsDialog>
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
              Icons.person_rounded,
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
                  'Customer Details',
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
                    'View complete customer information',
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
              widget.customer.id,
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
          _buildCustomerNameCard(isCompact),
          SizedBox(height: context.cardPadding),
          _buildContactInfoCard(isCompact),
          SizedBox(height: context.cardPadding),
          _buildDescriptionCard(isCompact),
          SizedBox(height: context.cardPadding),
          _buildPurchaseInfoCard(isCompact),
          SizedBox(height: context.cardPadding),
          _buildCustomerStatsCard(isCompact),
          SizedBox(height: context.mainPadding),
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

  Widget _buildCustomerNameCard(bool isCompact) {
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
                'Customer Name',
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
                  widget.customer.name,
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

  Widget _buildContactInfoCard(bool isCompact) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: _buildContactInfoCompact(),
      small: _buildContactInfoCompact(),
      medium: _buildContactInfoExpanded(),
      large: _buildContactInfoExpanded(),
      ultrawide: _buildContactInfoExpanded(),
    );
  }

  Widget _buildContactInfoCompact() {
    return Column(
      children: [
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
                  Icon(Icons.phone, size: context.iconSize('small'), color: Colors.orange),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Phone Number',
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
                widget.customer.phone,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
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
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.email, size: context.iconSize('small'), color: Colors.purple),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Email Address',
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
                widget.customer.email,
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

  Widget _buildContactInfoExpanded() {
    return Row(
      children: [
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
                    Icon(Icons.phone, size: context.iconSize('small'), color: Colors.orange),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Phone Number',
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
                  widget.customer.phone,
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
        SizedBox(width: context.cardPadding),
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
                    Icon(Icons.email, size: context.iconSize('small'), color: Colors.purple),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Email Address',
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
                  widget.customer.email,
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
                'Description',
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
              widget.customer.description.isEmpty
                  ? 'No description provided'
                  : widget.customer.description,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: widget.customer.description.isEmpty
                    ? Colors.grey[500]
                    : AppTheme.charcoalGray,
                height: 1.5,
                fontStyle: widget.customer.description.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseInfoCard(bool isCompact) {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: _buildPurchaseInfoCompact(),
      small: _buildPurchaseInfoCompact(),
      medium: _buildPurchaseInfoExpanded(),
      large: _buildPurchaseInfoExpanded(),
      ultrawide: _buildPurchaseInfoExpanded(),
    );
  }

  Widget _buildPurchaseInfoCompact() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart, size: context.iconSize('small'), color: Colors.green),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Last Purchase Amount',
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
                widget.customer.lastPurchase != null
                    ? 'PKR ${widget.customer.lastPurchase!.toStringAsFixed(0)}'
                    : 'No purchases yet',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: widget.customer.lastPurchase != null ? AppTheme.charcoalGray : Colors.grey[500],
                  fontStyle: widget.customer.lastPurchase == null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        if (widget.customer.lastPurchase != null) ...[
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.teal),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Last Purchase Date',
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
                  _formatDate(widget.customer.lastPurchaseDate!),
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  _getRelativeDate(widget.customer.lastPurchaseDate!),
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPurchaseInfoExpanded() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart, size: context.iconSize('small'), color: Colors.green),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Last Purchase Amount',
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
                  widget.customer.lastPurchase != null
                      ? 'PKR ${widget.customer.lastPurchase!.toStringAsFixed(0)}'
                      : 'No purchases yet',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.customer.lastPurchase != null ? AppTheme.charcoalGray : Colors.grey[500],
                    fontStyle: widget.customer.lastPurchase == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.customer.lastPurchase != null) ...[
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: context.iconSize('small'), color: Colors.teal),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Last Purchase Date',
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
                    _formatDate(widget.customer.lastPurchaseDate!),
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    _getRelativeDate(widget.customer.lastPurchaseDate!),
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
        ],
      ],
    );
  }

  Widget _buildCustomerStatsCard(bool isCompact) {
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
                'Customer Information',
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
            tablet: _buildCustomerStatsCompact(),
            small: _buildCustomerStatsCompact(),
            medium: _buildCustomerStatsExpanded(),
            large: _buildCustomerStatsExpanded(),
            ultrawide: _buildCustomerStatsExpanded(),
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
                  'Customer Active',
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

  Widget _buildCustomerStatsCompact() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Since:',
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
                _formatDate(widget.customer.createdAt),
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
              'Status:',
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
                color: widget.customer.lastPurchase != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                widget.customer.lastPurchase != null ? 'Active Buyer' : 'New Customer',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: widget.customer.lastPurchase != null ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerStatsExpanded() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Since:',
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
                  _formatDate(widget.customer.createdAt),
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
                'Status:',
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
                  color: widget.customer.lastPurchase != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  widget.customer.lastPurchase != null ? 'Active Buyer' : 'New Customer',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.customer.lastPurchase != null ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}