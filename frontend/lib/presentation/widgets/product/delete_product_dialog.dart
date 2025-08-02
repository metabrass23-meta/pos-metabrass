import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class DeleteProductDialog extends StatefulWidget {
  final Product product;

  const DeleteProductDialog({
    super.key,
    required this.product,
  });

  @override
  State<DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends State<DeleteProductDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    await provider.deleteProduct(widget.product.id);

    if (mounted) {
      _showSuccessSnackbar();
      Navigator.of(context).pop();
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              'Product deleted successfully!',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
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
          backgroundColor: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(
                  _shakeAnimation.value * 2 * (1 - _scaleAnimation.value),
                  0,
                ),
                child: Container(
                  width: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 85.w,
                    small: 75.w,
                    medium: 65.w,
                    large: 55.w,
                    ultrawide: 45.w,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 550,
                    maxHeight: 85.h,
                  ),
                  margin: EdgeInsets.all(context.mainPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(context.borderRadius('large')),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: context.shadowBlur('heavy'),
                        offset: Offset(0, context.cardPadding),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        _buildContent(),
                      ],
                    ),
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
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
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
              Icons.warning_rounded,
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
                  context.shouldShowCompactLayout ? 'Delete Product' : 'Delete Product Record',
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
                    'This action cannot be undone',
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
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: ResponsiveBreakpoints.responsive(
                context,
                tablet: 5.w,
                small: 5.w,
                medium: 5.w,
                large: 5.w,
                ultrawide: 5.w,
              ),
              height: ResponsiveBreakpoints.responsive(
                context,
                tablet: 5.w,
                small: 5.w,
                medium: 5.w,
                large: 5.w,
                ultrawide: 5.w,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                size: context.iconSize('xl'),
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            context.shouldShowCompactLayout
                ? 'Are you sure you want to delete this product?'
                : 'Are you absolutely sure you want to delete this product record?',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize * 1.1,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.cardPadding),

          // Product Details Card
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(
                color: Colors.red.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Product ID and Name Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.smallPadding,
                        vertical: context.smallPadding / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                      ),
                      child: Text(
                        widget.product.id,
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(width: context.smallPadding),
                    Expanded(
                      child: Text(
                        widget.product.name,
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoalGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.smallPadding),

                // Detail and Price Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail:',
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            widget.product.detail,
                            style: GoogleFonts.inter(
                              fontSize: context.subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.charcoalGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.cardPadding),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Price:',
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'PKR ${widget.product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: context.bodyFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.smallPadding),

                // Color, Fabric and Quantity Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color & Fabric:',
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getColorFromName(widget.product.color),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                              ),
                              SizedBox(width: context.smallPadding / 2),
                              Text(
                                '${widget.product.color} • ${widget.product.fabric}',
                                style: GoogleFonts.inter(
                                  fontSize: context.subtitleFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.charcoalGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.cardPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Quantity:',
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.smallPadding,
                              vertical: context.smallPadding / 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.product.stockStatusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(context.borderRadius('small')),
                            ),
                            child: Text(
                              '${widget.product.quantity} units (${widget.product.stockStatusText})',
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

                SizedBox(height: context.smallPadding),

                // Pieces Row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pieces:',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    Wrap(
                      spacing: context.smallPadding / 2,
                      runSpacing: context.smallPadding / 2,
                      children: widget.product.pieces.map((piece) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.smallPadding,
                            vertical: context.smallPadding / 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMaroon.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(context.borderRadius('small')),
                            border: Border.all(
                              color: AppTheme.primaryMaroon.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            piece,
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryMaroon,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: context.cardPadding),

          // Warning Message
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: context.iconSize('small'),
                ),
                SizedBox(width: context.smallPadding),
                Expanded(
                  child: Text(
                    context.shouldShowCompactLayout
                        ? 'This will permanently delete the product record.'
                        : 'This will permanently delete the product record and all associated data. This action cannot be undone.',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
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
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleCancel,
          height: context.buttonHeight,
          backgroundColor: Colors.grey[600],
          textColor: AppTheme.pureWhite,
        ),
        SizedBox(height: context.cardPadding),
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Delete Product',
              onPressed: provider.isLoading ? null : _handleDelete,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.delete_forever_rounded,
              backgroundColor: Colors.red,
            );
          },
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
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Delete',
                onPressed: provider.isLoading ? null : _handleDelete,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.delete_forever_rounded,
                backgroundColor: Colors.red,
              );
            },
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
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'navy':
        return Colors.indigo;
      case 'maroon':
        return const Color(0xFF800000);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return Colors.grey[400]!;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return Colors.grey;
    }
  }
}