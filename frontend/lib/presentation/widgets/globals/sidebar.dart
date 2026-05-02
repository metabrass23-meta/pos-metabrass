import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/auth_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/providers/category_provider.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/providers/purchase_provider.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/providers/receivables_provider.dart';
import '../../../src/providers/payables_provider.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/providers/payment_provider.dart';
import '../../../src/providers/expenses_provider.dart';
import '../../../src/providers/zakat_provider.dart';
import '../../../src/providers/return_provider.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/providers/receipt_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../../src/utils/storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/dashboard_provider.dart';
import '../../../src/models/role_model.dart';

class LogoutDialogWidget extends StatefulWidget {
  final bool isExpanded;

  const LogoutDialogWidget({super.key, required this.isExpanded});

  @override
  _LogoutDialogWidgetState createState() => _LogoutDialogWidgetState();
}

class _LogoutDialogWidgetState extends State<LogoutDialogWidget> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius('medium')),
          ),
          backgroundColor: AppTheme.creamWhite,
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                AppLocalizations.of(context)!.confirmLogout,
                style: TextStyle(
                  fontSize: context.headerFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.logoutMessage,
            style: TextStyle(
              fontSize: context.bodyFontSize,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  fontSize: context.bodyFontSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.pureWhite,
                                ),
                              ),
                            ),
                            SizedBox(width: context.smallPadding),
                            Text(
                              AppLocalizations.of(context)!.loggingOut,
                              style: TextStyle(
                                fontSize: context.captionFontSize,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.primaryMaroon,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.borderRadius('medium'),
                          ),
                        ),
                        margin: EdgeInsets.all(context.mainPadding),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    final navigator = Navigator.of(context);
                    final dashboardProvider = context.read<DashboardProvider>();
                    
                    try {
                      await authProvider.logout();
                      await StorageService().clearAll();
                      
                      dashboardProvider.reset();
                      navigator.pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.logoutSuccess,
                              style: TextStyle(
                                fontSize: context.captionFontSize,
                              ),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.borderRadius('medium'),
                              ),
                            ),
                            margin: EdgeInsets.all(context.mainPadding),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                              (route) => false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: AppTheme.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        context.borderRadius(),
                      ),
                    ),
                    elevation: 2,
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.pureWhite,
                      ),
                    ),
                  )
                      : Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        child: Container(
          padding: EdgeInsets.all(
            widget.isExpanded
                ? context.sidebarPadding / 1.5
                : context.sidebarPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(context.borderRadius()),
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
          ),
          child: widget.isExpanded
              ? Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red.shade300,
                size: context.sidebarIconSize * 0.8,
              ),
              SizedBox(width: context.sidebarPadding),
              Text(
                AppLocalizations.of(context)!.logout,
                style: TextStyle(
                  fontSize: context.sidebarFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.pureWhite,
                ),
              ),
            ],
          )
              : Icon(
            Icons.logout_rounded,
            color: Colors.red.shade300,
            size: context.sidebarIconSize,
          ),
        ),
      ),
    );
  }
}

