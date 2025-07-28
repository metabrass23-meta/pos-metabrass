import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/image_upload.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bonusController = TextEditingController();
  final _deductionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  PaymentLabor? _selectedLabor;
  String? _selectedPaymentMethod;
  String? _selectedPaymentMonth;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isFinalPayment = false;
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

    // Initialize payment month with current month
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    _selectedPaymentMonth = '${months[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _bonusController.dispose();
    _deductionController.dispose();
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

      if (_selectedPaymentMethod == null) {
        _showErrorSnackbar('Please select a payment method');
        return;
      }

      if (_selectedPaymentMonth == null) {
        _showErrorSnackbar('Please select a payment month');
        return;
      }

      final amount = double.parse(_amountController.text.trim());
      final bonus = double.tryParse(_bonusController.text.trim()) ?? 0.0;
      final deduction = double.tryParse(_deductionController.text.trim()) ?? 0.0;
      final netAmount = amount + bonus - deduction;

      if (netAmount > _selectedLabor!.remainingAmount && !_isFinalPayment) {
        _showErrorSnackbar('Net amount cannot exceed remaining amount of PKR ${_selectedLabor!.remainingAmount.toStringAsFixed(0)}');
        return;
      }

      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

      await paymentProvider.addPayment(
        laborId: _selectedLabor!.id,
        amountPaid: amount,
        bonus: bonus,
        deduction: deduction,
        paymentMonth: _selectedPaymentMonth!,
        isFinalPayment: _isFinalPayment,
        paymentMethod: _selectedPaymentMethod!,
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
              'Payment added successfully!',
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
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

  List<String> _generatePaymentMonths() {
    final List<String> months = [];
    final now = DateTime.now();
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    // Add current year months
    for (int i = 0; i < 12; i++) {
      months.add('${monthNames[i]} ${now.year}');
    }

    // Add next year months
    for (int i = 0; i < 12; i++) {
      months.add('${monthNames[i]} ${now.year + 1}');
    }

    return months;
  }

  double get netAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final bonus = double.tryParse(_bonusController.text) ?? 0;
    final deduction = double.tryParse(_deductionController.text) ?? 0;
    return amount + bonus - deduction;
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
                  maxHeight: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 90.h,
                    small: 95.h,
                    medium: 85.h,
                    large: 80.h,
                    ultrawide: 75.h,
                  ),
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
                    Flexible(
                      child: ResponsiveBreakpoints.responsive(
                        context,
                        tablet: _buildScrollableContent(),
                        small: _buildScrollableContent(),
                        medium: _buildDesktopLayout(),
                        large: _buildDesktopLayout(),
                        ultrawide: _buildDesktopLayout(),
                      ),
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
              Icons.payments_rounded,
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
                  context.shouldShowCompactLayout ? 'Add Payment' : 'Add Labor Payment',
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
                    'Record new payment to labor with receipt',
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

  Widget _buildScrollableContent() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoCard(),
              SizedBox(height: context.cardPadding),
              _buildAmountCard(),
              SizedBox(height: context.cardPadding),
              _buildPaymentDetailsCard(),
              SizedBox(height: context.cardPadding),
              _buildReceiptCard(),
              SizedBox(height: context.mainPadding),
              _buildActionButtons(),
            ],
          ),
        ),
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
              _buildBasicInfoCard(),
              SizedBox(height: context.cardPadding),
              _buildAmountCard(),
              SizedBox(height: context.cardPadding),
              _buildPaymentDetailsCard(),
              SizedBox(height: context.cardPadding),
              _buildReceiptCard(),
              SizedBox(height: context.mainPadding),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Basic Information',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildLaborSelection(),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(child: _buildPaymentMonthSelection()),
              SizedBox(width: context.cardPadding),
              Expanded(child: _buildPaymentMethodSelection()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Payment Amount',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildAmountField(),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(child: _buildBonusField()),
              SizedBox(width: context.cardPadding),
              Expanded(child: _buildDeductionField()),
            ],
          ),
          if (_amountController.text.isNotEmpty ||
              _bonusController.text.isNotEmpty ||
              _deductionController.text.isNotEmpty) ...[
            SizedBox(height: context.cardPadding),
            _buildNetAmountPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Payment Details',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildDescriptionField(),
          SizedBox(height: context.cardPadding),
          _buildDateTimeFields(),
          SizedBox(height: context.cardPadding),
          _buildFinalPaymentToggle(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_rounded,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt Image (Optional)',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'Upload receipt image for better record keeping',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildResponsiveImageUpload(),
        ],
      ),
    );
  }

  Widget _buildLaborSelection() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<PaymentLabor>(
          value: _selectedLabor,
          isDense: false,
          decoration: InputDecoration(
            labelText: 'Select Labor',
            labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
            prefixIcon: Icon(Icons.person_outline, size: context.iconSize('medium')),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.borderRadius()),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: ResponsiveBreakpoints.responsive(
                context,
                tablet: 16,
                small: 18,
                medium: 20,
                large: 22,
                ultrawide: 24,
              ),
              horizontal: 16,
            ),
          ),
          items: provider.laborers.map((labor) => DropdownMenuItem<PaymentLabor>(
            value: labor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.smallPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${labor.name} - ${labor.role}',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Remaining: PKR ${labor.remainingAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: labor.remainingAmount <= 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
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

  Widget _buildPaymentMonthSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMonth,
      decoration: InputDecoration(
        labelText: 'Payment Month',
        labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
        prefixIcon: Icon(Icons.calendar_month, size: context.iconSize('medium')),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: ResponsiveBreakpoints.responsive(
            context,
            tablet: 16,
            small: 18,
            medium: 20,
            large: 22,
            ultrawide: 24,
          ),
          horizontal: 16,
        ),
      ),
      items: _generatePaymentMonths().map((month) => DropdownMenuItem<String>(
        value: month,
        child: Text(
          month,
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
      onChanged: (month) {
        setState(() {
          _selectedPaymentMonth = month;
        });
      },
      validator: (value) => value == null ? 'Please select payment month' : null,
    );
  }

  Widget _buildPaymentMethodSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethod,
      decoration: InputDecoration(
        labelText: 'Payment Method',
        labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
        prefixIcon: Icon(Icons.payment, size: context.iconSize('medium')),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: ResponsiveBreakpoints.responsive(
            context,
            tablet: 16,
            small: 18,
            medium: 20,
            large: 22,
            ultrawide: 24,
          ),
          horizontal: 16,
        ),
      ),
      items: PaymentProvider.paymentMethods.map((method) => DropdownMenuItem<String>(
        value: method,
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: _getPaymentMethodColor(method),
              size: context.iconSize('small'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              method,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )).toList(),
      onChanged: (method) {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      validator: (value) => value == null ? 'Please select payment method' : null,
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank transfer':
        return Icons.account_balance_rounded;
      case 'jazzcash':
      case 'easypaisa':
      case 'sadapay':
        return Icons.phone_android_rounded;
      case 'check':
        return Icons.receipt_long_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank transfer':
        return Colors.blue;
      case 'jazzcash':
      case 'easypaisa':
        return Colors.purple;
      case 'sadapay':
        return Colors.orange;
      case 'check':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAmountField() {
    return PremiumTextField(
      label: 'Payment Amount (PKR)',
      hint: context.shouldShowCompactLayout ? 'Enter amount' : 'Enter payment amount (PKR)',
      controller: _amountController,
      prefixIcon: Icons.attach_money_rounded,
      keyboardType: TextInputType.number,
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter payment amount';
        final amount = double.tryParse(value!);
        if (amount == null || amount <= 0) return 'Please enter a valid amount';
        return null;
      },
    );
  }

  Widget _buildBonusField() {
    return PremiumTextField(
      label: 'Bonus (PKR)',
      hint: 'Optional bonus',
      controller: _bonusController,
      prefixIcon: Icons.star_outline,
      keyboardType: TextInputType.number,
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final bonus = double.tryParse(value);
          if (bonus == null || bonus < 0) return 'Please enter a valid bonus amount';
        }
        return null;
      },
    );
  }

  Widget _buildDeductionField() {
    return PremiumTextField(
      label: 'Deduction (PKR)',
      hint: 'Optional deduction',
      controller: _deductionController,
      prefixIcon: Icons.remove_circle_outline,
      keyboardType: TextInputType.number,
      onChanged: (value) => setState(() {}),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final deduction = double.tryParse(value);
          if (deduction == null || deduction < 0) return 'Please enter a valid deduction amount';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return PremiumTextField(
      label: 'Description',
      hint: context.shouldShowCompactLayout ? 'Enter notes' : 'Enter payment description or notes',
      controller: _descriptionController,
      prefixIcon: Icons.description_outlined,
      maxLines: ResponsiveBreakpoints.responsive(
        context,
        tablet: 2,
        small: 3,
        medium: 3,
        large: 4,
        ultrawide: 4,
      ),
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
            onTap: _selectDate,
            child: PremiumTextField(
              label: 'Date',
              hint: 'Select date',
              controller: TextEditingController(
                text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
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
                text: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              ),
              prefixIcon: Icons.access_time,
              enabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalPaymentToggle() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: _isFinalPayment ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: _isFinalPayment ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isFinalPayment ? Icons.check_circle : Icons.radio_button_unchecked,
            color: _isFinalPayment ? Colors.green : Colors.grey,
            size: context.iconSize('medium'),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Payment for Month',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: _isFinalPayment ? Colors.green : AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  _isFinalPayment
                      ? 'This completes the payment for the selected month'
                      : 'Mark this as the final payment for the month',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    color: _isFinalPayment ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isFinalPayment,
            onChanged: (value) {
              setState(() {
                _isFinalPayment = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildNetAmountPreview() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: netAmount >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: netAmount >= 0 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calculate_rounded,
            color: netAmount >= 0 ? Colors.green : Colors.red,
            size: context.iconSize('medium'),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Payment Amount',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  'PKR ${netAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: netAmount >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                if (_selectedLabor != null) ...[
                  Text(
                    'Remaining after payment: PKR ${(_selectedLabor!.remainingAmount - netAmount).toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveImageUpload() {
    return Container(
      height: ResponsiveBreakpoints.responsive(
        context,
        tablet: 35.h,
        small: 40.h,
        medium: 45.h,
        large: 50.h,
        ultrawide: 55.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ResponsiveImageUploadWidget(
        initialImagePath: _receiptImagePath,
        onImageChanged: (imagePath) {
          setState(() {
            _receiptImagePath = imagePath;
          });
        },
        label: 'Payment Receipt (Optional)',
        context: context,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (context.shouldShowCompactLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<PaymentProvider>(
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
            child: Consumer<PaymentProvider>(
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
      );
    }
  }
}