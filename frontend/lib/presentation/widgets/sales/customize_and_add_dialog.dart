import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/product_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_field.dart';
import '../globals/text_button.dart';

class CustomizeAndAddDialog extends StatefulWidget {
  final Product product;

  const CustomizeAndAddDialog({super.key, required this.product});

  @override
  State<CustomizeAndAddDialog> createState() => _CustomizeAndAddDialogState();
}

class _CustomizeAndAddDialogState extends State<CustomizeAndAddDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _customPriceController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Customization options
  int _quantity = 1;
  double _itemDiscount = 0.0;
  bool _isCustomPrice = false;
  bool _hasNotes = false;

  // Advanced customization options
  String _selectedSize = '';
  String _selectedFitting = 'Standard';
  String _selectedEmbroidery = 'None';
  String _selectedFabricQuality = 'Standard';
  Color _selectedAccentColor = Colors.transparent;
  bool _expressDelivery = false;
  bool _giftWrapping = false;

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Custom'];
  final List<String> _fittingOptions = ['Slim Fit', 'Standard', 'Loose Fit', 'Custom Tailored'];
  final List<String> _embroideryOptions = ['None', 'Basic', 'Premium', 'Luxury Hand Work'];
  final List<String> _fabricQualityOptions = ['Standard', 'Premium', 'Luxury'];
  final List<Color> _accentColors = [
    Colors.transparent,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _customPriceController.text = widget.product.price.toStringAsFixed(0);
    _selectedSize = _availableSizes[2]; // Default to 'M'
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<SalesProvider>(context, listen: false);

      final customPrice = _isCustomPrice ? double.tryParse(_customPriceController.text) ?? widget.product.price : widget.product.price;
      final notes = _buildCustomizationNotes();

      // Calculate additional charges
      final additionalCharges = _calculateAdditionalCharges();
      final finalPrice = customPrice + additionalCharges;

      // Create a modified product if custom price or additional charges apply
      final productToAdd = (additionalCharges > 0 || _isCustomPrice)
          ? widget.product.copyWith(price: finalPrice)
          : widget.product;

      provider.addToCartWithCustomization(
        productToAdd,
        _quantity,
        itemDiscount: _itemDiscount,
        customizationNotes: notes,
        customOptions: _getCustomOptions(),
      );

      _handleSuccess();
    }
  }

  void _handleSuccess() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Text(
                  'Customized ${widget.product.name} added to cart',
                  style: GoogleFonts.inter(color: AppTheme.pureWhite),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
        ),
      );
    });
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  double get _currentPrice {
    return _isCustomPrice
        ? double.tryParse(_customPriceController.text) ?? widget.product.price
        : widget.product.price;
  }

  double _calculateAdditionalCharges() {
    double charges = 0.0;

    // Size charges
    if (_selectedSize == 'Custom') charges += 2000;

    // Fitting charges
    switch (_selectedFitting) {
      case 'Custom Tailored':
        charges += 3000;
        break;
      case 'Slim Fit':
        charges += 500;
        break;
    }

    // Embroidery charges
    switch (_selectedEmbroidery) {
      case 'Basic':
        charges += 1500;
        break;
      case 'Premium':
        charges += 4000;
        break;
      case 'Luxury Hand Work':
        charges += 8000;
        break;
    }

    // Fabric quality charges
    switch (_selectedFabricQuality) {
      case 'Premium':
        charges += widget.product.price * 0.3;
        break;
      case 'Luxury':
        charges += widget.product.price * 0.6;
        break;
    }

    // Additional services
    if (_expressDelivery) charges += 1000;
    if (_giftWrapping) charges += 500;

    return charges;
  }

  double get _lineTotal {
    final basePrice = _currentPrice + _calculateAdditionalCharges();
    return (basePrice * _quantity) - _itemDiscount;
  }

  String _buildCustomizationNotes() {
    List<String> notes = [];

    notes.add('Size: $_selectedSize');
    notes.add('Fitting: $_selectedFitting');
    if (_selectedEmbroidery != 'None') notes.add('Embroidery: $_selectedEmbroidery');
    notes.add('Fabric Quality: $_selectedFabricQuality');
    if (_selectedAccentColor != Colors.transparent) {
      notes.add('Accent Color: ${_getColorName(_selectedAccentColor)}');
    }
    if (_expressDelivery) notes.add('Express Delivery Required');
    if (_giftWrapping) notes.add('Gift Wrapping Required');

    if (_hasNotes && _notesController.text.isNotEmpty) {
      notes.add('Special Instructions: ${_notesController.text}');
    }

    return notes.join(' • ');
  }

  Map<String, dynamic> _getCustomOptions() {
    return {
      'size': _selectedSize,
      'fitting': _selectedFitting,
      'embroidery': _selectedEmbroidery,
      'fabric_quality': _selectedFabricQuality,
      'accent_color': _getColorName(_selectedAccentColor),
      'express_delivery': _expressDelivery,
      'gift_wrapping': _giftWrapping,
      'additional_charges': _calculateAdditionalCharges(),
    };
  }

  String _getColorName(Color color) {
    if (color == Colors.transparent) return 'None';
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.orange) return 'Orange';
    return 'Custom';
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
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 95.w,
                    small: 90.w,
                    medium: 85.w,
                    large: 80.w,
                    ultrawide: 75.w,
                  ),
                  maxHeight: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 95.h,
                    small: 90.h,
                    medium: 85.h,
                    large: 80.h,
                    ultrawide: 75.h,
                  ),
                ),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: context.shadowBlur('heavy'),
                      offset: Offset(0, context.cardPadding),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: ResponsiveBreakpoints.responsive(
                        context,
                        tablet: _buildScrollableContent(),
                        small: _buildScrollableContent(),
                        medium: _buildDesktopLayout(),
                        large: _buildDesktopLayout(),
                        ultrawide: _buildDesktopLayout(),
                      ),
                    ),
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
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('large'),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize & Add',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                  ),
                ),
                Text(
                  widget.product.name,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: AppTheme.pureWhite.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.pureWhite,
                  size: context.iconSize('medium'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProductInfo(),
              SizedBox(height: context.cardPadding),
              _buildQuantityAndPricing(),
              SizedBox(height: context.cardPadding),
              _buildSizeAndFitting(),
              SizedBox(height: context.cardPadding),
              _buildCustomizationOptions(),
              SizedBox(height: context.cardPadding),
              _buildAdditionalServices(),
              SizedBox(height: context.cardPadding),
              _buildSpecialInstructions(),
              SizedBox(height: context.cardPadding),
              _buildOrderSummary(),
              SizedBox(height: context.cardPadding),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildProductInfo(),
                    SizedBox(height: context.cardPadding),
                    _buildQuantityAndPricing(),
                    SizedBox(height: context.cardPadding),
                    _buildSizeAndFitting(),
                    SizedBox(height: context.cardPadding),
                    _buildOrderSummary(),
                  ],
                ),
              ),

              SizedBox(width: context.cardPadding),

              // Right Column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildCustomizationOptions(),
                    SizedBox(height: context.cardPadding),
                    _buildAdditionalServices(),
                    SizedBox(height: context.cardPadding),
                    _buildSpecialInstructions(),
                    SizedBox(height: context.cardPadding),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Colors.blue,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Product Information',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Icon(
                  Icons.checkroom_outlined,
                  color: Colors.grey[500],
                  size: context.iconSize('large'),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColorFromName(widget.product.color),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        SizedBox(width: context.smallPadding / 2),
                        Text(
                          '${widget.product.color} • ${widget.product.fabric}',
                          style: GoogleFonts.inter(
                            fontSize: context.captionFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.smallPadding,
                        vertical: context.smallPadding / 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.product.stockStatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                      ),
                      child: Text(
                        'Stock: ${widget.product.quantity} available',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w500,
                          color: widget.product.stockStatusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndPricing() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_rounded,
                color: Colors.green,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Quantity & Pricing',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Quantity Controls
          Text(
            'Quantity',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _quantity > 1 ? () {
                          setState(() {
                            _quantity--;
                            _quantityController.text = _quantity.toString();
                          });
                        } : null,
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                        child: Container(
                          padding: EdgeInsets.all(context.smallPadding),
                          child: Icon(
                            Icons.remove,
                            color: _quantity > 1 ? Colors.green : Colors.grey,
                            size: context.iconSize('medium'),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      padding: EdgeInsets.symmetric(vertical: context.smallPadding),
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoalGray,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          final qty = int.tryParse(value) ?? 1;
                          setState(() => _quantity = qty.clamp(1, widget.product.quantity));
                        },
                        validator: (value) {
                          final qty = int.tryParse(value ?? '') ?? 0;
                          if (qty < 1) return 'Min 1';
                          if (qty > widget.product.quantity) return 'Max ${widget.product.quantity}';
                          return null;
                        },
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _quantity < widget.product.quantity ? () {
                          setState(() {
                            _quantity++;
                            _quantityController.text = _quantity.toString();
                          });
                        } : null,
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                        child: Container(
                          padding: EdgeInsets.all(context.smallPadding),
                          child: Icon(
                            Icons.add,
                            color: _quantity < widget.product.quantity ? Colors.green : Colors.grey,
                            size: context.iconSize('medium'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: context.cardPadding),

          // Custom Price Toggle
          Row(
            children: [
              Text(
                'Custom Price',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: _isCustomPrice,
                onChanged: (value) {
                  setState(() {
                    _isCustomPrice = value;
                    if (!value) {
                      _customPriceController.text = widget.product.price.toStringAsFixed(0);
                    }
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),

          if (_isCustomPrice) ...[
            SizedBox(height: context.smallPadding),
            PremiumTextField(
              label: 'Custom Price (PKR)',
              controller: _customPriceController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money_rounded,
              validator: (value) {
                final price = double.tryParse(value ?? '');
                if (price == null || price <= 0) return 'Please enter a valid price';
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
          ],

          SizedBox(height: context.cardPadding),

          // Item Discount
          Text(
            'Item Discount (Optional)',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Row(
            children: [5, 10, 15, 20].map((percentage) {
              final discountAmount = (_currentPrice * percentage) / 100;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: percentage != 20 ? context.smallPadding / 2 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _itemDiscount = discountAmount;
                        });
                      },
                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.smallPadding / 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _itemDiscount == discountAmount
                                ? Colors.orange
                                : Colors.orange.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(context.borderRadius('small')),
                          color: _itemDiscount == discountAmount
                              ? Colors.orange.withOpacity(0.1)
                              : null,
                        ),
                        child: Text(
                          '$percentage%',
                          style: GoogleFonts.inter(
                            fontSize: context.captionFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_itemDiscount > 0) ...[
            SizedBox(height: context.smallPadding / 2),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _itemDiscount = 0.0),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.smallPadding,
                      vertical: context.smallPadding / 2,
                    ),
                    child: Text(
                      'Clear Discount (PKR ${_itemDiscount.toStringAsFixed(0)})',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSizeAndFitting() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten_rounded,
                color: Colors.purple,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Size & Fitting',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Size Selection
          Text(
            'Size',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Wrap(
            spacing: context.smallPadding / 2,
            runSpacing: context.smallPadding / 2,
            children: _availableSizes.map((size) {
              final isSelected = _selectedSize == size;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedSize = size),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.smallPadding,
                      vertical: context.smallPadding / 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.purple : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                      color: isSelected ? Colors.purple.withOpacity(0.1) : null,
                    ),
                    child: Text(
                      size,
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.purple : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: context.cardPadding),

          // Fitting Options
          Text(
            'Fitting Style',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFitting,
                isExpanded: true,
                onChanged: (value) => setState(() => _selectedFitting = value ?? 'Standard'),
                items: _fittingOptions.map((fitting) => DropdownMenuItem<String>(
                  value: fitting,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
                    child: Text(
                      fitting,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationOptions() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: Colors.orange,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Customization Options',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Embroidery Options
          Text(
            'Embroidery Work',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEmbroidery,
                isExpanded: true,
                onChanged: (value) => setState(() => _selectedEmbroidery = value ?? 'None'),
                items: _embroideryOptions.map((embroidery) => DropdownMenuItem<String>(
                  value: embroidery,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
                    child: Text(
                      embroidery,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          SizedBox(height: context.cardPadding),

          // Fabric Quality
          Text(
            'Fabric Quality',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFabricQuality,
                isExpanded: true,
                onChanged: (value) => setState(() => _selectedFabricQuality = value ?? 'Standard'),
                items: _fabricQualityOptions.map((quality) => DropdownMenuItem<String>(
                  value: quality,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2),
                    child: Text(
                      quality,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          SizedBox(height: context.cardPadding),

          // Accent Color
          Text(
            'Accent Color',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Wrap(
            spacing: context.smallPadding / 2,
            runSpacing: context.smallPadding / 2,
            children: _accentColors.map((color) {
              final isSelected = _selectedAccentColor == color;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedAccentColor = color),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color == Colors.transparent ? Colors.grey.shade200 : color,
                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                      border: Border.all(
                        color: isSelected ? AppTheme.charcoalGray : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: color == Colors.transparent
                        ? Icon(
                      Icons.close_rounded,
                      color: Colors.grey[600],
                      size: context.iconSize('small'),
                    )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalServices() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_box_rounded,
                color: Colors.teal,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Additional Services',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Express Delivery
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: _expressDelivery ? Colors.teal.withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(
                color: _expressDelivery ? Colors.teal.withOpacity(0.3) : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Switch.adaptive(
                  value: _expressDelivery,
                  onChanged: (value) => setState(() => _expressDelivery = value),
                  activeColor: Colors.teal,
                ),
                SizedBox(width: context.smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Express Delivery',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                      Text(
                        'Get your order in 2-3 days (+PKR 1,000)',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: context.smallPadding),

          // Gift Wrapping
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: _giftWrapping ? Colors.teal.withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(
                color: _giftWrapping ? Colors.teal.withOpacity(0.3) : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Switch.adaptive(
                  value: _giftWrapping,
                  onChanged: (value) => setState(() => _giftWrapping = value),
                  activeColor: Colors.teal,
                ),
                SizedBox(width: context.smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gift Wrapping',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                      Text(
                        'Beautiful gift packaging (+PKR 500)',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: Colors.indigo,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Special Instructions',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: _hasNotes,
                onChanged: (value) {
                  setState(() {
                    _hasNotes = value;
                    if (!value) {
                      _notesController.clear();
                    }
                  });
                },
                activeColor: Colors.indigo,
              ),
            ],
          ),

          if (_hasNotes) ...[
            SizedBox(height: context.cardPadding),
            PremiumTextField(
              label: 'Additional Requirements',
              controller: _notesController,
              prefixIcon: Icons.edit_note_rounded,
              maxLines: 4,
              hint: 'Any special requirements, measurements, design preferences, or delivery instructions...',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final additionalCharges = _calculateAdditionalCharges();

    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Colors.green,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Order Summary',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Base Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Price × $_quantity:',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                'PKR ${(_currentPrice * _quantity).toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),

          // Additional Charges Breakdown
          if (additionalCharges > 0) ...[
            SizedBox(height: context.smallPadding / 2),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: context.smallPadding / 2),

            // Show breakdown of additional charges
            if (_selectedSize == 'Custom') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Size:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR 2,000',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],

            if (_selectedFitting == 'Custom Tailored') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Tailoring:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR 3,000',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ] else if (_selectedFitting == 'Slim Fit') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Slim Fit:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR 500',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],

            if (_selectedEmbroidery != 'None') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedEmbroidery:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR ${_getEmbroideryCharge().toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],

            if (_selectedFabricQuality != 'Standard') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedFabricQuality Fabric:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR ${_getFabricQualityCharge().toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],

            if (_expressDelivery) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Express Delivery:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR 1,000',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],

            if (_giftWrapping) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gift Wrapping:',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '+PKR 500',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],
          ],

          // Subtotal with charges
          if (additionalCharges > 0) ...[
            SizedBox(height: context.smallPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal with Customizations:',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  'PKR ${((_currentPrice + additionalCharges) * _quantity).toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ],

          // Item Discount
          if (_itemDiscount > 0) ...[
            SizedBox(height: context.smallPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Discount:',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: Colors.orange[700],
                  ),
                ),
                Text(
                  '- PKR ${_itemDiscount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: context.smallPadding),
          Divider(color: Colors.grey.shade400, thickness: 1.5),
          SizedBox(height: context.smallPadding),

          // Final Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                'PKR ${_lineTotal.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),

          // Savings indicator
          if (_itemDiscount > 0) ...[
            SizedBox(height: context.smallPadding / 2),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  'You save PKR ${_itemDiscount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (context.shouldShowCompactLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumButton(
            text: 'Add to Cart',
            onPressed: _handleAddToCart,
            height: context.buttonHeight,
            icon: Icons.add_shopping_cart_rounded,
            backgroundColor: Colors.blue,
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
    } else {
      return Row(
        children: [
          Expanded(
            child: PremiumButton(
              text: 'Cancel',
              onPressed: _handleCancel,
              isOutlined: true,
              height: context.buttonHeight / 1.5,
              backgroundColor: Colors.grey[600],
              textColor: Colors.grey[600],
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            flex: 2,
            child: PremiumButton(
              text: 'Add to Cart',
              onPressed: _handleAddToCart,
              height: context.buttonHeight / 1.5,
              icon: Icons.add_shopping_cart_rounded,
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      );
    }
  }

  // Helper methods for charge calculations
  double _getEmbroideryCharge() {
    switch (_selectedEmbroidery) {
      case 'Basic':
        return 1500;
      case 'Premium':
        return 4000;
      case 'Luxury Hand Work':
        return 8000;
      default:
        return 0;
    }
  }

  double _getFabricQualityCharge() {
    switch (_selectedFabricQuality) {
      case 'Premium':
        return widget.product.price * 0.3;
      case 'Luxury':
        return widget.product.price * 0.6;
      default:
        return 0;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'navy':
        return Colors.indigo;
      case 'maroon':
        return Colors.red[900]!;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey[400]!;
      case 'beige':
        return Colors.brown[200]!;
      default:
        return Colors.grey;
    }
  }
}