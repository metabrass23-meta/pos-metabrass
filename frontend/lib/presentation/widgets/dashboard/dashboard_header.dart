import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1.w,
            offset: Offset(0, 0.3.w),
          ),
        ],
      ),
      child: Row(
        children: [
          // Page Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  _getSubtitle(),
                  style: GoogleFonts.inter(
                    fontSize: 9.6.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          // Container(
          //   width: 25.w,
          //   height: 5.h,
          //   decoration: BoxDecoration(
          //     color: AppTheme.lightGray,
          //     borderRadius: BorderRadius.circular(2.5.h),
          //     border: Border.all(
          //       color: Colors.grey.shade300,
          //       width: 0.05.w,
          //     ),
          //   ),
          //   child: TextField(
          //     style: GoogleFonts.inter(
          //       fontSize: 9.8.sp,
          //       color: AppTheme.charcoalGray,
          //     ),
          //     decoration: InputDecoration(
          //       hintText: 'Search products, orders, customers...',
          //       hintStyle: GoogleFonts.inter(
          //         fontSize: 10.6.sp,
          //         color: Colors.grey[500],
          //       ),
          //       prefixIcon: Icon(
          //         Icons.search_rounded,
          //         color: Colors.grey[500],
          //         size: 11.5.sp,
          //       ),
          //       border: InputBorder.none,
          //       contentPadding: EdgeInsets.symmetric(
          //         horizontal: 2.w,
          //         vertical: 1.h,
          //       ),
          //     ),
          //   ),
          // ),
          //
          // SizedBox(width: 2.w),

          // Quick Actions
          Row(
            children: [
              // Add New Button
              // Container(
              //   height: 5.h,
              //   padding: EdgeInsets.symmetric(horizontal: 2.w),
              //   decoration: BoxDecoration(
              //     gradient: const LinearGradient(
              //       colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
              //     ),
              //     borderRadius: BorderRadius.circular(1.2.w),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppTheme.primaryMaroon.withOpacity(0.3),
              //         blurRadius: 0.8.w,
              //         offset: Offset(0, 0.3.w),
              //       ),
              //     ],
              //   ),
              //   child: Material(
              //     color: Colors.transparent,
              //     child: InkWell(
              //       onTap: () {
              //         // Handle add new
              //       },
              //       borderRadius: BorderRadius.circular(1.2.w),
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Icon(
              //             Icons.add_rounded,
              //             color: AppTheme.pureWhite,
              //             size: 12.2.sp,
              //           ),
              //           SizedBox(width: 0.8.w),
              //           Text(
              //             'Add New',
              //             style: GoogleFonts.inter(
              //               fontSize: 10.6.sp,
              //               fontWeight: FontWeight.w500,
              //               color: AppTheme.pureWhite,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              // SizedBox(width: 1.w),

              // Notifications
              // Material(
              //   color: Colors.transparent,
              //   child: InkWell(
              //     onTap: onNotificationTap,
              //     borderRadius: BorderRadius.circular(1.w),
              //     child: Container(
              //       width: 4.w,
              //       height: 4.w,
              //       decoration: BoxDecoration(
              //         color: AppTheme.lightGray,
              //         borderRadius: BorderRadius.circular(1.w),
              //       ),
              //       child: Stack(
              //         alignment: Alignment.center,
              //         children: [
              //           Icon(
              //             Icons.notifications_outlined,
              //             color: AppTheme.charcoalGray,
              //             size: 14.2.sp,
              //           ),
              //           Positioned(
              //             top: 0.8.w,
              //             right: 0.8.w,
              //             child: Container(
              //               width: 0.8.w,
              //               height: 0.8.w,
              //               decoration: const BoxDecoration(
              //                 color: Colors.red,
              //                 shape: BoxShape.circle,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              // SizedBox(width: 1.w),

              // Profile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(2.w),
                  child: Container(
                    padding: EdgeInsets.all(0.3.w),
                    child: CircleAvatar(
                      radius: 2.w,
                      backgroundColor: AppTheme.primaryMaroon,
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return '$greeting!';
  }
}