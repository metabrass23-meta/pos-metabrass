import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/receipt_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/models/sales/sale_model.dart';

class CreateReceiptDialog extends StatefulWidget {
  const CreateReceiptDialog({super.key});

  @override
  State<CreateReceiptDialog> createState() => _CreateReceiptDialogState();
}

class _CreateReceiptDialogState extends State<CreateReceiptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedSaleId;
  String? _selectedPaymentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text('Create New Receipt', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),

              // Sale Selection
              Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  if (salesProvider.sales.isEmpty) {
                    return const Text('No sales available');
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedSaleId,
                    decoration: const InputDecoration(
                      labelText: 'Select Sale *',
                      border: OutlineInputBorder(),
                      hintText: 'Choose a sale to create receipt for',
                    ),
                    items: salesProvider.sales.map((sale) {
                      return DropdownMenuItem(
                        value: sale.id,
                        child: Text('${sale.invoiceNumber} - ${sale.customerName} (PKR ${sale.grandTotal.toStringAsFixed(2)})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSaleId = value;
                        _selectedPaymentId = null; // Reset payment selection
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a sale';
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Payment Method (derived from sale)
              if (_selectedSaleId != null)
                Consumer<SalesProvider>(
                  builder: (context, salesProvider, child) {
                    final sale = salesProvider.sales.firstWhere((s) => s.id == _selectedSaleId);

                    return TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                      initialValue: sale.paymentMethodDisplay,
                    );
                  },
                ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes', hintText: 'Additional receipt notes (optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createReceipt,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Create Receipt'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createReceipt() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSaleId == null || _selectedPaymentId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final receiptProvider = context.read<ReceiptProvider>();
      final success = await receiptProvider.createReceipt(
        saleId: _selectedSaleId!,
        paymentId: _selectedSaleId!, // Use sale ID as payment ID for now
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt created successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create receipt: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
