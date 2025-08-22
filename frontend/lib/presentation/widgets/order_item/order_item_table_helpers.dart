import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/order/order_item_model.dart';
import '../../../src/providers/order_item_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/confirmation_dialog.dart';

class OrderItemTableHelpers {
  final Function(OrderItemModel) onEdit;
  final Function(OrderItemModel) onDelete;
  final Function(OrderItemModel) onView;

  OrderItemTableHelpers({required this.onEdit, required this.onDelete, required this.onView});

  /// Build the actions row for each order item in the table
  Widget buildActionsRow(BuildContext context, OrderItemModel orderItem) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onView(orderItem),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.visibility_outlined, color: Colors.purple, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onEdit(orderItem),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.edit_outlined, color: Colors.blue, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Delete Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDelete(orderItem),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.delete_outline, color: Colors.red, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Quick Actions Dropdown
        PopupMenuButton<String>(
          onSelected: (value) => _handleQuickAction(context, orderItem, value),
          itemBuilder: (context) => _buildQuickActionMenuItems(context, orderItem),
          child: Container(
            padding: EdgeInsets.all(context.smallPadding * 0.5),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
            child: Icon(Icons.more_vert, color: Colors.grey[600], size: context.iconSize('small')),
          ),
        ),
      ],
    );
  }

  /// Build quick action menu items based on order item state
  List<PopupMenuEntry<String>> _buildQuickActionMenuItems(BuildContext context, OrderItemModel orderItem) {
    final items = <PopupMenuEntry<String>>[];

    // Status change actions based on current status
    if (orderItem.isActive) {
      items.add(
        PopupMenuItem(
          value: 'deactivate',
          child: Row(
            children: [
              Icon(Icons.visibility_off, color: Colors.orange, size: context.iconSize('small')),
              SizedBox(width: context.smallPadding),
              Text('Deactivate', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
            ],
          ),
        ),
      );
    } else {
      items.add(
        PopupMenuItem(
          value: 'activate',
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.green, size: context.iconSize('small')),
              SizedBox(width: context.smallPadding),
              Text('Activate', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
            ],
          ),
        ),
      );
    }

    // Additional actions
    // Removed duplicate and export options as requested
    // items.addAll([
    //   PopupMenuItem(
    //     value: 'duplicate',
    //     child: Row(
    //       children: [
    //         Icon(
    //           Icons.content_copy,
    //           color: Colors.blue,
    //           size: context.iconSize('small'),
    //         ),
    //         SizedBox(width: context.smallPadding),
    //         Text(
    //           'Duplicate',
    //           style: GoogleFonts.inter(fontSize: context.captionFontSize),
    //         ),
    //       ],
    //     ),
    //   ),
    //   PopupMenuItem(
    //     value: 'export',
    //     child: Row(
    //       children: [
    //         Icon(
    //           Icons.download,
    //           color: AppTheme.accentGold,
    //           size: context.iconSize('small'),
    //         ),
    //         SizedBox(width: context.smallPadding),
    //         Text(
    //           'Export Details',
    //           style: GoogleFonts.inter(fontSize: context.captionFontSize),
    //         ),
    //       ],
    //     ),
    //   ),
    // ]);

    return items;
  }

  /// Handle quick action selection
  void _handleQuickAction(BuildContext context, OrderItemModel orderItem, String action) async {
    final provider = context.read<OrderItemProvider>();

    switch (action) {
      case 'activate':
        await _handleStatusChange(context, provider, orderItem, true);
        break;
      case 'deactivate':
        await _handleStatusChange(context, provider, orderItem, false);
        break;
      // Removed duplicate and export cases as requested
      // case 'duplicate':
      //   await _handleDuplicate(context, provider, orderItem);
      //   break;
      // case 'export':
      //   await _handleExport(context, orderItem);
      //   break;
    }
  }

  /// Handle order item status change
  Future<void> _handleStatusChange(BuildContext context, OrderItemProvider provider, OrderItemModel orderItem, bool isActive) async {
    final statusText = isActive ? 'activate' : 'deactivate';
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
            title: '${isActive ? 'Activate' : 'Deactivate'} Order Item',
            message: 'Are you sure you want to $statusText "${orderItem.productName}"?',
            actionText: isActive ? 'Activate' : 'Deactivate',
            actionColor: isActive ? Colors.green : Colors.orange,
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await provider.updateOrderItemStatus(orderItem.id, isActive);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(context, provider.errorMessage ?? 'Failed to update item status');
      } else if (success) {
        _showSuccessSnackbar(context, 'Order item ${isActive ? 'activated' : 'deactivated'} successfully');
      }
    }
  }

  /// Handle duplicate order item
  Future<void> _handleDuplicate(BuildContext context, OrderItemProvider provider, OrderItemModel orderItem) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
            title: 'Duplicate Order Item',
            message: 'Are you sure you want to create a copy of "${orderItem.productName}"?',
            actionText: 'Duplicate',
            actionColor: Colors.blue,
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await provider.duplicateOrderItem(orderItem.id);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(context, provider.errorMessage ?? 'Failed to duplicate item');
      } else if (success) {
        _showSuccessSnackbar(context, 'Order item duplicated successfully');
      }
    }
  }

  /// Handle export order item
  Future<void> _handleExport(BuildContext context, OrderItemModel orderItem) async {
    try {
      // TODO: Implement actual export functionality
      _showSuccessSnackbar(context, 'Order item details exported successfully');
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to export: ${e.toString()}');
    }
  }

  /// Show success snackbar
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              message,
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

  /// Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
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

  /// Build error state widget
  Widget buildErrorState(BuildContext context, OrderItemProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.error_outline, size: context.iconSize('xl'), color: Colors.red[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'Failed to Load Order Items',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              provider.errorMessage ?? 'An unexpected error occurred',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Container(
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  provider.loadOrderItems(); // Use the refresh method from provider
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.pureWhite,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.inventory_2_outlined, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Order Items Found',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              'Start managing your order items by adding products to track inventory, pricing, and customizations for customer orders.',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // This will trigger the add order item dialog from parent
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Add Order Item',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.pureWhite,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color based on order item active state
  Color getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.orange;
  }

  /// Get status text based on order item active state
  String getStatusText(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }
}
