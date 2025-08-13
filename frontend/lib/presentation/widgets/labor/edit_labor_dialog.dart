import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/models/labor/labor_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class EnhancedEditLaborDialog extends StatefulWidget {
  final LaborModel labor;

  const EnhancedEditLaborDialog({super.key, required this.labor});

  @override
  State<EnhancedEditLaborDialog> createState() => _EnhancedEditLaborDialogState();
}

class _EnhancedEditLaborDialogState extends State<EnhancedEditLaborDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cnicController;
  late TextEditingController _phoneController;
  late TextEditingController _casteController;
  late TextEditingController _designationController;
  late TextEditingController _salaryController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _ageController;
  late String _selectedGender;
  late DateTime _selectedJoiningDate;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.labor.name);
    _cnicController = TextEditingController(text: widget.labor.cnic);
    _phoneController = TextEditingController(text: widget.labor.phoneNumber);
    _casteController = TextEditingController(text: widget.labor.caste);
    _designationController = TextEditingController(text: widget.labor.designation);
    _salaryController = TextEditingController(text: widget.labor.salary.toString());
    _areaController = TextEditingController(text: widget.labor.area);
    _cityController = TextEditingController(text: widget.labor.city);
    _ageController = TextEditingController(text: widget.labor.age.toString());
    _selectedGender = widget.labor.gender;
    _selectedJoiningDate = widget.labor.joiningDate;

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

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isUpdating) return;

      setState(() {
        _isUpdating = true;
      });

      try {
        final provider = Provider.of<LaborProvider>(context, listen: false);

        final success = await provider.updateLabor(
          id: widget.labor.id,
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
            _showSuccessSnackbar('Labor updated successfully!');
            Navigator.of(context).pop();
          } else {
            _showErrorSnackbar(provider.errorMessage ?? 'Failed to update labor');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar('Error updating labor: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUpdating = false;
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
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
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
    if (_isUpdating) return;

    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isUpdating) return;

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
                    children: [_buildHeader(), _buildFormContent()],
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
        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
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
            child: Icon(Icons.edit_outlined, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.shouldShowCompactLayout ? 'Edit Labor' : 'Edit Labor Details',
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
                    'Update worker information',
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
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              widget.labor.id,
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
              onTap: _isUpdating ? null : _handleCancel,
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
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumTextField(
              label: 'Name',
              hint: context.shouldShowCompactLayout ? 'Enter name' : 'Enter full name',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              enabled: !_isUpdating,
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
              hint: context.shouldShowCompactLayout ? 'Enter CNIC' : 'Enter CNIC (e.g., 42101-1234567-1)',
              controller: _cnicController,
              prefixIcon: Icons.credit_card,
              enabled: !_isUpdating,
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
              enabled: !_isUpdating,
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
              enabled: !_isUpdating,
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Designation',
              hint: context.shouldShowCompactLayout
                  ? 'Enter designation'
                  : 'Enter designation (e.g., Tailor)',
              controller: _designationController,
              prefixIcon: Icons.work_outline,
              enabled: !_isUpdating,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a designation';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            GestureDetector(
              onTap: _isUpdating ? null : () => _selectDate(context),
              child: AbsorbPointer(
                child: PremiumTextField(
                  label: 'Joining Date',
                  hint: 'Select joining date',
                  controller: TextEditingController(
                    text:
                        '${_selectedJoiningDate.day}/${_selectedJoiningDate.month}/${_selectedJoiningDate.year}',
                  ),
                  prefixIcon: Icons.calendar_today,
                  enabled: !_isUpdating,
                ),
              ),
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Salary',
              hint: context.shouldShowCompactLayout ? 'Enter salary' : 'Enter monthly salary (PKR)',
              controller: _salaryController,
              prefixIcon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              enabled: !_isUpdating,
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
              hint: context.shouldShowCompactLayout ? 'Enter area' : 'Enter area (e.g., Gulshan)',
              controller: _areaController,
              prefixIcon: Icons.location_on_outlined,
              enabled: !_isUpdating,
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
              hint: context.shouldShowCompactLayout ? 'Enter city' : 'Enter city (e.g., Karachi)',
              controller: _cityController,
              prefixIcon: Icons.location_city_outlined,
              enabled: !_isUpdating,
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
                enabled: !_isUpdating,
              ),
              items: [
                'Male',
                'Female',
                'Other',
              ].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
              onChanged: _isUpdating
                  ? null
                  : (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Age',
              hint: context.shouldShowCompactLayout ? 'Enter age' : 'Enter age (e.g., 30)',
              controller: _ageController,
              prefixIcon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              enabled: !_isUpdating,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an age';
                }
                if (int.tryParse(value!) == null || int.parse(value) < 18) {
                  return 'Age must be at least 18';
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
              text: 'Update Labor',
              onPressed: (_isUpdating || provider.isLoading) ? null : _handleUpdate,
              isLoading: _isUpdating || provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.save_rounded,
              backgroundColor: Colors.blue,
            );
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _isUpdating ? null : _handleCancel,
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
            onPressed: _isUpdating ? null : _handleCancel,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: Consumer<LaborProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update Labor',
                onPressed: (_isUpdating || provider.isLoading) ? null : _handleUpdate,
                isLoading: _isUpdating || provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.save_rounded,
                backgroundColor: Colors.blue,
              );
            },
          ),
        ),
      ],
    );
  }
}
