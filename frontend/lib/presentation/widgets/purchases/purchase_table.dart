import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/models/purchase_model.dart';
import '../../../src/providers/purchase_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../globals/text_button.dart'; // Import for PremiumButton
import 'purchase_table_helpers.dart';
import 'view_purchase_details_dialog.dart';
import 'edit_purchase_dialog.dart';
import 'delete_purchase_dialog.dart';
import 'add_purchase_dialog.dart';

class PurchaseTable extends StatelessWidget {
  const PurchaseTable({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<PurchaseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.purchases.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryMaroon)
          );
        }

        if (provider.purchases.isEmpty) {
          return _buildEmptyState(context, l10n);
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.borderRadius('medium')),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.borderRadius('medium')),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                    AppTheme.primaryMaroon.withOpacity(0.05)
                ),
                columnSpacing: context.mainPadding * 2,
                columns: [
                  DataColumn(label: _headerText(l10n.date ?? "Date")),
                  DataColumn(label: _headerText("Invoice #")),
                  DataColumn(label: _headerText(l10n.vendor ?? "Vendor")),
                  DataColumn(label: _headerText(l10n.total ?? "Total")),
                  DataColumn(label: _headerText("Status")),
                  DataColumn(label: _headerText("Actions")),
                ],
                rows: provider.purchases.map((purchase) {
                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('dd MMM yyyy').format(purchase.purchaseDate))),
                      DataCell(Text(
                          purchase.invoiceNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold)
                      )),
                      DataCell(Text(purchase.vendorDetail?.name ?? "N/A")),
                      DataCell(Text(
                        purchase.total.toStringAsFixed(2),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryMaroon
                        ),
                      )),
                      // FIXED: Passed context and status string
                      DataCell(PurchaseTableHelpers.buildStatusBadge(context, purchase.status)),
                      DataCell(_buildActions(context, purchase)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _headerText(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: AppTheme.charcoalGray.withOpacity(0.8),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildActions(BuildContext context, PurchaseModel purchase) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionIcon(Icons.visibility_rounded, Colors.blue, () {
          showDialog(
              context: context,
              builder: (_) => ViewPurchaseDetailsDialog(purchase: purchase)
          );
        }),
        SizedBox(width: context.smallPadding),
        _actionIcon(Icons.edit_rounded, Colors.orange, () {
          showDialog(
              context: context,
              builder: (_) => EditPurchaseDialog(purchase: purchase)
          );
        }),
        SizedBox(width: context.smallPadding),
        _actionIcon(Icons.delete_rounded, Colors.red, () {
          showDialog(
              context: context,
              builder: (_) => DeletePurchaseDialog(purchase: purchase)
          );
        }),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 20,
      tooltip: "Action",
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: AppTheme.primaryMaroon.withOpacity(0.2)
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            "No Purchases Found",
            style: TextStyle(
                fontSize: 22,
                color: AppTheme.charcoalGray,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            "Start by recording your first inventory purchase.",
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600]
            ),
          ),
          SizedBox(height: context.mainPadding),
          // UPDATED: Replaced ElevatedButton with PremiumButton
          PremiumButton(
            text: "Record New Purchase",
            onPressed: () => showDialog(
                context: context,
                builder: (_) => const AddPurchaseDialog()
            ),
            icon: Icons.add_rounded,
            width: 250,
          ),
        ],
      ),
    );
  }
}