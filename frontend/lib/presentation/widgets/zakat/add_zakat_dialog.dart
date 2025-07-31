import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/zakat_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class AddZakatDialog extends StatefulWidget {
  const AddZakatDialog({super.key});

  @override
  State<AddZakatDialog> createState() => _AddZakatDialogState();
}

class _AddZakatDialogState extends State<AddZakatDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

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
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final zakatProvider = Provider.of<ZakatProvider>(context, listen: false);

      await zakatProvider.addZakat(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        amount: double.parse(_amountController.text.trim()),
      );

      if (mounted) {
        _showSuccessSnackbar();
        Navigator.of(context).pop();
      }
    }
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
              'Zakat record added successfully!',
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
              Icons.error_rounded,
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
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryMaroon,
              onPrimary: AppTheme.pureWhite,
              surface: AppTheme.pureWhite,
              onSurface: AppTheme.charcoalGray,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryMaroon,
              onPrimary: AppTheme.pureWhite,
              surface: AppTheme.pureWhite,
              onSurface: AppTheme.charcoalGray,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(isCompact: true),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(isCompact: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(isCompact: false),
        ],
      ),
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
                  context.shouldShowCompactLayout ? 'Add Zakat' : 'Add New Zakat Record',
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
                    'Record your zakat contribution',
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

  Widget _buildFormContent({required bool isCompact}) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumTextField(
              label: 'Name (Optional)',
              hint: isCompact ? 'Enter name' : 'Enter name or leave empty',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              // No validator since this field is optional
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Description',
              hint: isCompact ? 'Enter description' : 'Enter description/purpose of zakat',
              controller: _descriptionController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter description';
                }
                if (value!.length < 5) {
                  return 'Description must be at least 5 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Amount',
              hint: isCompact ? 'Enter amount' : 'Enter amount (PKR)',
              controller: _amountController,
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            // Date and Time Selection
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(context.cardPadding),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppTheme.primaryMaroon,
                                size: context.iconSize('medium'),
                              ),
                              SizedBox(width: context.smallPadding),
                              Text(
                                'Date',
                                style: GoogleFonts.inter(
                                  fontSize: context.bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.charcoalGray,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.smallPadding / 2),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: GoogleFonts.inter(
                              fontSize: context.subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: EdgeInsets.all(context.cardPadding),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                color: AppTheme.primaryMaroon,
                                size: context.iconSize('medium'),
                              ),
                              SizedBox(width: context.smallPadding),
                              Text(
                                'Time',
                                style: GoogleFonts.inter(
                                  fontSize: context.bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.charcoalGray,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.smallPadding / 2),
                          Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.inter(
                              fontSize: context.subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
        Consumer<ZakatProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Add Zakat',
              onPressed: provider.isLoading ? null : _handleSubmit,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.add_rounded,
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
          child: Consumer<ZakatProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Add Zakat',
                onPressed: provider.isLoading ? null : _handleSubmit,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.add_rounded,
              );
            },
          ),
        ),
      ],
    );
  }
}