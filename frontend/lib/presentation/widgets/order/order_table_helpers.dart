import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/confirmation_dialog.dart';
import 'order_items_management_dialog.dart';

class OrderTableHelpers {
  final Function(OrderModel) onEdit;
  final Function(OrderModel) onDelete;
  final Function(OrderModel) onView;

  OrderTableHelpers({required this.onEdit, required this.onDelete, required this.onView});

  /// Build the actions row for each order in the table
  Widget buildActionsRow(BuildContext context, OrderModel order) {
    return Container(
      constraints: BoxConstraints(maxWidth: 320.0), // Ensure it doesn't exceed the allocated width
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // View Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onView(order),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding * 0.4),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                child: Icon(Icons.visibility_outlined, color: Colors.purple, size: context.iconSize('small')),
              ),
            ),
          ),

          SizedBox(width: context.smallPadding / 3),

          // Order Items Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showOrderItemsManagementDialog(context, order),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding * 0.4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1),
                ),
                child: Icon(Icons.shopping_cart_rounded, color: AppTheme.accentGold, size: context.iconSize('small')),
              ),
            ),
          ),

          SizedBox(width: context.smallPadding / 3),

          // Edit Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onEdit(order),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding * 0.4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                child: Icon(Icons.edit_outlined, color: Colors.blue, size: context.iconSize('small')),
              ),
            ),
          ),

          SizedBox(width: context.smallPadding / 3),

          // Delete Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDelete(order),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding * 0.4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                child: Icon(Icons.delete_outline, color: Colors.red, size: context.iconSize('small')),
              ),
            ),
          ),

          SizedBox(width: context.smallPadding / 3),

          // Quick Actions Dropdown
          PopupMenuButton<String>(
            onSelected: (value) => _handleQuickAction(context, order, value),
            itemBuilder: (context) => _buildQuickActionMenuItems(context, order),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.4),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.more_vert, color: Colors.grey[600], size: context.iconSize('small')),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick action menu items based on order state
  List<PopupMenuEntry<String>> _buildQuickActionMenuItems(BuildContext context, OrderModel order) {
    final items = <PopupMenuEntry<String>>[];

    // Status change actions based on current status
    switch (order.status) {
      case OrderStatus.PENDING:
        items.addAll([
          PopupMenuItem(
            value: 'confirm',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: context.iconSize('small')),
                SizedBox(width: context.smallPadding),
                Text('Confirm Order', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: context.iconSize('small')),
                SizedBox(width: context.smallPadding),
                Text('Cancel Order', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
              ],
            ),
          ),
        ]);
        break;
      case OrderStatus.CONFIRMED:
        items.add(
          PopupMenuItem(
            value: 'start_production',
            child: Row(
              children: [
                Icon(Icons.build, color: Colors.blue, size: context.iconSize('small')),
                SizedBox(width: context.smallPadding),
                Text('Start Production', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
              ],
            ),
          ),
        );
        break;
      case OrderStatus.IN_PRODUCTION:
        items.add(
          PopupMenuItem(
            value: 'mark_ready',
            child: Row(
              children: [
                Icon(Icons.done_all, color: Colors.green, size: context.iconSize('small')),
                SizedBox(width: context.smallPadding),
                Text('Mark as Ready', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
              ],
            ),
          ),
        );
        break;
      case OrderStatus.READY:
        items.add(
          PopupMenuItem(
            value: 'mark_delivered',
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.purple, size: context.iconSize('small')),
                SizedBox(width: context.smallPadding),
                Text('Mark as Delivered', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
              ],
            ),
          ),
        );
        break;
      case OrderStatus.DELIVERED:
      case OrderStatus.CANCELLED:
        // No status change actions for delivered/cancelled orders
        break;
    }

    // Soft delete/restore actions
    if (order.isActive) {
      items.add(
        PopupMenuItem(
          value: 'soft_delete',
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
          value: 'restore',
          child: Row(
            children: [
              Icon(Icons.restore, color: Colors.green, size: context.iconSize('small')),
              SizedBox(width: context.smallPadding),
              Text('Restore', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
            ],
          ),
        ),
      );
    }

    return items;
  }

  /// Handle quick action selection
  void _handleQuickAction(BuildContext context, OrderModel order, String action) async {
    final provider = context.read<OrderProvider>();

    switch (action) {
      case 'confirm':
        await _handleStatusChange(context, provider, order, 'confirmed');
        break;
      case 'start_production':
        await _handleStatusChange(context, provider, order, 'in_production');
        break;
      case 'mark_ready':
        await _handleStatusChange(context, provider, order, 'ready');
        break;
      case 'mark_delivered':
        await _handleStatusChange(context, provider, order, 'delivered');
        break;
      case 'cancel':
        await _handleStatusChange(context, provider, order, 'cancelled');
        break;
      case 'soft_delete':
        await _handleSoftDelete(context, provider, order);
        break;
      case 'restore':
        await _handleRestore(context, provider, order);
        break;
    }
  }

  /// Handle order status change
  Future<void> _handleStatusChange(BuildContext context, OrderProvider provider, OrderModel order, String newStatus) async {
    final statusText = _getStatusTextFromString(newStatus);
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
            title: 'Change Order Status',
            message: 'Are you sure you want to change the status of order #${order.id.substring(0, 8)} to "$statusText"?',
            actionText: 'Change Status',
            actionColor: Colors.blue,
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await provider.updateOrderStatus(order.id, newStatus);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(context, provider.errorMessage ?? 'Failed to update order status');
      } else if (success) {
        _showSuccessSnackbar(context, 'Order status updated to $statusText successfully');
      }
    }
  }

  /// Handle soft delete (deactivate)
  Future<void> _handleSoftDelete(BuildContext context, OrderProvider provider, OrderModel order) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
            title: 'Deactivate Order',
            message: 'Are you sure you want to deactivate order #${order.id.substring(0, 8)}? This action can be reversed.',
            actionText: 'Deactivate',
            actionColor: Colors.orange,
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await provider.softDeleteOrder(order.id);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(context, provider.errorMessage ?? 'Failed to deactivate order');
      } else if (success) {
        _showSuccessSnackbar(context, 'Order deactivated successfully');
      }
    }
  }

  /// Handle restore order
  Future<void> _handleRestore(BuildContext context, OrderProvider provider, OrderModel order) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
            title: 'Restore Order',
            message: 'Are you sure you want to restore order #${order.id.substring(0, 8)}?',
            actionText: 'Restore',
            actionColor: Colors.green,
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await provider.restoreOrder(order.id);
      if (provider.errorMessage != null) {
        _showErrorSnackbar(context, provider.errorMessage ?? 'Failed to restore order');
      } else if (success) {
        _showSuccessSnackbar(context, 'Order restored successfully');
      }
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
  Widget buildErrorState(BuildContext context, OrderProvider provider) {
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
            'Failed to Load Orders',
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
                  provider.refreshOrders();
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
            child: Icon(Icons.shopping_bag_outlined, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Orders Found',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              'Start managing your customer orders by creating your first order. Track deliveries, manage payments, and keep customers informed.',
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
                  // This will trigger the add order dialog from parent
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
                        'Create New Order',
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

  /// Build no search results state widget
  Widget buildNoSearchResultsState(BuildContext context, OrderProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.search_off_rounded, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Orders Found',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              'No orders match your search criteria "${provider.searchQuery}". Try adjusting your search terms or filters to find what you\'re looking for.',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clear Search Button
              Container(
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(context.borderRadius())),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      provider.clearFilters();
                    },
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear_rounded, color: Colors.grey[700], size: context.iconSize('medium')),
                          SizedBox(width: context.smallPadding),
                          Text(
                            'Clear Search',
                            style: GoogleFonts.inter(
                              fontSize: context.bodyFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: context.mainPadding),

              // Create New Order Button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // This will trigger the add order dialog from parent
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
                            'Create New Order',
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
        ],
      ),
    );
  }

  /// Get status color based on order status
  Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return AppTheme.accentGold;
      case OrderStatus.CONFIRMED:
        return AppTheme.primaryMaroon;
      case OrderStatus.IN_PRODUCTION:
        return AppTheme.secondaryMaroon;
      case OrderStatus.READY:
        return Colors.green;
      case OrderStatus.DELIVERED:
        return Colors.purple;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }

  /// Get status text based on order status
  String getStatusText(OrderStatus status) {
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

  /// Get status text from string
  String _getStatusTextFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_production':
        return 'In Production';
      case 'ready':
        return 'Ready';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Format date for display
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Show Order Items Management Dialog
  void _showOrderItemsManagementDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OrderItemsManagementDialog(order: order),
    );
  }
}
