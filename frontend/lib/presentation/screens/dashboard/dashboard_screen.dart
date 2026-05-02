import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../src/providers/dashboard_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../widgets/dashboard/dashboard_content.dart';
import '../../widgets/globals/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dashboardProvider = context.read<DashboardProvider>();
        dashboardProvider.setInstance(); // Set global instance
        dashboardProvider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return SizedBox.expand(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: dashboardProvider.isSidebarExpanded
                      ? ResponsiveBreakpoints.getSidebarExpandedWidth(context)
                      : ResponsiveBreakpoints.getSidebarCollapsedWidth(context),
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
            ),
          );
        },
      ),
    );
  }
}
