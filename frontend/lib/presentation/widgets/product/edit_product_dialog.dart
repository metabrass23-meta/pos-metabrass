import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/product/product_model.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/drop_down.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class EditProductDialog extends StatefulWidget {
  final Product product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _detailController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _colorController;
  late TextEditingController _fabricController;

  late String? _selectedCategoryId;
  late List<String> _selectedPieces;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _detailController = TextEditingController(text: widget.product.detail);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _colorController = TextEditingController(text: widget.product.color);
    _fabricController = TextEditingController(text: widget.product.fabric);
    _selectedCategoryId = widget.product.categoryId;
    _selectedPieces = List.from(widget.product.pieces);

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _detailController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _colorController.dispose();
    _fabricController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPieces.isEmpty) {
        _showErrorSnackbar('Please select at least one piece');
        return;
      }

      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      final success = await productProvider.updateProduct(
        id: widget.product.id,
        name: _nameController.text.trim(),
        detail: _detailController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        color: _colorController.text.trim(),
        fabric: _fabricController.text.trim(),
        pieces: _selectedPieces,
        quantity: int.parse(_quantityController.text.trim()),
        categoryId: _selectedCategoryId,
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(productProvider.errorMessage ?? 'Failed to update product');
        }
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              'Product updated successfully!',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.pureWhite,
              ),
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
            Icon(Icons.error_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.pureWhite,
                ),
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

  void _handleCancel() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
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
                width: context.dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 95.w,
                    small: 90.w,
                    medium: 80.w,
                    large: 70.w,
                    ultrawide: 60.w,
                  ),
                  maxHeight: 90.h,
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildHeader(), _buildFormContent()],
                  ),
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
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Icon(Icons.edit_outlined, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.shouldShowCompactLayout ? 'Edit Product' : 'Edit Product Details',
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
                    'Update product information',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.pureWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              widget.product.id,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
          SizedBox(width: context.smallPadding),
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
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumTextField(
              label: 'Product Name',
              hint: context.shouldShowCompactLayout ? 'Enter name' : 'Enter product name',
              controller: _nameController,
              prefixIcon: Icons.label_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a product name';
                }
                if (value!.length < 2) {
                  return 'Product name must be at least 2 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Product Detail',
              hint: context.shouldShowCompactLayout ? 'Enter details' : 'Enter product description/details',
              controller: _detailController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter product details';
                }
                if (value!.length < 5) {
                  return 'Product detail must be at least 5 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    label: 'Price',
                    hint: context.shouldShowCompactLayout ? 'Enter price' : 'Enter price (PKR)',
                    controller: _priceController,
                    prefixIcon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter price';
                      }
                      final price = double.tryParse(value!);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: PremiumTextField(
                    label: 'Quantity',
                    hint: context.shouldShowCompactLayout ? 'Enter qty' : 'Enter quantity',
                    controller: _quantityController,
                    prefixIcon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter quantity';
                      }
                      final quantity = int.tryParse(value!);
                      if (quantity == null || quantity < 0) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: context.cardPadding),

            // Category Selection
            Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return PremiumDropdownField<String>(
                  label: 'Category',
                  hint: context.shouldShowCompactLayout ? 'Select category' : 'Select product category',
                  prefixIcon: Icons.category_outlined,
                  items: provider.categories
                      .where((category) => category.isActive)
                      .map((category) => DropdownItem<String>(value: category.id, label: category.name))
                      .toList(),
                  value: _selectedCategoryId,
                  onChanged: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: context.cardPadding),

            // Color Input Field
            PremiumTextField(
              label: 'Color',
              hint: context.shouldShowCompactLayout
                  ? 'Enter color'
                  : 'Enter color name (e.g., Red, Blue, Turquoise)',
              controller: _colorController,
              prefixIcon: Icons.color_lens_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a color';
                }
                if (value!.length < 2) {
                  return 'Color name must be at least 2 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            // Fabric Input Field
            PremiumTextField(
              label: 'Fabric',
              hint: context.shouldShowCompactLayout
                  ? 'Enter fabric'
                  : 'Enter fabric type (e.g., Cotton, Silk, Chiffon)',
              controller: _fabricController,
              prefixIcon: Icons.texture_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a fabric';
                }
                if (value!.length < 2) {
                  return 'Fabric name must be at least 2 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            // Pieces Selection
            Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pieces',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    SizedBox(height: context.smallPadding),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.cardPadding),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                      ),
                      child: Wrap(
                        spacing: context.smallPadding,
                        runSpacing: context.smallPadding,
                        children: provider.availablePieces.map((piece) {
                          final isSelected = _selectedPieces.contains(piece);
                          return FilterChip(
                            label: Text(
                              piece,
                              style: GoogleFonts.inter(
                                fontSize: context.captionFontSize,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppTheme.pureWhite : AppTheme.charcoalGray,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedPieces.add(piece);
                                } else {
                                  _selectedPieces.remove(piece);
                                }
                              });
                            },
                            selectedColor: Colors.blue,
                            checkmarkColor: AppTheme.pureWhite,
                            backgroundColor: AppTheme.lightGray,
                          );
                        }).toList(),
                      ),
                    ),
                    if (_selectedPieces.isEmpty) ...[
                      SizedBox(height: context.smallPadding / 2),
                      Text(
                        'Please select at least one piece',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.red),
                      ),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: context.mainPadding),

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
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Update Product',
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
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update Product',
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
