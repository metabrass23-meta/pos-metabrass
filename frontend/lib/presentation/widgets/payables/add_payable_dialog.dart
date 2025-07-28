import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/payables_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class AddPayableDialog extends StatefulWidget {
  const AddPayableDialog({super.key});

  @override
  State<AddPayableDialog> createState() => _AddPayableDialogState();
}

class _AddPayableDialogState extends State<AddPayableDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _creditorNameController = TextEditingController();
  final _creditorPhoneController = TextEditingController();
  final _amountBorrowedController = TextEditingController();
  final _reasonOrItemController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _scrollController = ScrollController();

  DateTime _dateBorrowed = DateTime.now();
  DateTime _expectedRepaymentDate = DateTime.now().add(const Duration(days: 30));

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
    _creditorNameController.dispose();
    _creditorPhoneController.dispose();
    _amountBorrowedController.dispose();
    _reasonOrItemController.dispose();
    _notesController.dispose();
    _amountPaidController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
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

      await payablesProvider.addPayable(
        creditorName: _creditorNameController.text.trim(),
        creditorPhone: _creditorPhoneController.text.trim(),
        amountBorrowed: amountBorrowed,
        reasonOrItem: _reasonOrItemController.text.trim(),
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
              'Payable added successfully!',
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
                  context.shouldShowCompactLayout ? 'Add Payable' : 'Add New Payable',
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
                    'Record amount owed to creditor',
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
              _buildCreditorInfoCard(),
              SizedBox(height: context.cardPadding),
              _buildAmountCard(),
              SizedBox(height: context.cardPadding),
              _buildDetailsCard(),
              SizedBox(height: context.cardPadding),
              _buildDatesCard(),
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
              _buildCreditorInfoCard(),
              SizedBox(height: context.cardPadding),
              _buildAmountCard(),
              SizedBox(height: context.cardPadding),
              _buildDetailsCard(),
              SizedBox(height: context.cardPadding),
              _buildDatesCard(),
              SizedBox(height: context.mainPadding),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditorInfoCard() {
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
                'Creditor Information',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Creditor Name',
            hint: context.shouldShowCompactLayout ? 'Enter name' : 'Enter creditor full name',
            controller: _creditorNameController,
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter creditor name';
              if (value!.length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Phone Number',
            hint: context.shouldShowCompactLayout ? 'Enter phone' : 'Enter phone number (+92XXXXXXXXXX)',
            controller: _creditorPhoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter phone number';
              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value!)) return 'Please enter a valid phone number';
              return null;
            },
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
                'Amount Details',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Amount Borrowed (PKR)',
            hint: context.shouldShowCompactLayout ? 'Enter amount' : 'Enter amount borrowed from creditor',
            controller: _amountBorrowedController,
            prefixIcon: Icons.trending_up_rounded,
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter amount borrowed';
              final amount = double.tryParse(value!);
              if (amount == null || amount <= 0) return 'Please enter a valid amount';
              return null;
            },
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Amount Paid (PKR)',
            hint: 'Optional - if any amount already paid',
            controller: _amountPaidController,
            prefixIcon: Icons.trending_down_rounded,
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final amountPaid = double.tryParse(value);
                if (amountPaid == null || amountPaid < 0) return 'Please enter a valid amount';
                final amountBorrowed = double.tryParse(_amountBorrowedController.text) ?? 0;
                if (amountPaid > amountBorrowed) return 'Cannot exceed amount borrowed';
              }
              return null;
            },
          ),
          if (_amountBorrowedController.text.isNotEmpty || _amountPaidController.text.isNotEmpty) ...[
            SizedBox(height: context.cardPadding),
            _buildBalancePreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
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
                'Transaction Details',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Reason/Item',
            hint: context.shouldShowCompactLayout ? 'Reason for borrowing' : 'Enter reason for borrowing or item description',
            controller: _reasonOrItemController,
            prefixIcon: Icons.assignment_outlined,
            maxLines: ResponsiveBreakpoints.responsive(
              context,
              tablet: 2,
              small: 2,
              medium: 3,
              large: 3,
              ultrawide: 3,
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
            hint: context.shouldShowCompactLayout ? 'Additional notes' : 'Enter additional notes or terms',
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
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
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
                Icons.calendar_today_outlined,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Date Information',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
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
                      text: '${_dateBorrowed.day}/${_dateBorrowed.month}/${_dateBorrowed.year}',
                    ),
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
                      text: '${_expectedRepaymentDate.day}/${_expectedRepaymentDate.month}/${_expectedRepaymentDate.year}',
                    ),
                    prefixIcon: Icons.event_available,
                    enabled: false,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildDateInfoRow(),
        ],
      ),
    );
  }

  Widget _buildBalancePreview() {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Remaining',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  'PKR ${balanceRemaining.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: balanceRemaining >= 0 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoRow() {
    final daysDifference = _expectedRepaymentDate.difference(_dateBorrowed).inDays;
    return Container(
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: context.iconSize('small'),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            child: Text(
              daysDifference > 0
                  ? 'Borrowing period: $daysDifference days'
                  : 'Please select a valid repayment date',
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                color: daysDifference > 0 ? Colors.blue[700] : Colors.red[700],
              ),
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
          Consumer<PayablesProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Add Payable',
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
            child: Consumer<PayablesProvider>(
              builder: (context, provider, child) {
                return PremiumButton(
                  text: 'Add Payable',
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