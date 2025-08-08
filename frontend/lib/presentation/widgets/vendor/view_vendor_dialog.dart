import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';

class ViewVendorDetailsDialog extends StatefulWidget {
  final Vendor vendor;

  const ViewVendorDetailsDialog({super.key, required this.vendor});

  @override
  State<ViewVendorDetailsDialog> createState() => _ViewVendorDetailsDialogState();
}

class _ViewVendorDetailsDialogState extends State<ViewVendorDetailsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoadingDetails = false;

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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.pureWhite,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
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

  void _handleVerifyContact(String type) async {
    try {
      setState(() {
        _isLoadingDetails = true;
      });

      final provider = context.read<VendorProvider>();
      final success = await provider.verifyVendorContact(
        id: widget.vendor.id,
        verificationType: type,
        verified: true,
      );

      if (success) {
        _showSuccessSnackbar('${type.capitalize()} verified successfully!');
      } else {
        _showErrorSnackbar('Failed to verify $type');
      }
    } catch (e) {
      _showErrorSnackbar('Error verifying $type: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  void _handleUpdateActivity(String activityType) async {
    try {
      setState(() {
        _isLoadingDetails = true;
      });

      final provider = context.read<VendorProvider>();
      final success = await provider.updateVendorActivity(
        id: widget.vendor.id,
        activityType: activityType,
        activityDate: DateTime.now().toIso8601String(),
      );

      if (success) {
        _showSuccessSnackbar('Vendor ${activityType} updated successfully!');
      } else {
        _showErrorSnackbar('Failed to update vendor $activityType');
      }
    } catch (e) {
      _showErrorSnackbar('Error updating vendor $activityType: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  void _handleStatusChange(String newStatus) async {
    try {
      setState(() {
        _isLoadingDetails = true;
      });

      final provider = context.read<VendorProvider>();
      final success = await provider.updateVendor(
        id: widget.vendor.id,
        name: widget.vendor.name,
        businessName: widget.vendor.businessName,
        cnic: widget.vendor.cnic,
        phone: widget.vendor.phone,
        email: widget.vendor.email,
        address: widget.vendor.address,
        city: widget.vendor.city,
        area: widget.vendor.area,
        country: widget.vendor.country,
        vendorType: widget.vendor.vendorType,
        status: newStatus,
        taxNumber: widget.vendor.taxNumber,
        notes: widget.vendor.notes,
        phoneVerified: widget.vendor.phoneVerified,
        emailVerified: widget.vendor.emailVerified,
      );

      if (success) {
        _showSuccessSnackbar('Vendor status updated successfully!');
        Navigator.of(context).pop(); // Close dialog to refresh data
      } else {
        _showErrorSnackbar('Failed to update vendor status');
      }
    } catch (e) {
      _showErrorSnackbar('Error updating vendor status: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
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
                child: _isLoadingDetails
                    ? _buildLoadingState()
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryMaroon,
            strokeWidth: 3,
          ),
          SizedBox(height: context.cardPadding),
          Text(
            'Loading vendor details...',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
              Icons.store_rounded,
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
                  'Vendor Details',
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
                    'Complete vendor information',
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
              widget.vendor.id.length > 10
                  ? '${widget.vendor.id.substring(0, 10)}...'
                  : widget.vendor.id,
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

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVendorProfileCard(),
            SizedBox(height: context.cardPadding),
            _buildContactInfoCard(),
            SizedBox(height: context.cardPadding),
            _buildLocationCard(),
            SizedBox(height: context.cardPadding),
            _buildStatusAndTypeCard(),
            SizedBox(height: context.cardPadding),
            _buildVerificationCard(),
            if (widget.vendor.taxNumber != null && widget.vendor.taxNumber!.isNotEmpty) ...[
              SizedBox(height: context.cardPadding),
              _buildBusinessInfoCard(),
            ],
            if (widget.vendor.notes != null && widget.vendor.notes!.isNotEmpty) ...[
              SizedBox(height: context.cardPadding),
              _buildNotesCard(),
            ],
            SizedBox(height: context.cardPadding),
            _buildActivityCard(),
            SizedBox(height: context.cardPadding),
            _buildQuickActionsCard(),
            SizedBox(height: context.mainPadding),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorProfileCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.vendor.initials,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vendor.displayName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize * 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                SizedBox(height: context.smallPadding / 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: context.iconSize('small'),
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'Vendor since ${widget.vendor.formattedCreatedAt}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: context.iconSize('small'),
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      '${widget.vendor.vendorAgeDays} days old (${widget.vendor.relativeCreatedAt})',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
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
        _buildInfoCard(
          title: 'Phone Number',
          value: widget.vendor.phone,
          icon: Icons.phone,
          color: Colors.orange,
          trailing: widget.vendor.phoneVerified
              ? Icon(Icons.verified, color: Colors.green, size: context.iconSize('small'))
              : Icon(Icons.error, color: Colors.red, size: context.iconSize('small')),
        ),
        if (widget.vendor.email != null && widget.vendor.email!.isNotEmpty) ...[
          SizedBox(height: context.cardPadding),
          _buildInfoCard(
            title: 'Email Address',
            value: widget.vendor.email!,
            icon: Icons.email,
            color: Colors.purple,
            trailing: widget.vendor.emailVerified
                ? Icon(Icons.verified, color: Colors.green, size: context.iconSize('small'))
                : Icon(Icons.error, color: Colors.red, size: context.iconSize('small')),
          ),
        ],
      ],
    );
  }

  Widget _buildContactInfoExpanded() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Phone Number',
            value: widget.vendor.phone,
            icon: Icons.phone,
            color: Colors.orange,
            trailing: widget.vendor.phoneVerified
                ? Icon(Icons.verified, color: Colors.green, size: context.iconSize('small'))
                : Icon(Icons.error, color: Colors.red, size: context.iconSize('small')),
          ),
        ),
        if (widget.vendor.email != null && widget.vendor.email!.isNotEmpty) ...[
          SizedBox(width: context.cardPadding),
          Expanded(
            child: _buildInfoCard(
              title: 'Email Address',
              value: widget.vendor.email!,
              icon: Icons.email,
              color: Colors.purple,
              trailing: widget.vendor.emailVerified
                  ? Icon(Icons.verified, color: Colors.green, size: context.iconSize('small'))
                  : Icon(Icons.error, color: Colors.red, size: context.iconSize('small')),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationCard() {
    final locationParts = <String>[];
    if (widget.vendor.address != null && widget.vendor.address!.isNotEmpty) {
      locationParts.add(widget.vendor.address!);
    }
    locationParts.add(widget.vendor.area);
    locationParts.add(widget.vendor.city);
    if (widget.vendor.country != null && widget.vendor.country!.isNotEmpty) {
      locationParts.add(widget.vendor.country!);
    }

    final locationText = locationParts.join(', ');

    return _buildInfoCard(
      title: 'Location',
      value: locationText,
      icon: Icons.location_on,
      color: Colors.teal,
    );
  }

  Widget _buildStatusAndTypeCard() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Status',
            value: widget.vendor.statusDisplayName,
            icon: Icons.flag,
            color: _getStatusColor(widget.vendor.status),
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildInfoCard(
            title: 'Type',
            value: widget.vendor.vendorTypeDisplayName,
            icon: _getTypeIcon(widget.vendor.vendorType),
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: Colors.green,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Verification Status',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      widget.vendor.phoneVerified ? Icons.check_circle : Icons.cancel,
                      color: widget.vendor.phoneVerified ? Colors.green : Colors.red,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'Phone ${widget.vendor.phoneVerified ? 'Verified' : 'Unverified'}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: widget.vendor.phoneVerified ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.vendor.email != null && widget.vendor.email!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        widget.vendor.emailVerified ? Icons.check_circle : Icons.cancel,
                        color: widget.vendor.emailVerified ? Colors.green : Colors.red,
                        size: context.iconSize('small'),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        'Email ${widget.vendor.emailVerified ? 'Verified' : 'Unverified'}',
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: widget.vendor.emailVerified ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoCard() {
    final businessInfo = <String>[];
    if (widget.vendor.taxNumber != null && widget.vendor.taxNumber!.isNotEmpty) {
      businessInfo.add('Tax Number: ${widget.vendor.taxNumber}');
    }
    businessInfo.add('CNIC: ${widget.vendor.cnic}');

    return _buildInfoCard(
      title: 'Business Information',
      value: businessInfo.join('\n'),
      icon: Icons.business,
      color: Colors.indigo,
    );
  }

  Widget _buildNotesCard() {
    return _buildInfoCard(
      title: 'Notes',
      value: widget.vendor.notes!,
      icon: Icons.note,
      color: Colors.amber,
    );
  }

  Widget _buildActivityCard() {
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
                Icons.timeline,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Activity Timeline',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Order',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    Text(
                      widget.vendor.lastOrderDate != null
                          ? widget.vendor.formattedLastOrderDate!
                          : 'No orders yet',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: widget.vendor.lastOrderDate != null
                            ? AppTheme.charcoalGray
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Contact',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    Text(
                      widget.vendor.lastContactDate != null
                          ? widget.vendor.formattedLastContactDate!
                          : 'No contact yet',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: widget.vendor.lastContactDate != null
                            ? AppTheme.charcoalGray
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.vendor.totalOrders != null) ...[
            SizedBox(height: context.cardPadding),
            Container(
              padding: EdgeInsets.all(context.smallPadding),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.blue,
                    size: context.iconSize('small'),
                  ),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Total Order Value: PKR ${widget.vendor.totalOrders!.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: Colors.orange,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Wrap(
            spacing: context.smallPadding,
            runSpacing: context.smallPadding / 2,
            children: [
              if (!widget.vendor.phoneVerified)
                _buildActionChip(
                  label: 'Verify Phone',
                  icon: Icons.phone_android,
                  color: Colors.green,
                  onTap: () => _handleVerifyContact('phone'),
                ),
              if (widget.vendor.email != null &&
                  widget.vendor.email!.isNotEmpty &&
                  !widget.vendor.emailVerified)
                _buildActionChip(
                  label: 'Verify Email',
                  icon: Icons.email,
                  color: Colors.blue,
                  onTap: () => _handleVerifyContact('email'),
                ),
              _buildActionChip(
                label: 'Update Order',
                icon: Icons.shopping_cart,
                color: Colors.purple,
                onTap: () => _handleUpdateActivity('order'),
              ),
              _buildActionChip(
                label: 'Update Contact',
                icon: Icons.contact_phone,
                color: Colors.teal,
                onTap: () => _handleUpdateActivity('contact'),
              ),
              if (widget.vendor.status == 'INACTIVE')
                _buildActionChip(
                  label: 'Activate Vendor',
                  icon: Icons.power_settings_new,
                  color: Colors.green,
                  onTap: () => _handleStatusChange('ACTIVE'),
                ),
              if (widget.vendor.status == 'ACTIVE')
                _buildActionChip(
                  label: 'Deactivate',
                  icon: Icons.power_off,
                  color: Colors.orange,
                  onTap: () => _handleStatusChange('INACTIVE'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: context.smallPadding),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.borderRadius('small')),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.cardPadding / 2,
          vertical: context.smallPadding,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: context.iconSize('small')),
            SizedBox(width: context.smallPadding / 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: PremiumButton(
        text: 'Close',
        onPressed: _handleClose,
        height: context.buttonHeight / 1.5,
        isOutlined: true,
        backgroundColor: Colors.grey[600],
        textColor: Colors.grey[600],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.orange;
      case 'SUSPENDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String vendorType) {
    switch (vendorType.toUpperCase()) {
      case 'SUPPLIER':
        return Icons.local_shipping;
      case 'DISTRIBUTOR':
        return Icons.store;
      case 'MANUFACTURER':
        return Icons.factory;
      default:
        return Icons.business;
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}