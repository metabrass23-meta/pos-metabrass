import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountPaidController = TextEditingController();
  final _overallDiscountController = TextEditingController();
  final _gstController = TextEditingController();
  final _taxController = TextEditingController();
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();

  // Split Payment Controllers
  final _cashAmountController = TextEditingController();
  final _cardAmountController = TextEditingController();
  final _bankTransferAmountController = TextEditingController();

  String _selectedPaymentMethod = 'Cash';
  bool _isSplitPayment = false;
  bool _showAdvancedOptions = false;

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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Initialize with current provider values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SalesProvider>(context, listen: false);
      _amountPaidController.text = provider.cartGrandTotal.toStringAsFixed(0);
      _overallDiscountController.text = provider.overallDiscount.toStringAsFixed(0);
      _gstController.text = provider.gstPercentage.toStringAsFixed(0);
      _taxController.text = provider.taxPercentage.toStringAsFixed(0);
      _notesController.text = provider.notes;
      _selectedPaymentMethod = provider.paymentMethod;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountPaidController.dispose();
    _overallDiscountController.dispose();
    _gstController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    _cashAmountController.dispose();
    _cardAmountController.dispose();
    _bankTransferAmountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleCheckout() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<SalesProvider>(context, listen: false);

      // Update provider values
      provider.setOverallDiscount(double.tryParse(_overallDiscountController.text) ?? 0.0);
      provider.setGstPercentage(double.tryParse(_gstController.text) ?? 18.0);
      provider.setTaxPercentage(double.tryParse(_taxController.text) ?? 0.0);
      provider.setPaymentMethod(_selectedPaymentMethod);
      provider.setNotes(_notesController.text);

      final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
      String? splitPaymentDetails;

      if (_isSplitPayment) {
        final cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;
        final cardAmount = double.tryParse(_cardAmountController.text) ?? 0.0;
        final bankAmount = double.tryParse(_bankTransferAmountController.text) ?? 0.0;

        splitPaymentDetails = '{"cash": $cashAmount, "card": $cardAmount, "bank_transfer": $bankAmount}';
      }

      await provider.createSale(
        amountPaid: amountPaid,
        splitPaymentDetails: splitPaymentDetails,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _updateAmountFromSplit() {
    if (_isSplitPayment) {
      final cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;
      final cardAmount = double.tryParse(_cardAmountController.text) ?? 0.0;
      final bankAmount = double.tryParse(_bankTransferAmountController.text) ?? 0.0;
      final totalAmount = cashAmount + cardAmount + bankAmount;

      setState(() {
        _amountPaidController.text = totalAmount.toStringAsFixed(0);
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
                    medium: 85.w,
                    large: 75.w,
                    ultrawide: 65.w,
                  ),
                  maxHeight: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 95.h,
                    small: 90.h,
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
                  context.shouldShowCompactLayout ? 'Checkout' : 'Checkout & Payment',
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
                    'Complete the sale transaction',
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

          // Order Summary (Desktop only)
          if (context.shouldShowFullLayout)
            Consumer<SalesProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${provider.cartTotalItems} Items',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          color: AppTheme.pureWhite.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'PKR ${provider.cartGrandTotal.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
              _buildOrderSummaryCard(),
              SizedBox(height: context.cardPadding),
              _buildPaymentMethodCard(),
              SizedBox(height: context.cardPadding),
              if (_showAdvancedOptions) ...[
                _buildAdvancedOptionsCard(),
                SizedBox(height: context.cardPadding),
              ],
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Order Summary & Advanced Options
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildOrderSummaryCard(),
                    if (_showAdvancedOptions) ...[
                      SizedBox(height: context.cardPadding),
                      _buildAdvancedOptionsCard(),
                    ],
                  ],
                ),
              ),

              SizedBox(width: context.cardPadding),

              // Right Column - Payment & Actions
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildPaymentMethodCard(),
                    SizedBox(height: context.cardPadding),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.borderRadius()),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.blue,
                    size: context.iconSize('medium'),
                  ),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Order Summary',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.cardPadding),

              // Customer Info
              if (provider.selectedCustomer != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: Colors.grey[600],
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.selectedCustomer!.name,
                            style: GoogleFonts.inter(
                              fontSize: context.subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                          Text(
                            provider.selectedCustomer!.phone,
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
                SizedBox(height: context.smallPadding),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: context.smallPadding),
              ],

              // Items Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items (${provider.cartTotalItems})',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    'PKR ${provider.cartSubtotal.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                ],
              ),

              // Overall Discount
              if (provider.overallDiscount > 0) ...[
                SizedBox(height: context.smallPadding / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        color: Colors.orange[700],
                      ),
                    ),
                    Text(
                      '- PKR ${provider.overallDiscount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],

              // GST
              if (provider.gstPercentage > 0) ...[
                SizedBox(height: context.smallPadding / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GST (${provider.gstPercentage}%)',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'PKR ${provider.cartGstAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
              ],

              // Tax
              if (provider.taxPercentage > 0) ...[
                SizedBox(height: context.smallPadding / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax (${provider.taxPercentage}%)',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'PKR ${provider.cartTaxAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: context.smallPadding),
              Divider(color: Colors.grey.shade400, thickness: 1.5),
              SizedBox(height: context.smallPadding),

              // Grand Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total',
                    style: GoogleFonts.inter(
                      fontSize: context.headerFontSize * 0.8,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    'PKR ${provider.cartGrandTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.headerFontSize * 0.8,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryMaroon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment_rounded,
                color: Colors.green,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Payment Method',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),

          SizedBox(height: context.cardPadding),

          // Payment Method Selection
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPaymentMethod,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value ?? 'Cash';
                    _isSplitPayment = value == 'Split';
                  });
                },
                items: ['Cash', 'Card', 'Bank Transfer', 'Credit', 'Split'].map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
                      child: Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(method),
                            color: AppTheme.primaryMaroon,
                            size: context.iconSize('medium'),
                          ),
                          SizedBox(width: context.smallPadding),
                          Text(
                            method,
                            style: GoogleFonts.inter(
                              fontSize: context.bodyFontSize,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: context.cardPadding),

          // Split Payment Fields
          if (_isSplitPayment) ...[
            Text(
              'Split Payment Details',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.smallPadding),

            PremiumTextField(
              label: 'Cash Amount',
              controller: _cashAmountController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.money_rounded,
              onChanged: (value) => _updateAmountFromSplit(),
            ),
            SizedBox(height: context.smallPadding),

            PremiumTextField(
              label: 'Card Amount',
              controller: _cardAmountController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.credit_card_rounded,
              onChanged: (value) => _updateAmountFromSplit(),
            ),
            SizedBox(height: context.smallPadding),

            PremiumTextField(
              label: 'Bank Transfer Amount',
              controller: _bankTransferAmountController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.account_balance_rounded,
              onChanged: (value) => _updateAmountFromSplit(),
            ),
            SizedBox(height: context.cardPadding),
          ],

          // Amount Paid
          PremiumTextField(
            label: 'Amount Paid',
            controller: _amountPaidController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money_rounded,
            enabled: !_isSplitPayment,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter amount paid';
              final amount = double.tryParse(value!);
              if (amount == null || amount < 0) return 'Please enter a valid amount';
              return null;
            },
          ),

          // Change/Remaining Amount
          Consumer<SalesProvider>(
            builder: (context, provider, child) {
              final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
              final grandTotal = provider.cartGrandTotal;
              final difference = amountPaid - grandTotal;

              if (difference == 0) return const SizedBox.shrink();

              return Container(
                margin: EdgeInsets.only(top: context.smallPadding),
                padding: EdgeInsets.all(context.smallPadding),
                decoration: BoxDecoration(
                  color: difference > 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  border: Border.all(
                    color: difference > 0 ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      difference > 0 ? 'Change' : 'Remaining',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: difference > 0 ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    Text(
                      'PKR ${difference.abs().toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w700,
                        color: difference > 0 ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: context.cardPadding),

          // Advanced Options Toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.primaryMaroon,
                      size: context.iconSize('medium'),
                    ),
                    SizedBox(width: context.smallPadding),
                    Text(
                      _showAdvancedOptions ? 'Hide Advanced Options' : 'Show Advanced Options',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: Colors.orange,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Advanced Options',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),

          SizedBox(height: context.cardPadding),

          // Overall Discount
          PremiumTextField(
            label: 'Overall Discount (PKR)',
            controller: _overallDiscountController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.local_offer_rounded,
            onChanged: (value) {
              final provider = Provider.of<SalesProvider>(context, listen: false);
              provider.setOverallDiscount(double.tryParse(value) ?? 0.0);
            },
          ),

          SizedBox(height: context.smallPadding),

          // GST Percentage
          PremiumTextField(
            label: 'GST Percentage (%)',
            controller: _gstController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.receipt_rounded,
            onChanged: (value) {
              final provider = Provider.of<SalesProvider>(context, listen: false);
              provider.setGstPercentage(double.tryParse(value) ?? 18.0);
            },
          ),

          SizedBox(height: context.smallPadding),

          // Tax Percentage
          PremiumTextField(
            label: 'Additional Tax (%)',
            controller: _taxController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.account_balance_rounded,
            onChanged: (value) {
              final provider = Provider.of<SalesProvider>(context, listen: false);
              provider.setTaxPercentage(double.tryParse(value) ?? 0.0);
            },
          ),

          SizedBox(height: context.smallPadding),

          // Notes
          PremiumTextField(
            label: 'Notes (Optional)',
            controller: _notesController,
            prefixIcon: Icons.note_outlined,
            maxLines: 3,
            hint: 'Any special instructions or remarks...',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        if (context.shouldShowCompactLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumButton(
                text: provider.isLoading ? 'Processing...' : 'Complete Sale',
                onPressed: provider.isLoading ? null : _handleCheckout,
                isLoading: provider.isLoading,
                height: context.buttonHeight,
                icon: Icons.check_circle_rounded,
                backgroundColor: AppTheme.primaryMaroon,
              ),
              SizedBox(height: context.cardPadding),
              PremiumButton(
                text: 'Cancel',
                onPressed: provider.isLoading ? null : _handleCancel,
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
                  onPressed: provider.isLoading ? null : _handleCancel,
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
                  text: provider.isLoading ? 'Processing...' : 'Complete Sale',
                  onPressed: provider.isLoading ? null : _handleCheckout,
                  isLoading: provider.isLoading,
                  height: context.buttonHeight / 1.5,
                  icon: Icons.check_circle_rounded,
                  backgroundColor: AppTheme.primaryMaroon,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveBreakpoints.responsive(
            context,
            tablet: 85.w,
            small: 75.w,
            medium: 65.w,
            large: 55.w,
            ultrawide: 45.w,
          ),
        ),
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
            // Success Header
            Container(
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
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
                      Icons.check_circle_rounded,
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
                          'Sale Completed!',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: context.headerFontSize,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.pureWhite,
                          ),
                        ),
                        Text(
                          'Transaction processed successfully',
                          style: GoogleFonts.inter(
                            fontSize: context.subtitleFontSize,
                            color: AppTheme.pureWhite.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Success Content
            Padding(
              padding: EdgeInsets.all(context.cardPadding),
              child: Column(
                children: [
                  Consumer<SalesProvider>(
                    builder: (context, provider, child) {
                      return Container(
                        padding: EdgeInsets.all(context.cardPadding),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(context.borderRadius()),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Invoice Number:',
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    color: AppTheme.charcoalGray,
                                  ),
                                ),
                                Text(
                                  'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryMaroon,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.smallPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    color: AppTheme.charcoalGray,
                                  ),
                                ),
                                Text(
                                  'PKR ${provider.cartGrandTotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.smallPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment Method:',
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    color: AppTheme.charcoalGray,
                                  ),
                                ),
                                Text(
                                  _selectedPaymentMethod,
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.charcoalGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: context.cardPadding),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(context.borderRadius()),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Print receipt functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Print functionality to be implemented'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(context.borderRadius()),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.cardPadding / 1.5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print_rounded,
                                      color: Colors.blue,
                                      size: context.iconSize('medium'),
                                    ),
                                    SizedBox(width: context.smallPadding),
                                    Text(
                                      'Print Receipt',
                                      style: GoogleFonts.inter(
                                        fontSize: context.bodyFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.cardPadding),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
                            ),
                            borderRadius: BorderRadius.circular(context.borderRadius()),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop(); // Close success dialog
                                Navigator.of(context).pop(); // Close checkout dialog
                              },
                              borderRadius: BorderRadius.circular(context.borderRadius()),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.cardPadding / 1.5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.done_rounded,
                                      color: AppTheme.pureWhite,
                                      size: context.iconSize('medium'),
                                    ),
                                    SizedBox(width: context.smallPadding),
                                    Text(
                                      'New Sale',
                                      style: GoogleFonts.inter(
                                        fontSize: context.bodyFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.pureWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.money_rounded;
      case 'Card':
        return Icons.credit_card_rounded;
      case 'Bank Transfer':
        return Icons.account_balance_rounded;
      case 'Credit':
        return Icons.account_balance_wallet_rounded;
      case 'Split':
        return Icons.call_split_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}