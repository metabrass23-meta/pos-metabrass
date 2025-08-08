import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class EnhancedDeleteVendorDialog extends StatefulWidget {
  final Vendor vendor;

  const EnhancedDeleteVendorDialog({
    super.key,
    required this.vendor,
  });

  @override
  State<EnhancedDeleteVendorDialog> createState() => _EnhancedDeleteVendorDialogState();
}

class _EnhancedDeleteVendorDialogState extends State<EnhancedDeleteVendorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  bool _isPermanentDelete = true; // Toggle between permanent and soft delete
  bool _confirmationChecked = false; // Requires user to check confirmation
  String _confirmationText = ''; // User must type confirmation text

  final TextEditingController _confirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    if (!_validateDeletion()) {
      _showValidationError();
      return;
    }

    final provider = Provider.of<VendorProvider>(context, listen: false);

    bool success;
    if (_isPermanentDelete) {
      success = await provider.deleteVendor(widget.vendor.id);
    } else {
      success = await provider.softDeleteVendor(widget.vendor.id);
    }

    if (mounted) {
      if (success) {
        _showSuccessSnackbar();
        Navigator.of(context).pop();
      } else {
        _showErrorSnackbar(provider.errorMessage ?? 'Failed to delete vendor');
      }
    }
  }

  bool _validateDeletion() {
    if (!_confirmationChecked) {
      return false;
    }

    if (_isPermanentDelete) {
      // For permanent deletion, require typing vendor name
      return _confirmationText.toLowerCase().trim() ==
          widget.vendor.name.toLowerCase().trim();
    } else {
      // For soft deletion, just require checkbox
      return true;
    }
  }

  void _showValidationError() {
    String message;
    if (!_confirmationChecked) {
      message = 'Please confirm that you understand this action';
    } else if (_isPermanentDelete && _confirmationText.toLowerCase().trim() !=
        widget.vendor.name.toLowerCase().trim()) {
      message = 'Please type the vendor name exactly to confirm permanent deletion';
    } else {
      message = 'Please complete all confirmation steps';
    }

    _showSnackbar(message, Colors.orange, Icons.warning_outlined);
  }

  void _showSuccessSnackbar() {
    _showSnackbar(
      _isPermanentDelete
          ? 'Vendor deleted permanently!'
          : 'Vendor deactivated successfully!',
      Colors.green,
      Icons.check_circle_rounded,
    );
  }

  void _showErrorSnackbar(String message) {
    _showSnackbar(message, Colors.red, Icons.error_outline);
  }

  void _showSnackbar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
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
        backgroundColor: color,
        duration: Duration(seconds: color == Colors.red ? 4 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _handleCancel() {
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
          backgroundColor: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(
                  _shakeAnimation.value * 2 * (1 - _scaleAnimation.value),
                  0,
                ),
                child: Container(
                  width: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 85.w,
                    small: 75.w,
                    medium: 60.w,
                    large: 50.w,
                    ultrawide: 40.w,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 85.h,
                  ),
                  margin: EdgeInsets.all(context.mainPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(context.borderRadius('large')),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: context.shadowBlur('heavy'),
                        offset: Offset(0, context.cardPadding),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _buildContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isPermanentDelete
              ? [Colors.red, Colors.redAccent]
              : [Colors.orange, Colors.orangeAccent],
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
              _isPermanentDelete ? Icons.delete_forever_rounded : Icons.visibility_off_rounded,
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
                  _isPermanentDelete ? 'Delete Permanently' : 'Deactivate Vendor',
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
                    _isPermanentDelete
                        ? 'This action cannot be undone'
                        : 'Vendor can be restored later',
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

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleCancel,
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning Message
              _buildWarningMessage(),

              SizedBox(height: context.cardPadding),

              // Delete Type Toggle
              _buildDeleteTypeToggle(),

              SizedBox(height: context.cardPadding),

              // Vendor Details Card
              _buildVendorDetailsCard(),

              SizedBox(height: context.cardPadding),

              // Impact Warning
              _buildImpactWarning(),

              SizedBox(height: context.cardPadding),

              // Confirmation Section
              _buildConfirmationSection(),

              SizedBox(height: context.mainPadding),

              // Action Buttons
              ResponsiveBreakpoints.responsive(
                context,
                tablet: _buildCompactButtons(),
                small: _buildCompactButtons(),
                medium: _buildDesktopButtons(),
                large: _buildDesktopButtons(),
                ultrawide: _buildDesktopButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: _isPermanentDelete ? Colors.red : Colors.orange,
            size: context.iconSize('large'),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPermanentDelete ? 'Permanent Deletion Warning' : 'Deactivation Notice',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w700,
                    color: _isPermanentDelete ? Colors.red[700] : Colors.orange[700],
                  ),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  _isPermanentDelete
                      ? 'This will permanently remove all vendor data from the database. This action cannot be reversed.'
                      : 'This will deactivate the vendor but preserve all data. The vendor can be restored later.',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: AppTheme.charcoalGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteTypeToggle() {
    return Container(
      padding: EdgeInsets.all(context.smallPadding),
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
                Icons.info_outline,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Choose deletion type:',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: _buildDeleteOption(
                  title: 'Permanent Delete',
                  subtitle: 'Removes from database permanently',
                  icon: Icons.delete_forever_rounded,
                  color: Colors.red,
                  isSelected: _isPermanentDelete,
                  onTap: () {
                    setState(() {
                      _isPermanentDelete = true;
                      _confirmationChecked = false;
                      _confirmationText = '';
                      _confirmationController.clear();
                    });
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: _buildDeleteOption(
                  title: 'Deactivate',
                  subtitle: 'Hide but can be restored',
                  icon: Icons.visibility_off_rounded,
                  color: Colors.orange,
                  isSelected: !_isPermanentDelete,
                  onTap: () {
                    setState(() {
                      _isPermanentDelete = false;
                      _confirmationChecked = false;
                      _confirmationText = '';
                      _confirmationController.clear();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(context.borderRadius()),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: context.iconSize('medium'),
            ),
            SizedBox(height: context.smallPadding),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.smallPadding / 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize * 0.9,
                color: isSelected ? color : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorDetailsCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getVendorInitials(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _isPermanentDelete ? Colors.red[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.smallPadding,
                            vertical: context.smallPadding / 2,
                          ),
                          decoration: BoxDecoration(
                            color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(context.borderRadius('small')),
                          ),
                          child: Text(
                            widget.vendor.id,
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w600,
                              color: _isPermanentDelete ? Colors.red : Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Expanded(
                          child: Text(
                            widget.vendor.name,
                            style: GoogleFonts.inter(
                              fontSize: context.bodyFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!context.isTablet) ...[
                      SizedBox(height: context.smallPadding),
                      Text(
                        '${widget.vendor.businessName} | ${widget.vendor.cnic}',
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
                    'Vendor since: ${_formatDate(widget.vendor.createdAt)}',
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

  Widget _buildImpactWarning() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: Colors.amber[700],
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Impact Assessment',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          Text(
            _isPermanentDelete
                ? '• All vendor data will be permanently removed\n• Order history will be anonymized\n• Contact information will be deleted\n• Business information will be lost\n• This action cannot be undone'
                : '• Vendor will be hidden from active lists\n• All data will be preserved\n• Vendor can be restored later\n• Order history remains intact\n• Business information is maintained',
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              color: AppTheme.charcoalGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (_isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: _confirmationChecked,
            onChanged: (value) {
              setState(() {
                _confirmationChecked = value ?? false;
              });
            },
            title: Text(
              _isPermanentDelete
                  ? 'I understand this will permanently delete the vendor and cannot be undone'
                  : 'I understand this will deactivate the vendor',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: (_isPermanentDelete ? Colors.red : Colors.orange)[700],
              ),
            ),
            activeColor: _isPermanentDelete ? Colors.red : Colors.orange,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          if (_isPermanentDelete) ...[
            SizedBox(height: context.cardPadding),
            Text(
              'Type the vendor name to confirm permanent deletion:',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: context.smallPadding),
            Container(
              child: TextFormField(
                controller: _confirmationController,
                onChanged: (value) {
                  setState(() {
                    _confirmationText = value;
                  });
                },
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  color: AppTheme.charcoalGray,
                ),
                decoration: InputDecoration(
                  hintText: widget.vendor.name,
                  hintStyle: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(context.cardPadding / 2),
                ),
              ),
            ),
            SizedBox(height: context.smallPadding),
            Text(
              'Expected: ${widget.vendor.name}',
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cancel Button (safe action)
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleCancel,
          height: context.buttonHeight,
          backgroundColor: Colors.grey[600],
          textColor: AppTheme.pureWhite,
        ),

        SizedBox(height: context.cardPadding),

        // Delete Button (destructive action)
        Consumer<VendorProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: _isPermanentDelete ? 'Delete Permanently' : 'Deactivate Vendor',
              onPressed: provider.isLoading ? null : _handleDelete,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: _isPermanentDelete ? Icons.delete_forever_rounded : Icons.visibility_off_rounded,
              backgroundColor: _isPermanentDelete ? Colors.red : Colors.orange,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        // Cancel Button (safe action)
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: AppTheme.pureWhite,
          ),
        ),

        SizedBox(width: context.cardPadding),

        // Delete Button (destructive action)
        Expanded(
          flex: 1,
          child: Consumer<VendorProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: _isPermanentDelete ? 'Delete' : 'Deactivate',
                onPressed: provider.isLoading ? null : _handleDelete,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: _isPermanentDelete ? Icons.delete_forever_rounded : Icons.visibility_off_rounded,
                backgroundColor: _isPermanentDelete ? Colors.red : Colors.orange,
              );
            },
          ),
        ),
      ],
    );
  }

  String _getVendorInitials() {
    final words = widget.vendor.name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.length == 1) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'VE';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}