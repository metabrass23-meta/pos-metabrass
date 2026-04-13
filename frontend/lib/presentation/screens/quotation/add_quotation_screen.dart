import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../src/models/quotation/quotation_model.dart';
import '../../../../src/services/quotation_service.dart';
import '../../../../src/theme/app_theme.dart';
import '../../../../src/providers/customer_provider.dart';
import '../../../../src/providers/product_provider.dart';
import '../../../../src/models/customer/customer_model.dart';
import '../../../../src/models/product/product_model.dart';

class AddQuotationScreen extends StatefulWidget {
  final QuotationModel? existingQuotation;
  const AddQuotationScreen({Key? key, this.existingQuotation}) : super(key: key);

  @override
  _AddQuotationScreenState createState() => _AddQuotationScreenState();
}

class _AddQuotationScreenState extends State<AddQuotationScreen> {
  final QuotationService _quotationService = QuotationService();

  final TextEditingController _qNoController = TextEditingController(text: 'QT-00000');
  final TextEditingController _dateController = TextEditingController(text: '');
  final TextEditingController _discountController = TextEditingController(text: '0.0');
  final TextEditingController _quantityController = TextEditingController(text: '1');

  Customer? _selectedCustomer;
  ProductModel? _selectedProduct;
  List<QuotationItemModel> _items = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
    if (widget.existingQuotation != null) {
      _qNoController.text = widget.existingQuotation!.quotationNumber;
      _dateController.text = widget.existingQuotation!.dateIssued.toString().split(' ')[0];
      _discountController.text = widget.existingQuotation!.discountAmount.toString();
      _items = List.from(widget.existingQuotation!.items);
    }
    _fetchInitialData();
  }

  void _fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CustomerProvider>().loadCustomers(showLoadingIndicator: false);
      context.read<ProductProvider>().loadProducts(showInactive: false);
      
      if (widget.existingQuotation != null) {
        final customers = context.read<CustomerProvider>().customers;
        setState(() {
          try {
            _selectedCustomer = customers.firstWhere((c) => c.id == widget.existingQuotation!.customerId);
          } catch (_) {
             _selectedCustomer = null;
          }
        });
      }
    });
  }

  void _addItem() {
    if (_selectedProduct == null) return;
    int quantity = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      _items.add(QuotationItemModel(
        id: '',
        quotationId: '',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: quantity,
        unitPrice: _selectedProduct!.price,
        lineTotal: _selectedProduct!.price * quantity,
      ));
      _selectedProduct = null;
      _quantityController.text = '1';
    });
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);
  double get _discount => double.tryParse(_discountController.text) ?? 0.0;
  double get _grandTotal => _subtotal - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Add Quotation', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Header Section from Screenshot
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildHeaderField('CUSTOMER:', _buildCustomerDropdown()),
                      const SizedBox(width: 16),
                      _buildHeaderField('DATE:', _buildDateField()),
                      const SizedBox(width: 16),
                      _buildHeaderField('QUOTATION NO:', _buildEditableField(_qNoController)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductDialog(),
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        label: const Text('ADD PRODUCT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0061E0),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Table Section
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildTableHeader(),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) => _buildItemRow(_items[index], index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Section with Totals and Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildTotalSection(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _footerButton('Save Quotation', const Color(0xFF0061E0), Colors.white, Icons.save, _saveQuotation),
                          const SizedBox(width: 12),
                          _footerButton('Cancel', const Color(0xFFEF5350), Colors.white, Icons.close, () => Navigator.pop(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        SizedBox(width: 180, child: child),
      ],
    );
  }

  Widget _buildCustomerDropdown() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        // Find current selected customer in the current list to avoid reference errors
        Customer? currentMatch;
        if (_selectedCustomer != null) {
           try {
             currentMatch = provider.customers.firstWhere((c) => c.id == _selectedCustomer!.id);
           } catch (_) {
             currentMatch = null;
           }
        }

        return Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black87, width: 1), 
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Customer>(
              value: currentMatch,
              isExpanded: true,
              dropdownColor: Colors.white,
              hint: const Text('SEARCH & SELECT CUSTOMER', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
              onChanged: (val) => setState(() => _selectedCustomer = val),
              items: provider.customers.map((c) => DropdownMenuItem(
                value: c, 
                child: Text('${c.name} (${c.phone})', style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))
              )).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: _dateController,
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) => Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0061E0),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            setState(() => _dateController.text = picked.toString().split(' ')[0]);
          }
        },
        style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.calendar_month, size: 20, color: Color(0xFF0061E0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black26, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black26, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF0061E0), width: 2)),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF0061E0), width: 2)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF0061E0), width: 2.5)),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFFF1F3F5),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('PRODUCT NAME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12))),
          Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12))),
          Expanded(child: Text('PRICE (EDIT)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12))),
          Expanded(child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12))),
          Expanded(child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildItemRow(QuotationItemModel item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
          Expanded(child: Text('${item.quantity}', style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold))),
          Expanded(
            child: InkWell(
              onTap: () => _editItem(index),
              child: Text(
                item.unitPrice.toStringAsFixed(0), 
                style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
              ),
            ),
          ),
          Expanded(child: Text(item.lineTotal.toStringAsFixed(0), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black))),
          Expanded(
            child: Row(
              children: [
                _smallActionButton(Icons.edit, Colors.grey.shade700, () => _editItem(index)),
                const SizedBox(width: 8),
                _smallActionButton(Icons.delete, const Color(0xFFEF5350), () => setState(() => _items.removeAt(index))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  void _editItem(int index) {
    final qtyController = TextEditingController(text: _items[index].quantity.toString());
    final priceController = TextEditingController(text: _items[index].unitPrice.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Icon(Icons.edit_note, size: 40, color: Color(0xFF0061E0)),
            const SizedBox(height: 8),
            Text('Edit Item Details', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(_items[index].productName, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('  QUANTITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 4),
            TextField(
              controller: qtyController,
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('  UNIT PRICE (PKR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 4),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.payments, color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.close, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text('CANCEL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      int newQty = int.tryParse(qtyController.text) ?? _items[index].quantity;
                      double newPrice = double.tryParse(priceController.text) ?? _items[index].unitPrice;
                      setState(() {
                        _items[index] = _items[index].copyWith(
                          quantity: newQty,
                          unitPrice: newPrice,
                          lineTotal: newPrice * newQty,
                        );
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061E0),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('UPDATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          _totalRow('Subtotal:', _subtotal.toStringAsFixed(0)),
          const Divider(height: 1),
          _totalRow('Total Discount:', _discount.toStringAsFixed(0)),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('PKR ${_grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0061E0))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _footerButton(String label, Color bg, Color text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: text, size: 16),
      label: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          title: const Text('Add Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Dropdown
              Consumer<ProductProvider>(
                builder: (context, provider, child) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProductModel>(
                      isExpanded: true,
                      hint: const Text('Select Product', style: TextStyle(fontSize: 14)),
                      value: _selectedProduct,
                      onChanged: (val) {
                        setDialogState(() => _selectedProduct = val);
                        setState(() => _selectedProduct = val);
                      },
                      items: provider.allProducts.map((p) => DropdownMenuItem(
                        value: p, 
                        child: Text(p.name, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600))
                      )).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Rounded Quantity Field
              TextField(
                controller: _quantityController,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black26)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black26)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFF0061E0), width: 2)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: Colors.black26),
                  ),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedProduct != null) {
                      _addItem();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0061E0),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'ADD PRODUCT', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuotation() async {
    if (_selectedCustomer == null || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer and add items')));
      return;
    }
    setState(() => _isSaving = true);
    
    final quotation = QuotationModel(
      id: widget.existingQuotation?.id ?? '',
      customerId: _selectedCustomer!.id,
      customerName: _selectedCustomer!.name,
      baseAmount: _subtotal,
      discountAmount: _discount,
      taxAmount: 0.0,
      grandTotal: _grandTotal,
      manualQuotationNumber: _qNoController.text,
      dateIssued: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      description: '',
      termsConditions: '',
      status: widget.existingQuotation?.status ?? QuotationStatus.PENDING,
      conversionStatus: widget.existingQuotation?.conversionStatus ?? 'NOT_CONVERTED',
      items: _items,
    );

    final response = widget.existingQuotation != null
        ? await _quotationService.updateQuotation(quotation)
        : await _quotationService.createQuotation(quotation);

    if (response.success) {
      if (mounted) Navigator.pop(context, true);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.message}')));
    }
    setState(() => _isSaving = false);
  }
}
