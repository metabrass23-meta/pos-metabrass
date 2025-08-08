import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class EnhancedAddVendorDialog extends StatefulWidget {
  const EnhancedAddVendorDialog({super.key});

  @override
  State<EnhancedAddVendorDialog> createState() => _EnhancedAddVendorDialogState();
}

class _EnhancedAddVendorDialogState extends State<EnhancedAddVendorDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _countryController = TextEditingController(text: 'Pakistan');
  final _taxNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  String _selectedVendorType = 'SUPPLIER';
  String _selectedStatus = 'ACTIVE';

  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Options
  final List<String> _vendorTypes = ['SUPPLIER', 'DISTRIBUTOR', 'MANUFACTURER'];
  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE', 'SUSPENDED'];
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
  final List<String> _commonCountries = [
    'Pakistan',
    'UAE',
    'Saudi Arabia',
    'India',
    'China',
    'Turkey',
    'Bangladesh',
  ];

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _countryController.dispose();
    _taxNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleVendorTypeChange(String type) {
    setState(() {
      _selectedVendorType = type;
    });
  }

  void _handleStatusChange(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<VendorProvider>(context, listen: false);

      final success = await provider.addVendor(
        name: _nameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        cnic: _cnicController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        vendorType: _selectedVendorType,
        taxNumber: _taxNumberController.text.trim().isEmpty ? null : _taxNumberController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(provider.errorMessage ?? 'Failed to add vendor');
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
              'Vendor added successfully!',
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
          backgroundColor: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
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
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Icon(Icons.store_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.shouldShowCompactLayout ? 'Add Vendor' : 'Add New Vendor',
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
                    'Create a new vendor profile',
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
              // Vendor Type and Status Selection
              _buildVendorTypeAndStatusSection(),

              SizedBox(height: context.cardPadding),

              // Basic Information Section
              _buildBasicInfoSection(),

              SizedBox(height: context.cardPadding),

              // Contact Information Section
              _buildContactInfoSection(),

              SizedBox(height: context.cardPadding),

              // Location Information Section
              _buildLocationInfoSection(),

              SizedBox(height: context.cardPadding),

              // Business Information Section
              _buildBusinessInfoSection(),

              SizedBox(height: context.cardPadding),

              // Additional Information Section
              _buildAdditionalInfoSection(),

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

  Widget _buildVendorTypeAndStatusSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category_outlined, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Vendor Type & Status',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Vendor Type Selection
          Text(
            'Vendor Type',
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Wrap(
            spacing: context.smallPadding,
            runSpacing: context.smallPadding / 2,
            children: _vendorTypes
                .map(
                  (type) => InkWell(
                    onTap: () => _handleVendorTypeChange(type),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.cardPadding / 2,
                        vertical: context.smallPadding,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedVendorType == type
                            ? AppTheme.primaryMaroon.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                        border: Border.all(
                          color: _selectedVendorType == type ? AppTheme.primaryMaroon : Colors.grey.shade300,
                          width: _selectedVendorType == type ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getVendorTypeIcon(type),
                            color: _selectedVendorType == type ? AppTheme.primaryMaroon : Colors.grey[600],
                            size: context.iconSize('small'),
                          ),
                          SizedBox(width: context.smallPadding / 2),
                          Text(
                            _getVendorTypeDisplayName(type),
                            style: GoogleFonts.inter(
                              fontSize: context.subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: _selectedVendorType == type ? AppTheme.primaryMaroon : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          SizedBox(height: context.cardPadding),

          // Status Selection
          Text(
            'Initial Status',
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Wrap(
            spacing: context.smallPadding,
            runSpacing: context.smallPadding / 2,
            children: _statusOptions
                .map(
                  (status) => InkWell(
                    onTap: () => _handleStatusChange(status),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.cardPadding / 2,
                        vertical: context.smallPadding,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedStatus == status
                            ? _getStatusColor(status).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                        border: Border.all(
                          color: _selectedStatus == status ? _getStatusColor(status) : Colors.grey.shade300,
                          width: _selectedStatus == status ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _getStatusDisplayName(status),
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: _selectedStatus == status ? FontWeight.w600 : FontWeight.w500,
                          color: _selectedStatus == status ? _getStatusColor(status) : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
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
            if (value?.isEmpty ?? true) {
              return 'Please enter CNIC';
            }
            if (!RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(value!)) {
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
          hint: context.shouldShowCompactLayout ? 'Enter phone' : 'Enter phone number (e.g., +923001234567)',
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
        SizedBox(height: context.cardPadding),

        // Email Address
        PremiumTextField(
          label: 'Email Address',
          hint: context.shouldShowCompactLayout ? 'Enter email' : 'Enter email address (optional)',
          controller: _emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
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

        // Address
        PremiumTextField(
          label: 'Address',
          hint: context.shouldShowCompactLayout ? 'Enter address' : 'Enter complete address (optional)',
          controller: _addressController,
          prefixIcon: Icons.home_outlined,
          maxLines: 2,
        ),
        SizedBox(height: context.cardPadding),

        // City and Area Row/Column
        ResponsiveBreakpoints.responsive(
          context,
          tablet: _buildCityAreaColumn(),
          small: _buildCityAreaColumn(),
          medium: _buildCityAreaRow(),
          large: _buildCityAreaRow(),
          ultrawide: _buildCityAreaRow(),
        ),
        SizedBox(height: context.cardPadding),

        // Country Field
        _buildCountryField(),
      ],
    );
  }

  Widget _buildCityAreaRow() {
    return Row(
      children: [
        Expanded(child: _buildCityField()),
        SizedBox(width: context.cardPadding),
        Expanded(child: _buildAreaField()),
      ],
    );
  }

  Widget _buildCityAreaColumn() {
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

  Widget _buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumTextField(
          label: 'Country',
          hint: 'Enter country',
          controller: _countryController,
          prefixIcon: Icons.public_outlined,
        ),
        SizedBox(height: context.smallPadding),
        Wrap(
          spacing: context.smallPadding / 2,
          runSpacing: context.smallPadding / 4,
          children: _commonCountries
              .take(4)
              .map(
                (country) => _buildQuickSelectChip(
                  label: country,
                  onTap: () => setState(() => _countryController.text = country),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Business Information', Icons.business_center_outlined),
        SizedBox(height: context.cardPadding),

        // Tax Number
        PremiumTextField(
          label: 'Tax/NTN Number',
          hint: context.shouldShowCompactLayout ? 'Enter tax number' : 'Enter tax or NTN number (optional)',
          controller: _taxNumberController,
          prefixIcon: Icons.receipt_outlined,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length > 50) {
              return 'Tax number must be less than 50 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Additional Information', Icons.note_outlined),
        SizedBox(height: context.cardPadding),
        PremiumTextField(
          label: 'Notes',
          hint: context.shouldShowCompactLayout
              ? 'Enter notes'
              : 'Enter any additional notes about the vendor (optional)',
          controller: _notesController,
          prefixIcon: Icons.description_outlined,
          maxLines: 3,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length > 500) {
              return 'Notes must be less than 500 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
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
              text: 'Add Vendor',
              onPressed: provider.isLoading ? null : _handleSubmit,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.add_rounded,
              backgroundColor: AppTheme.primaryMaroon,
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
                text: 'Add Vendor',
                onPressed: provider.isLoading ? null : _handleSubmit,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.add_rounded,
                backgroundColor: AppTheme.primaryMaroon,
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper methods for display names and icons
  String _getVendorTypeDisplayName(String type) {
    switch (type.toUpperCase()) {
      case 'SUPPLIER':
        return 'Supplier';
      case 'DISTRIBUTOR':
        return 'Distributor';
      case 'MANUFACTURER':
        return 'Manufacturer';
      default:
        return type;
    }
  }

  IconData _getVendorTypeIcon(String type) {
    switch (type.toUpperCase()) {
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

  String _getStatusDisplayName(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'INACTIVE':
        return 'Inactive';
      case 'SUSPENDED':
        return 'Suspended';
      default:
        return status;
    }
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
}
