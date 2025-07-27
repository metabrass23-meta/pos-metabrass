import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../global/image_upload.dart';
import '../global/text_button.dart';
import '../global/text_field.dart';

class AddAdvancePaymentDialog extends StatefulWidget {
  const AddAdvancePaymentDialog({super.key});

  @override
  State<AddAdvancePaymentDialog> createState() => _AddAdvancePaymentDialogState();
}

class _AddAdvancePaymentDialogState extends State<AddAdvancePaymentDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Labor? _selectedLabor;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _receiptImagePath;

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

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
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
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedLabor == null) {
        _showErrorSnackbar('Please select a labor');
        return;
      }

      final amount = double.parse(_amountController.text.trim());
      if (amount > _selectedLabor!.remainingSalary) {
        _showErrorSnackbar('Amount cannot exceed remaining salary of PKR ${_selectedLabor!.remainingSalary.toStringAsFixed(0)}');
        return;
      }

      final advancePaymentProvider = Provider.of<AdvancePaymentProvider>(context, listen: false);

      await advancePaymentProvider.addAdvancePayment(
        laborId: _selectedLabor!.id,
        amount: amount,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        receiptImagePath: _receiptImagePath,
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
              'Advance payment added successfully!',
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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryMaroon,
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryMaroon,
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

  double get remainingAfterAdvance {
    if (_selectedLabor == null) return 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _selectedLabor!.remainingSalary - amount;
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
            child: _buildFormContent(isCompact: true),
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
            child: _buildFormContent(isCompact: true),
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
            child: _buildFormContent(isCompact: false),
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
              Icons.payment_rounded,
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
                  context.shouldShowCompactLayout ? 'Add Payment' : 'Add Advance Payment',
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
                    'Record new advance payment to labor with receipt',
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
        child: isCompact
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormFields(isCompact: true),
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildFormFields(isCompact: false),
              ),
            ),
            SizedBox(width: context.cardPadding * 1.5),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Receipt Image',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize * 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  SizedBox(height: context.smallPadding),
                  Text(
                    'Upload receipt image for this advance payment (optional)',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: context.cardPadding),
                  DesktopImageUploadWidget(
                    initialImagePath: _receiptImagePath,
                    onImageChanged: (imagePath) {
                      setState(() {
                        _receiptImagePath = imagePath;
                      });
                    },
                    label: 'Receipt Image (Optional)',
                    height: ResponsiveBreakpoints.responsive(
                      context,
                      tablet: 25.h,
                      small: 30.h,
                      medium: 35.h,
                      large: 40.h,
                      ultrawide: 45.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields({required bool isCompact}) {
    return [
      Consumer<AdvancePaymentProvider>(
        builder: (context, provider, child) {
          return DropdownButtonFormField<Labor>(
            value: _selectedLabor,
            isDense: false, // Prevents compression to ensure text visibility
            decoration: InputDecoration(
              labelText: 'Select Labor',
              labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
              prefixIcon: Icon(Icons.person_outline, size: context.iconSize('medium')),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Increased vertical padding for taller field and text visibility
            ),
            items: provider.laborers
                .map((labor) => DropdownMenuItem<Labor>(
              value: labor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${labor.name} - ${labor.role}',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Remaining: PKR ${labor.remainingSalary.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: labor.remainingSalary <= 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
            onChanged: (labor) {
              setState(() {
                _selectedLabor = labor;
              });
            },
            validator: (value) => value == null ? 'Please select a labor' : null,
          );
        },
      ),
      SizedBox(height: context.cardPadding),
      PremiumTextField(
        label: 'Advance Amount (PKR)',
        hint: isCompact ? 'Enter amount' : 'Enter advance amount (PKR)',
        controller: _amountController,
        prefixIcon: Icons.attach_money_rounded,
        keyboardType: TextInputType.number,
        onChanged: (value) => setState(() {}),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter advance amount';
          final amount = double.tryParse(value!);
          if (amount == null || amount <= 0) return 'Please enter a valid amount';
          if (_selectedLabor != null && amount > _selectedLabor!.remainingSalary) {
            return 'Amount exceeds remaining salary';
          }
          return null;
        },
      ),
      SizedBox(height: context.cardPadding),
      PremiumTextField(
        label: 'Description',
        hint: isCompact ? 'Enter reason' : 'Enter reason for advance payment',
        controller: _descriptionController,
        prefixIcon: Icons.description_outlined,
        maxLines: ResponsiveBreakpoints.responsive(
          context,
          tablet: 2,
          small: 3,
          medium: 4,
          large: 5,
          ultrawide: 6,
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter description';
          if (value!.length < 5) return 'Description must be at least 5 characters';
          return null;
        },
      ),
      SizedBox(height: context.cardPadding),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: PremiumTextField(
                label: 'Date',
                hint: 'Select date',
                controller: TextEditingController(
                    text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                prefixIcon: Icons.calendar_today,
                enabled: false,
              ),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: GestureDetector(
              onTap: _selectTime,
              child: PremiumTextField(
                label: 'Time',
                hint: 'Select time',
                controller: TextEditingController(
                    text: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                prefixIcon: Icons.access_time,
                enabled: false,
              ),
            ),
          ),
        ],
      ),
      if (_selectedLabor != null && _amountController.text.isNotEmpty) ...[
        SizedBox(height: context.cardPadding),
        Container(
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: remainingAfterAdvance < 0 ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius()),
            border: Border.all(
              color: remainingAfterAdvance < 0 ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                remainingAfterAdvance < 0 ? Icons.warning_rounded : Icons.calculate_rounded,
                color: remainingAfterAdvance < 0 ? Colors.red : Colors.blue,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Remaining: PKR ${_selectedLabor!.remainingSalary.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'After Advance: PKR ${remainingAfterAdvance.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: remainingAfterAdvance < 0 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      SizedBox(height: context.mainPadding),
      if (isCompact) ...[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Receipt Image',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize * 1.2,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.smallPadding),
            Text(
              'Upload receipt image for this advance payment (optional)',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: context.cardPadding),
            DesktopImageUploadWidget(
              initialImagePath: _receiptImagePath,
              onImageChanged: (imagePath) {
                setState(() {
                  _receiptImagePath = imagePath;
                });
              },
              label: 'Receipt Image (Optional)',
              height: ResponsiveBreakpoints.responsive(
                context,
                tablet: 25.h,
                small: 30.h,
                medium: 35.h,
                large: 40.h,
                ultrawide: 45.h,
              ),
            ),
            SizedBox(height: context.mainPadding),
            Consumer<AdvancePaymentProvider>(
              builder: (context, provider, child) {
                return PremiumButton(
                  text: 'Add Payment',
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
        ),
      ] else ...[
        Row(
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
              child: Consumer<AdvancePaymentProvider>(
                builder: (context, provider, child) {
                  return PremiumButton(
                    text: 'Add Payment',
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
        ),
      ],
    ];
  }}