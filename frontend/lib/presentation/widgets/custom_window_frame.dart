import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../src/theme/app_theme.dart';

class CustomWindowFrame extends StatelessWidget {
  final Widget child;
  final String title;

  const CustomWindowFrame({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Title Bar
        WindowTitleBarBox(
          child: Container(
            height: 5.h,
            decoration: const BoxDecoration(
              color: AppTheme.primaryMaroon,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // App Icon and Title
                Expanded(
                  child: MoveWindow(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 2.2.w,
                            color: AppTheme.pureWhite,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 1.8.w,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.pureWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Window Controls
                Row(
                  children: [
                    MinimizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: AppTheme.pureWhite.withOpacity(0.8),
                        mouseOver: AppTheme.pureWhite.withOpacity(0.1),
                        mouseDown: AppTheme.pureWhite.withOpacity(0.2),
                        iconMouseOver: AppTheme.pureWhite,
                        iconMouseDown: AppTheme.pureWhite,
                      ),
                    ),
                    MaximizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: AppTheme.pureWhite.withOpacity(0.8),
                        mouseOver: AppTheme.pureWhite.withOpacity(0.1),
                        mouseDown: AppTheme.pureWhite.withOpacity(0.2),
                        iconMouseOver: AppTheme.pureWhite,
                        iconMouseDown: AppTheme.pureWhite,
                      ),
                    ),
                    CloseWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: AppTheme.pureWhite.withOpacity(0.8),
                        mouseOver: Colors.red.withOpacity(0.8),
                        mouseDown: Colors.red,
                        iconMouseOver: AppTheme.pureWhite,
                        iconMouseDown: AppTheme.pureWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Content
        Expanded(child: child),
      ],
    );
  }
}