import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class EditPaymentDialog extends StatefulWidget {
  final Payment payment;

  const EditPaymentDialog({
    super.key,
    required this.payment,
  });

  @override
  State<EditPaymentDialog> createState() => _EditPaymentDialogState();
}

class _EditPaymentDialogState extends State<EditPaymentDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _bonusController;
  late TextEditingController _deductionController;
  late TextEditingController _descriptionController;

  late String _selectedLaborId;
  late String _selectedPaymentMethod;
  late String _selectedPaymentMonth;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isFinalPayment;
  String? _receiptImagePath;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.payment.amountPaid.toString());
    _bonusController = TextEditingController(text: widget.payment.bonus > 0 ? widget.payment.bonus.toString() : '');
    _deductionController = TextEditingController(text: widget.payment.deduction > 0 ? widget.payment.deduction.toString() : '');
    _descriptionController = TextEditingController(text: widget.payment.description);
    _selectedLaborId = widget.payment.laborId;
    _selectedPaymentMethod = widget.payment.paymentMethod;
    _selectedPaymentMonth = widget.payment.paymentMonth;
    _selectedDate = widget.payment.date;
    _selectedTime = widget.payment.time;
    _isFinalPayment = widget.payment.isFinalPayment;
    _receiptImagePath = widget.payment.receiptImagePath;

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
    _amountController.dispose();
    _bonusController.dispose();
    _deductionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      final selectedLabor = provider.laborers.firstWhere(
            (labor) => labor.id == _selectedLaborId,
        orElse: () => provider.laborers.first,
      );

      final amount = double.parse(_amountController.text.trim());
      final bonus = double.tryParse(_bonusController.text.trim()) ?? 0.0;
      final deduction = double.tryParse(_deductionController.text.trim()) ?? 0.0;
      final netAmount = amount + bonus - deduction;

      // Calculate available amount considering the current payment being edited
      final availableAmount = selectedLabor.remainingAmount +
          (selectedLabor.id == widget.payment.laborId ? widget.payment.netAmount : 0);

      if (netAmount > availableAmount && !_isFinalPayment) {
        _showErrorSnackbar('Net amount cannot exceed available amount of PKR ${availableAmount.toStringAsFixed(0)}');
        return;
      }

      await provider.updatePayment(
        id: widget.payment.id,
        laborId: _selectedLaborId,
        amountPaid: amount,
        bonus: bonus,
        deduction: deduction,
        paymentMonth: _selectedPaymentMonth,
        isFinalPayment: _isFinalPayment,
        paymentMethod: _selectedPaymentMethod,
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
              'Payment updated successfully!',
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

  void _selectReceiptImage() {
    setState(() {
      _receiptImagePath = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt image selected'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeReceiptImage() {
    setState(() {
      _receiptImagePath = null;
    });
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
              Icons.edit_outlined,
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
                  context.shouldShowCompactLayout ? 'Edit Payment' : 'Edit Payment Details',
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
                    'Update payment information',
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
              widget.payment.id,
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
            Consumer<PaymentProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedLaborId,
                  isDense: false,
                  decoration: InputDecoration(
                    labelText: 'Labor',
                    labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
                    prefixIcon: Icon(Icons.person_outline, size: context.iconSize('medium')),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsiveBreakpoints.responsive(
                        context,
                        tablet: 20,
                        small: 22,
                        medium: 24,
                        large: 26,
                        ultrawide: 28,
                      ),
                      horizontal: 16,
                    ),
                  ),
                  items: provider.laborers
                      .map((labor) => DropdownMenuItem<String>(
                    value: labor.id,
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
                          'Available: PKR ${(labor.remainingAmount + (labor.id == widget.payment.laborId ? widget.payment.netAmount : 0)).toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: context.captionFontSize,
                            color: labor.remainingAmount <= 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (laborId) {
                    setState(() => _selectedLaborId = laborId!);
                  },
                  validator: (value) => value == null ? 'Please select a labor' : null,
                );
              },
            ),
            SizedBox(height: context.cardPadding),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentMonth,
                    decoration: InputDecoration(
                      labelText: 'Payment Month',
                      labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
                      prefixIcon: Icon(Icons.calendar_month, size: context.iconSize('medium')),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                      ),
                    ),
                    items: _generatePaymentMonths().map((month) => DropdownMenuItem<String>(
                      value: month,
                      child: Text(month, style: GoogleFonts.inter(fontSize: context.bodyFontSize)),
                    )).toList(),
                    onChanged: (month) {
                      setState(() {
                        _selectedPaymentMonth = month!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select payment month' : null,
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize),
                      prefixIcon: Icon(Icons.payment, size: context.iconSize('medium')),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                      ),
                    ),
                    items: PaymentProvider.paymentMethods.map((method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method, style: GoogleFonts.inter(fontSize: context.bodyFontSize)),
                    )).toList(),
                    onChanged: (method) {
                      setState(() {
                        _selectedPaymentMethod = method!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select payment method' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Payment Amount',
              hint: isCompact ? 'Enter amount' : 'Enter payment amount (PKR)',
              controller: _amountController,
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter amount';
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) return 'Please enter a valid amount';
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    label: 'Bonus (PKR)',
                    hint: 'Optional bonus',
                    controller: _bonusController,
                    prefixIcon: Icons.star_outline,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final bonus = double.tryParse(value);
                        if (bonus == null || bonus < 0) return 'Enter valid bonus';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: PremiumTextField(
                    label: 'Deduction (PKR)',
                    hint: 'Optional deduction',
                    controller: _deductionController,
                    prefixIcon: Icons.remove_circle_outline,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final deduction = double.tryParse(value);
                        if (deduction == null || deduction < 0) return 'Enter valid deduction';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_amountController.text.isNotEmpty ||
                _bonusController.text.isNotEmpty ||
                _deductionController.text.isNotEmpty) ...[
              SizedBox(height: context.cardPadding),
              Container(
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
                      child: Text(
                        'Net Amount: PKR ${netAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: netAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Description',
              hint: isCompact ? 'Enter notes' : 'Enter payment description or notes',
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
            SizedBox(height: context.cardPadding),
            Container(
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
            ),
            SizedBox(height: context.cardPadding),
            Container(
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
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
                  SizedBox(height: context.smallPadding),
                  if (_receiptImagePath == null) ...[
                    GestureDetector(
                      onTap: _selectReceiptImage,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(context.cardPadding),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(context.borderRadius()),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: context.iconSize('xl'),
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: context.smallPadding),
                            Text(
                              'Tap to select receipt image',
                              style: GoogleFonts.inter(
                                fontSize: context.bodyFontSize,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(context.cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_rounded,
                            color: Colors.green,
                            size: context.iconSize('medium'),
                          ),
                          SizedBox(width: context.smallPadding),
                          Expanded(
                            child: Text(
                              'Receipt image selected',
                              style: GoogleFonts.inter(
                                fontSize: context.bodyFontSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _removeReceiptImage,
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                              size: context.iconSize('small'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
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
        Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Update Payment',
              onPressed: provider.isLoading ? null : _handleUpdate,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.save_rounded,
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
          child: Consumer<PaymentProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update Payment',
                onPressed: provider.isLoading ? null : _handleUpdate,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.save_rounded,
                backgroundColor: AppTheme.primaryMaroon,
              );
            },
          ),
        ),
      ],
    );
  }
}