import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'src/providers/auth_provider.dart';
import 'src/screens/splash_screen.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const BridalPOSApp(),
    ),
  );
  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(750, 600);
    win.size = const Size(1280, 720);
    win.alignment = Alignment.center;
    win.title = "Elegant Bridal POS";
    win.show();
  });
}

/// The main application widget for the Elegant Bridal POS system.
class BridalPOSApp extends StatelessWidget {
  const BridalPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Elegant Bridal POS',
          theme: AppTheme.theme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}