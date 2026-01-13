import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final String saleId;
  final String invoiceNumber;
  final String customerName;
  final double grandTotal;
  final double amountPaid;
  final String currentStatus;
  final Function(bool success)? onPaymentConfirmed;

  const PaymentConfirmationDialog({
    super.key,
    required this.saleId,
    required this.invoiceNumber,
    required this.customerName,
    required this.grandTotal,
    required this.amountPaid,
    required this.currentStatus,
    this.onPaymentConfirmed,
  });

  @override
  State<PaymentConfirmationDialog> createState() => _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'CASH';
  bool _isLoading = false;
  bool _isPartialPayment = false;
  Map<String, dynamic>? _workflowSummary;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Initialize amount controller with remaining amount
    final remainingAmount = widget.grandTotal - widget.amountPaid;
    _amountController.text = remainingAmount.toStringAsFixed(2);
    _isPartialPayment = remainingAmount < widget.grandTotal;

    // Load workflow summary
    _loadWorkflowSummary();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkflowSummary() async {
    final provider = Provider.of<SalesProvider>(context, listen: false);
    final summary = await provider.getPaymentWorkflowSummary(widget.saleId);
    if (mounted) {
      setState(() {
        _workflowSummary = summary;
      });
    }
  }

  void _handlePaymentConfirmation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<SalesProvider>(context, listen: false);
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final reference = _referenceController.text.trim();
      final notes = _notesController.text.trim();

      // Validate payment amount
      if (!provider.validatePaymentWorkflowData(
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        saleTotal: widget.grandTotal,
        previousAmountPaid: widget.amountPaid,
      )) {
        _showErrorDialog('Invalid payment amount. Please check the amount and try again.');
        return;
      }

      // Process payment workflow
      final success = await provider.confirmPaymentWorkflow(
        saleId: widget.saleId,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        reference: reference.isNotEmpty ? reference : null,
        notes: notes.isNotEmpty ? notes : null,
        isPartialPayment: _isPartialPayment,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog('Payment processing failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('An error occurred: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Text('Payment Confirmed', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Payment has been processed successfully!'), SizedBox(height: 16), _buildPaymentSummary()],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close success dialog
              Navigator.of(context).pop(); // Close payment dialog
              widget.onPaymentConfirmed?.call(true);
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text('Payment Error', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final remainingAmount = widget.grandTotal - widget.amountPaid;
    final newAmountPaid = widget.amountPaid + (double.tryParse(_amountController.text) ?? 0.0);
    final newRemainingAmount = widget.grandTotal - newAmountPaid;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 12),
          _buildSummaryRow('Invoice:', widget.invoiceNumber),
          _buildSummaryRow('Customer:', widget.customerName),
          _buildSummaryRow('Grand Total:', 'PKR ${widget.grandTotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Previously Paid:', 'PKR ${widget.amountPaid.toStringAsFixed(2)}'),
          _buildSummaryRow('This Payment:', 'PKR ${_amountController.text}'),
          Divider(height: 16),
          _buildSummaryRow(
            'New Balance:',
            'PKR ${newRemainingAmount.toStringAsFixed(2)}',
            isBold: true,
            color: newRemainingAmount > 0 ? Colors.orange : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.w600 : FontWeight.w500, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.w600 : FontWeight.w500, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowProgress() {
    if (_workflowSummary == null) return SizedBox.shrink();

    final progress = Provider.of<SalesProvider>(context, listen: false).getPaymentWorkflowProgress(_workflowSummary!);
    final isComplete = Provider.of<SalesProvider>(context, listen: false).isPaymentWorkflowComplete(_workflowSummary!);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Progress', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              Text(
                '${progress.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: isComplete ? Colors.green : AppTheme.primaryMaroon),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(isComplete ? Colors.green : AppTheme.primaryMaroon),
            minHeight: 8,
          ),
          SizedBox(height: 8),
          Text(
            isComplete ? 'Payment Complete' : 'Payment in Progress',
            style: GoogleFonts.poppins(fontSize: 12, color: isComplete ? Colors.green : Colors.orange),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 500, maxHeight: 0.8.sh),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMaroon,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Payment Confirmation',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Workflow Progress
                          _buildWorkflowProgress(),

                          // Payment Summary
                          _buildPaymentSummary(),

                          SizedBox(height: 24),

                          // Payment Method Selection
                          Text('Payment Method', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentMethod,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: [
                              DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                              DropdownMenuItem(value: 'CARD', child: Text('Credit/Debit Card')),
                              DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                              DropdownMenuItem(value: 'MOBILE_PAYMENT', child: Text('Mobile Payment')),
                              DropdownMenuItem(value: 'CHECK', child: Text('Check')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a payment method';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          // Amount Input
                          Text('Payment Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixText: 'PKR ',
                              hintText: 'Enter amount',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter payment amount';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              if (amount > (widget.grandTotal - widget.amountPaid)) {
                                return 'Amount exceeds remaining balance';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          // Reference Input
                          Text('Reference (Optional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _referenceController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              hintText: 'Transaction reference or receipt number',
                            ),
                          ),

                          SizedBox(height: 16),

                          // Notes Input
                          Text('Notes (Optional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              hintText: 'Additional notes about this payment',
                            ),
                          ),

                          SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: AppTheme.primaryMaroon),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handlePaymentConfirmation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryMaroon,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                        )
                                      : Text(
                                          'Confirm Payment',
                                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

