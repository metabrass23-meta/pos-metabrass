import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/return_provider.dart';
import '../../../src/models/sales/return_model.dart';

class CreateReturnDialog extends StatefulWidget {
  const CreateReturnDialog({Key? key}) : super(key: key);

  @override
  State<CreateReturnDialog> createState() => _CreateReturnDialogState();
}

class _CreateReturnDialogState extends State<CreateReturnDialog> {
  final _formKey = GlobalKey<FormState>();
  final _saleIdController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _reasonDetailsController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedReason = '';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _returnItems = [];

  @override
  void dispose() {
    _saleIdController.dispose();
    _customerIdController.dispose();
    _reasonController.dispose();
    _reasonDetailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildReturnItemsSection(),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_return, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Create New Return',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Information', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _saleIdController,
                decoration: const InputDecoration(labelText: 'Sale ID', hintText: 'Enter sale ID', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sale ID is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _customerIdController,
                decoration: const InputDecoration(labelText: 'Customer ID', hintText: 'Enter customer ID', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Customer ID is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedReason.isEmpty ? null : _selectedReason,
          decoration: const InputDecoration(labelText: 'Return Reason', border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem(value: '', child: Text('Select a reason')),
            const DropdownMenuItem(value: 'DEFECTIVE', child: Text('Defective Product')),
            const DropdownMenuItem(value: 'WRONG_SIZE', child: Text('Wrong Size')),
            const DropdownMenuItem(value: 'WRONG_COLOR', child: Text('Wrong Color')),
            const DropdownMenuItem(value: 'QUALITY_ISSUE', child: Text('Quality Issue')),
            const DropdownMenuItem(value: 'CUSTOMER_CHANGE_MIND', child: Text('Customer Changed Mind')),
            const DropdownMenuItem(value: 'DAMAGED_IN_TRANSIT', child: Text('Damaged in Transit')),
            const DropdownMenuItem(value: 'OTHER', child: Text('Other')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a return reason';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _selectedReason = value ?? '';
            });
          },
        ),
        if (_selectedReason == 'OTHER') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonDetailsController,
            decoration: const InputDecoration(labelText: 'Reason Details', hintText: 'Please specify the reason', border: OutlineInputBorder()),
            maxLines: 2,
            validator: (value) {
              if (_selectedReason == 'OTHER' && (value == null || value.isEmpty)) {
                return 'Please provide reason details';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReturnItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Return Items', style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton.icon(onPressed: _addReturnItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
          ],
        ),
        const SizedBox(height: 16),
        if (_returnItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No return items added'),
                  Text('Click "Add Item" to add items to return'),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _returnItems.length,
            itemBuilder: (context, index) {
              return _buildReturnItemCard(index);
            },
          ),
      ],
    );
  }

  Widget _buildReturnItemCard(int index) {
    final item = _returnItems[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  onPressed: () => _removeReturnItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove Item',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['sale_item_id'] ?? '',
                    decoration: const InputDecoration(labelText: 'Sale Item ID', hintText: 'Enter sale item ID', border: OutlineInputBorder()),
                    onChanged: (value) {
                      _returnItems[index]['sale_item_id'] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Sale item ID is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: item['quantity_returned']?.toString() ?? '',
                    decoration: const InputDecoration(labelText: 'Quantity', hintText: 'Enter quantity', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _returnItems[index]['quantity_returned'] = int.tryParse(value) ?? 0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Quantity must be a positive number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item['condition'] ?? '',
                    decoration: const InputDecoration(labelText: 'Condition', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Select condition')),
                      const DropdownMenuItem(value: 'NEW', child: Text('New')),
                      const DropdownMenuItem(value: 'GOOD', child: Text('Good')),
                      const DropdownMenuItem(value: 'FAIR', child: Text('Fair')),
                      const DropdownMenuItem(value: 'POOR', child: Text('Poor')),
                      const DropdownMenuItem(value: 'DAMAGED', child: Text('Damaged')),
                    ],
                    onChanged: (value) {
                      _returnItems[index]['condition'] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select condition';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: item['condition_notes'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Condition Notes',
                      hintText: 'Additional notes about condition',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _returnItems[index]['condition_notes'] = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Notes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: 'Notes', hintText: 'Any additional notes about the return', border: OutlineInputBorder()),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitReturn,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Return'),
          ),
        ],
      ),
    );
  }

  void _addReturnItem() {
    setState(() {
      _returnItems.add({'sale_item_id': '', 'quantity_returned': 0, 'condition': '', 'condition_notes': ''});
    });
  }

  void _removeReturnItem(int index) {
    setState(() {
      _returnItems.removeAt(index);
    });
  }

  void _submitReturn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one return item'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ReturnProvider>();
      final success = await provider.createReturn(
        saleId: _saleIdController.text,
        customerId: _customerIdController.text,
        reason: _selectedReason,
        reasonDetails: _reasonDetailsController.text.isEmpty ? null : _reasonDetailsController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        returnItems: _returnItems,
      );

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return created successfully'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Failed to create return'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating return: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