class PremiumSidebar extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onToggle;

  const PremiumSidebar({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onToggle,
  });

  List<Map<String, dynamic>> getMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final salesCount = context.watch<SalesProvider>().sales.length.toString();
    final purchasesCount = context.watch<PurchaseProvider>().purchases.length.toString();
    final productsCount = context.watch<ProductProvider>().products.length.toString();
    final categoriesCount = context.watch<CategoryProvider>().categories.length.toString();
    final customersCount = context.watch<CustomerProvider>().customers.length.toString();
    final vendorsCount = context.watch<VendorProvider>().vendors.length.toString();
    final laborsCount = context.watch<LaborProvider>().labors.length.toString();
    final receivablesCount = context.watch<ReceivablesProvider>().receivables.length.toString();
    final payablesCount = context.watch<PayablesProvider>().payables.length.toString();
    final advancePaymentsCount = context.watch<AdvancePaymentProvider>().advancePayments.length.toString();
    final paymentsCount = context.watch<PaymentProvider>().payments.length.toString();
    final expensesCount = context.watch<ExpensesProvider>().expenses.length.toString();
    final zakatCount = context.watch<ZakatProvider>().zakatRecords.length.toString();
    final returnsCount = context.watch<ReturnProvider>().returns.length.toString();
    final invoicesCount = context.watch<InvoiceProvider>().invoices.length.toString();
    final receiptsCount = context.watch<ReceiptProvider>().receipts.length.toString();

    final allItems = [
      {'icon': Icons.dashboard_rounded, 'title': l10n.dashboard, 'badge': null, 'module': 'Dashboard', 'globalIndex': 0},
      {'icon': Icons.point_of_sale_rounded, 'title': l10n.sales, 'badge': salesCount, 'module': 'Sales', 'globalIndex': 1},
      {'icon': Icons.shopping_cart_rounded, 'title': l10n.purchases, 'badge': purchasesCount, 'module': 'Purchases', 'globalIndex': 2},
      {'icon': Icons.inventory_2_rounded, 'title': l10n.products, 'badge': productsCount, 'module': 'Products', 'globalIndex': 3},
      {'icon': Icons.category_rounded, 'title': l10n.category, 'badge': categoriesCount, 'module': 'Category', 'globalIndex': 4},
      {'icon': Icons.description_rounded, 'title': 'Quotations', 'badge': null, 'module': 'Quotations', 'globalIndex': 5},
      {'icon': Icons.people_rounded, 'title': l10n.customers, 'badge': customersCount, 'module': 'Customers', 'globalIndex': 6},
      {'icon': Icons.store_rounded, 'title': l10n.vendor, 'badge': vendorsCount, 'module': 'Vendor', 'globalIndex': 7},
      {'icon': Icons.engineering_rounded, 'title': l10n.labor, 'badge': laborsCount, 'module': 'Labour', 'globalIndex': 8},
      {'icon': Icons.account_balance_wallet_rounded, 'title': l10n.receivables, 'badge': receivablesCount, 'module': 'Receivables', 'globalIndex': 9},
      {'icon': Icons.money_off_rounded, 'title': l10n.payables, 'badge': payablesCount, 'module': 'Payables', 'globalIndex': 10},
      {'icon': Icons.payments_rounded, 'title': l10n.advancePayment, 'badge': advancePaymentsCount, 'module': 'Advance Payment', 'globalIndex': 11},
      {'icon': Icons.payment_rounded, 'title': l10n.payments, 'badge': paymentsCount, 'module': 'Payments', 'globalIndex': 12},
      {'icon': Icons.account_balance_rounded, 'title': l10n.expenses, 'badge': expensesCount, 'module': 'Expenses', 'globalIndex': 13},
      {'icon': Icons.account_circle_rounded, 'title': l10n.principalAccount, 'badge': null, 'module': 'Principal Account', 'globalIndex': 14},
      {'icon': Icons.handshake_rounded, 'title': l10n.zakat, 'badge': zakatCount, 'module': 'Zakat', 'globalIndex': 15},
      {'icon': Icons.calculate_rounded, 'title': l10n.profitLoss, 'badge': null, 'module': 'Profit & Loss', 'globalIndex': 16},
      {'icon': Icons.assignment_return_rounded, 'title': l10n.returns, 'badge': returnsCount, 'module': 'Returns', 'globalIndex': 17},
      {'icon': Icons.receipt_long_rounded, 'title': l10n.invoices, 'badge': invoicesCount, 'module': 'Invoices', 'globalIndex': 18},
      {'icon': Icons.receipt_rounded, 'title': l10n.receipts, 'badge': receiptsCount, 'module': 'Receipts', 'globalIndex': 19},
      {'icon': Icons.manage_accounts_rounded, 'title': 'User Management', 'badge': null, 'module': 'User Management', 'globalIndex': 20},
      {'icon': Icons.security_rounded, 'title': 'Roles & Permissions', 'badge': null, 'module': 'Roles & Permissions', 'globalIndex': 21},
      {'icon': Icons.settings_rounded, 'title': l10n.settings, 'badge': null, 'module': 'Settings', 'globalIndex': 22},
    ];

    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return allItems;
    
    // Admin sees everything
    if (user.roleName == 'Admin') return allItems;

    // Filter based on permissions
    return allItems.where((item) {
      if (item['module'] == null) {
        // Non-admins cannot see Settings
        if (item['title'] == l10n.settings) return false;
        return true; 
      }
      final permission = user.roleData?.permissions.firstWhere(
        (p) => p.moduleName.toLowerCase() == item['module'].toString().toLowerCase(),
        orElse: () => ModulePermissionModel(moduleName: '', canView: false),
      );
      return permission?.canView ?? false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded
          ? context.sidebarExpandedWidth
          : context.sidebarCollapsedWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: context.shadowBlur(),
            offset: Offset(context.smallPadding / 2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(context.cardPadding / 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.pureWhite.withOpacity(0.1),
                  width: 0.1.w,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 2.5.w,
                  height: 2.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.pureWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: context.shadowBlur('light'),
                        offset: Offset(0, context.smallPadding / 2),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/metabras.png'),
                ),

                if (isExpanded) ...[
                  SizedBox(width: context.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.headerFontSize * 1.1,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.pureWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.brandTagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.captionFontSize * 1.1,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.pureWhite.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: Builder(
              builder: (context) {
                final menuItems = getMenuItems(context);
                return ListView.builder(
                  padding: context.sectionPadding / 4,
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final isSelected = item['globalIndex'] == selectedIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(
                        horizontal: context.smallPadding / 2,
                        vertical: context.smallPadding / 3,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onMenuSelected(item['globalIndex']),
                          borderRadius: BorderRadius.circular(
                            context.borderRadius(),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sidebarPadding,
                              vertical: context.sidebarPadding / 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.pureWhite.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                context.borderRadius(),
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.pureWhite.withOpacity(0.3),
                                      width: 0.05.w,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: context.iconSize('large'),
                                  height: context.iconSize('large'),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.accentGold.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      context.borderRadius('small'),
                                    ),
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    color: isSelected
                                        ? AppTheme.accentGold
                                        : AppTheme.pureWhite.withOpacity(0.8),
                                    size: context.sidebarIconSize,
                                  ),
                                ),

                                  if (isExpanded) ...[
                                    SizedBox(width: context.sidebarPadding),

                                    Expanded(
                                    child: Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontSize: context.sidebarFontSize,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? AppTheme.pureWhite
                                            : AppTheme.pureWhite.withOpacity(0.85),
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                  if (item['badge'] != null) ...[
                                    SizedBox(width: context.sidebarPadding / 2),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: (context.smallPadding * 0.6).clamp(6.0, 12.0),
                                        vertical: (context.smallPadding * 0.3).clamp(2.0, 6.0),
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(
                                          context.borderRadius('small'),
                                        ),
                                      ),
                                      child: Text(
                                        item['badge'],
                                        style: TextStyle(
                                          fontSize: context.sidebarBadgeFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.pureWhite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(context.sidebarPadding),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.pureWhite.withOpacity(0.1),
                  width: 0.1.w,
                ),
              ),
            ),
            child: Column(
              children: [
                if (isExpanded) ...[
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final user = authProvider.currentUser;
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: context.sidebarIconSize / 2,
                            backgroundColor: AppTheme.accentGold,
                            child: Text(
                              user?.fullName.isNotEmpty == true
                                  ? user!.fullName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: context.sidebarFontSize * 0.9,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryMaroon,
                              ),
                            ),
                          ),
                          SizedBox(width: context.sidebarPadding),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? '',
                                  style: TextStyle(
                                    fontSize: context.bodyFontSize * 1.1,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.pureWhite,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      fontSize: context.sidebarFontSize * 0.8,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.pureWhite.withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const LogoutDialogWidget(isExpanded: true),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  const LogoutDialogWidget(isExpanded: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
