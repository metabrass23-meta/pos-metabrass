import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/order/order_item_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class ViewOrderItemDialog extends StatefulWidget {
  final OrderItemModel orderItem;

  const ViewOrderItemDialog({super.key, required this.orderItem});

  @override
  State<ViewOrderItemDialog> createState() => _ViewOrderItemDialogState();
}

class _ViewOrderItemDialogState extends State<ViewOrderItemDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
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
          backgroundColor: Colors.black.withOpacity(0.7 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: context.dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 90.w, small: 85.w, medium: 75.w, large: 65.w, ultrawide: 55.w),
                  maxHeight: 85.h,
                ),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: context.shadowBlur('heavy'), offset: Offset(0, context.cardPadding)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ResponsiveBreakpoints.responsive(
                        context,
                        tablet: _buildTabletContent(),
                        small: _buildMobileContent(),
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

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildLeftPanel()),
        Container(width: 1, color: Colors.grey.withOpacity(0.3)),
        Expanded(flex: 3, child: _buildRightPanel()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
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
            child: Icon(Icons.visibility_outlined, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View Order Item',
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
                    'Complete order item information',
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
                          widget.orderItem.id.length > 8 ? '${widget.orderItem.id.substring(0, 8)}...' : widget.orderItem.id,
                          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
                        ),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          widget.orderItem.productName.length > 15
                              ? '${widget.orderItem.productName.substring(0, 15)}...'
                              : widget.orderItem.productName,
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
              onTap: _handleClose,
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

  Widget _buildLeftPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: context.cardPadding),
            _buildProductDetailsSection(),
            SizedBox(height: context.cardPadding),
            _buildFinancialSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfoSection(),
            SizedBox(height: context.cardPadding),
            _buildStatusSection(),
            SizedBox(height: context.cardPadding),
            _buildTimestampsSection(),
            SizedBox(height: context.cardPadding),
            _buildCustomizationSection(),
            SizedBox(height: context.mainPadding),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: context.cardPadding),
            _buildProductDetailsSection(),
            SizedBox(height: context.cardPadding),
            _buildFinancialSection(),
            SizedBox(height: context.cardPadding),
            _buildOrderInfoSection(),
            SizedBox(height: context.cardPadding),
            _buildStatusSection(),
            SizedBox(height: context.cardPadding),
            _buildTimestampsSection(),
            SizedBox(height: context.cardPadding),
            _buildCustomizationSection(),
            SizedBox(height: context.mainPadding),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: context.cardPadding),
            _buildProductDetailsSection(),
            SizedBox(height: context.cardPadding),
            _buildFinancialSection(),
            SizedBox(height: context.cardPadding),
            _buildOrderInfoSection(),
            SizedBox(height: context.cardPadding),
            _buildStatusSection(),
            SizedBox(height: context.cardPadding),
            _buildTimestampsSection(),
            SizedBox(height: context.cardPadding),
            _buildCustomizationSection(),
            SizedBox(height: context.mainPadding),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
              Icon(Icons.info_outline, color: Colors.blue, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Basic Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildInfoRow('Order Item ID', widget.orderItem.id, Icons.qr_code_outlined),
          SizedBox(height: context.smallPadding),
          _buildInfoRow('Order ID', widget.orderItem.orderId, Icons.receipt_long_outlined),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection() {
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
              Icon(Icons.inventory_2_outlined, color: Colors.green, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Product Details',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          // Product ID (already shown in Basic Info, but keeping for completeness)
          _buildInfoRow('Product ID', widget.orderItem.productId, Icons.qr_code_outlined),
          SizedBox(height: context.smallPadding),

          // Product Name (already shown in Basic Info, but keeping for completeness)
          _buildInfoRow('Product Name', widget.orderItem.productName, Icons.shopping_bag_outlined),
          SizedBox(height: context.smallPadding),

          // Product Color
          if (widget.orderItem.productColor != null && widget.orderItem.productColor!.isNotEmpty) ...[
            _buildInfoRow('Color', widget.orderItem.productColor!, Icons.palette_outlined),
            SizedBox(height: context.smallPadding),
          ],

          // Product Fabric
          if (widget.orderItem.productFabric != null && widget.orderItem.productFabric!.isNotEmpty) ...[
            _buildInfoRow('Fabric', widget.orderItem.productFabric!, Icons.texture_outlined),
            SizedBox(height: context.smallPadding),
          ],

          // Current Stock
          if (widget.orderItem.currentStock != null) ...[
            _buildInfoRow('Current Stock', '${widget.orderItem.currentStock!} units', Icons.inventory_outlined),
            SizedBox(height: context.smallPadding),
          ],

          // Product Display Info (if available)
          if (widget.orderItem.productDisplayInfo != null && widget.orderItem.productDisplayInfo!.isNotEmpty) ...[
            _buildInfoRow('Product Info', _formatProductDisplayInfo(widget.orderItem.productDisplayInfo!), Icons.info_outline),
            SizedBox(height: context.smallPadding),
          ],

          // Show "No additional details" if no extra info is available
          if ((widget.orderItem.productColor == null || widget.orderItem.productColor!.isEmpty) &&
              (widget.orderItem.productFabric == null || widget.orderItem.productFabric!.isEmpty) &&
              widget.orderItem.currentStock == null &&
              (widget.orderItem.productDisplayInfo == null || widget.orderItem.productDisplayInfo!.isEmpty)) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius()),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding),
                  Expanded(
                    child: Text(
                      'No additional product details available',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialSection() {
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
              Icon(Icons.attach_money_outlined, color: Colors.orange, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Financial Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildInfoRow('Quantity', widget.orderItem.quantity.toString(), Icons.numbers_outlined),
          SizedBox(height: context.smallPadding),
          _buildInfoRow('Unit Price', 'PKR ${widget.orderItem.unitPrice.toStringAsFixed(2)}', Icons.attach_money_outlined),
          SizedBox(height: context.smallPadding),
          _buildInfoRow('Line Total', 'PKR ${widget.orderItem.lineTotal.toStringAsFixed(2)}', Icons.calculate_outlined),
          SizedBox(height: context.smallPadding),
          _buildInfoRow('Total Value', 'PKR ${widget.orderItem.totalValue.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Colors.purple, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Order Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildInfoRow('Order ID', widget.orderItem.orderId, Icons.receipt_outlined),
          SizedBox(height: context.smallPadding),
          _buildInfoRow('Created Date', _formatDate(widget.orderItem.createdAt), Icons.calendar_today_outlined),
          if (widget.orderItem.updatedAt != null) ...[
            SizedBox(height: context.smallPadding),
            _buildInfoRow('Last Updated', _formatDate(widget.orderItem.updatedAt!), Icons.update_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.indigo.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Status Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildStatusRow('Active Status', widget.orderItem.isActive, Icons.check_circle_outline),
          if (widget.orderItem.hasBeenSold != null) ...[
            SizedBox(height: context.smallPadding),
            _buildStatusRow('Sold Status', widget.orderItem.hasBeenSold!, Icons.shopping_cart_outlined),
          ],
          if (widget.orderItem.remainingToSell != null) ...[
            SizedBox(height: context.smallPadding),
            _buildInfoRow('Remaining to Sell', widget.orderItem.remainingToSell!.toString(), Icons.inventory_2_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampsSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.teal.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_outlined, color: Colors.teal, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Timestamps',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          _buildInfoRow('Created At', _formatDateTime(widget.orderItem.createdAt), Icons.add_circle_outline),
          if (widget.orderItem.updatedAt != null) ...[
            SizedBox(height: context.smallPadding),
            _buildInfoRow('Updated At', _formatDateTime(widget.orderItem.updatedAt!), Icons.edit_calendar_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.amber.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, color: Colors.amber, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Customization Notes',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Text(
              widget.orderItem.customizationNotes.isNotEmpty ? widget.orderItem.customizationNotes : 'No customization notes available',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: widget.orderItem.customizationNotes.isNotEmpty ? Colors.amber[800] : Colors.grey[600],
                fontStyle: widget.orderItem.customizationNotes.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.smallPadding / 2),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
          child: Icon(icon, color: Colors.grey[600], size: context.iconSize('small')),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, bool value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.smallPadding / 2),
          decoration: BoxDecoration(
            color: (value ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
          ),
          child: Icon(icon, color: value ? Colors.green : Colors.red, size: context.iconSize('small')),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                decoration: BoxDecoration(
                  color: (value ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: (value ? Colors.green : Colors.red).withOpacity(0.3)),
                ),
                child: Text(
                  value ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: value ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: _buildCompactButtons(),
      small: _buildCompactButtons(),
      medium: _buildDesktopButtons(),
      large: _buildDesktopButtons(),
      ultrawide: _buildDesktopButtons(),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumButton(
          text: 'Close',
          onPressed: _handleClose,
          height: context.buttonHeight,
          icon: Icons.close_rounded,
          backgroundColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Close',
            onPressed: _handleClose,
            height: context.buttonHeight / 1.5,
            icon: Icons.close_rounded,
            backgroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatProductDisplayInfo(Map<String, dynamic> productInfo) {
    try {
      final List<String> infoParts = [];

      if (productInfo['category'] != null) {
        infoParts.add('Category: ${productInfo['category']}');
      }
      if (productInfo['brand'] != null) {
        infoParts.add('Brand: ${productInfo['brand']}');
      }
      if (productInfo['size'] != null) {
        infoParts.add('Size: ${productInfo['size']}');
      }
      if (productInfo['material'] != null) {
        infoParts.add('Material: ${productInfo['material']}');
      }
      if (productInfo['style'] != null) {
        infoParts.add('Style: ${productInfo['style']}');
      }

      if (infoParts.isEmpty) {
        return 'No additional details';
      }

      return infoParts.join(' • ');
    } catch (e) {
      return 'Additional product information available';
    }
  }
}
