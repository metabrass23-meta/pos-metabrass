import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../widgets/globals/text_field.dart'; // ✅ Use PremiumTextField
import '../../widgets/globals/custom_date_picker.dart'; // ✅ Use Syncfusion Picker

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
    _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_termsController.text.isEmpty) {
      _termsController.text = l10n.standardTermsAndConditionsApply;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text(
                      l10n.createNewInvoice,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 1. Select Sale ---
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
                      hintText: l10n.chooseASaleToCreateInvoiceFor,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    dropdownColor: Colors.white,
                    items: salesProvider.sales.map((sale) {
                      return DropdownMenuItem(
                        value: sale.id,
                        child: Text(
                          '${sale.invoiceNumber} - ${sale.customerName} (PKR ${sale.grandTotal.toStringAsFixed(2)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSaleId = value;
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

              // --- 2. Due Date Picker ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.dueDateRequired, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _selectedDueDate != null
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : l10n.selectDueDate,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    // ✅ FIXED: Using Syncfusion Picker Extension
                    context.showSyncfusionDateTimePicker(
                      initialDate: _selectedDueDate ?? DateTime.now(),
                      initialTime: TimeOfDay.now(),
                      showTimeInline: false, // Only Date needed
                      onDateTimeSelected: (date, time) {
                        setState(() {
                          _selectedDueDate = date;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // --- 3. Notes ---
              PremiumTextField(
                label: l10n.notes,
                hint: l10n.additionalInvoiceNotesOptional,
                controller: _notesController,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // --- 4. Terms ---
              PremiumTextField(
                label: l10n.termsAndConditions,
                hint: l10n.invoiceTermsAndConditions,
                controller: _termsController,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // --- Actions ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createInvoice,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.createInvoice),
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
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSaleId == null || _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSelectASale), backgroundColor: Colors.red)
      );
      return;
    }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invoiceCreatedSuccessfully), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToCreateInvoice}: $e'), backgroundColor: Colors.red),
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
