import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/auth_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';

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
                'Confirm Logout',
                style: GoogleFonts.playfairDisplay(
                  fontSize: context.headerFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
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
                    debugPrint('Logout button pressed');
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
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
                              'Logging out...',
                              style: GoogleFonts.inter(
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
                    try {
                      await authProvider.logout();
                      debugPrint('Logout completed successfully');
                      if (mounted) {
                        debugPrint('Navigating to /login');
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                              (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully logged out. See you soon!',
                              style: GoogleFonts.inter(
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
                      } else {
                        debugPrint('Context not mounted, skipping navigation');
                      }
                    } catch (e) {
                      debugPrint('Logout error: $e');
                      if (mounted) {
                        debugPrint('Navigating to /login after error');
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                              (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Logged out locally due to an error.',
                              style: GoogleFonts.inter(
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
                      } else {
                        debugPrint('Context not mounted after error, skipping navigation');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: AppTheme.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                    elevation: 2,
                  ),
                  child: authProvider.isLoading
                      ? SizedBox(
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
                    style: GoogleFonts.inter(
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
          padding: EdgeInsets.all(widget.isExpanded ? context.smallPadding / 1.5 : context.smallPadding),
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
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.pureWhite,
                ),
              ),
            ],
          )
              : Icon(
            Icons.logout_rounded,
            color: Colors.red.shade300,
            size: context.iconSize('medium'),
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

  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.dashboard_rounded, 'title': 'Dashboard', 'badge': null},
    {'icon': Icons.category_rounded, 'title': 'Categories', 'badge': '11'},
    {'icon': Icons.shopping_bag_rounded, 'title': 'Orders', 'badge': '7'},
    {'icon': Icons.inventory_2_rounded, 'title': 'Products', 'badge': '432'},
    {'icon': Icons.engineering_rounded, 'title': 'Labor', 'badge': '14731'},
    {'icon': Icons.store_rounded, 'title': 'Vendors', 'badge': '8'},
    {'icon': Icons.people_rounded, 'title': 'Customers', 'badge': '156'},
    {'icon': Icons.payments_rounded, 'title': 'Advance', 'badge': '12'},
    {'icon': Icons.payment_rounded, 'title': 'Payment', 'badge': '3'},
    {'icon': Icons.account_balance_wallet_rounded, 'title': 'Receivables', 'badge': '15'},
    {'icon': Icons.money_off_rounded, 'title': 'Payables', 'badge': '9'},
    {'icon': Icons.point_of_sale_rounded, 'title': 'Sales', 'badge': '23'},
    {'icon': Icons.account_balance_rounded, 'title': 'Expense', 'badge': '16'},
    {'icon': Icons.handshake_rounded, 'title': 'Zakat', 'badge': '4'},
    {'icon': Icons.account_circle_rounded, 'title': 'Principal Account', 'badge': '0'},
    {'icon': Icons.calculate_rounded, 'title': 'Profit/Loss', 'badge': null},
    {'icon': Icons.settings_rounded, 'title': 'Settings', 'badge': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? context.sidebarExpandedWidth : context.sidebarCollapsedWidth,
      height: 100.h,
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
                bottom: BorderSide(color: AppTheme.pureWhite.withOpacity(0.1), width: 0.1.w),
              ),
            ),
            child: Row(
              children: [
                // Logo
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
                  child: Icon(
                    Icons.diamond_sharp,
                    size: context.iconSize('medium'),
                    color: AppTheme.primaryMaroon,
                  ),
                ),

                if (isExpanded) ...[
                  SizedBox(width: context.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maqbool Fashion',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: context.headerFontSize,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.pureWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Premium POS',
                          style: GoogleFonts.inter(
                            fontSize: context.captionFontSize,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.pureWhite.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Toggle Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                    child: Container(
                      padding: EdgeInsets.all(context.smallPadding / 2),
                      child: Icon(
                        isExpanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                        color: AppTheme.pureWhite.withOpacity(0.9),
                        size: context.iconSize('medium'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: context.sectionPadding / 4,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = index == selectedIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: isExpanded ? context.cardPadding : context.smallPadding,
                    vertical: context.smallPadding / 2.5,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onMenuSelected(index),
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? context.cardPadding : context.smallPadding,
                          vertical: context.cardPadding / 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.pureWhite.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.borderRadius()),
                          border: isSelected
                              ? Border.all(color: AppTheme.pureWhite.withOpacity(0.3), width: 0.05.w)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: context.iconSize('large'),
                              height: context.iconSize('large'),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.accentGold.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                              ),
                              child: Icon(
                                item['icon'],
                                color: isSelected ? AppTheme.accentGold : AppTheme.pureWhite.withOpacity(0.8),
                                size: context.iconSize('medium'),
                              ),
                            ),

                            if (isExpanded) ...[
                              SizedBox(width: context.smallPadding),

                              // Title
                              Expanded(
                                child: Text(
                                  item['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? AppTheme.pureWhite
                                        : AppTheme.pureWhite.withOpacity(0.85),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),

                              // Badge
                              if (item['badge'] != null) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.smallPadding,
                                    vertical: context.smallPadding / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item['badge'] == '156'
                                        ? Colors.blue.withOpacity(0.9)
                                        : item['badge'] == '8'
                                        ? Colors.green.withOpacity(0.9)
                                        : item['badge'] == '7'
                                        ? Colors.purple.withOpacity(0.9)
                                        : item['badge'] == '15'
                                        ? Colors.cyan.withOpacity(0.9)
                                        : item['badge'] == '9'
                                        ? Colors.red.withOpacity(0.9)
                                        : item['badge'] == '16'
                                        ? Colors.yellow.withOpacity(0.9)
                                        : item['badge'] == '4'
                                        ? Colors.pink.withOpacity(0.9)
                                        : (item['badge'] == '5' ||
                                        item['badge'] == '12' ||
                                        item['badge'] == '23')
                                        ? Colors.orange.withOpacity(0.9)
                                        : AppTheme.accentGold.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                                  ),
                                  child: Text(
                                    item['badge'],
                                    style: GoogleFonts.inter(
                                      fontSize: context.captionFontSize,
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
            ),
          ),

          // Footer with User Info and Logout
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.pureWhite.withOpacity(0.1), width: 0.1.w),
              ),
            ),
            child: Column(
              children: [
                if (isExpanded) ...[
                  // User Info Row with Logout Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final user = authProvider.currentUser;
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: context.iconSize('medium') / 2,
                            backgroundColor: AppTheme.accentGold,
                            child: Text(
                              user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                              style: GoogleFonts.inter(
                                fontSize: context.bodyFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryMaroon,
                              ),
                            ),
                          ),
                          SizedBox(width: context.smallPadding),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'User',
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.pureWhite,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user?.email ?? 'user@email.com',
                                  style: GoogleFonts.inter(
                                    fontSize: context.captionFontSize,
                                    fontWeight: FontWeight.w300,
                                    color: AppTheme.pureWhite.withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Logout Button
                          LogoutDialogWidget(isExpanded: true),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  // Collapsed state - just logout icon
                  LogoutDialogWidget(isExpanded: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}