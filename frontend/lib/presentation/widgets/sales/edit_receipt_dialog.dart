import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/receipt_provider.dart';
import '../../../src/models/sales/sale_model.dart';

class EditReceiptDialog extends StatefulWidget {
  final ReceiptModel receipt;

  const EditReceiptDialog({super.key, required this.receipt});

  @override
  State<EditReceiptDialog> createState() => _EditReceiptDialogState();
}

class _EditReceiptDialogState extends State<EditReceiptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.receipt.notes ?? '';
    _selectedStatus = widget.receipt.status;
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
                  Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Receipt - ${widget.receipt.receiptNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Selection
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status *', border: OutlineInputBorder(), hintText: 'Select receipt status'),
                items: [
                  const DropdownMenuItem(value: 'GENERATED', child: Text('Generated')),
                  const DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                  const DropdownMenuItem(value: 'VIEWED', child: Text('Viewed')),
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
                    onPressed: _isLoading ? null : _updateReceipt,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Update Receipt'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final receiptProvider = context.read<ReceiptProvider>();
      final success = await receiptProvider.updateReceipt(
        id: widget.receipt.id,
        status: _selectedStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt updated successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update receipt: $e'), backgroundColor: Colors.red));
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
