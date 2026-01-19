import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
    final l10n = AppLocalizations.of(context)!;

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
            l10n.createNewReturn,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.basicInformation, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _saleIdController,
                decoration: InputDecoration(
                  labelText: l10n.saleId,
                  hintText: l10n.enterSaleId,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.saleIdRequired;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _customerIdController,
                decoration: InputDecoration(
                  labelText: l10n.customerId,
                  hintText: l10n.enterCustomerId,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.customerIdRequired;
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
          decoration: InputDecoration(
            labelText: l10n.returnReason,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.selectReason)),
            DropdownMenuItem(value: 'DEFECTIVE', child: Text(l10n.reasonDefective)),
            DropdownMenuItem(value: 'WRONG_SIZE', child: Text(l10n.reasonWrongSize)),
            DropdownMenuItem(value: 'WRONG_COLOR', child: Text(l10n.reasonWrongColor)),
            DropdownMenuItem(value: 'QUALITY_ISSUE', child: Text(l10n.reasonQualityIssue)),
            DropdownMenuItem(value: 'CUSTOMER_CHANGE_MIND', child: Text(l10n.reasonChangeMind)),
            DropdownMenuItem(value: 'DAMAGED_IN_TRANSIT', child: Text(l10n.reasonDamagedTransit)),
            DropdownMenuItem(value: 'OTHER', child: Text(l10n.reasonOther)),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.selectReturnReason;
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
            decoration: InputDecoration(
              labelText: l10n.reasonDetails,
              hintText: l10n.specifyReason,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (value) {
              if (_selectedReason == 'OTHER' && (value == null || value.isEmpty)) {
                return l10n.provideReasonDetails;
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReturnItemsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.returnItems, style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton.icon(
              onPressed: _addReturnItem,
              icon: const Icon(Icons.add),
              label: Text(l10n.addItem),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_returnItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noItemsAdded),
                  Text(l10n.clickAddItem),
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
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.item(index + 1), style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  onPressed: () => _removeReturnItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: l10n.removeItem,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item['sale_item_id'] ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.saleItemId,
                      hintText: l10n.enterSaleItemId,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _returnItems[index]['sale_item_id'] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.saleItemIdRequired;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: item['quantity_returned']?.toString() ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      hintText: l10n.enterQuantity,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _returnItems[index]['quantity_returned'] = int.tryParse(value) ?? 0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.quantityRequired;
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return l10n.quantityPositive;
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
                    decoration: InputDecoration(
                      labelText: l10n.condition,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: '', child: Text(l10n.selectCondition)),
                      DropdownMenuItem(value: 'NEW', child: Text(l10n.conditionNew)),
                      DropdownMenuItem(value: 'GOOD', child: Text(l10n.conditionGood)),
                      DropdownMenuItem(value: 'FAIR', child: Text(l10n.conditionFair)),
                      DropdownMenuItem(value: 'POOR', child: Text(l10n.conditionPoor)),
                      DropdownMenuItem(value: 'DAMAGED', child: Text(l10n.conditionDamaged)),
                    ],
                    onChanged: (value) {
                      _returnItems[index]['condition'] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.selectConditionError;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: item['condition_notes'] ?? '',
                    decoration: InputDecoration(
                      labelText: l10n.conditionNotes,
                      hintText: l10n.conditionNotesHint,
                      border: const OutlineInputBorder(),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.additionalNotes, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.notes,
            hintText: l10n.notesHint,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitReturn,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.createReturn),
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
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addOneItem),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.createdSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? l10n.failedToCreate),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorCreating(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
