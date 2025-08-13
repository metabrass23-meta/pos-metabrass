import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';
import '../globals/drop_down.dart'; // Added import for PremiumDropdownField

class AddLaborDialog extends StatefulWidget {
  const AddLaborDialog({super.key});

  @override
  State<AddLaborDialog> createState() => _AddLaborDialogState();
}

class _AddLaborDialogState extends State<AddLaborDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime _selectedJoiningDate = DateTime.now();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Map<String, String> _validationErrors = {};

  bool _isCreating = false;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _casteController.dispose();
    _designationController.dispose();
    _salaryController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final provider = Provider.of<LaborProvider>(context, listen: false);
    _validationErrors = {};

    // Pre-validate required fields
    if (_nameController.text.trim().isEmpty) {
      _validationErrors['name'] = 'Name is required';
    }
    if (_cnicController.text.trim().isEmpty) {
      _validationErrors['cnic'] = 'CNIC is required';
    }
    if (_phoneController.text.trim().isEmpty) {
      _validationErrors['phoneNumber'] = 'Phone number is required';
    }
    if (_casteController.text.trim().isEmpty) {
      _validationErrors['caste'] = 'Caste is required';
    }
    if (_designationController.text.trim().isEmpty) {
      _validationErrors['designation'] = 'Designation is required';
    }
    if (_areaController.text.trim().isEmpty) {
      _validationErrors['area'] = 'Area is required';
    }
    if (_cityController.text.trim().isEmpty) {
      _validationErrors['city'] = 'City is required';
    }
    if (_selectedGender.isEmpty) {
      _validationErrors['gender'] = 'Gender is required';
    }
    if (_selectedJoiningDate.isAfter(DateTime.now())) {
      _validationErrors['joiningDate'] = 'Joining date cannot be in the future';
    }

    // Convert and validate salary
    double? salary;
    if (_salaryController.text.trim().isEmpty) {
      _validationErrors['salary'] = 'Salary is required';
    } else {
      salary = double.tryParse(_salaryController.text.trim());
      if (salary == null) {
        _validationErrors['salary'] = 'Please enter a valid salary amount';
      }
    }

    // Convert and validate age
    int? age;
    if (_ageController.text.trim().isEmpty) {
      _validationErrors['age'] = 'Age is required';
    } else {
      age = int.tryParse(_ageController.text.trim());
      if (age == null) {
        _validationErrors['age'] = 'Please enter a valid age';
      }
    }

    // If pre-validation errors exist, update UI and return
    if (_validationErrors.isNotEmpty) {
      setState(() {});
      return;
    }

    // Call validateLaborData with converted values
    _validationErrors = provider.validateLaborData(
      name: _nameController.text.trim(),
      cnic: _cnicController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      caste: _casteController.text.trim(),
      designation: _designationController.text.trim(),
      salary: salary!, // Non-null after checks
      area: _areaController.text.trim(),
      city: _cityController.text.trim(),
      age: age!, // Non-null after checks
      gender: _selectedGender,
      joiningDate: _selectedJoiningDate,
    );

    setState(() {});
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isCreating) return;

      setState(() {
        _isCreating = true;
      });

      _validateForm();

      if (_validationErrors.isNotEmpty) {
        _showValidationErrors();
        setState(() {
          _isCreating = false;
        });
        return;
      }

      try {
        final provider = Provider.of<LaborProvider>(context, listen: false);

        // Convert salary and age for createLabor
        double salary = double.parse(_salaryController.text.trim());
        int age = int.parse(_ageController.text.trim());

        final success = await provider.createLabor(
          name: _nameController.text.trim(),
          cnic: _cnicController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          caste: _casteController.text.trim(),
          designation: _designationController.text.trim(),
          joiningDate: _selectedJoiningDate,
          salary: salary,
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          gender: _selectedGender,
          age: age,
        );

        if (mounted) {
          if (success) {
            _showSuccessSnackbar();
            _clearForm();
            Navigator.of(context).pop();
          } else {
            _showErrorSnackbar(provider.errorMessage ?? 'Failed to create labor');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar('Error creating labor: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCreating = false;
          });
        }
      }
    }
  }

  void _showValidationErrors() {
    final errorMessages = _validationErrors.values.join('\n');
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
                'Please fix the following errors:\n$errorMessages',
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
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _showSuccessSnackbar() {
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
              'Labor created successfully!',
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

  void _handleCancel() {
    if (_isCreating) return;

    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _clearForm() {
    _nameController.clear();
    _cnicController.clear();
    _phoneController.clear();
    _casteController.clear();
    _designationController.clear();
    _salaryController.clear();
    _areaController.clear();
    _cityController.clear();
    _ageController.clear();
    setState(() {
      _selectedGender = 'Male';
      _selectedJoiningDate = DateTime.now();
      _validationErrors = {};
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isCreating) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedJoiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedJoiningDate) {
      setState(() {
        _selectedJoiningDate = picked;
      });
    }
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
        gradient: const LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
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
              Icons.person_add_alt_1_rounded,
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
                  context.shouldShowCompactLayout ? 'Add Labor' : 'Add New Labor',
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
                    'Create a new labor record',
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
              onTap: _isCreating ? null : _handleCancel,
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

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              SizedBox(height: context.cardPadding),
              _buildContactInfoSection(),
              SizedBox(height: context.cardPadding),
              _buildLocationInfoSection(),
              SizedBox(height: context.cardPadding),
              _buildEmploymentInfoSection(),
              SizedBox(height: context.mainPadding),
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
        PremiumTextField(
          label: 'Full Name *',
          hint: context.shouldShowCompactLayout ? 'Enter name' : 'Enter worker\'s full name',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
          enabled: !_isCreating,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a name';
            }
            if (value!.length < 2) {
              return 'Name must be at least 2 characters';
            }
            if (value.length > 50) {
              return 'Name must be less than 50 characters';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumTextField(
          label: 'CNIC *',
          hint: context.shouldShowCompactLayout
              ? 'Enter CNIC'
              : 'Enter CNIC (e.g., 42101-1234567-1)',
          controller: _cnicController,
          prefixIcon: Icons.credit_card,
          enabled: !_isCreating,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a CNIC';
            }
            if (!RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(value!)) {
              return 'Please enter a valid CNIC (XXXXX-XXXXXXX-X)';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumTextField(
          label: 'Caste',
          hint: context.shouldShowCompactLayout ? 'Enter caste' : 'Enter caste (optional)',
          controller: _casteController,
          prefixIcon: Icons.group_outlined,
          enabled: !_isCreating,
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
        PremiumTextField(
          label: 'Phone Number *',
          hint: context.shouldShowCompactLayout
              ? 'Enter phone'
              : 'Enter phone number (e.g., +923001234567)',
          controller: _phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          enabled: !_isCreating,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a phone number';
            }
            if (!RegExp(r'^\+92\d{10}$').hasMatch(value!)) {
              return 'Please enter a valid phone number (+92XXXXXXXXXX)';
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
        ResponsiveBreakpoints.responsive(
          context,
          tablet: _buildCityAreaColumn(),
          small: _buildCityAreaColumn(),
          medium: _buildCityAreaRow(),
          large: _buildCityAreaRow(),
          ultrawide: _buildCityAreaRow(),
        ),
      ],
    );
  }

  Widget _buildEmploymentInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Employment Information', Icons.work_outline),
        SizedBox(height: context.cardPadding),
        PremiumTextField(
          label: 'Designation *',
          hint: context.shouldShowCompactLayout
              ? 'Enter designation'
              : 'Enter job designation (e.g., Tailor, Operator)',
          controller: _designationController,
          prefixIcon: Icons.work_outline,
          enabled: !_isCreating,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a designation';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),
        GestureDetector(
          onTap: _isCreating ? null : () => _selectDate(context),
          child: AbsorbPointer(
            child: PremiumTextField(
              label: 'Joining Date *',
              hint: 'Select joining date',
              controller: TextEditingController(
                  text:
                  '${_selectedJoiningDate.day}/${_selectedJoiningDate.month}/${_selectedJoiningDate.year}'),
              prefixIcon: Icons.calendar_today,
              enabled: !_isCreating,
            ),
          ),
        ),
        SizedBox(height: context.cardPadding),
        PremiumTextField(
          label: 'Monthly Salary *',
          hint: context.shouldShowCompactLayout
              ? 'Enter salary'
              : 'Enter monthly salary in PKR',
          controller: _salaryController,
          prefixIcon: Icons.account_balance_wallet_outlined,
          keyboardType: TextInputType.number,
          enabled: !_isCreating,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a salary';
            }
            if (double.tryParse(value!) == null || double.parse(value) <= 0) {
              return 'Please enter a valid salary';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumDropdownField<String>(
          label: 'Gender *',
          hint: context.shouldShowCompactLayout ? 'Select gender' : 'Select gender',
          prefixIcon: Icons.person_pin_rounded,
          items: ['Male', 'Female', 'Other']
              .map((gender) => DropdownItem<String>(value: gender, label: gender))
              .toList(),
          value: _selectedGender,
          onChanged: _isCreating
              ? null
              : (value) {
            setState(() {
              _selectedGender = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a gender';
            }
            return null;
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumTextField(
          label: 'Age *',
          hint: context.shouldShowCompactLayout ? 'Enter age' : 'Enter age (minimum 18 years)',
          controller: _ageController,
          prefixIcon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
          enabled: !_isCreating,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter an age';
            }
            if (int.tryParse(value!) == null || int.parse(value) < 18) {
              return 'Age must be at least 18';
            }
            if (int.parse(value) > 65) {
              return 'Age must be less than 65';
            }
            return null;
          },
        ),
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
          enabled: !_isCreating,
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
          enabled: !_isCreating,
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

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<LaborProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Add Labor',
              onPressed: (_isCreating || provider.isLoading) ? null : _handleSubmit,
              isLoading: _isCreating || provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.person_add_alt_1_rounded,
              backgroundColor: AppTheme.primaryMaroon,
            );
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _isCreating ? null : _handleCancel,
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
            onPressed: _isCreating ? null : _handleCancel,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: Consumer<LaborProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Add Labor',
                onPressed: (_isCreating || provider.isLoading) ? null : _handleSubmit,
                isLoading: _isCreating || provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.person_add_alt_1_rounded,
                backgroundColor: AppTheme.primaryMaroon,
              );
            },
          ),
        ),
      ],
    );
  }
}