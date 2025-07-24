import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/dashboard_provider.dart';
import '../../../src/theme/app_theme.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
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
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primaryMaroon,
                  size: 2.5.sp,
                ),
              ),

              SizedBox(width: 1.5.w),

              Expanded(
                child: Text(
                  'Recent Orders',
                  style: GoogleFonts.inter(
                    fontSize: 2.2.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  // View all orders
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 1.6.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Orders List
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                final orders = provider.recentOrders;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderItem(order, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, int index) {
    Color statusColor = _getStatusColor(order['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1.2.w),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.05.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(0.8.w),
                ),
                child: Text(
                  order['id'],
                  style: GoogleFonts.inter(
                    fontSize: 1.4.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.w,
                  vertical: 0.3.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(0.8.w),
                ),
                child: Text(
                  order['status'],
                  style: GoogleFonts.inter(
                    fontSize: 1.3.sp,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Customer Info
          Row(
            children: [
              CircleAvatar(
                radius: 1.5.w,
                backgroundColor: AppTheme.accentGold,
                child: Text(
                  order['customer'][0].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 1.6.sp,
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
                      order['customer'],
                      style: GoogleFonts.inter(
                        fontSize: 1.7.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      order['type'],
                      style: GoogleFonts.inter(
                        fontSize: 1.4.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Amount and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['amount'],
                style: GoogleFonts.inter(
                  fontSize: 2.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryMaroon,
                ),
              ),

              Text(
                order['date'],
                style: GoogleFonts.inter(
                  fontSize: 1.4.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}