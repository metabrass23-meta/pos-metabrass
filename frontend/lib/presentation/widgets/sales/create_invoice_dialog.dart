import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/models/sales/sale_model.dart';

class CreateInvoiceDialog extends StatefulWidget {
  const CreateInvoiceDialog({super.key});

  @override
  State<CreateInvoiceDialog> createState() => _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends State<CreateInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();

  String? _selectedSaleId;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _termsController.text = 'Standard terms and conditions apply';
    _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
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
                  Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text('Create New Invoice', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                      hintText: 'Choose a sale to create invoice for',
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

              // Due Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date *'),
                subtitle: Text(
                  _selectedDueDate != null ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}' : 'Select due date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDueDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes', hintText: 'Additional invoice notes (optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Terms & Conditions
              TextFormField(
                controller: _termsController,
                decoration: const InputDecoration(
                  labelText: 'Terms & Conditions',
                  hintText: 'Invoice terms and conditions',
                  border: OutlineInputBorder(),
                ),
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
                    onPressed: _isLoading ? null : _createInvoice,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Create Invoice'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSaleId == null || _selectedDueDate == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      final success = await invoiceProvider.createInvoice(
        saleId: _selectedSaleId!,
        dueDate: _selectedDueDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice created successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create invoice: $e'), backgroundColor: Colors.red));
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
