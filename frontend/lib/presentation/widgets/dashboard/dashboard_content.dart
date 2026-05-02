import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../l10n/app_localizations.dart';
import '../../../src/providers/dashboard_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../../src/utils/permission_helper.dart';

// Screens
import '../../screens/advance payment/advance_payment_screen.dart';
import '../../screens/category/category_screen.dart';
import '../../screens/customer/customer_screen.dart';
import '../../screens/expenses/expenses_screen.dart';
import '../../screens/invoices/invoice_management_screen.dart';
import '../../screens/labor/labor_screen.dart';
import '../../screens/order/order_screen.dart';
import '../../screens/payables/payables_screen.dart';
import '../../screens/payment/payment_screen.dart';
import '../../screens/principal acc/principal_acc_screen.dart';
import '../../screens/product/product_screen.dart';
import '../../screens/profit loss/profit_loss_screen.dart';
import '../../screens/purchases/purchases_screen.dart';
import '../../screens/receipts/receipt_management_screen.dart';
import '../../screens/receivables/receivables_screen.dart';
import '../../screens/returns/return_management_screen.dart';
import '../../screens/sales/sales_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/tax_management_screen.dart';
import '../../screens/vendor/vendor_screen.dart';
import '../../screens/zakat/zakat_screen.dart';
import '../../screens/quotation/quotation_list_screen.dart';
import '../../screens/settings/user_management_screen.dart';
import '../../screens/settings/role_permission_screen.dart';


// Dashboard Widgets
import 'sales_overview_chart.dart';
import 'recent_orders_card.dart';
import 'sales_chart_card.dart';
import 'stats_card.dart';

class DashboardContent extends StatelessWidget {
  final int selectedIndex;

