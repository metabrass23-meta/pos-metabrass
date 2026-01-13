import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/models/sales/sale_model.dart';

class EditInvoiceDialog extends StatefulWidget {
  final InvoiceModel invoice;

  const EditInvoiceDialog({super.key, required this.invoice});

  @override
  State<EditInvoiceDialog> createState() => _EditInvoiceDialogState();
}

class _EditInvoiceDialogState extends State<EditInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();

  DateTime? _selectedDueDate;
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.invoice.notes ?? '';
    _termsController.text = widget.invoice.termsConditions ?? 'Standard terms and conditions apply';
    _selectedDueDate = widget.invoice.dueDate;
    _selectedStatus = widget.invoice.status;
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
                  Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Invoice - ${widget.invoice.invoiceNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Selection
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status *', border: OutlineInputBorder(), hintText: 'Select invoice status'),
                items: [
                  const DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                  const DropdownMenuItem(value: 'ISSUED', child: Text('Issued')),
                  const DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                  const DropdownMenuItem(value: 'VIEWED', child: Text('Viewed')),
                  const DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                  const DropdownMenuItem(value: 'OVERDUE', child: Text('Overdue')),
                  const DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Due Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(
                  _selectedDueDate != null ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}' : 'Not specified',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                        tooltip: 'Clear due date',
                      ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
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
                    onPressed: _isLoading ? null : _updateInvoice,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Update Invoice'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      final success = await invoiceProvider.updateInvoice(
        id: widget.invoice.id,
        status: _selectedStatus,
        dueDate: _selectedDueDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice updated successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update invoice: $e'), backgroundColor: Colors.red));
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
