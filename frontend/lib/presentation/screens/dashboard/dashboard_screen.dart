import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/dashboard_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/dashboard/dashboard_content.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/global/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.creamWhite,
        body: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, child) {
            return Row(
              children: [
                // Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: dashboardProvider.isSidebarExpanded ? 28.w : 8.w,
                  child: PremiumSidebar(
                    isExpanded: dashboardProvider.isSidebarExpanded,
                    selectedIndex: dashboardProvider.selectedMenuIndex,
                    onMenuSelected: (index) {
                      dashboardProvider.selectMenu(index);
                    },
                    onToggle: () {
                      dashboardProvider.toggleSidebar();
                    },
                  ),
                ),

                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      // Header
                      // DashboardHeader(
                      //   title: dashboardProvider.currentPageTitle,
                      //   onNotificationTap: () {
                      //     // Handle notifications
                      //   },
                      //   onProfileTap: () {
                      //     // Handle profile
                      //   },
                      // ),

                      // Content
                      Expanded(
                        child: DashboardContent(
                          selectedIndex: dashboardProvider.selectedMenuIndex,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}