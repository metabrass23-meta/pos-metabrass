import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../src/providers/auth_provider.dart';
import '../../../src/theme/app_theme.dart';

// Helper StatefulWidget to manage logout dialog and navigation
class LogoutDialogWidget extends StatefulWidget {
  const LogoutDialogWidget({super.key});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius('medium'))),
          backgroundColor: AppTheme.creamWhite,
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
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
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: Colors.grey[600], height: 1.4),
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
                          debugPrint('Logout button pressed'); // Debug log
                          // Close dialog first
                          Navigator.of(dialogContext).pop();

                          // Show loading snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
                                    ),
                                  ),
                                  SizedBox(width: context.smallPadding),
                                  Text(
                                    'Logging out...',
                                    style: GoogleFonts.inter(fontSize: context.captionFontSize),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.primaryMaroon,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.borderRadius('medium')),
                              ),
                              margin: EdgeInsets.all(context.mainPadding),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          try {
                            // Perform logout
                            await authProvider.logout();
                            debugPrint('Logout completed successfully'); // Debug log

                            // Navigate to login screen
                            if (mounted) {
                              debugPrint('Navigating to /login'); // Debug log
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Successfully logged out. See you soon!',
                                    style: GoogleFonts.inter(fontSize: context.captionFontSize),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.borderRadius('medium')),
                                  ),
                                  margin: EdgeInsets.all(context.mainPadding),
                                ),
                              );
                            } else {
                              debugPrint('Context not mounted, skipping navigation'); // Debug log
                            }
                          } catch (e) {
                            debugPrint('Logout error: $e'); // Debug log
                            // Navigate even if logout fails, since storage is cleared
                            if (mounted) {
                              debugPrint('Navigating to /login after error'); // Debug log
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Logged out locally due to an error.',
                                    style: GoogleFonts.inter(fontSize: context.captionFontSize),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.borderRadius('medium')),
                                  ),
                                  margin: EdgeInsets.all(context.mainPadding),
                                ),
                              );
                            } else {
                              debugPrint('Context not mounted after error, skipping navigation'); // Debug log
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
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
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
    return Builder(
      builder: (BuildContext dialogContext) {
        return GestureDetector(
          onTap: () => _showLogoutDialog(dialogContext),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.mainPadding,
              vertical: context.buttonHeight * 0.3,
            ),
            color: Colors.transparent,
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: context.iconSize('medium'), color: AppTheme.primaryMaroon),
                SizedBox(width: context.smallPadding),
                Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
