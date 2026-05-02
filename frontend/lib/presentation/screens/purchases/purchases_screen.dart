import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/purchase_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/permission_helper.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../widgets/globals/text_button.dart'; // PremiumButton
import '../../widgets/purchases/purchase_table.dart';
import '../../widgets/purchases/add_purchase_dialog.dart';
import '../../widgets/purchases/purchase_filter_dialog.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  // Local state for the current filter
  PurchaseFilter _activeFilter = PurchaseFilter();

  @override
  void initState() {
    super.initState();
    // Fetch initial data when screen loads
    Future.microtask(() =>
        context.read<PurchaseProvider>().initialize());
  }

  /// Opens the filter dialog and updates the local filter state
  void _showFilterDialog() async {
    final result = await showDialog<PurchaseFilter>(
      context: context,
      builder: (context) => PurchaseFilterDialog(initialFilter: _activeFilter),
    );

    if (result != null) {
      setState(() {
        _activeFilter = result;
      });
    }
  }

  /// Opens the dialog to record a new inventory purchase
  void _showAddPurchaseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddPurchaseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Padding(
        padding: EdgeInsets.all(context.mainPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section: Title, Tagline and Action Buttons
            _buildHeader(context, l10n),

            SizedBox(height: context.mainPadding),

            // Statistics Summary Cards
            _buildSummaryRow(context, l10n),

            SizedBox(height: context.mainPadding),

            // Main Data Section: Purchase List Table
            Expanded(
              child: PurchaseTable(filter: _activeFilter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.purchases ?? "Purchases",
                        style: TextStyle(
                          fontSize: context.headingFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                      if (!isNarrow) ...[
                        SizedBox(height: context.smallPadding / 2),
                        Text(
                          l10n.purchasesTagline ?? "Track and manage inventory supply and purchase records",
                          style: TextStyle(
                            fontSize: context.bodyFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Action Buttons
                Wrap(
                  spacing: context.smallPadding,
                  runSpacing: context.smallPadding,
                  children: [
                    PremiumButton(
                      text: isNarrow ? "" : (l10n.filterPurchases ?? "Filter"),
                      icon: Icons.filter_alt_outlined,
                      onPressed: _showFilterDialog,
                      isOutlined: true,
                      height: 40,
                      backgroundColor: AppTheme.charcoalGray,
                    ),
                    if (PermissionHelper.canAdd(context, 'Purchases'))
                      PremiumButton(
                        text: isNarrow ? "" : (l10n.newPurchase ?? "New Purchase"),
                        icon: Icons.add_rounded,
                        onPressed: _showAddPurchaseDialog,
                        height: 40,
                        backgroundColor: AppTheme.primaryMaroon,
                      ),
                  ],
                ),
              ],
            ),
            if (isNarrow) ...[
              SizedBox(height: context.smallPadding),
              Text(
                l10n.purchasesTagline ?? "Track and manage inventory supply and purchase records",
                style: TextStyle(
                  fontSize: context.bodyFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(BuildContext context, AppLocalizations l10n) {
    return Consumer<PurchaseProvider>(
      builder: (context, provider, child) {
        final totalPurchases = provider.purchases.length;
        final totalAmount = provider.purchases.fold(0.0, (sum, p) => sum + p.total);

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardCount = constraints.maxWidth < 600 ? 1 : 2;
            final spacing = context.mainPadding;
            final itemWidth = (constraints.maxWidth - (spacing * (cardCount - 1))) / cardCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildStatCard(
                    context,
                    l10n.totalRecords ?? "Total Records",
                    totalPurchases.toString(),
                    Icons.inventory_2_outlined,
                    Colors.blue,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildStatCard(
                    context,
                    l10n.totalInvestment ?? "Total Investment",
                    "Rs. ${totalAmount.toStringAsFixed(2)}",
                    Icons.account_balance_wallet_outlined,
                    Colors.green,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: context.shadowBlur(),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: context.iconSize('medium')),
          ),
          SizedBox(width: context.mainPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.captionFontSize,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

