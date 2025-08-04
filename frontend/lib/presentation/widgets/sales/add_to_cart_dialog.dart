import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/models/product/product_model.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_field.dart';
import '../globals/text_button.dart';

class EnhancedAddToCartDialog extends StatefulWidget {
  final Product product;

  const EnhancedAddToCartDialog({super.key, required this.product});

  @override
  State<EnhancedAddToCartDialog> createState() => _EnhancedAddToCartDialogState();
}

class _EnhancedAddToCartDialogState extends State<EnhancedAddToCartDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _customPriceController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isCustomPrice = false;
  bool _hasNotes = false;
  int _quantity = 1;
  double _itemDiscount = 0.0;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<SalesProvider>(context, listen: false);

      final customPrice = _isCustomPrice ? double.tryParse(_customPriceController.text) ?? widget.product.price : widget.product.price;
      final notes = _hasNotes && _notesController.text.isNotEmpty ? _notesController.text : null;

      // Create a modified product if custom price is used
      final productToAdd = _isCustomPrice
          ? widget.product.copyWith(price: customPrice)
          : widget.product;

      provider.addToCartWithCustomization(
        productToAdd,
        _quantity,
        itemDiscount: _itemDiscount,
        customizationNotes: notes,
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
                  '${widget.product.name} added to cart',
                  style: GoogleFonts.inter(color: AppTheme.pureWhite),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
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

  double get _lineTotal {
    return (_currentPrice * _quantity) - _itemDiscount;
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
                    tablet: 90.w,
                    small: 85.w,
                    medium: 75.w,
                    large: 65.w,
                    ultrawide: 55.w,
                  ),
                  maxHeight: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 90.h,
                    small: 85.h,
                    medium: 80.h,
                    large: 75.h,
                    ultrawide: 70.h,
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
                    Flexible(child: _buildContent()),
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
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
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
              Icons.add_shopping_cart_rounded,
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
                  'Add to Cart',
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductInfo(),
            SizedBox(height: context.cardPadding),
            _buildQuantitySection(),
            SizedBox(height: context.cardPadding),
            _buildPriceSection(),
            SizedBox(height: context.cardPadding),
            _buildDiscountSection(),
            SizedBox(height: context.cardPadding),
            _buildNotesSection(),
            SizedBox(height: context.cardPadding),
            _buildOrderSummary(),
            SizedBox(height: context.cardPadding),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Row(
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
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            // Quantity Controls
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
                          color: _quantity > 1 ? AppTheme.primaryMaroon : Colors.grey,
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
                        setState(() {
                          _quantity = qty.clamp(1, widget.product.quantity);
                        });
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
                          color: _quantity < widget.product.quantity ? AppTheme.primaryMaroon : Colors.grey,
                          size: context.iconSize('medium'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.cardPadding),

            // Quick Quantity Buttons
            ...([2, 5, 10].where((qty) => qty <= widget.product.quantity).map((qty) {
              return Container(
                margin: EdgeInsets.only(right: context.smallPadding / 2),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _quantity = qty;
                        _quantityController.text = qty.toString();
                      });
                    },
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.smallPadding,
                        vertical: context.smallPadding / 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _quantity == qty ? AppTheme.primaryMaroon : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                        color: _quantity == qty ? AppTheme.primaryMaroon.withOpacity(0.1) : null,
                      ),
                      child: Text(
                        qty.toString(),
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w600,
                          color: _quantity == qty ? AppTheme.primaryMaroon : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price',
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
              activeColor: AppTheme.primaryMaroon,
            ),
            SizedBox(width: context.smallPadding),
            Text(
              'Custom Price',
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),

        if (_isCustomPrice) ...[
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
        ] else ...[
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unit Price:',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  'PKR ${widget.product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Discount (Optional)',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoalGray,
          ),
        ),
        SizedBox(height: context.smallPadding),

        // Quick Discount Buttons
        Row(
          children: [
            ...[5, 10, 15, 20].map((percentage) {
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
            SizedBox(width: context.smallPadding),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                'PKR ${_itemDiscount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: context.smallPadding),

        // Clear Discount Button
        if (_itemDiscount > 0)
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
                    'Clear Discount',
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
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Customization Notes',
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
              activeColor: AppTheme.primaryMaroon,
            ),
          ],
        ),

        if (_hasNotes) ...[
          SizedBox(height: context.smallPadding),
          PremiumTextField(
            label: 'Special Instructions',
            controller: _notesController,
            prefixIcon: Icons.note_outlined,
            maxLines: 3,
            hint: 'Any special requirements, alterations, or notes...',
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unit Price:',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                'PKR ${_currentPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity:',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                _quantity.toString(),
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
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

          if (_itemDiscount > 0) ...[
            SizedBox(height: context.smallPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount:',
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

          SizedBox(height: context.smallPadding / 2),
          Divider(),
          SizedBox(height: context.smallPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            isOutlined: true,
            height: context.buttonHeight,
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
            height: context.buttonHeight,
            icon: Icons.add_shopping_cart_rounded,
            backgroundColor: AppTheme.primaryMaroon,
          ),
        ),
      ],
    );
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