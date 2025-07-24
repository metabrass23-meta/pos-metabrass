import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../src/theme/app_theme.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  final List<Map<String, dynamic>> quickActions = const [
    {
      'title': 'New Order',
      'subtitle': 'Create order',
      'icon': Icons.add_shopping_cart_rounded,
      'color': Colors.green,
      'gradient': [Color(0xFF4CAF50), Color(0xFF45A049)],
    },
    {
      'title': 'Add Product',
      'subtitle': 'Manage inventory',
      'icon': Icons.inventory_2_rounded,
      'color': Colors.blue,
      'gradient': [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
    {
      'title': 'Payment',
      'subtitle': 'Process payment',
      'icon': Icons.payment_rounded,
      'color': Colors.purple,
      'gradient': [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    },
    {
      'title': 'Reports',
      'subtitle': 'View analytics',
      'icon': Icons.analytics_rounded,
      'color': Colors.orange,
      'gradient': [Color(0xFFFF9800), Color(0xFFF57C00)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1.w,
            offset: Offset(0, 0.5.w),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: AppTheme.accentGold,
                  size: 2.5.sp,
                ),
              ),

              SizedBox(width: 1.5.w),

              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 2.2.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Actions Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 1.5.w,
              mainAxisSpacing: 1.5.h,
              childAspectRatio: 1.8,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return _buildActionCard(action);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Handle action tap
        },
        borderRadius: BorderRadius.circular(1.5.w),
        child: Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: action['gradient'],
            ),
            borderRadius: BorderRadius.circular(1.5.w),
            boxShadow: [
              BoxShadow(
                color: action['color'].withOpacity(0.3),
                blurRadius: 1.w,
                offset: Offset(0, 0.5.w),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(0.8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Icon(
                  action['icon'],
                  color: Colors.white,
                  size: 2.5.sp,
                ),
              ),

              // Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action['title'],
                    style: GoogleFonts.inter(
                      fontSize: 1.8.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    action['subtitle'],
                    style: GoogleFonts.inter(
                      fontSize: 1.4.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}