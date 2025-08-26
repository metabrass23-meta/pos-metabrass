import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import '../../../src/models/labor/labor_model.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../widgets/globals/image_upload_widget.dart';
import '../../widgets/globals/text_button.dart';
import '../../widgets/globals/text_field.dart';
import '../../widgets/globals/drop_down.dart';
import '../../widgets/globals/custom_date_picker.dart';

class AddAdvancePaymentDialog extends StatefulWidget {
  const AddAdvancePaymentDialog({super.key});

  @override
  State<AddAdvancePaymentDialog> createState() => _AddAdvancePaymentDialogState();
}

class _AddAdvancePaymentDialogState extends State<AddAdvancePaymentDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  LaborModel? _selectedLabor;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _receiptImageFile;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Load laborers when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final laborProvider = Provider.of<LaborProvider>(context, listen: false);
      laborProvider.loadLabors();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedLabor == null) {
        _showErrorSnackbar('Please select a labor');
        return;
      }

      final amount = double.parse(_amountController.text.trim());
      if (amount > _selectedLabor!.remainingAdvanceAmount) {
        _showErrorSnackbar(
          'Amount cannot exceed remaining advance amount of PKR ${_selectedLabor!.remainingAdvanceAmount.toStringAsFixed(0)}. Total advances this month: PKR ${_selectedLabor!.totalAdvancesAmount.toStringAsFixed(0)}',
        );
        return;
      }

      final advancePaymentProvider = Provider.of<AdvancePaymentProvider>(context, listen: false);

      // Show loading state
      setState(() {
        _isSubmitting = true;
      });

      try {
        final success = await advancePaymentProvider.addAdvancePayment(
          laborId: _selectedLabor!.id,
          amount: amount,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          time: _selectedTime,
          receiptImageFile: _receiptImageFile,
        );

        if (mounted) {
          if (success) {
            _showSuccessSnackbar();
            Navigator.of(context).pop();
          } else {
            // Error message will be shown by the provider
            _showErrorSnackbar(advancePaymentProvider.errorMessage ?? 'Failed to add advance payment');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar('An unexpected error occurred: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Advance payment added successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }

  void _onImageChanged(File? imageFile) {
    setState(() {
      _receiptImageFile = imageFile;
    });
  }

  void _selectDateTime() {
    context.showSyncfusionDateTimePicker(
      initialDate: _selectedDate,
      initialTime: _selectedTime,
      onDateTimeSelected: (date, time) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      },
      title: 'Select Date & Time',
      showTimeInline: true,
    );
  }

  double get remainingAfterAdvance {
    if (_selectedLabor == null) return 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    // Calculate remaining advance amount after this advance
    return _selectedLabor!.remainingAdvanceAmount - amount;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
          body: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: context.dialogWidth,
              constraints: BoxConstraints(
                maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 95.w, small: 85.w, medium: 75.w, large: 65.w, ultrawide: 55.w),
                maxHeight: 85.h,
              ),
              margin: EdgeInsets.all(context.mainPadding),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(context.borderRadius('large')),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: context.shadowBlur('heavy'),
                    offset: Offset(0, context.cardPadding),
                  ),
                ],
              ),
              transform: Matrix4.identity()
                ..scale(_scaleAnimation.value)
                ..translate(0.0, 0.0),
              transformAlignment: Alignment.center,
              child: ResponsiveBreakpoints.responsive(
                context,
                tablet: _buildDesktopLayout(),
                small: _buildDesktopLayout(),
                medium: _buildDesktopLayout(),
                large: _buildDesktopLayout(),
                ultrawide: _buildDesktopLayout(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormFieldsCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: context.shadowBlur('light'), offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.edit_document, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Payment Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Form Fields
          _buildLaborSelection(),
          SizedBox(height: context.cardPadding),
          _buildAmountField(),
          SizedBox(height: context.cardPadding),
          _buildDescriptionField(),
          SizedBox(height: context.cardPadding),
          _buildDateTimeFields(),

          // Calculation Preview
          if (_selectedLabor != null && _amountController.text.isNotEmpty) ...[SizedBox(height: context.cardPadding), _buildCalculationPreview()],
        ],
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: context.shadowBlur('light'), offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.receipt_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt Image (Optional)',
                      style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                    ),
                    Text(
                      'Upload receipt image for better record keeping',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Receipt Upload Widget
          ImageUploadWidget(
            initialImagePath: null, // No initial image for new payments
            onImageChanged: _onImageChanged,
            label: 'Receipt Image (Optional)',
            isRequired: false,
            maxHeight: 200,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
            maxFileSizeMB: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form Fields Section
              _buildFormFieldsCard(),
              SizedBox(height: context.cardPadding),

              // Receipt Section - Full Width Below Fields
              _buildReceiptCard(),
              SizedBox(height: context.mainPadding),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaborSelection() {
    return Consumer<LaborProvider>(
      builder: (context, provider, child) {
        return PremiumDropdownField<LaborModel>(
          label: 'Select Labor',
          hint: 'Select a labor',
          prefixIcon: Icons.person_outline,
          items: provider.labors.map((labor) => DropdownItem<LaborModel>(value: labor, label: '${labor.name} (${labor.designation})')).toList(),
          value: _selectedLabor,
          onChanged: (labor) {
            setState(() {
              _selectedLabor = labor;
            });
          },
          validator: (value) => value == null ? 'Please select a labor' : null,
        );
      },
    );
  }

  Widget _buildAmountField() {
    return PremiumTextField(
      label: 'Advance Amount (PKR)',
      hint: context.shouldShowCompactLayout ? 'Enter amount' : 'Enter advance amount (PKR)',
      controller: _amountController,
      prefixIcon: Icons.attach_money_rounded,
      keyboardType: TextInputType.number,
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter advance amount';
        final amount = double.tryParse(value!);
        if (amount == null || amount <= 0) return 'Please enter a valid amount';
        if (_selectedLabor != null && amount > _selectedLabor!.remainingMonthlySalary) {
          return 'Amount exceeds remaining monthly salary';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return PremiumTextField(
      label: 'Description',
      hint: context.shouldShowCompactLayout ? 'Enter reason' : 'Enter reason for advance payment',
      controller: _descriptionController,
      prefixIcon: Icons.description_outlined,
      maxLines: ResponsiveBreakpoints.responsive(context, tablet: 2, small: 3, medium: 3, large: 4, ultrawide: 4),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter description';
        if (value!.length < 5) return 'Description must be at least 5 characters';
        return null;
      },
    );
  }

  Widget _buildDateTimeFields() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDateTime,
            child: PremiumTextField(
              label: 'Date & Time',
              hint: 'Select date & time',
              controller: TextEditingController(
                text:
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              ),
              prefixIcon: Icons.calendar_today,
              enabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationPreview() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: remainingAfterAdvance < 0 ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: remainingAfterAdvance < 0 ? Colors.red.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                remainingAfterAdvance < 0 ? Icons.warning_rounded : Icons.calculate_rounded,
                color: remainingAfterAdvance < 0 ? Colors.red : Colors.blue,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Text(
                  'Salary Calculation',
                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          _buildSalaryInfoRow('Original Salary', 'PKR ${_selectedLabor!.salary.toStringAsFixed(0)}', Colors.green),
          _buildSalaryInfoRow(
            'Current Month Advances',
            'PKR ${(_selectedLabor!.salary - _selectedLabor!.remainingMonthlySalary).toStringAsFixed(0)}',
            Colors.orange,
          ),
          _buildSalaryInfoRow('Remaining for Month', 'PKR ${_selectedLabor!.remainingMonthlySalary.toStringAsFixed(0)}', Colors.blue),
          Divider(color: Colors.grey.shade300, height: context.cardPadding),
          _buildSalaryInfoRow('New Advance', 'PKR ${double.tryParse(_amountController.text)?.toStringAsFixed(0) ?? '0.00'}', AppTheme.primaryMaroon),
          _buildSalaryInfoRow(
            'After Advance',
            'PKR ${remainingAfterAdvance.toStringAsFixed(0)}',
            remainingAfterAdvance < 0 ? Colors.red : Colors.green,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryInfoRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.smallPadding / 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: color),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (context.shouldShowCompactLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumButton(
            text: 'Add Payment',
            onPressed: _isSubmitting ? null : _handleSubmit,
            isLoading: _isSubmitting,
            height: context.buttonHeight,
            icon: Icons.add_rounded,
            backgroundColor: AppTheme.primaryMaroon,
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
    } else {
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
            child: PremiumButton(
              text: 'Add Payment',
              onPressed: _isSubmitting ? null : _handleSubmit,
              isLoading: _isSubmitting,
              height: context.buttonHeight / 1.5,
              icon: Icons.add_rounded,
              backgroundColor: AppTheme.primaryMaroon,
            ),
          ),
        ],
      );
    }
  }
}
