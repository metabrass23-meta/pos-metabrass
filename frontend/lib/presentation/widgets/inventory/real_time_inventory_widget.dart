import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/inventory_provider.dart';
import '../../../src/theme/app_theme.dart';

class RealTimeInventoryWidget extends StatefulWidget {
  final List<String> productIds;
  final VoidCallback? onStockUpdated;
  final bool showAlerts;
  final bool showStockInfo;

  const RealTimeInventoryWidget({super.key, required this.productIds, this.onStockUpdated, this.showAlerts = true, this.showStockInfo = true});

  @override
  State<RealTimeInventoryWidget> createState() => _RealTimeInventoryWidgetState();
}

class _RealTimeInventoryWidgetState extends State<RealTimeInventoryWidget> {
  @override
  void initState() {
    super.initState();
    // Load initial stock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.productIds.isNotEmpty) {
        context.read<InventoryProvider>().checkStockAvailability(widget.productIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(inventoryProvider),

              SizedBox(height: 16),

              // Stock Information
              if (widget.showStockInfo) ...[_buildStockInfo(inventoryProvider), SizedBox(height: 16)],

              // Low Stock Alerts
              if (widget.showAlerts) ...[_buildLowStockAlerts(inventoryProvider), SizedBox(height: 16)],

              // Action Buttons
              _buildActionButtons(inventoryProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(InventoryProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2, color: AppTheme.primaryMaroon, size: 24),
            SizedBox(width: 12),
            Text(
              'Real-Time Inventory',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
            ),
          ],
        ),
        Row(
          children: [
            if (provider.isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMaroon)),
              ),
            SizedBox(width: 12),
            IconButton(
              onPressed: () => _refreshInventory(provider),
              icon: Icon(Icons.refresh, color: AppTheme.primaryMaroon),
              tooltip: 'Refresh Inventory',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockInfo(InventoryProvider provider) {
    if (provider.stockInfo.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text('No stock information available', style: GoogleFonts.poppins(color: Colors.grey[600])),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stock Information', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        ...provider.stockInfo.map((stock) => _buildStockItem(stock)).toList(),
      ],
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock) {
    final productName = stock['product_name'] as String? ?? 'Unknown Product';
    final availableQuantity = stock['available_quantity'] as int? ?? 0;
    final stockStatus = stock['stock_status'] as String? ?? 'UNKNOWN';
    final lowStockWarning = stock['low_stock_warning'] as bool? ?? false;
    final outOfStock = stock['out_of_stock'] as bool? ?? false;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (outOfStock) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Out of Stock';
    } else if (lowStockWarning) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'Low Stock';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'In Stock';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Available: $availableQuantity', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(
              statusText,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlerts(InventoryProvider provider) {
    if (provider.lowStockAlerts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'All products have sufficient stock',
                style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              'Low Stock Alerts',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange[700]),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
              child: Text(
                '${provider.getLowStockAlertCount()}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...provider.lowStockAlerts.map((alert) => _buildAlertItem(alert)).toList(),
      ],
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final productName = alert['product_name'] as String? ?? 'Unknown Product';
    final currentQuantity = alert['current_quantity'] as int? ?? 0;
    final alertLevel = alert['alert_level'] as String? ?? 'WARNING';
    final categoryName = alert['category_name'] as String? ?? 'Uncategorized';

    Color alertColor;
    IconData alertIcon;

    switch (alertLevel) {
      case 'CRITICAL':
        alertColor = Colors.red;
        alertIcon = Icons.error;
        break;
      case 'WARNING':
        alertColor = Colors.orange;
        alertIcon = Icons.warning;
        break;
      default:
        alertColor = Colors.blue;
        alertIcon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alertColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Category: $categoryName', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                Text(
                  'Current Stock: $currentQuantity',
                  style: GoogleFonts.poppins(fontSize: 12, color: alertColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: alertColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(
              alertLevel,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: alertColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(InventoryProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () => _refreshInventory(provider),
            icon: Icon(Icons.refresh, size: 18),
            label: Text('Refresh Stock', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryMaroon,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: provider.isLoading ? null : () => _showLowStockAlerts(provider),
            icon: Icon(Icons.warning, size: 18),
            label: Text('View Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryMaroon,
              side: BorderSide(color: AppTheme.primaryMaroon),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  void _refreshInventory(InventoryProvider provider) {
    if (widget.productIds.isNotEmpty) {
      provider.checkStockAvailability(widget.productIds);
    }
    provider.getLowStockAlerts();
    widget.onStockUpdated?.call();
  }

  void _showLowStockAlerts(InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Low Stock Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.lowStockAlerts.isEmpty)
                Text('No low stock alerts at this time.', style: GoogleFonts.poppins(color: Colors.grey[600]))
              else
                ...provider.lowStockAlerts.map((alert) => _buildAlertItem(alert)).toList(),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close'))],
      ),
    );
  }
}
