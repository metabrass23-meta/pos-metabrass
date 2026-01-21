import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/models/purchase_model.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../globals/text_button.dart'; // Import for PremiumButton
import 'purchase_table_helpers.dart';

class ViewPurchaseDetailsDialog extends StatelessWidget {
  final PurchaseModel purchase;

  const ViewPurchaseDetailsDialog({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
      ),
      backgroundColor: AppTheme.creamWhite,
      child: Container(
        width: 60.w, // Desktop-optimized fixed width
        constraints: BoxConstraints(maxHeight: 85.h),
        padding: EdgeInsets.all(context.mainPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            _buildHeader(context, l10n),
            const Divider(height: 32),

            // Content Section (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetaInfo(context, l10n),
                    SizedBox(height: context.mainPadding),
                    _buildItemsTable(context, l10n),
                  ],
                ),
              ),
            ),

            // Footer Section (Totals)
            const Divider(height: 32),
            _buildTotalsSection(context, l10n),

            SizedBox(height: context.mainPadding),
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.smallPadding),
          decoration: BoxDecoration(
            color: AppTheme.primaryMaroon.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: AppTheme.primaryMaroon,
            size: context.iconSize('medium'),
          ),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Purchase Details",
                style: GoogleFonts.playfairDisplay(
                  fontSize: context.headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoalGray,
                ),
              ),
              Text(
                "Invoice: ${purchase.invoiceNumber}",
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildMetaInfo(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(context.mainPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoColumn(l10n.vendor, purchase.vendorDetail?.name ?? "N/A"),
          _infoColumn(l10n.date, PurchaseTableHelpers.formatDate(purchase.purchaseDate)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Status", style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
              SizedBox(height: context.smallPadding / 4),
              PurchaseTableHelpers.buildStatusBadge(context, purchase.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildItemsTable(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.smallPadding),
          child: Text(
            "Purchased Items",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: AppTheme.primaryMaroon.withOpacity(0.05)),
              children: [
                _tableHeader("Item"),
                _tableHeader("Qty"),
                _tableHeader("Cost"),
                _tableHeader("Total"),
              ],
            ),
            ...purchase.items.map((item) => TableRow(
              children: [
                _tableCell(item.productDetail?.name ?? "Unknown Product"),
                _tableCell(item.quantity.toStringAsFixed(0)),
                _tableCell(item.unitCost.toStringAsFixed(2)),
                _tableCell(item.totalPrice.toStringAsFixed(2), isBold: true),
              ],
            )),
          ],
        ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _tableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTotalsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _totalRow("Subtotal", purchase.subtotal),
        SizedBox(height: context.smallPadding / 2),
        _totalRow("Tax", purchase.tax),
        const Divider(height: 24),
        _totalRow("Grand Total", purchase.total, isMain: true),
      ],
    );
  }

  Widget _totalRow(String label, double amount, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
            fontSize: isMain ? 18 : 14,
          ),
        ),
        Text(
          NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isMain ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
            fontSize: isMain ? 20 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PremiumButton(
          text: "Print Invoice",
          onPressed: () {
            // Print logic implementation
          },
          icon: Icons.print_rounded,
          isOutlined: true,
          width: 200,
          height: 45,
        ),
        SizedBox(width: context.mainPadding),
        PremiumButton(
          text: l10n.cancel,
          onPressed: () => Navigator.pop(context),
          width: 150,
          height: 45,
          backgroundColor: AppTheme.primaryMaroon,
        ),
      ],
    );
  }
}