  const DashboardContent({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return _buildDashboard(context);
      case 1:
        return const SalesPage();
      case 2:
        return const PurchasesScreen();
      case 3:
        return const ProductPage();
      case 4:
        return const CategoryPage();
      case 5:
        return const QuotationListScreen();
      case 6:
        return const CustomerPage();
      case 7:
        return const VendorPage();
      case 8:
        return const LaborPage();
      case 9:
        return const ReceivablesPage();
      case 10:
        return const PayablesPage();
      case 11:
        return const AdvancePaymentPage();
      case 12:
        return const PaymentPage();
      case 13:
        return const ExpensesPage();
      case 14:
        return const PrincipalAccountPage();
      case 15:
        return const ZakatPage();
      case 16:
        return const ProfitLossPage();
      case 17:
        return const ReturnManagementScreen();
      case 18:
        return const InvoiceManagementScreen();
      case 19:
        return const ReceiptManagementScreen();
      case 20:
        return const UserManagementScreen();
      case 21:
        return const RolePermissionScreen();
      case 22:
        return const SettingsScreen();

      default:
        return _buildPlaceholderContent(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    if (!PermissionHelper.canView(context, 'Dashboard')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Access Denied",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have permission to view the Dashboard.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        // 1. Initial Loading State
        if (provider.isLoading && provider.analytics == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error State
        if (provider.errorMessage != null && provider.analytics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load dashboard data',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => provider.loadDashboardAnalytics(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // 3. Real Data
        final stats = provider.dashboardStats;

        return Container(
          padding: context.pagePadding / 2.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context),

                SizedBox(height: context.formFieldSpacing * 3),

                // --- STATS CARDS (RESTORED & ACTIVE) ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardCount = context.statsCardColumns;
                    final availableWidth = constraints.maxWidth;
                    final cardPadding = context.cardPadding;
                    final totalPadding = cardPadding * (cardCount - 1);
                    final cardWidth =
                        (availableWidth - totalPadding) / cardCount;

                    return Wrap(
                      spacing: context.cardPadding,
                      runSpacing: context.formFieldSpacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: AppLocalizations.of(context)!.totalSales,
                            value: stats['totalSales']['value'],
                            change: stats['totalSales']['change'],
                            isPositive: stats['totalSales']['isPositive'],
                            icon: Icons.trending_up_rounded,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: AppLocalizations.of(context)!.totalIncome,
                            value: stats['totalIncome']['value'],
                            change: stats['totalIncome']['change'],
                            isPositive: stats['totalIncome']['isPositive'],
                            icon: Icons.attach_money_rounded,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: AppLocalizations.of(context)!.totalExpenses,
                            value: stats['totalExpenses']['value'],
                            change: stats['totalExpenses']['change'],
                            isPositive: stats['totalExpenses']['isPositive'],
                            icon: Icons.money_off_rounded,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: AppLocalizations.of(
                              context,
                            )!.activeCustomers,
                            value: stats['activeCustomers']['value'],
                            change: stats['activeCustomers']['change'],
                            isPositive: stats['activeCustomers']['isPositive'],
                            icon: Icons.people_rounded,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: AppLocalizations.of(context)!.activeVendors,
                            value: stats['activeVendors']['value'],
                            change: stats['activeVendors']['change'],
                            isPositive: stats['activeVendors']['isPositive'],
                            icon: Icons.store_rounded,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: context.formFieldSpacing * 3),

                // --- Main Content Row (Charts & Analytics) ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive layout
                    if (constraints.maxWidth < 1200) {
                      return Column(
                        children: [
                          // Top Row - Charts
                          Row(
                            children: [
                              // Sales Overview Chart
                              Expanded(
                                child: SalesOverviewChart(
                                  analytics: provider.analytics?.toJson() ?? {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    // Desktop Layout
                    return Column(
                      children: [
                        // Top Row - Charts
                        Row(
                          children: [
                            // Sales Overview Chart
                            Expanded(
                              flex: 2,
                              child: SalesOverviewChart(
                                analytics: provider.analytics?.toJson() ?? {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: context.formFieldSpacing * 2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
        ),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeToPos,
                  style: TextStyle(
                    fontSize: context.headingFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: context.formFieldSpacing),
                Text(
                  AppLocalizations.of(context)!.welcomeTagline,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.pureWhite.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.formFieldSpacing * 2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.cardPadding,
                    vertical: context.smallPadding,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(
                      context.borderRadius('small'),
                    ),
                  ),
                  child: Text(
                    '${AppLocalizations.of(context)!.today}: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryMaroon,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: context.dialogWidth / 5,
            height: context.dialogWidth / 5,
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.cardPadding),
            ),
            child: Image.asset('assets/images/metabras.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    final List<String> pageNames = [
      AppLocalizations.of(context)!.dashboard,
      AppLocalizations.of(context)!.sales,
      AppLocalizations.of(context)!.orders,
      AppLocalizations.of(context)!.orderItems,
      AppLocalizations.of(context)!.products,
      AppLocalizations.of(context)!.category,
      AppLocalizations.of(context)!.customers,
      AppLocalizations.of(context)!.vendor,
      AppLocalizations.of(context)!.labor,
      AppLocalizations.of(context)!.receivables,
      AppLocalizations.of(context)!.payables,
      AppLocalizations.of(context)!.advancePayment,
      AppLocalizations.of(context)!.payments,
      AppLocalizations.of(context)!.expenses,
      AppLocalizations.of(context)!.principalAccount,
      AppLocalizations.of(context)!.zakat,
      AppLocalizations.of(context)!.profitLoss,
      AppLocalizations.of(context)!.taxManagement,
      AppLocalizations.of(context)!.returns,
      AppLocalizations.of(context)!.invoices,
      AppLocalizations.of(context)!.receipts,
      'Quotations',
      AppLocalizations.of(context)!.settings,
    ];

    final title = (selectedIndex >= 0 && selectedIndex < pageNames.length)
        ? pageNames[selectedIndex]
        : 'Unknown';

    return Container(
      padding: context.pagePadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.dialogWidth * 0.5,
              height: context.dialogWidth * 0.5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
                ),
                borderRadius: BorderRadius.circular(
                  context.borderRadius('large'),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryMaroon.withOpacity(0.3),
                    blurRadius: context.shadowBlur('heavy'),
                    offset: Offset(0, context.smallPadding),
                  ),
                ],
              ),
              child: Icon(
                Icons.construction_rounded,
                size: context.iconSize('xl'),
                color: AppTheme.pureWhite,
              ),
            ),

            SizedBox(height: context.formFieldSpacing * 4),

            Text(
              '$title ${AppLocalizations.of(context)!.page}',
              style: TextStyle(
                fontSize: context.headingFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoalGray,
              ),
            ),

            SizedBox(height: context.formFieldSpacing * 2),

            Text(
              '${AppLocalizations.of(context)!.underConstruction}\n${AppLocalizations.of(context)!.comingSoon}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            SizedBox(height: context.formFieldSpacing * 4),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Provider.of<DashboardProvider>(
                    context,
                    listen: false,
                  ).selectMenu(0);
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.cardPadding,
                    vertical: context.buttonHeight * 0.3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryMaroon,
                        AppTheme.secondaryMaroon,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryMaroon.withOpacity(0.3),
                        blurRadius: context.shadowBlur(),
                        offset: Offset(0, context.smallPadding),
                      ),
                    ],
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
