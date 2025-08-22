import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/order_item_provider.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/models/product/product_model.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/models/order/order_item_model.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';
import '../globals/drop_down.dart';

class EditOrderItemDialog extends StatefulWidget {
  final OrderItemModel orderItem;

  const EditOrderItemDialog({super.key, required this.orderItem});

  @override
  State<EditOrderItemDialog> createState() => _EditOrderItemDialogState();
}

class _EditOrderItemDialogState extends State<EditOrderItemDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _customizationNotesController;

  // Selected models for dropdowns
  OrderModel? _selectedOrder;
  Product? _selectedProduct;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing order item data
    _quantityController = TextEditingController(text: widget.orderItem.quantity.toString());
    _unitPriceController = TextEditingController(text: widget.orderItem.unitPrice.toString());
    _customizationNotesController = TextEditingController(text: widget.orderItem.customizationNotes);

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Load orders and products for dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDropdownData();
      _setInitialSelections();
    });
  }

  void _loadDropdownData() {
    // Load orders and products for dropdowns
    final orderProvider = context.read<OrderProvider>();
    final productProvider = context.read<ProductProvider>();

    if (orderProvider.orders.isEmpty) {
      orderProvider.refreshOrders();
    }

    if (productProvider.products.isEmpty) {
      productProvider.refreshProducts();
    }
  }

  void _setInitialSelections() {
    // Set initial selections based on existing order item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      final productProvider = context.read<ProductProvider>();

      // Find and set the current order
      final currentOrder = orderProvider.orders.firstWhere(
        (order) => order.id == widget.orderItem.orderId,
        orElse: () => OrderModel(
          id: widget.orderItem.orderId,
          customerId: '',
          customerName: 'Unknown Customer',
          customerPhone: '',
          customerEmail: '',
          advancePayment: 0.0,
          totalAmount: 0.0,
          remainingAmount: 0.0,
          isFullyPaid: false,
          dateOrdered: DateTime.now(),
          expectedDeliveryDate: DateTime.now(),
          description: '',
          status: OrderStatus.PENDING,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: null,
          createdById: null,
          conversionStatus: '',
          convertedSalesAmount: 0.0,
          conversionDate: null,
          daysSinceOrdered: 0,
          daysUntilDelivery: null,
          isOverdue: false,
          paymentPercentage: 0.0,
          orderSummary: {},
          deliveryStatus: '',
        ),
      );

      // Find and set the current product
      final currentProduct = productProvider.products.firstWhere(
        (product) => product.id == widget.orderItem.productId,
        orElse: () => Product(
          id: widget.orderItem.productId,
          name: widget.orderItem.productName,
          detail: '',
          price: widget.orderItem.unitPrice,
          costPrice: null,
          color: '',
          fabric: '',
          pieces: [],
          quantity: 0,
          categoryId: null,
          categoryName: null,
          stockStatus: '',
          stockStatusDisplay: '',
          totalValue: 0.0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: null,
          createdById: null,
          createdByEmail: null,
        ),
      );

      setState(() {
        _selectedOrder = currentOrder;
        _selectedProduct = currentProduct;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _customizationNotesController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate that order and product selections haven't changed
      if (_selectedOrder?.id != widget.orderItem.orderId) {
        _showErrorSnackbar('Changing the order is not allowed. Please create a new order item instead.');
        return;
      }

      if (_selectedProduct?.id != widget.orderItem.productId) {
        _showErrorSnackbar('Changing the product is not allowed. Please create a new order item instead.');
        return;
      }

      final orderItemProvider = Provider.of<OrderItemProvider>(context, listen: false);

      final success = await orderItemProvider.updateOrderItem(
        id: widget.orderItem.id,
        quantity: int.tryParse(_quantityController.text.trim()) ?? widget.orderItem.quantity,
        unitPrice: double.tryParse(_unitPriceController.text.trim()) ?? widget.orderItem.unitPrice,
        customizationNotes: _customizationNotesController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(orderItemProvider.errorMessage ?? 'Failed to update order item');
        }
      }
    }
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              'Order item updated successfully!',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  double get _lineTotal {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    return quantity * unitPrice;
  }

  Widget _buildSearchableDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownItem<T?>> items,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
    String? searchHint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
        ),
        SizedBox(height: context.smallPadding / 2),
        InkWell(
          onTap: () => _showSearchableDropdown<T>(context, items, value, onChanged, searchHint),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              color: AppTheme.pureWhite,
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: context.iconSize('small'), color: Colors.grey[600]),
                  SizedBox(width: context.smallPadding / 2),
                ],
                Expanded(
                  child: Text(
                    value != null
                        ? items.firstWhere((item) => item.value == value, orElse: () => DropdownItem<T?>(value: null, label: '')).label
                        : hint,
                    style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: value != null ? AppTheme.charcoalGray : Colors.grey[500]),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchableDropdown<T>(
    BuildContext context,
    List<DropdownItem<T?>> items,
    T? currentValue,
    ValueChanged<T?> onChanged,
    String? searchHint,
  ) {
    final searchController = TextEditingController();
    List<DropdownItem<T?>> filteredItems = List.from(items);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius('large'))),
            child: Container(
              width: 400,
              padding: EdgeInsets.all(context.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select ${T == OrderModel ? 'Order' : 'Product'}',
                    style: GoogleFonts.inter(fontSize: context.headerFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                  ),
                  SizedBox(height: context.cardPadding),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: searchHint ?? 'Search...',
                      hintStyle: GoogleFonts.inter(fontSize: context.subtitleFontSize, color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                    ),
                    onChanged: (query) {
                      setState(() {
                        if (query.isEmpty) {
                          filteredItems = List.from(items);
                        } else {
                          filteredItems = items.where((item) => item.label.toLowerCase().contains(query.toLowerCase())).toList();
                        }
                      });
                    },
                  ),
                  SizedBox(height: context.cardPadding),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text(
                            item.label,
                            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            onChanged(item.value);
                            Navigator.of(context).pop();
                          },
                          tileColor: item.value == currentValue ? AppTheme.primaryMaroon.withOpacity(0.1) : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderDropdown() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return _buildSearchableDropdown<OrderModel>(
          label: 'Select Order',
          hint: 'Type customer name to search...',
          value: _selectedOrder,
          items: _getOrderDropdownItems(orderProvider),
          onChanged: (order) {
            setState(() {
              _selectedOrder = order;
            });
          },
          prefixIcon: Icons.receipt_long_outlined,
          searchHint: 'Search by customer name...',
        );
      },
    );
  }

  Widget _buildProductDropdown() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return _buildSearchableDropdown<Product>(
          label: 'Select Product',
          hint: 'Type product name to search...',
          value: _selectedProduct,
          items: _getProductDropdownItems(productProvider),
          onChanged: (product) {
            setState(() {
              _selectedProduct = product;
            });
          },
          prefixIcon: Icons.inventory_2_outlined,
          searchHint: 'Search by product name...',
        );
      },
    );
  }

  List<DropdownItem<OrderModel?>> _getOrderDropdownItems(OrderProvider orderProvider) {
    final orders = orderProvider.orders;
    return [
      DropdownItem<OrderModel?>(value: null, label: 'Select an order...'),
      ...orders.map((order) => DropdownItem<OrderModel?>(value: order, label: '${order.customerName} - ${order.id.substring(0, 8)}...')),
    ];
  }

  List<DropdownItem<Product?>> _getProductDropdownItems(ProductProvider productProvider) {
    final products = productProvider.products;
    return [
      DropdownItem<Product?>(value: null, label: 'Select a product...'),
      ...products.map((product) => DropdownItem<Product?>(value: product, label: '${product.name} - ${product.id.substring(0, 8)}...')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: ResponsiveBreakpoints.responsive(context, tablet: 85.w, small: 80.w, medium: 75.w, large: 70.w, ultrawide: 65.w),
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 85.h),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: context.shadowBlur('heavy'), offset: Offset(0, context.cardPadding)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildFormContent()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Icon(Icons.edit_outlined, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Order Item',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!context.isTablet) ...[
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    'Update order item information',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.pureWhite.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          widget.orderItem.id,
                          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
                        ),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          widget.orderItem.productName,
                          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleCancel,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                child: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.cardPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Information Section
                _buildProductInfoSection(),
                SizedBox(height: context.cardPadding),

                // Order Item Details Section
                _buildOrderItemDetailsSection(),
                SizedBox(height: context.cardPadding),

                // Line Total Section
                _buildLineTotalSection(),
                SizedBox(height: context.mainPadding),

                // Action Buttons
                ResponsiveBreakpoints.responsive(
                  context,
                  tablet: _buildCompactButtons(),
                  small: _buildCompactButtons(),
                  medium: _buildDesktopButtons(),
                  large: _buildDesktopButtons(),
                  ultrawide: _buildDesktopButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.blue, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Product Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Product Name',
            hint: 'Product name',
            controller: TextEditingController(text: widget.orderItem.productName),
            prefixIcon: Icons.shopping_bag_outlined,
            enabled: false,
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(child: _buildProductDropdown()),
              SizedBox(width: context.cardPadding),
              Expanded(child: _buildOrderDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemDetailsSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_outlined, color: Colors.green, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Order Item Details',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  label: 'Quantity *',
                  hint: 'Enter quantity',
                  controller: _quantityController,
                  prefixIcon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter quantity';
                    }
                    final quantity = int.tryParse(value!);
                    if (quantity == null || quantity <= 0) {
                      return 'Quantity must be a positive number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumTextField(
                  label: 'Unit Price (PKR) *',
                  hint: 'Enter unit price',
                  controller: _unitPriceController,
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter unit price';
                    }
                    final price = double.tryParse(value!);
                    if (price == null || price < 0) {
                      return 'Unit price must be a positive number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Customization Notes',
            hint: 'Enter any customization notes or special requirements',
            controller: _customizationNotesController,
            prefixIcon: Icons.note_outlined,
            maxLines: 3,
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'Notes must be less than 500 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineTotalSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: Colors.orange, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Line Total',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Line Total:',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: Colors.orange[700]),
                ),
                Text(
                  'PKR ${_lineTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w700, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<OrderItemProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Update Order Item',
              onPressed: provider.isLoading ? null : _handleUpdate,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.save_rounded,
              backgroundColor: Colors.blue,
            );
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleCancel,
          isOutlined: true,
          height: context.buttonHeight,
          backgroundColor: Colors.grey[600],
          textColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: AppTheme.pureWhite,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 1,
          child: Consumer<OrderItemProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update',
                onPressed: provider.isLoading ? null : _handleUpdate,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.save_rounded,
                backgroundColor: Colors.blue,
              );
            },
          ),
        ),
      ],
    );
  }
}
