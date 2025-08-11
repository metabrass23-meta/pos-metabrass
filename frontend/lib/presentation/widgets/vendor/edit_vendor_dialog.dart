import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/models/vendor/vendor_model.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class EnhancedEditVendorDialog extends StatefulWidget {
  final VendorModel vendor;

  const EnhancedEditVendorDialog({super.key, required this.vendor});

  @override
  State<EnhancedEditVendorDialog> createState() => _EnhancedEditVendorDialogState();
}

class _EnhancedEditVendorDialogState extends State<EnhancedEditVendorDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _cnicController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _areaController;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Track changes
  bool _hasChanges = false;
  Map<String, dynamic> _originalData = {};

  // Options
  final List<String> _commonCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
  ];
  final List<String> _commonAreas = [
    'Gulshan',
    'Clifton',
    'DHA',
    'Johar Town',
    'Model Town',
    'F-7',
    'Blue Area',
    'Saddar',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing vendor data
    _nameController = TextEditingController(text: widget.vendor.name);
    _businessNameController = TextEditingController(text: widget.vendor.businessName);
    _cnicController = TextEditingController(text: widget.vendor.cnic);
    _phoneController = TextEditingController(text: widget.vendor.phone);
    _cityController = TextEditingController(text: widget.vendor.city);
    _areaController = TextEditingController(text: widget.vendor.area);

    // Store original data for change tracking
    _originalData = {
      'name': widget.vendor.name,
      'businessName': widget.vendor.businessName,
      'cnic': widget.vendor.cnic,
      'phone': widget.vendor.phone,
      'city': widget.vendor.city,
      'area': widget.vendor.area,
    };

    // Add listeners to track changes
    _nameController.addListener(_checkForChanges);
    _businessNameController.addListener(_checkForChanges);
    _cnicController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _cityController.addListener(_checkForChanges);
    _areaController.addListener(_checkForChanges);

    // Initialize animations
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final currentData = {
      'name': _nameController.text,
      'businessName': _businessNameController.text,
      'cnic': _cnicController.text,
      'phone': _phoneController.text,
      'city': _cityController.text,
      'area': _areaController.text,
    };

    bool hasChanges = false;
    for (String key in _originalData.keys) {
      if (_originalData[key] != currentData[key]) {
        hasChanges = true;
        break;
      }
    }

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_hasChanges) {
        _showInfoSnackbar('No changes detected');
        return;
      }

      final provider = Provider.of<VendorProvider>(context, listen: false);

      final success = await provider.updateVendor(
        id: widget.vendor.id,
        name: _nameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        cnic: _cnicController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(provider.errorMessage ?? 'Failed to update vendor');
        }
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              'Vendor updated successfully!',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.pureWhite, size: context.iconSize('medium')),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.pureWhite, size: context.iconSize('medium')),
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
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _handleCancel() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Discard Changes?'),
          content: Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Continue Editing')),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation dialog
                _animationController.reverse().then((_) {
                  Navigator.of(context).pop(); // Close edit dialog
                });
              },
              child: Text('Discard', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      _animationController.reverse().then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: context.dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 95.w,
                    small: 90.w,
                    medium: 80.w,
                    large: 70.w,
                    ultrawide: 60.w,
                  ),
                  maxHeight: 90.h,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(child: _buildFormContent()),
                  ],
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
          colors: _hasChanges ? [Colors.orange, Colors.orangeAccent] : [Colors.blue, Colors.blueAccent],
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
              _hasChanges ? Icons.edit : Icons.edit_outlined,
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
                  context.shouldShowCompactLayout ? 'Edit Vendor' : 'Edit Vendor Details',
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
                    _hasChanges ? 'You have unsaved changes' : 'Update vendor information',
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
          if (_hasChanges)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.orange, size: 8),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    'Modified',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              widget.vendor.id.length > 8 ? '${widget.vendor.id.substring(0, 8)}...' : widget.vendor.id,
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
              onTap: _handleCancel,
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

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information Section
              _buildBasicInfoSection(),
              SizedBox(height: context.cardPadding),

              // Contact Information Section
              _buildContactInfoSection(),
              SizedBox(height: context.cardPadding),

              // Location Information Section
              _buildLocationInfoSection(),
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

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', Icons.info_outline),
        SizedBox(height: context.cardPadding),

        // Vendor Name
        PremiumTextField(
          label: 'Vendor Name *',
          hint: context.shouldShowCompactLayout ? 'Enter name' : 'Enter vendor\'s full name',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter vendor name';
            }
            if (value!.length < 2) {
              return 'Name must be at least 2 characters';
            }
            if (value.length > 100) {
              return 'Name must be less than 100 characters';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),

        // Business Name
        PremiumTextField(
          label: 'Business Name *',
          hint: context.shouldShowCompactLayout ? 'Enter business name' : 'Enter business/company name',
          controller: _businessNameController,
          prefixIcon: Icons.business_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter business name';
            }
            if (value!.length < 2) {
              return 'Business name must be at least 2 characters';
            }
            if (value.length > 200) {
              return 'Business name must be less than 200 characters';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),

        // CNIC
        PremiumTextField(
          label: 'CNIC *',
          hint: context.shouldShowCompactLayout ? 'Enter CNIC' : 'Enter CNIC (e.g., 42101-1234567-1)',
          controller: _cnicController,
          prefixIcon: Icons.credit_card,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter CNIC';
            }
            if (!RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(value)) {
              return 'Please enter a valid CNIC (XXXXX-XXXXXXX-X)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contact Information', Icons.contact_phone_outlined),
        SizedBox(height: context.cardPadding),

        // Phone Number
        PremiumTextField(
          label: 'Phone Number *',
          hint: context.shouldShowCompactLayout ? 'Enter phone' : 'Enter phone number',
          controller: _phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter phone number';
            }
            if (value!.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Location Information', Icons.location_on_outlined),
        SizedBox(height: context.cardPadding),

        // City and Area Row/Column
        ResponsiveBreakpoints.responsive(
          context,
          tablet: _buildLocationFieldsColumn(),
          small: _buildLocationFieldsColumn(),
          medium: _buildLocationFieldsRow(),
          large: _buildLocationFieldsRow(),
          ultrawide: _buildLocationFieldsRow(),
        ),
      ],
    );
  }

  Widget _buildLocationFieldsRow() {
    return Row(
      children: [
        Expanded(child: _buildCityField()),
        SizedBox(width: context.cardPadding),
        Expanded(child: _buildAreaField()),
      ],
    );
  }

  Widget _buildLocationFieldsColumn() {
    return Column(
      children: [
        _buildCityField(),
        SizedBox(height: context.cardPadding),
        _buildAreaField(),
      ],
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumTextField(
          label: 'City *',
          hint: 'Enter city',
          controller: _cityController,
          prefixIcon: Icons.location_city_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter city';
            }
            return null;
          },
        ),
        SizedBox(height: context.smallPadding),
        Wrap(
          spacing: context.smallPadding / 2,
          runSpacing: context.smallPadding / 4,
          children: _commonCities
              .take(4)
              .map(
                (city) => _buildQuickSelectChip(
                  label: city,
                  onTap: () => setState(() => _cityController.text = city),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAreaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumTextField(
          label: 'Area *',
          hint: 'Enter area',
          controller: _areaController,
          prefixIcon: Icons.map_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter area';
            }
            return null;
          },
        ),
        SizedBox(height: context.smallPadding),
        Wrap(
          spacing: context.smallPadding / 2,
          runSpacing: context.smallPadding / 4,
          children: _commonAreas
              .take(4)
              .map(
                (area) => _buildQuickSelectChip(
                  label: area,
                  onTap: () => setState(() => _areaController.text = area),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: context.iconSize('medium')),
        SizedBox(width: context.smallPadding),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoalGray,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSelectChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.borderRadius('small')),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
        decoration: BoxDecoration(
          color: AppTheme.accentGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            fontWeight: FontWeight.w500,
            color: AppTheme.accentGold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<VendorProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Update Vendor',
              onPressed: (!_hasChanges || provider.isLoading) ? null : _handleUpdate,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.save_rounded,
              backgroundColor: _hasChanges ? Colors.orange : Colors.blue,
            );
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleCancel,
          isOutlined: true,
          height: context.buttonHeight,
          backgroundColor: Colors.grey[600],
          textColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: Consumer<VendorProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update Vendor',
                onPressed: (!_hasChanges || provider.isLoading) ? null : _handleUpdate,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.save_rounded,
                backgroundColor: _hasChanges ? Colors.orange : Colors.blue,
              );
            },
          ),
        ),
      ],
    );
  }
}
