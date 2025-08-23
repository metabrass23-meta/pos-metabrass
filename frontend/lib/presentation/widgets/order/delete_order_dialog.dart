import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class DeleteOrderDialog extends StatefulWidget {
  final OrderModel order;

  const DeleteOrderDialog({super.key, required this.order});

  @override
  State<DeleteOrderDialog> createState() => _DeleteOrderDialogState();
}

class _DeleteOrderDialogState extends State<DeleteOrderDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  bool _confirmationChecked = false;
  String _confirmationText = '';
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    if (!_validateDeletion()) {
      _showValidationError();
      return;
    }

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success = await provider.deleteOrder(widget.order.id);

    if (mounted) {
      if (success) {
        _showSuccessSnackbar();
        Navigator.of(context).pop();
      } else {
        _showErrorSnackbar(provider.errorMessage ?? 'Failed to delete order');
      }
    }
  }

  bool _validateDeletion() {
    return _confirmationChecked && _confirmationText.toLowerCase().trim() == widget.order.id.toLowerCase().trim();
  }

  void _showValidationError() {
    String message;
    if (!_confirmationChecked) {
      message = 'Please confirm that you understand this action';
    } else if (_confirmationText.toLowerCase().trim() != widget.order.id.toLowerCase().trim()) {
      message = 'Please type the order ID exactly to confirm deletion';
    } else {
      message = 'Please complete all confirmation steps';
    }

    _showSnackbar(message, Colors.orange, Icons.warning_outlined);
  }

  void _showSuccessSnackbar() {
    _showSnackbar('Order deleted successfully!', Colors.green, Icons.check_circle_rounded);
  }

  void _showErrorSnackbar(String message) {
    _showSnackbar(message, Colors.red, Icons.error_outline);
  }

  void _showSnackbar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: color == Colors.red ? 4 : 3),
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
          backgroundColor: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(_shakeAnimation.value * 2 * (1 - _scaleAnimation.value), 0),
                child: Container(
                  width: ResponsiveBreakpoints.responsive(context, tablet: 85.w, small: 75.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
                  constraints: BoxConstraints(maxWidth: 500, maxHeight: 85.h),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildContent()),
                    ],
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
        gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
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
            child: Icon(Icons.delete_forever_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Order',
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
                child: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWarningMessage(),
              SizedBox(height: context.cardPadding),
              _buildOrderDetailsCard(),
              SizedBox(height: context.cardPadding),
              _buildImpactWarning(),
              SizedBox(height: context.cardPadding),
              _buildConfirmationSection(),
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
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red, size: context.iconSize('large')),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deletion Warning',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w700, color: Colors.red[700]),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  'This will permanently remove all order data from the database. This action cannot be reversed.',
                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, color: AppTheme.charcoalGray, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _getOrderInitials(),
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red[700]),
                  ),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(context.borderRadius('small')),
                          ),
                          child: Text(
                            widget.order.id,
                            style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.red),
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Expanded(
                          child: Text(
                            widget.order.customerName,
                            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!context.isTablet) ...[
                      SizedBox(height: context.smallPadding),
                      Text(
                        widget.order.description,
                        style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue, size: context.iconSize('small')),
                SizedBox(width: context.smallPadding),
                Text(
                  'Order created: ${_formatDate(widget.order.createdAt)}',
                  style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactWarning() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.amber[700], size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Impact Assessment',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          Text(
            '• All order data will be permanently removed\n• Associated customer records will remain unaffected\n• Payment records will be anonymized\n• This action cannot be undone',
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, color: AppTheme.charcoalGray, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: _confirmationChecked,
            onChanged: (value) {
              setState(() {
                _confirmationChecked = value ?? false;
              });
            },
            title: Text(
              'I understand this will permanently delete the order and cannot be undone',
              style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: Colors.red[700]),
            ),
            activeColor: Colors.red,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          SizedBox(height: context.cardPadding),
          Text(
            'Type the order ID to confirm permanent deletion:',
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: Colors.red[700]),
          ),
          SizedBox(height: context.smallPadding),
          Container(
            child: TextFormField(
              controller: _confirmationController,
              onChanged: (value) {
                setState(() {
                  _confirmationText = value;
                });
              },
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
              decoration: InputDecoration(
                hintText: widget.order.id,
                hintStyle: GoogleFonts.inter(fontSize: context.bodyFontSize, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(context.cardPadding / 2),
              ),
            ),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Expected: ${widget.order.id}',
            style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600], fontStyle: FontStyle.italic),
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
        Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Delete Order',
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
          child: Consumer<OrderProvider>(
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

  String _getOrderInitials() {
    final words = widget.order.customerName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.length == 1) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'OR';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return 'Pending';
      case OrderStatus.CONFIRMED:
        return 'Confirmed';
      case OrderStatus.IN_PRODUCTION:
        return 'In Production';
      case OrderStatus.READY:
        return 'Ready';
      case OrderStatus.DELIVERED:
        return 'Delivered';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
    }
  }
}
