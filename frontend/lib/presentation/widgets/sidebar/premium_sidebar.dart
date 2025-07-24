import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/theme/app_theme.dart';

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
    {'icon': Icons.category_rounded, 'title': 'Categories', 'badge': null},
    {'icon': Icons.inventory_2_rounded, 'title': 'Products', 'badge': '432'},
    {'icon': Icons.engineering_rounded, 'title': 'Labor', 'badge': null},
    {'icon': Icons.payments_rounded, 'title': 'Advance', 'badge': '12'},
    {'icon': Icons.payment_rounded, 'title': 'Payment', 'badge': null},
    {'icon': Icons.point_of_sale_rounded, 'title': 'Sales', 'badge': '23'},
    {'icon': Icons.trending_down_rounded, 'title': 'Expenses', 'badge': null},
    {'icon': Icons.inventory_rounded, 'title': 'Stock', 'badge': '5'},
    {'icon': Icons.analytics_rounded, 'title': 'Reports', 'badge': null},
    {'icon': Icons.settings_rounded, 'title': 'Settings', 'badge': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryMaroon,
            AppTheme.secondaryMaroon,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.w,
            offset: Offset(0.5.w, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(1.w),
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
                // Logo
                Container(
                  width: 3.5.w,
                  height: 3.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.pureWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 0.8.w,
                        offset: Offset(0, 0.3.w),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.diamond_sharp,
                    size: 18.sp,
                    color: AppTheme.primaryMaroon,
                  ),
                ),

                if (isExpanded) ...[
                  SizedBox(width: 1.5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maqbool Fabrics',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14.2.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.pureWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Premium POS',
                          style: GoogleFonts.inter(
                            fontSize: 10.4.sp,
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
                    borderRadius: BorderRadius.circular(0.8.w),
                    child: Container(
                      padding: EdgeInsets.all(0.8.w),
                      child: Icon(
                        isExpanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                        color: AppTheme.pureWhite.withOpacity(0.9),
                        size: 2.5.sp,
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
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = index == selectedIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: isExpanded ? 1.w : 0.5.w,
                    vertical: 0.3.h,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onMenuSelected(index),
                      borderRadius: BorderRadius.circular(1.2.w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? 1.5.w : 1.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.pureWhite.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(1.2.w),
                          border: isSelected
                              ? Border.all(
                            color: AppTheme.pureWhite.withOpacity(0.3),
                            width: 0.05.w,
                          )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentGold.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(0.8.w),
                              ),
                              child: Icon(
                                item['icon'],
                                color: isSelected
                                    ? AppTheme.accentGold
                                    : AppTheme.pureWhite.withOpacity(0.8),
                                size: 12.2.sp,
                              ),
                            ),

                            if (isExpanded) ...[
                              SizedBox(width: 1.5.w),

                              // Title
                              Expanded(
                                child: Text(
                                  item['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: 10.8.sp,
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
                                    horizontal: 0.8.w,
                                    vertical: 0.3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item['badge'] == '5' || item['badge'] == '12' || item['badge'] == '23'
                                        ? Colors.orange.withOpacity(0.9)
                                        : AppTheme.accentGold.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(1.w),
                                  ),
                                  child: Text(
                                    item['badge'],
                                    style: GoogleFonts.inter(
                                      fontSize: 9.3.sp,
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

          // Footer
          if (isExpanded) ...[
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.pureWhite.withOpacity(0.1),
                    width: 0.1.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 1.6.w,
                    backgroundColor: AppTheme.accentGold,
                    child: Text(
                      'A',
                      style: GoogleFonts.inter(
                        fontSize: 10.8.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryMaroon,
                      ),
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: GoogleFonts.inter(
                            fontSize: 10.6.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.pureWhite,
                          ),
                        ),
                        Text(
                          'admin@maqboolfabric.com',
                          style: GoogleFonts.inter(
                            fontSize: 9.2.sp,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.pureWhite.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}