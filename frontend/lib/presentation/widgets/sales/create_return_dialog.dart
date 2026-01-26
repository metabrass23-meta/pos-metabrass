import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/return_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/models/sales/sale_model.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/globals/text_field.dart';

class CreateReturnDialog extends StatefulWidget {
  final SaleModel? sale;

  const CreateReturnDialog({Key? key, this.sale}) : super(key: key);

  @override
  State<CreateReturnDialog> createState() => _CreateReturnDialogState();
}

class _CreateReturnDialogState extends State<CreateReturnDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _saleIdController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _reasonDetailsController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedReason = '';
  String? _selectedSaleId;
  bool _isLoading = false;
  bool _isFetchingItems = false;

  // Holds data + controllers for each return item
  final List<Map<String, dynamic>> _returnItems = [];

  @override
  void initState() {
    super.initState();

    if (widget.sale != null) {
      _populateFormFromSale(widget.sale!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SalesProvider>().loadSales();
      });
    }
  }

  // Handle Sale Dropdown Selection
  Future<void> _handleSaleSelection(String saleId) async {
    setState(() {
      _selectedSaleId = saleId;
      _isFetchingItems = true;
      // Dispose old controllers before clearing
      for (var item in _returnItems) {
        (item['quantity_controller'] as TextEditingController).dispose();
      }
      _returnItems.clear();
    });

    try {
      final fullSale = await context.read<SalesProvider>().getSaleById(saleId);

      if (mounted && fullSale != null) {
        _populateFormFromSale(fullSale);
      }
    } catch (e) {
      debugPrint("Error fetching sale details: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingItems = false;
        });
      }
    }
  }

  void _populateFormFromSale(SaleModel sale) {
    setState(() {
      _selectedSaleId = sale.id;
      _saleIdController.text = sale.invoiceNumber;
      _customerIdController.text = sale.customerName;

      // Clear existing items and controllers
      for (var item in _returnItems) {
        (item['quantity_controller'] as TextEditingController).dispose();
      }
      _returnItems.clear();

      if (sale.saleItems.isNotEmpty) {
        for (var item in sale.saleItems) {
          _returnItems.add({
            'sale_item_id': item.id,
            'product_name': item.productName,
            'max_quantity': item.quantity,
            'condition': 'NEW',
            'condition_notes': '',
            // ✅ Use explicit controller for each item's quantity
            'quantity_controller': TextEditingController(text: '0'),
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _saleIdController.dispose();
    _customerIdController.dispose();
    _reasonController.dispose();
    _reasonDetailsController.dispose();
    _notesController.dispose();
    // ✅ Dispose dynamic item controllers
    for (var item in _returnItems) {
      (item['quantity_controller'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
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
        color: AppTheme.primaryMaroon,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_return, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            l10n.createNewReturn,
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
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

        if (widget.sale == null)
          Consumer<SalesProvider>(
            builder: (context, salesProvider, child) {
              if (salesProvider.isLoading) {
                return const Center(child: LinearProgressIndicator());
              }

              return DropdownButtonFormField<String>(
                value: _selectedSaleId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.selectSale,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                dropdownColor: Colors.white,
                hint: Text(l10n.selectSale, style: const TextStyle(color: Colors.grey)),
                items: salesProvider.sales.map((sale) {
                  return DropdownMenuItem(
                    value: sale.id,
                    child: Text(
                      '${sale.invoiceNumber} - ${sale.customerName} (PKR ${sale.grandTotal.toStringAsFixed(0)})',
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _handleSaleSelection(val);
                  }
                },
                validator: (val) => val == null ? l10n.pleaseSelectASale : null,
              );
            },
          )
        else
          PremiumTextField(
            label: l10n.saleId,
            controller: _saleIdController,
            enabled: false,
          ),

        const SizedBox(height: 16),

        PremiumTextField(
          label: l10n.customer,
          controller: _customerIdController,
          enabled: false,
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _selectedReason.isEmpty ? null : _selectedReason,
          decoration: InputDecoration(
            labelText: l10n.returnReason,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.selectReason, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'DEFECTIVE', child: Text(l10n.reasonDefective, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'WRONG_SIZE', child: Text(l10n.reasonWrongSize, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'WRONG_COLOR', child: Text(l10n.reasonWrongColor, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'QUALITY_ISSUE', child: Text(l10n.reasonQualityIssue, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'CUSTOMER_CHANGE_MIND', child: Text(l10n.reasonChangeMind, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'DAMAGED_IN_TRANSIT', child: Text(l10n.reasonDamagedTransit, style: const TextStyle(color: Colors.black))),
            DropdownMenuItem(value: 'OTHER', child: Text(l10n.reasonOther, style: const TextStyle(color: Colors.black))),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return l10n.selectReturnReason;
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
          PremiumTextField(
            label: l10n.reasonDetails,
            hint: l10n.specifyReason,
            controller: _reasonDetailsController,
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
        Text(l10n.returnItems, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),

        if (_isFetchingItems)
          const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ))
        else if (_returnItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!)
            ),
            child: Column(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _selectedSaleId == null
                      ? l10n.pleaseSelectASale
                      : l10n.noItemsAdded,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _returnItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
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
      key: ValueKey(item['sale_item_id']),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['product_name'] ?? 'Unknown Product',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    // ✅ Using Controller instead of initialValue for stable editing
                    controller: item['quantity_controller'],
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      hintText: '0',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixText: '/ ${item['max_quantity']}',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.quantityRequired;
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity < 0) return l10n.quantityPositive;

                      final max = item['max_quantity'] ?? 9999;
                      if (quantity > max) return 'Max $max';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item['condition'] != '' ? item['condition'] : null,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: l10n.condition,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem(value: 'NEW', child: Text(l10n.conditionNew, style: const TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'GOOD', child: Text(l10n.conditionGood, style: const TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'FAIR', child: Text(l10n.conditionFair, style: const TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'POOR', child: Text(l10n.conditionPoor, style: const TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'DAMAGED', child: Text(l10n.conditionDamaged, style: const TextStyle(color: Colors.black))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        item['condition'] = value ?? '';
                      });
                    },
                    validator: (value) => (value == null || value.isEmpty) ? l10n.selectConditionError : null,
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
        PremiumTextField(
          label: l10n.notes,
          hint: l10n.notesHint,
          controller: _notesController,
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
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryMaroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.createReturn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _submitReturn() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSaleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectASale), backgroundColor: Colors.red));
      return;
    }

    // Collect Data from Controllers
    List<Map<String, dynamic>> itemsToSubmit = [];

    for (var item in _returnItems) {
      final qtyText = (item['quantity_controller'] as TextEditingController).text;
      final qty = int.tryParse(qtyText) ?? 0;

      if (qty > 0) {
        itemsToSubmit.add({
          ...item,
          'quantity_returned': qty, // Override with controller value
        });
      }
    }

    if (itemsToSubmit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addOneItem), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ReturnProvider>();
      final success = await provider.createReturn(
        saleId: _selectedSaleId!,
        customerId: _customerIdController.text,
        reason: _selectedReason,
        reasonDetails: _reasonDetailsController.text.isEmpty ? null : _reasonDetailsController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        returnItems: itemsToSubmit,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.createdSuccessfully), backgroundColor: Colors.green));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? l10n.failedToCreate), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorCreating(e.toString())), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}