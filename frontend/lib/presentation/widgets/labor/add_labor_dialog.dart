import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

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

  bool _isCreating = false;

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

  void _handleCreate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isCreating) return;

      setState(() {
        _isCreating = true;
      });

      try {
        final provider = Provider.of<LaborProvider>(context, listen: false);

        final success = await provider.createLabor(
          name: _nameController.text.trim(),
          cnic: _cnicController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          caste: _casteController.text.trim(),
          designation: _designationController.text.trim(),
          joiningDate: _selectedJoiningDate,
          salary: double.parse(_salaryController.text.trim()),
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          gender: _selectedGender,
          age: int.parse(_ageController.text.trim()),
        );

        if (mounted) {
          if (success) {
            _showSuccessSnackbar('Labor created successfully!');
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildFormContent(),
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
          if (!context.isTablet)
            TextButton(
              onPressed: _isCreating ? null : _clearForm,
              child: Text(
                'Clear',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite.withOpacity(0.8),
                ),
              ),
            ),
          SizedBox(width: context.smallPadding),
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
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumTextField(
              label: 'Full Name',
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
              label: 'CNIC',
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
              label: 'Phone Number',
              hint: context.shouldShowCompactLayout
                  ? 'Enter phone'
                  : 'Enter phone number (e.g., +923001234567)',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
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
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Caste',
              hint: context.shouldShowCompactLayout ? 'Enter caste' : 'Enter caste (optional)',
              controller: _casteController,
              prefixIcon: Icons.group_outlined,
              enabled: !_isCreating,
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Designation',
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
                  label: 'Joining Date',
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
              label: 'Monthly Salary',
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
            PremiumTextField(
              label: 'Area',
              hint: context.shouldShowCompactLayout ? 'Enter area' : 'Enter area (e.g., Gulshan, Clifton)',
              controller: _areaController,
              prefixIcon: Icons.location_on_outlined,
              enabled: !_isCreating,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an area';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'City',
              hint: context.shouldShowCompactLayout ? 'Enter city' : 'Enter city (e.g., Karachi, Lahore)',
              controller: _cityController,
              prefixIcon: Icons.location_city_outlined,
              enabled: !_isCreating,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a city';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_pin_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                enabled: !_isCreating,
              ),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
              onChanged: _isCreating ? null : (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Age',
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
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<LaborProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Create Labor',
              onPressed: (_isCreating || provider.isLoading) ? null : _handleCreate,
              isLoading: _isCreating || provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.person_add_alt_1_rounded,
              backgroundColor: AppTheme.primaryMaroon,
            );
          },
        ),
        SizedBox(height: context.cardPadding),
        Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: 'Clear Form',
                onPressed: _isCreating ? null : _clearForm,
                height: context.buttonHeight,
                icon: Icons.clear_all,
                isOutlined: true,
                backgroundColor: Colors.orange[600],
                textColor: Colors.orange[600],
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: PremiumButton(
                text: 'Cancel',
                onPressed: _isCreating ? null : _handleCancel,
                height: context.buttonHeight,
                isOutlined: true,
                backgroundColor: Colors.grey[600],
                textColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Clear Form',
            onPressed: _isCreating ? null : _clearForm,
            height: context.buttonHeight / 1.5,
            icon: Icons.clear_all,
            isOutlined: true,
            backgroundColor: Colors.orange[600],
            textColor: Colors.orange[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _isCreating ? null : _handleCancel,
            height: context.buttonHeight / 1.5,
            isOutlined: true,
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
                text: 'Create Labor',
                onPressed: (_isCreating || provider.isLoading) ? null : _handleCreate,
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