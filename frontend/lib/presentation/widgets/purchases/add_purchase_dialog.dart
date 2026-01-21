import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/models/purchase_model.dart';
import '../../../src/providers/purchase_provider.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../globals/text_field.dart'; // PremiumTextField
import '../globals/drop_down.dart';  // PremiumDropdownField
import '../globals/custom_date_picker.dart'; // SyncfusionDateTimePicker
import '../globals/text_button.dart'; // PremiumButton

class AddPurchaseDialog extends StatefulWidget {
  const AddPurchaseDialog({super.key});

  @override
  State<AddPurchaseDialog> createState() => _AddPurchaseDialogState();
}

class _AddPurchaseDialogState extends State<AddPurchaseDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController(text: '0.0');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedVendorId;
  String _status = 'draft';

  List<PurchaseItemModel> _items = [];
  bool _isLocalLoading = false; // Local loading state to prevent double taps

  @override
  void initState() {
    super.initState();
    // Initialize data providers when dialog opens
    Future.microtask(() {
      context.read<VendorProvider>().initialize();
      context.read<ProductProvider>().initialize();
    });
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get _taxAmount => double.tryParse(_taxController.text) ?? 0.0;
  double get _total => _subtotal + _taxAmount;

  void _addItem() {
    setState(() {
      _items.add(PurchaseItemModel(
        quantity: 1,
        unitCost: 0,
        totalPrice: 0,
        // Product is initially null
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
      ),
      backgroundColor: AppTheme.creamWhite,
      child: Container(
        width: 75.w, // Desktop-optimized width
        constraints: BoxConstraints(maxHeight: 90.h),
        padding: EdgeInsets.all(context.mainPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.smallPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMaroon.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_shopping_cart_rounded,
                      color: AppTheme.primaryMaroon,
                      size: context.iconSize('medium'),
                    ),
                  ),
                  SizedBox(width: context.smallPadding),
                  Text(
                    "New Purchase", // Hardcoded fallback if l10n fails
                    style: GoogleFonts.playfairDisplay(
                      fontSize: context.headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGeneralInfo(context, l10n),
                      SizedBox(height: context.mainPadding),
                      _buildItemsSection(context, l10n),
                      SizedBox(height: context.mainPadding),
                      _buildSummarySection(context, l10n),
                    ],
                  ),
                ),
              ),

              const Divider(height: 32),
              _buildActions(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralInfo(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Consumer<VendorProvider>(
                builder: (context, provider, child) {
                  return PremiumDropdownField<String>(
                    label: l10n.vendor,
                    value: _selectedVendorId,
                    items: provider.vendors.map((v) => DropdownItem<String>(
                      value: v.id!,
                      label: v.name,
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedVendorId = val),
                    hint: "Select Vendor",
                  );
                },
              ),
            ),
            SizedBox(width: context.mainPadding),
            Expanded(
              child: PremiumTextField(
                controller: _invoiceController,
                label: "Invoice #",
                hint: "Enter Invoice Reference",
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
            ),
          ],
        ),
        SizedBox(height: context.mainPadding),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  context.showSyncfusionDateTimePicker(
                    initialDate: _selectedDate,
                    initialTime: _selectedTime,
                    onDateTimeSelected: (date, time) {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = time;
                      });
                    },
                  );
                },
                child: IgnorePointer(
                  child: PremiumTextField(
                    label: "Purchase Date",
                    controller: TextEditingController(
                      text: "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedTime.format(context)}",
                    ),
                    prefixIcon: Icons.calendar_today_rounded,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.mainPadding),
            Expanded(
              child: PremiumDropdownField<String>(
                label: "Status",
                value: _status,
                items: [
                  DropdownItem(value: 'draft', label: "Draft"),
                  DropdownItem(value: 'posted', label: "Posted"),
                ],
                onChanged: (val) => setState(() => _status = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Purchased Products",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: context.bodyFontSize)),
            PremiumButton(
              text: "Add Product Row",
              onPressed: _addItem,
              icon: Icons.add_rounded,
              width: 200,
              height: 40,
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),
        if (_items.isEmpty)
          Container(
            padding: EdgeInsets.all(context.mainPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Center(child: Text("No items added yet. Click 'Add Product Row' to begin.", style: TextStyle(color: Colors.grey[500]))),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) => _buildItemRow(index, _items[index]),
          ),
      ],
    );
  }

  Widget _buildItemRow(int index, PurchaseItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: context.smallPadding),
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return PremiumDropdownField<String>(
                  label: "Product",
                  value: item.product, // Ensure this matches the ID type
                  items: provider.products.map((p) => DropdownItem<String>(
                    value: p.id!,
                    label: p.name,
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      // Update with copyWith to keep other fields
                      _items[index] = item.copyWith(product: val);
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            flex: 2,
            child: PremiumTextField(
              label: "Qty",
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: item.quantity.toString())..selection = TextSelection.collapsed(offset: item.quantity.toString().length),
              onChanged: (val) {
                final qty = double.tryParse(val) ?? 0;
                setState(() {
                  _items[index] = item.copyWith(
                    quantity: qty,
                    totalPrice: qty * item.unitCost,
                  );
                });
              },
            ),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            flex: 2,
            child: PremiumTextField(
              label: "Unit Cost",
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: item.unitCost.toString())..selection = TextSelection.collapsed(offset: item.unitCost.toString().length),
              onChanged: (val) {
                final cost = double.tryParse(val) ?? 0;
                setState(() {
                  _items[index] = item.copyWith(
                    unitCost: cost,
                    totalPrice: cost * item.quantity,
                  );
                });
              },
            ),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Line Total", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                Text(item.totalPrice.toStringAsFixed(2),
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(index),
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(context.mainPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", _subtotal),
          SizedBox(height: context.smallPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Calculated Tax", style: GoogleFonts.inter(color: Colors.grey[600])),
              SizedBox(
                width: 150,
                child: PremiumTextField(
                  controller: _taxController,
                  label: "Tax Amount",
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _summaryRow("Grand Total", _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          fontSize: isTotal ? 18 : 14,
        )),
        Text(value.toStringAsFixed(2), style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryMaroon,
          fontSize: isTotal ? 18 : 14,
        )),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PremiumButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
          isOutlined: true,
          width: 120,
          backgroundColor: Colors.grey,
        ),
        SizedBox(width: context.mainPadding),
        Consumer<PurchaseProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: "Save Purchase",
              isLoading: provider.isLoading || _isLocalLoading,
              onPressed: _handleSave,
              width: 200,
            );
          },
        ),
      ],
    );
  }

  void _handleSave() async {
    // 1. Validate Form Fields (Invoice #)
    if (!_formKey.currentState!.validate()) {
      _showError("Please check the Invoice Number.");
      return;
    }

    // 2. Validate Vendor
    if (_selectedVendorId == null) {
      _showError("Please select a Vendor.");
      return;
    }

    // 3. Validate Items Existence
    if (_items.isEmpty) {
      _showError("Please add at least one product.");
      return;
    }

    // 4. Validate Each Item has a Product Selected
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product == null) {
        _showError("Item #${i + 1} does not have a product selected.");
        return;
      }
      if (_items[i].quantity <= 0) {
        _showError("Item #${i + 1} quantity must be greater than 0.");
        return;
      }
    }

    setState(() => _isLocalLoading = true);

    try {
      final purchase = PurchaseModel(
        vendor: _selectedVendorId,
        invoiceNumber: _invoiceController.text,
        purchaseDate: _selectedDate,
        subtotal: _subtotal,
        tax: _taxAmount,
        total: _total,
        status: _status,
        items: _items,
      );

      final success = await context.read<PurchaseProvider>().addPurchase(purchase);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Purchase Added Successfully"),
                backgroundColor: Colors.green
            )
        );
      } else {
        // Show server error in dialog instead of snackbar to ensure visibility
        final error = context.read<PurchaseProvider>().error ?? "Failed to save purchase";
        _showError(error);
      }
    } catch (e) {
      _showError("Unexpected error: $e");
    } finally {
      if (mounted) setState(() => _isLocalLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Validation Error"),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK")
            )
          ],
        )
    );
  }
}