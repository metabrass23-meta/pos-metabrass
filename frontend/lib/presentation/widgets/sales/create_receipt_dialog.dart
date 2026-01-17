import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/receipt_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/models/sales/sale_model.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
                  Text(
                    l10n.createNewReceipt,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  if (salesProvider.sales.isEmpty) {
                    return Text(l10n.noSalesAvailable);
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedSaleId,
                    decoration: InputDecoration(
                      labelText: l10n.selectSaleRequired,
                      border: const OutlineInputBorder(),
                      hintText: l10n.chooseASaleToCreateReceiptFor,
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
                        _selectedPaymentId = null;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseSelectASale;
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              if (_selectedSaleId != null)
                Consumer<SalesProvider>(
                  builder: (context, salesProvider, child) {
                    final sale = salesProvider.sales.firstWhere((s) => s.id == _selectedSaleId);

                    return TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: l10n.paymentMethod,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: sale.paymentMethodDisplay,
                    );
                  },
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  hintText: l10n.additionalReceiptNotesOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createReceipt,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(l10n.createReceipt),
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
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (_selectedSaleId == null || _selectedPaymentId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final receiptProvider = context.read<ReceiptProvider>();
      final success = await receiptProvider.createReceipt(
        saleId: _selectedSaleId!,
        paymentId: _selectedSaleId!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.receiptCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToCreateReceipt}: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
