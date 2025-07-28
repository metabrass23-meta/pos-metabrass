import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/payables_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class EditPayableDialog extends StatefulWidget {
  final Payable payable;

  const EditPayableDialog({
    super.key,
    required this.payable,
  });

  @override
  State<EditPayableDialog> createState() => _EditPayableDialogState();
}

class _EditPayableDialogState extends State<EditPayableDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _creditorNameController;
  late TextEditingController _creditorPhoneController;
  late TextEditingController _amountBorrowedController;
  late TextEditingController _reasonController;
  late TextEditingController _notesController;
  late TextEditingController _amountPaidController;

  late DateTime _dateBorrowed;
  late DateTime _expectedRepaymentDate;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _creditorNameController = TextEditingController(text: widget.payable.creditorName);
    _creditorPhoneController = TextEditingController(text: widget.payable.creditorPhone);
    _amountBorrowedController = TextEditingController(text: widget.payable.amountBorrowed.toString());
    _reasonController = TextEditingController(text: widget.payable.reasonOrItem);
    _notesController = TextEditingController(text: widget.payable.notes ?? '');
    _amountPaidController = TextEditingController(text: widget.payable.amountPaid.toString());
    _dateBorrowed = widget.payable.dateBorrowed;
    _expectedRepaymentDate = widget.payable.expectedRepaymentDate;

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
    _creditorNameController.dispose();
    _creditorPhoneController.dispose();
    _amountBorrowedController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      final amountBorrowed = double.parse(_amountBorrowedController.text.trim());
      final amountPaid = double.tryParse(_amountPaidController.text.trim()) ?? 0.0;

      if (amountPaid > amountBorrowed) {
        _showErrorSnackbar('Amount paid cannot exceed amount borrowed');
        return;
      }

      if (_expectedRepaymentDate.isBefore(_dateBorrowed)) {
        _showErrorSnackbar('Expected repayment date cannot be before date borrowed');
        return;
      }

      final payablesProvider = Provider.of<PayablesProvider>(context, listen: false);

      await payablesProvider.updatePayable(
        id: widget.payable.id,
        creditorName: _creditorNameController.text.trim(),
        creditorPhone: _creditorPhoneController.text.trim(),
        amountBorrowed: amountBorrowed,
        reasonOrItem: _reasonController.text.trim(),
        dateBorrowed: _dateBorrowed,
        expectedRepaymentDate: _expectedRepaymentDate,
        amountPaid: amountPaid,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
              'Payable updated successfully!',
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

  Future<void> _selectDateBorrowed() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateBorrowed,
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
    if (picked != null && picked != _dateBorrowed) {
      setState(() {
        _dateBorrowed = picked;
        if (_expectedRepaymentDate.isBefore(_dateBorrowed.add(const Duration(days: 1)))) {
          _expectedRepaymentDate = _dateBorrowed.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectExpectedRepaymentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedRepaymentDate,
      firstDate: _dateBorrowed.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null && picked != _expectedRepaymentDate) {
      setState(() {
        _expectedRepaymentDate = picked;
      });
    }
  }

  double get balanceRemaining {
    final amountBorrowed = double.tryParse(_amountBorrowedController.text) ?? 0;
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    return amountBorrowed - amountPaid;
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
                  context.shouldShowCompactLayout ? 'Edit Payable' : 'Edit Payable Details',
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
                    'Update payable information',
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
              widget.payable.id,
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
            PremiumTextField(
              label: 'Creditor Name',
              hint: isCompact ? 'Enter name' : 'Enter creditor full name',
              controller: _creditorNameController,
              prefixIcon: Icons.business_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter creditor name';
                if (value!.length < 2) return 'Name must be at least 2 characters';
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Phone Number',
              hint: isCompact ? 'Enter phone' : 'Enter phone number (+92XXXXXXXXXX)',
              controller: _creditorPhoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter phone number';
                if (value!.length < 10) return 'Please enter a valid phone number';
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    label: 'Amount Borrowed (PKR)',
                    hint: 'Enter amount',
                    controller: _amountBorrowedController,
                    prefixIcon: Icons.trending_down_rounded,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter amount';
                      final amount = double.tryParse(value!);
                      if (amount == null || amount <= 0) return 'Please enter valid amount';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: PremiumTextField(
                    label: 'Amount Paid (PKR)',
                    hint: 'Enter paid',
                    controller: _amountPaidController,
                    prefixIcon: Icons.trending_up_rounded,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final amountPaid = double.tryParse(value);
                        if (amountPaid == null || amountPaid < 0) return 'Enter valid amount';
                        final amountBorrowed = double.tryParse(_amountBorrowedController.text) ?? 0;
                        if (amountPaid > amountBorrowed) return 'Cannot exceed amount borrowed';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_amountBorrowedController.text.isNotEmpty || _amountPaidController.text.isNotEmpty) ...[
              SizedBox(height: context.cardPadding),
              Container(
                padding: EdgeInsets.all(context.cardPadding),
                decoration: BoxDecoration(
                  color: balanceRemaining >= 0 ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  border: Border.all(
                    color: balanceRemaining >= 0 ? Colors.orange.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calculate_rounded,
                      color: balanceRemaining >= 0 ? Colors.orange : Colors.red,
                      size: context.iconSize('medium'),
                    ),
                    SizedBox(width: context.smallPadding),
                    Expanded(
                      child: Text(
                        'Balance Remaining: PKR ${balanceRemaining.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: balanceRemaining >= 0 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Reason/Item',
              hint: isCompact ? 'Reason for borrowing' : 'Enter reason for borrowing or item description',
              controller: _reasonController,
              prefixIcon: Icons.assignment_outlined,
              maxLines: ResponsiveBreakpoints.responsive(
                context,
                tablet: 2,
                small: 3,
                medium: 4,
                large: 5,
                ultrawide: 6,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter reason or item';
                if (value!.length < 5) return 'Please provide more details';
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Notes (Optional)',
              hint: isCompact ? 'Additional notes' : 'Enter additional notes or terms',
              controller: _notesController,
              prefixIcon: Icons.note_outlined,
              maxLines: ResponsiveBreakpoints.responsive(
                context,
                tablet: 3,
                small: 3,
                medium: 4,
                large: 4,
                ultrawide: 4,
              ),
            ),
            SizedBox(height: context.cardPadding),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDateBorrowed,
                    child: PremiumTextField(
                      label: 'Date Borrowed',
                      hint: 'Select date',
                      controller: TextEditingController(
                          text: '${_dateBorrowed.day}/${_dateBorrowed.month}/${_dateBorrowed.year}'),
                      prefixIcon: Icons.calendar_today,
                      enabled: false,
                    ),
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectExpectedRepaymentDate,
                    child: PremiumTextField(
                      label: 'Expected Repayment Date',
                      hint: 'Select date',
                      controller: TextEditingController(
                          text: '${_expectedRepaymentDate.day}/${_expectedRepaymentDate.month}/${_expectedRepaymentDate.year}'),
                      prefixIcon: Icons.event_available,
                      enabled: false,
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
        Consumer<PayablesProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Update Payable',
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
          child: Consumer<PayablesProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update Payable',
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