import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/models/sales/sale_model.dart';
import '../../widgets/globals/text_field.dart'; // ✅ Use PremiumTextField
import '../../widgets/globals/custom_date_picker.dart'; // ✅ Use Syncfusion Picker

class EditInvoiceDialog extends StatefulWidget {
  final InvoiceModel invoice;

  const EditInvoiceDialog({super.key, required this.invoice});

  @override
  State<EditInvoiceDialog> createState() => _EditInvoiceDialogState();
}

class _EditInvoiceDialogState extends State<EditInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late TextEditingController _termsController;

  DateTime? _selectedDueDate;
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.invoice.notes ?? '');
    _termsController = TextEditingController(text: widget.invoice.termsConditions ?? '');
    _selectedDueDate = widget.invoice.dueDate;
    _selectedStatus = widget.invoice.status;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    // Set default terms if empty (using standardTermsAndConditionsApply as seen in CreateDialog)
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
                  Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.editInvoiceWithNumber(widget.invoice.invoiceNumber),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Status Dropdown ---
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: l10n.statusRequired,
                  border: const OutlineInputBorder(),
                  hintText: l10n.selectInvoiceStatus,
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem(value: 'DRAFT', child: Text(l10n.draft)),
                  DropdownMenuItem(value: 'ISSUED', child: Text(l10n.issued)),
                  DropdownMenuItem(value: 'SENT', child: Text(l10n.sent)),
                  DropdownMenuItem(value: 'VIEWED', child: Text(l10n.viewed)),
                  DropdownMenuItem(value: 'PAID', child: Text(l10n.paid)),
                  DropdownMenuItem(value: 'OVERDUE', child: Text(l10n.overdue)),
                  DropdownMenuItem(value: 'CANCELLED', child: Text(l10n.cancelled)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseSelectStatus;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // --- Due Date Picker ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.dueDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _selectedDueDate != null
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : l10n.notSpecified,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                        tooltip: l10n.clearDueDate,
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        // ✅ Use Syncfusion Date Picker
                        context.showSyncfusionDateTimePicker(
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          initialTime: TimeOfDay.now(),
                          showTimeInline: false,
                          onDateTimeSelected: (date, time) {
                            setState(() {
                              _selectedDueDate = date;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- Notes ---
              PremiumTextField(
                label: l10n.notes,
                hint: l10n.additionalInvoiceNotes,
                controller: _notesController,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // --- Terms ---
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
                    onPressed: _isLoading ? null : _updateInvoice,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(l10n.updateInvoice),
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
    final l10n = AppLocalizations.of(context)!;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invoiceUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToUpdateInvoice}: $e'),
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