import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import 'payment_confirmation_dialog.dart';

class PaymentWorkflowStatus extends StatefulWidget {
  final String saleId;
  final String invoiceNumber;
  final String customerName;
  final double grandTotal;
  final double amountPaid;
  final String currentStatus;
  final VoidCallback? onStatusUpdated;

  const PaymentWorkflowStatus({
    super.key,
    required this.saleId,
    required this.invoiceNumber,
    required this.customerName,
    required this.grandTotal,
    required this.amountPaid,
    required this.currentStatus,
    this.onStatusUpdated,
  });

  @override
  State<PaymentWorkflowStatus> createState() => _PaymentWorkflowStatusState();
}

class _PaymentWorkflowStatusState extends State<PaymentWorkflowStatus> {
  Map<String, dynamic>? _workflowSummary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkflowSummary();
  }

  Future<void> _loadWorkflowSummary() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<SalesProvider>(context, listen: false);
      final summary = await provider.getPaymentWorkflowSummary(widget.saleId);

      if (mounted) {
        setState(() {
          _workflowSummary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentConfirmationDialog(
        saleId: widget.saleId,
        invoiceNumber: widget.invoiceNumber,
        customerName: widget.customerName,
        grandTotal: widget.grandTotal,
        amountPaid: widget.amountPaid,
        currentStatus: widget.currentStatus,
        onPaymentConfirmed: (success) {
          if (success) {
            _loadWorkflowSummary();
            widget.onStatusUpdated?.call();
          }
        },
      ),
    );
  }

  void _showStatusUpdateDialog() {
    if (_workflowSummary == null) return;

    final availableActions = Provider.of<SalesProvider>(context, listen: false).getAvailablePaymentActions(_workflowSummary!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Sale Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select an action to perform:'),
            SizedBox(height: 16),
            ...availableActions.map(
              (action) => ListTile(
                leading: _getActionIcon(action),
                title: Text(_getActionTitle(action)),
                subtitle: Text(_getActionDescription(action)),
                onTap: () {
                  Navigator.of(context).pop();
                  _performAction(action);
                },
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel'))],
      ),
    );
  }

  Icon _getActionIcon(String action) {
    switch (action) {
      case 'add_payment':
        return Icon(Icons.payment, color: AppTheme.primaryMaroon);
      case 'mark_delivered':
        return Icon(Icons.local_shipping, color: Colors.green);
      case 'cancel_sale':
        return Icon(Icons.cancel, color: Colors.red);
      case 'return_sale':
        return Icon(Icons.undo, color: Colors.orange);
      default:
        return Icon(Icons.info, color: Colors.grey);
    }
  }

  String _getActionTitle(String action) {
    switch (action) {
      case 'add_payment':
        return 'Add Payment';
      case 'mark_delivered':
        return 'Mark as Delivered';
      case 'cancel_sale':
        return 'Cancel Sale';
      case 'return_sale':
        return 'Return Sale';
      default:
        return 'Unknown Action';
    }
  }

  String _getActionDescription(String action) {
    switch (action) {
      case 'add_payment':
        return 'Process additional payment for this sale';
      case 'mark_delivered':
        return 'Mark the sale as delivered to customer';
      case 'cancel_sale':
        return 'Cancel this sale and restore inventory';
      case 'return_sale':
        return 'Process return for delivered sale';
      default:
        return 'No description available';
    }
  }

  Future<void> _performAction(String action) async {
    final provider = Provider.of<SalesProvider>(context, listen: false);

    try {
      bool success = false;

      switch (action) {
        case 'add_payment':
          _showPaymentConfirmationDialog();
          return;
        case 'mark_delivered':
          success = await provider.updateSaleStatusWithPayment(widget.saleId, 'DELIVERED', notes: 'Marked as delivered');
          break;
        case 'cancel_sale':
          success = await provider.updateSaleStatusWithPayment(widget.saleId, 'CANCELLED', notes: 'Sale cancelled');
          break;
        case 'return_sale':
          success = await provider.updateSaleStatusWithPayment(widget.saleId, 'RETURNED', notes: 'Sale returned');
          break;
      }

      if (success) {
        await _loadWorkflowSummary();
        widget.onStatusUpdated?.call();
      }
    } catch (e) {
      // Error handling is done in the provider
    }
  }

  Widget _buildProgressIndicator() {
    if (_workflowSummary == null) return SizedBox.shrink();

    final progress = Provider.of<SalesProvider>(context, listen: false).getPaymentWorkflowProgress(_workflowSummary!);
    final isComplete = Provider.of<SalesProvider>(context, listen: false).isPaymentWorkflowComplete(_workflowSummary!);

    return Container(
      width: 80,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(isComplete ? Colors.green : AppTheme.primaryMaroon),
            minHeight: 6,
          ),
          SizedBox(height: 4),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: isComplete ? Colors.green : AppTheme.primaryMaroon),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    if (_workflowSummary == null) return SizedBox.shrink();

    final currentStep = _workflowSummary!['current_workflow_step'] as String? ?? '';
    final nextAction = _workflowSummary!['next_action'] as String? ?? '';

    Color chipColor;
    String chipText;

    switch (currentStep) {
      case 'awaiting_payment':
        chipColor = Colors.red;
        chipText = 'Awaiting Payment';
        break;
      case 'partial_payment':
        chipColor = Colors.orange;
        chipText = 'Partial Payment';
        break;
      case 'payment_complete':
        chipColor = Colors.green;
        chipText = 'Payment Complete';
        break;
      default:
        chipColor = Colors.grey;
        chipText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        chipText,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: chipColor),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_workflowSummary == null) return SizedBox.shrink();

    final availableActions = Provider.of<SalesProvider>(context, listen: false).getAvailablePaymentActions(_workflowSummary!);

    if (availableActions.isEmpty) return SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Payment Button
        if (availableActions.contains('add_payment'))
          Container(
            margin: EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _showPaymentConfirmationDialog,
              icon: Icon(Icons.payment, size: 16),
              label: Text('Payment', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size(0, 28),
              ),
            ),
          ),

        // More Actions Button
        if (availableActions.length > 1)
          Container(
            child: IconButton(
              onPressed: _showStatusUpdateDialog,
              icon: Icon(Icons.more_vert, size: 20),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              style: IconButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.grey[700]),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: 120,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMaroon)),
          ),
        ),
      );
    }

    return Container(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress and Status Row
          Row(
            children: [
              _buildProgressIndicator(),
              SizedBox(width: 8),
              Expanded(child: _buildStatusChip()),
            ],
          ),

          SizedBox(height: 8),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }
}

