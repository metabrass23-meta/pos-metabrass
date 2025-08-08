import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class VendorFilterDialog extends StatefulWidget {
  const VendorFilterDialog({super.key});

  @override
  State<VendorFilterDialog> createState() => _VendorFilterDialogState();
}

class _VendorFilterDialogState extends State<VendorFilterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Filter state variables
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedCity;
  String? _selectedArea;
  String? _selectedCountry;
  String? _selectedVerification;

  // Text controllers for custom inputs
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Predefined options
  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE', 'SUSPENDED'];
  final List<String> _typeOptions = ['SUPPLIER', 'DISTRIBUTOR', 'MANUFACTURER'];
  final List<String> _verificationOptions = ['any', 'phone', 'email', 'both', 'none'];
  final List<String> _commonCities = ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Multan', 'Peshawar', 'Quetta'];
  final List<String> _commonAreas = ['Gulshan', 'Clifton', 'DHA', 'Johar Town', 'Model Town', 'F-7', 'Blue Area', 'Saddar'];
  final List<String> _commonCountries = ['Pakistan', 'UAE', 'Saudi Arabia', 'India', 'China', 'Turkey', 'Bangladesh'];

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

    // Initialize with current filter values
    final provider = context.read<VendorProvider>();
    _selectedStatus = provider.selectedStatus;
    _selectedType = provider.selectedType;
    _selectedCity = provider.selectedCity;
    _selectedArea = provider.selectedArea;
    _selectedCountry = provider.selectedCountry;
    _selectedVerification = provider.verificationFilter;

    _cityController.text = _selectedCity ?? '';
    _areaController.text = _selectedArea ?? '';
    _countryController.text = _selectedCountry ?? '';

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _handleApplyFilters() async {
    final provider = context.read<VendorProvider>();

    // Update city, area, and country from text controllers
    final city = _cityController.text.trim().isEmpty ? null : _cityController.text.trim();
    final area = _areaController.text.trim().isEmpty ? null : _areaController.text.trim();
    final country = _countryController.text.trim().isEmpty ? null : _countryController.text.trim();

    // Apply all filters
    await Future.wait([
      if (_selectedStatus != provider.selectedStatus)
        provider.setStatusFilter(_selectedStatus),
      if (_selectedType != provider.selectedType)
        provider.setTypeFilter(_selectedType),
      if (city != provider.selectedCity)
        provider.setCityFilter(city),
      if (area != provider.selectedArea)
        provider.setAreaFilter(area),
      if (country != provider.selectedCountry)
        provider.setCountryFilter(country),
      if (_selectedVerification != provider.verificationFilter)
        provider.setVerificationFilter(_selectedVerification),
    ]);

    _handleClose();
  }

  void _handleClearFilters() async {
    final provider = context.read<VendorProvider>();
    await provider.clearAllFilters();
    _handleClose();
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
          backgroundColor: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: 85.w,
                  small: 90.w,
                  medium: 70.w,
                  large: 60.w,
                  ultrawide: 50.w,
                ),
                constraints: BoxConstraints(
                  maxWidth: 600,
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentGold, Color(0xFFD4AF37)],
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
              Icons.filter_alt_rounded,
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
                  'Filter Vendors',
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
                    'Refine your vendor list with advanced filters',
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
            // Vendor Status Filter
            _buildFilterSection(
              title: 'Vendor Status',
              icon: Icons.flag_outlined,
              child: _buildStatusFilter(),
            ),

            SizedBox(height: context.cardPadding),

            // Vendor Type Filter
            _buildFilterSection(
              title: 'Vendor Type',
              icon: Icons.business_outlined,
              child: _buildTypeFilter(),
            ),

            SizedBox(height: context.cardPadding),

            // Location Filters
            _buildFilterSection(
              title: 'Location',
              icon: Icons.location_on_outlined,
              child: _buildLocationFilters(),
            ),

            SizedBox(height: context.cardPadding),

            // Verification Filter
            _buildFilterSection(
              title: 'Verification Status',
              icon: Icons.verified_user_outlined,
              child: _buildVerificationFilter(),
            ),

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
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
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
          ),
          SizedBox(height: context.cardPadding),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Wrap(
      spacing: context.smallPadding,
      runSpacing: context.smallPadding / 2,
      children: [
        _buildFilterChip(
          label: 'All Status',
          isSelected: _selectedStatus == null,
          onTap: () => setState(() => _selectedStatus = null),
        ),
        ..._statusOptions.map((status) => _buildFilterChip(
          label: _getStatusDisplayName(status),
          isSelected: _selectedStatus == status,
          onTap: () => setState(() => _selectedStatus = status),
        )),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Wrap(
      spacing: context.smallPadding,
      runSpacing: context.smallPadding / 2,
      children: [
        _buildFilterChip(
          label: 'All Types',
          isSelected: _selectedType == null,
          onTap: () => setState(() => _selectedType = null),
        ),
        ..._typeOptions.map((type) => _buildFilterChip(
          label: _getTypeDisplayName(type),
          isSelected: _selectedType == type,
          onTap: () => setState(() => _selectedType = type),
        )),
      ],
    );
  }

  Widget _buildLocationFilters() {
    return Column(
      children: [
        // City Filter
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.smallPadding),
            TextFormField(
              controller: _cityController,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                color: AppTheme.charcoalGray,
              ),
              decoration: InputDecoration(
                hintText: 'Enter city name',
                hintStyle: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.location_city_outlined,
                  color: Colors.grey[500],
                  size: context.iconSize('medium'),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.cardPadding / 2,
                ),
              ),
            ),
            SizedBox(height: context.smallPadding),
            Wrap(
              spacing: context.smallPadding / 2,
              runSpacing: context.smallPadding / 4,
              children: _commonCities.map((city) => _buildQuickSelectChip(
                label: city,
                onTap: () => setState(() => _cityController.text = city),
              )).toList(),
            ),
          ],
        ),

        SizedBox(height: context.cardPadding),

        // Area Filter
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Area',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.smallPadding),
            TextFormField(
              controller: _areaController,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                color: AppTheme.charcoalGray,
              ),
              decoration: InputDecoration(
                hintText: 'Enter area name',
                hintStyle: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.map_outlined,
                  color: Colors.grey[500],
                  size: context.iconSize('medium'),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.cardPadding / 2,
                ),
              ),
            ),
            SizedBox(height: context.smallPadding),
            Wrap(
              spacing: context.smallPadding / 2,
              runSpacing: context.smallPadding / 4,
              children: _commonAreas.map((area) => _buildQuickSelectChip(
                label: area,
                onTap: () => setState(() => _areaController.text = area),
              )).toList(),
            ),
          ],
        ),

        SizedBox(height: context.cardPadding),

        // Country Filter
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.smallPadding),
            TextFormField(
              controller: _countryController,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                color: AppTheme.charcoalGray,
              ),
              decoration: InputDecoration(
                hintText: 'Enter country name',
                hintStyle: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.public_outlined,
                  color: Colors.grey[500],
                  size: context.iconSize('medium'),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.cardPadding / 2,
                ),
              ),
            ),
            SizedBox(height: context.smallPadding),
            Wrap(
              spacing: context.smallPadding / 2,
              runSpacing: context.smallPadding / 4,
              children: _commonCountries.map((country) => _buildQuickSelectChip(
                label: country,
                onTap: () => setState(() => _countryController.text = country),
              )).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationFilter() {
    return Wrap(
      spacing: context.smallPadding,
      runSpacing: context.smallPadding / 2,
      children: _verificationOptions.map((verification) => _buildFilterChip(
        label: _getVerificationDisplayName(verification),
        isSelected: _selectedVerification == verification,
        onTap: () => setState(() => _selectedVerification = verification),
      )).toList(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
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
          color: isSelected ? AppTheme.primaryMaroon.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMaroon : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: context.subtitleFontSize,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryMaroon : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.borderRadius('small')),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.smallPadding,
          vertical: context.smallPadding / 2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.accentGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(
            color: AppTheme.accentGold.withOpacity(0.3),
            width: 1,
          ),
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
        PremiumButton(
          text: 'Apply Filters',
          onPressed: _handleApplyFilters,
          height: context.buttonHeight,
          icon: Icons.filter_alt_rounded,
          backgroundColor: AppTheme.accentGold,
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Clear All Filters',
          onPressed: _handleClearFilters,
          height: context.buttonHeight,
          icon: Icons.clear_all_rounded,
          isOutlined: true,
          backgroundColor: Colors.red[600],
          textColor: Colors.red[600],
        ),
        SizedBox(height: context.smallPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleClose,
          height: context.buttonHeight,
          isOutlined: true,
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
            onPressed: _handleClose,
            height: context.buttonHeight / 1.5,
            isOutlined: true,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Clear All',
            onPressed: _handleClearFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.clear_all_rounded,
            isOutlined: true,
            backgroundColor: Colors.red[600],
            textColor: Colors.red[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Apply Filters',
            onPressed: _handleApplyFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.filter_alt_rounded,
            backgroundColor: AppTheme.accentGold,
          ),
        ),
      ],
    );
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

  String _getTypeDisplayName(String type) {
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

  String _getVerificationDisplayName(String verification) {
    switch (verification.toLowerCase()) {
      case 'any':
        return 'Any Verification';
      case 'phone':
        return 'Phone Verified';
      case 'email':
        return 'Email Verified';
      case 'both':
        return 'Both Verified';
      case 'none':
        return 'Not Verified';
      default:
        return verification;
    }
  }
}