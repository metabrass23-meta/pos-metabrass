import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/dashboard/quick_actions_card.dart';
import 'package:frontend/presentation/widgets/dashboard/recent_orders_card.dart';
import 'package:frontend/presentation/widgets/dashboard/sales_chart_card.dart';
import 'package:frontend/presentation/widgets/dashboard/stats_card.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/dashboard_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../screens/category/category_screen.dart';
import '../../screens/labor/labor_screen.dart';

class DashboardContent extends StatelessWidget {
  final int selectedIndex;

  const DashboardContent({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      return _buildDashboard(context);
    } else if (selectedIndex == 1) {
      return const CategoryPage();
    } else if (selectedIndex == 3) {
      return const LaborPage();
    } else {
      return _buildPlaceholderContent(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    return Container(
      padding: context.pagePadding / 1.5,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryMaroon,
                    AppTheme.secondaryMaroon,
                  ],
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
                          'Welcome to Maqbool Fabrics POS',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: context.headingFontSize,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.pureWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: context.formFieldSpacing),
                        Text(
                          'Crafting Excellence in Every Stitch - Your Premium Fashion Management System',
                          style: GoogleFonts.inter(
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
                            borderRadius: BorderRadius.circular(context.borderRadius('small')),
                          ),
                          child: Text(
                            'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: GoogleFonts.inter(
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
                    child: Icon(
                      Icons.diamond_sharp,
                      size: context.iconSize('special'),
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.formFieldSpacing * 3),

            // Stats Cards
            Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                final stats = provider.dashboardStats;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cardCount = context.statsCardColumns.clamp(2, 4); // Ensure at least 2 columns
                    final cardWidth = constraints.maxWidth / cardCount - context.cardPadding * (cardCount - 1) / cardCount;
                    return Wrap(
                      spacing: context.cardPadding, // Responsive spacing between cards
                      runSpacing: context.formFieldSpacing, // Responsive spacing between rows
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: 'Total Sales',
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
                            title: 'Total Orders',
                            value: stats['totalOrders']['value'],
                            change: stats['totalOrders']['change'],
                            isPositive: stats['totalOrders']['isPositive'],
                            icon: Icons.shopping_bag_rounded,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: 'Total Products',
                            value: stats['totalProducts']['value'],
                            change: stats['totalProducts']['change'],
                            isPositive: stats['totalProducts']['isPositive'],
                            icon: Icons.inventory_2_rounded,
                            color: Colors.purple,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatsCard(
                            title: 'Pending Orders',
                            value: stats['pendingOrders']['value'],
                            change: stats['pendingOrders']['change'],
                            isPositive: stats['pendingOrders']['isPositive'],
                            icon: Icons.pending_actions_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            SizedBox(height: context.formFieldSpacing * 3),

            // Main Content Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: context.tableColumnFlexes[0],
                  child: Column(
                    children: [
                      // Sales Chart
                      SizedBox(
                        height: context.chartHeight,
                        child: const SalesChartCard(),
                      ),

                      SizedBox(height: context.formFieldSpacing * 2),

                      // Quick Actions
                      const QuickActionsCard(),
                    ],
                  ),
                ),

                SizedBox(width: context.cardPadding),

                // Right Column
                Expanded(
                  flex: context.tableColumnFlexes[1],
                  child: const RecentOrdersCard(),
                ),
              ],
            ),

            SizedBox(height: context.formFieldSpacing * 3),

            // Bottom Section - Recent Activity
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(context.borderRadius()),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: context.shadowBlur(),
                    offset: Offset(0, context.smallPadding),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        color: AppTheme.primaryMaroon,
                        size: context.iconSize('large'),
                      ),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Recent Activity',
                        style: GoogleFonts.inter(
                          fontSize: context.headerFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.formFieldSpacing * 2),

                  // Activity Items
                  _buildActivityItem(
                    context,
                    'New order received from Aisha Khan',
                    'Bridal Dress - ₨ 85,000',
                    '2 minutes ago',
                    Icons.shopping_bag_rounded,
                    Colors.green,
                  ),
                  _buildActivityItem(
                    context,
                    'Payment completed for order #MF002',
                    'Fatima Ali - ₨ 45,000',
                    '1 hour ago',
                    Icons.payment_rounded,
                    Colors.blue,
                  ),
                  _buildActivityItem(
                    context,
                    'Stock alert: Low inventory',
                    'Silk Fabric - Only 5 meters left',
                    '3 hours ago',
                    Icons.warning_rounded,
                    Colors.orange,
                  ),
                  _buildActivityItem(
                    context,
                    'New customer registered',
                    'Sarah Ahmed - Premium Member',
                    '5 hours ago',
                    Icons.person_add_rounded,
                    Colors.purple,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.formFieldSpacing * 3),

            // Performance Metrics Row
            Row(
              children: [
                // Monthly Performance
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(context.cardPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: context.shadowBlur(),
                          offset: Offset(0, context.smallPadding),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.blue,
                              size: context.iconSize('medium'),
                            ),
                            SizedBox(width: context.smallPadding),
                            Text(
                              'Monthly Performance',
                              style: GoogleFonts.inter(
                                fontSize: context.headerFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: context.formFieldSpacing * 2),

                        _buildMetricRow(context, 'Revenue Target', '₨ 3,00,000', '82%', Colors.blue),
                        _buildMetricRow(context, 'Orders Target', '1,500', '83%', Colors.green),
                        _buildMetricRow(context, 'Customer Growth', '200', '75%', Colors.purple),
                        _buildMetricRow(context, 'Conversion Rate', '65%', '92%', Colors.orange),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: context.cardPadding),

                // Top Products
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(context.cardPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: context.shadowBlur(),
                          offset: Offset(0, context.smallPadding),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppTheme.accentGold,
                              size: context.iconSize('medium'),
                            ),
                            SizedBox(width: context.smallPadding),
                            Text(
                              'Top Products',
                              style: GoogleFonts.inter(
                                fontSize: context.headerFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: context.formFieldSpacing * 2),

                        _buildProductRow(context, 'Bridal Silk Dress', '₨ 1,25,000', '45 sold'),
                        _buildProductRow(context, 'Groom Sherwani', '₨ 85,000', '38 sold'),
                        _buildProductRow(context, 'Party Lehenga', '₨ 75,000', '32 sold'),
                        _buildProductRow(context, 'Wedding Suit', '₨ 95,000', '28 sold'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context,
      String title,
      String subtitle,
      String time,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: context.formFieldSpacing),
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 0.05.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.iconSize('large') * 1.5,
            height: context.iconSize('large') * 1.5,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.iconSize('large') * 0.75),
            ),
            child: Icon(
              icon,
              color: color,
              size: context.iconSize('medium'),
            ),
          ),

          SizedBox(width: context.smallPadding),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: context.captionFontSize * 0.9,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, String percentage, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: context.formFieldSpacing),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding * 0.5,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              percentage,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, String name, String price, String sold) {
    return Container(
      margin: EdgeInsets.only(bottom: context.formFieldSpacing),
      child: Row(
        children: [
          Container(
            width: context.iconSize('medium') * 1.5,
            height: context.iconSize('medium') * 1.5,
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Icon(
              Icons.local_offer_rounded,
              color: AppTheme.primaryMaroon,
              size: context.iconSize('small'),
            ),
          ),

          SizedBox(width: context.smallPadding),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  '$price • $sold',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    final List<String> pageNames = [
      'Dashboard',
      'Categories',
      'Products',
      'Labor',
      'Advance',
      'Payment',
      'Sales',
      'Expenses',
      'Stock',
      'Reports',
      'Settings',
    ];

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
                borderRadius: BorderRadius.circular(context.borderRadius('large')),
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
              '${pageNames[selectedIndex]} Page',
              style: GoogleFonts.playfairDisplay(
                fontSize: context.headingFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoalGray,
              ),
            ),

            SizedBox(height: context.formFieldSpacing * 2),

            Text(
              'This page is under construction.\nComing soon with amazing features!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
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
                  Provider.of<DashboardProvider>(context, listen: false).selectMenu(0);
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.cardPadding,
                    vertical: context.buttonHeight * 0.3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
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
                    style: GoogleFonts.inter(
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