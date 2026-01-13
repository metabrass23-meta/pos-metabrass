import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/models/sales/sale_model.dart';
import '../../../src/models/sales/request_models.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import 'tax_configuration_widget.dart';

class SalesFormDialog extends StatefulWidget {
  final SaleModel? sale;
  final Function(SaleModel) onSaved;

  const SalesFormDialog({super.key, this.sale, required this.onSaved});

  @override
  State<SalesFormDialog> createState() => _SalesFormDialogState();
}

class _SalesFormDialogState extends State<SalesFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  late TaxConfiguration _taxConfiguration;
  late List<SaleItemModel> _saleItems;
  bool _isLoading = false;
  String? _selectedStatus;
  DateTime? _saleDate;
  String _selectedPaymentMethod = 'CASH';
  double _overallDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.sale != null) {
      // Editing existing sale
      _invoiceNumberController.text = widget.sale!.invoiceNumber;
      _customerNameController.text = widget.sale!.customerName;
      _customerPhoneController.text = widget.sale!.customerPhone;
      _notesController.text = widget.sale!.notes ?? '';
      _selectedStatus = widget.sale!.status;
      _saleDate = widget.sale!.dateOfSale;
      _taxConfiguration = widget.sale!.taxConfiguration;
      _saleItems = List.from(widget.sale!.saleItems);
      _selectedPaymentMethod = widget.sale!.paymentMethod;
      _overallDiscount = widget.sale!.overallDiscount;
    } else {
      // Creating new sale
      _invoiceNumberController.text = '';
      _customerNameController.text = '';
      _customerPhoneController.text = '';
      _notesController.text = '';
      _selectedStatus = 'DRAFT';
      _saleDate = DateTime.now();
      _taxConfiguration = TaxConfiguration();
      _saleItems = [];
      _selectedPaymentMethod = 'CASH';
      _overallDiscount = 0.0;
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius('medium'))),
      child: Container(
        width: 90.w,
        height: 90.h,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildForm()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('medium')),
          topRight: Radius.circular(context.borderRadius('medium')),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.point_of_sale_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Text(
              widget.sale == null ? 'Create New Sale' : 'Edit Sale',
              style: GoogleFonts.playfairDisplay(fontSize: context.headerFontSize, fontWeight: FontWeight.w700, color: AppTheme.pureWhite),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: context.pagePadding,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              SizedBox(height: context.cardPadding),
              _buildSaleItemsSection(),
              SizedBox(height: context.cardPadding),
              _buildTaxSection(),
              SizedBox(height: context.cardPadding),
              _buildSummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('medium')),
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: context.shadowBlur('light'), offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: GoogleFonts.inter(fontSize: context.headingFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _invoiceNumberController,
                  decoration: InputDecoration(
                    labelText: 'Invoice Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter an invoice number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  initialValue: _saleDate?.toString().split(' ')[0] ?? DateTime.now().toString().split(' ')[0],
                  decoration: InputDecoration(
                    labelText: 'Sale Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                    suffixIcon: IconButton(onPressed: () => _selectDate(context), icon: Icon(Icons.calendar_today_rounded)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: TextFormField(
                  controller: _customerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Customer Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter customer phone';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  ),
                  items: [
                    'CASH',
                    'CARD',
                    'BANK_TRANSFER',
                    'MOBILE_PAYMENT',
                    'CREDIT',
                  ].map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: TextFormField(
                  initialValue: _overallDiscount.toString(),
                  decoration: InputDecoration(
                    labelText: 'Overall Discount (Rs.)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _overallDiscount = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            ),
            maxLines: 3,
          ),
          SizedBox(height: context.cardPadding),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            ),
            items: [
              'DRAFT',
              'CONFIRMED',
              'INVOICED',
              'PAID',
              'DELIVERED',
              'CANCELLED',
              'RETURNED',
            ].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a status';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItemsSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('medium')),
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: context.shadowBlur('light'), offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sale Items',
                style: GoogleFonts.inter(fontSize: context.headingFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddSaleItemDialog(),
                icon: Icon(Icons.add_rounded, color: AppTheme.pureWhite, size: context.iconSize('small')),
                label: Text(
                  'Add Item',
                  style: GoogleFonts.inter(color: AppTheme.pureWhite, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          if (_saleItems.isEmpty) _buildEmptySaleItemsState() else _buildSaleItemsList(),
        ],
      ),
    );
  }

  Widget _buildEmptySaleItemsState() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding * 2),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, color: AppTheme.lightGray, size: 8.w),
            SizedBox(height: context.cardPadding),
            Text(
              'No Sale Items Added',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.lightGray),
            ),
            SizedBox(height: context.smallPadding),
            Text(
              'Add items to this sale',
              style: GoogleFonts.inter(fontSize: context.captionFontSize, color: AppTheme.lightGray.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleItemsList() {
    return Column(
      children: _saleItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: context.smallPadding),
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: AppTheme.creamWhite,
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            border: Border.all(color: AppTheme.lightGray.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item.productName,
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
                ),
              ),
              Expanded(
                child: Text(
                  'Qty: ${item.quantity}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
                ),
              ),
              Expanded(
                child: Text(
                  'Rs. ${item.unitPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
                ),
              ),
              Expanded(
                child: Text(
                  'Rs. ${item.lineTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                ),
              ),
              IconButton(
                onPressed: () => _removeSaleItem(index),
                icon: Icon(Icons.delete_rounded, color: Colors.red, size: context.iconSize('small')),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaxSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('medium')),
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: context.shadowBlur('light'), offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Configuration',
            style: GoogleFonts.inter(fontSize: context.headingFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          TaxConfigurationWidget(
            initialConfiguration: _taxConfiguration,
            onConfigurationChanged: (config) {
              setState(() {
                _taxConfiguration = config;
              });
            },
            isEditable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final subtotal = _calculateSubtotal();
    final totalTax = _taxConfiguration.totalTaxAmount;
    // Calculate grand total for display purposes
    final grandTotal = subtotal + totalTax - _overallDiscount;
    // Note: grandTotal is used in the summary display

    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('medium')),
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: context.shadowBlur('light'), offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.inter(fontSize: context.headingFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Overall Discount', _overallDiscount),
          _buildSummaryRow('Total Tax', totalTax),
          Divider(color: AppTheme.lightGray),
          _buildSummaryRow('Grand Total', grandTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.smallPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? context.headingFontSize : context.bodyFontSize,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.charcoalGray,
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? context.headingFontSize : context.bodyFontSize,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.borderRadius('medium')),
          bottomRight: Radius.circular(context.borderRadius('medium')),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.charcoalGray, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(width: context.cardPadding),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveSale,
            child: _isLoading
                ? SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: const CircularProgressIndicator(color: AppTheme.pureWhite, strokeWidth: 2),
                  )
                : Text(
                    widget.sale == null ? 'Create Sale' : 'Update Sale',
                    style: GoogleFonts.inter(color: AppTheme.pureWhite, fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return _saleItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _saleDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _saleDate) {
      setState(() {
        _saleDate = picked;
      });
    }
  }

  void _showAddSaleItemDialog() {
    // TODO: Implement add sale item dialog
    // This would integrate with the products module
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Add Sale Item functionality to be implemented'), backgroundColor: AppTheme.primaryMaroon));
  }

  void _removeSaleItem(int index) {
    setState(() {
      _saleItems.removeAt(index);
    });
  }

  void _saveSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add at least one sale item'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<SalesProvider>();
      final subtotal = _calculateSubtotal();
      final totalTax = _taxConfiguration.totalTaxAmount;
      final grandTotal = subtotal + totalTax - _overallDiscount;

      if (widget.sale == null) {
        // Create new sale
        final saleItems = _saleItems
            .map(
              (item) => CreateSaleItemRequest(
                productId: item.productId,
                unitPrice: item.unitPrice,
                quantity: item.quantity,
                itemDiscount: item.itemDiscount,
                customizationNotes: item.customizationNotes,
              ),
            )
            .toList();

        final request = CreateSaleRequest(
          customerId: 'temp_customer_id', // TODO: Get from customer selection
          overallDiscount: _overallDiscount,
          taxConfiguration: _taxConfiguration,
          paymentMethod: _selectedPaymentMethod,
          notes: _notesController.text.trim(),
          saleItems: saleItems,
        );

        final success = await provider.createSale(request);
        if (success) {
          // TODO: Get the created sale from provider and pass it to onSaved
          Navigator.of(context).pop();
        }
      } else {
        // Update existing sale
        final request = UpdateSaleRequest(
          overallDiscount: _overallDiscount,
          taxConfiguration: _taxConfiguration,
          paymentMethod: _selectedPaymentMethod,
          notes: _notesController.text.trim(),
          status: _selectedStatus,
        );

        final success = await provider.updateSale(widget.sale!.id, request);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving sale: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
