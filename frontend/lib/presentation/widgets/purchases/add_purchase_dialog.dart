import 'package:flutter/material.dart';
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
import '../globals/drop_down.dart'; // PremiumDropdownField
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
  final TextEditingController _taxController = TextEditingController(text: '0');
  final TextEditingController _productSearchController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedVendorId;
  String _status = 'draft';
  String _productSearchQuery = '';

  List<PurchaseItemModel> _items = [];
  bool _isLocalLoading = false;

  // ✅ Per-item controllers - prevents cursor reset on setState
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _costControllers = {};

  TextEditingController _getQtyController(int index) {
    if (!_qtyControllers.containsKey(index)) {
      _qtyControllers[index] = TextEditingController(
        text: _formatNumber(_items[index].quantity),
      );
    }
    return _qtyControllers[index]!;
  }

  TextEditingController _getCostController(int index) {
    if (!_costControllers.containsKey(index)) {
      _costControllers[index] = TextEditingController(
        text: _formatNumber(_items[index].unitCost),
      );
    }
    return _costControllers[index]!;
  }

  void _disposeItemControllers(int index) {
    _qtyControllers[index]?.dispose();
    _qtyControllers.remove(index);
    _costControllers[index]?.dispose();
    _costControllers.remove(index);
  }

  @override
  void initState() {
    super.initState();
    // Initialize data providers when dialog opens
    Future.microtask(() {
      context.read<VendorProvider>().initialize();
      context.read<ProductProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _taxController.dispose();
    _productSearchController.dispose();
    // ✅ Dispose all item controllers
    for (final c in _qtyControllers.values) c.dispose();
    for (final c in _costControllers.values) c.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get _taxAmount => double.tryParse(_taxController.text) ?? 0.0;
  double get _total => _subtotal + _taxAmount;

  void _addItem() {
    setState(() {
      _items.add(
        PurchaseItemModel(
          quantity: 1,
          unitCost: 0,
          totalPrice: 0,
        ),
      );
      // ✅ Pre-create controllers for new item
      final newIndex = _items.length - 1;
      _qtyControllers[newIndex] = TextEditingController(text: '1');
      _costControllers[newIndex] = TextEditingController(text: '0');
    });
  }

  void _removeItem(int index) {
    setState(() {
      _disposeItemControllers(index);
      _items.removeAt(index);
      // ✅ Re-map remaining controllers
      final newQty = <int, TextEditingController>{};
      final newCost = <int, TextEditingController>{};
      for (int i = 0; i < _items.length; i++) {
        final oldIndex = i >= index ? i + 1 : i;
        if (_qtyControllers.containsKey(oldIndex)) newQty[i] = _qtyControllers[oldIndex]!;
        if (_costControllers.containsKey(oldIndex)) newCost[i] = _costControllers[oldIndex]!;
      }
      _qtyControllers.clear();
      _costControllers.clear();
      _qtyControllers.addAll(newQty);
      _costControllers.addAll(newCost);
    });
  }

  /// Helper to format doubles nicely (e.g. 1.0 -> "1", 1.5 -> "1.5")
  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
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
              // --- Header ---
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
                    l10n.add ?? "New Purchase",
                    style: TextStyle(
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

              // --- Scrollable Body ---
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

              // --- Footer Actions ---
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
                    label: l10n.vendor ?? "Vendor",
                    value: _selectedVendorId,
                    items: provider.vendors
                        .map(
                          (v) =>
                              DropdownItem<String>(value: v.id!, label: v.name),
                        )
                        .toList(),
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
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
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
                    label: l10n.date ?? "Purchase Date",
                    controller: TextEditingController(
                      text:
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedTime.format(context)}",
                    ),
                    prefixIcon: Icons.calendar_today_rounded,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.mainPadding),
            Expanded(
              child: PremiumTextField(
                label: "Status",
                controller: TextEditingController(text: "Draft"),
                enabled: false, // Locked to Draft only
                prefixIcon: Icons.drafts,
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
            Text(
              "Purchased Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.bodyFontSize,
              ),
            ),
            PremiumButton(
              text: "Add Product Row",
              onPressed: _addItem,
              icon: Icons.add_rounded,
              width: 180,
              height: 40,
              backgroundColor: AppTheme.secondaryMaroon,
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),

        if (_items.isEmpty)
          Container(
            padding: EdgeInsets.all(context.mainPadding),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                Icon(Icons.list_alt_rounded, size: 40, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text(
                  "No items added yet.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) =>
                _buildItemRow(index, _items[index]),
          ),
      ],
    );
  }

  Widget _buildItemRow(int index, PurchaseItemModel item) {
    // ✅ Reuse stable controllers (no cursor reset on setState)
    final qtyController = _getQtyController(index);
    final costController = _getCostController(index);

    return Container(
      margin: EdgeInsets.only(bottom: context.smallPadding),
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top for error messages
        children: [
          // Product Selection - Searchable Dropdown
          Expanded(
            flex: 4,
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                // Filter products based on search query
                final filteredProducts = provider.products
                    .where(
                      (product) => product.name.toLowerCase().contains(
                        _productSearchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search text field
                    PremiumTextField(
                      label: "Products",
                      hint: "Type to search product...",
                      controller: _productSearchController,
                      onChanged: (val) {
                        setState(() {
                          _productSearchQuery = val;
                        });
                      },
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    // Product list dropdown
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(
                          context.borderRadius('small'),
                        ),
                      ),
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: context.bodyFontSize * 0.9,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'PKR ${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: context.captionFontSize,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _items[index] = item.copyWith(
                                        product: product.id,
                                      );
                                      _productSearchController.text =
                                          product.name;
                                      _productSearchQuery = product.name;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(width: context.smallPadding),

          // Quantity
          Expanded(
            flex: 2,
            child: PremiumTextField(
              label: "Qty",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: qtyController,
              onChanged: (val) {
                final qty = double.tryParse(val) ?? 0;
                setState(() {
                  _items[index] = item.copyWith(
                    quantity: qty,
                    totalPrice: qty * item.unitCost,
                  );
                  print(
                    'DEBUG: Updated item $index - qty: $qty, cost: ${item.unitCost}, total: ${qty * item.unitCost}',
                  );
                });
              },
            ),
          ),
          SizedBox(width: context.smallPadding),

          // Unit Cost
          Expanded(
            flex: 2,
            child: PremiumTextField(
              label: "Unit Cost",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: costController,
              onChanged: (val) {
                final cost = double.tryParse(val) ?? 0;
                setState(() {
                  _items[index] = item.copyWith(
                    unitCost: cost,
                    totalPrice: cost * item.quantity,
                  );
                  print(
                    'DEBUG: Updated item $index - qty: ${item.quantity}, cost: $cost, total: ${cost * item.quantity}',
                  );
                });
              },
            ),
          ),

          // Remove Button
          IconButton(
            onPressed: () => _removeItem(index),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: "Remove Item",
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(context.mainPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.03),
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
              Text(
                "Tax / Adjustment",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 150,
                child: PremiumTextField(
                  controller: _taxController,
                  label: "Tax / Adjustment",
                  hint: "0.0",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Trigger rebuild for total calc
                  },
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1),
          ),
          _summaryRow("Grand Total", _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppTheme.charcoalGray : Colors.grey[700],
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryMaroon,
            fontSize: isTotal ? 20 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PremiumButton(
          text: l10n.cancel ?? "Cancel",
          onPressed: () => Navigator.pop(context),
          isOutlined: true,
          width: 120,
          height: 48,
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
              height: 48,
              icon: Icons.check_circle_outline_rounded,
            );
          },
        ),
      ],
    );
  }

  void _handleSave() async {
    debugPrint('🔍 [AddPurchaseDialog] Starting save process...');

    // 1. Validate General Fields
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ [AddPurchaseDialog] Form validation failed');
      return; // TextField validators will show errors
    }

    if (_invoiceController.text.isEmpty) {
      debugPrint('❌ [AddPurchaseDialog] Invoice number is empty');
      _showError("Please enter an Invoice Number.");
      return;
    }

    if (_selectedVendorId == null) {
      debugPrint('❌ [AddPurchaseDialog] No vendor selected');
      _showError("Please select a Vendor.");
      return;
    }

    // 2. Validate Items
    if (_items.isEmpty) {
      debugPrint('❌ [AddPurchaseDialog] No items added');
      _showError("Please add at least one product to the purchase.");
      return;
    }

    debugPrint('🔍 [AddPurchaseDialog] Validating ${_items.length} items...');
    for (int i = 0; i < _items.length; i++) {
      debugPrint(
        '🔍 [AddPurchaseDialog] Item $i: product=${_items[i].product}, quantity=${_items[i].quantity}, unitCost=${_items[i].unitCost}',
      );

      if (_items[i].product == null) {
        debugPrint('❌ [AddPurchaseDialog] Item #$i: No product selected');
        _showError("Item #${i + 1}: Please select a product.");
        return;
      }
      if (_items[i].quantity <= 0) {
        debugPrint('❌ [AddPurchaseDialog] Item #$i: Invalid quantity');
        _showError("Item #${i + 1}: Quantity must be greater than 0.");
        return;
      }
      // Note: Unit cost can arguably be 0 (free items), so we might not strictly enforce > 0
    }

    debugPrint('✅ [AddPurchaseDialog] All validations passed');
    setState(() => _isLocalLoading = true);

    try {
      final purchase = PurchaseModel(
        vendor: _selectedVendorId,
        invoiceNumber: _invoiceController.text,
        purchaseDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        subtotal: _subtotal,
        tax: _taxAmount,
        total: _total,
        status: _status,
        items: _items,
      );

      debugPrint(
        '🔍 [AddPurchaseDialog] Creating purchase: ${purchase.toJson()}',
      );
      final success = await context.read<PurchaseProvider>().addPurchase(
        purchase,
      );

      if (!mounted) return;

      if (success) {
        debugPrint('✅ [AddPurchaseDialog] Purchase created successfully');
        Navigator.pop(context);
      } else {
        final error =
            context.read<PurchaseProvider>().error ?? "Failed to save purchase";
        debugPrint('❌ [AddPurchaseDialog] Failed to save purchase: $error');
        _showError(error);
      }
    } catch (e) {
      debugPrint('❌ [AddPurchaseDialog] Exception during save: $e');
      _showError("Unexpected error: $e");
    } finally {
      if (mounted) setState(() => _isLocalLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Validation Error",
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(color: AppTheme.primaryMaroon),
            ),
          ),
        ],
      ),
    );
  }
}
