import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/auth/login_screen.dart';
import 'package:frontend/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:frontend/presentation/screens/auth/signup_screen.dart';
import 'package:frontend/presentation/screens/splash/splash_screen.dart';
import 'package:frontend/src/providers/app_provider.dart';
import 'package:frontend/src/providers/auth_provider.dart';
import 'package:frontend/src/providers/category_provider.dart';
import 'package:frontend/src/providers/dashboard_provider.dart';
import 'package:frontend/src/providers/labor_provider.dart';
import 'package:frontend/src/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  runApp(const MaqboolFabricApp());

  // Add this for desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = Size(1024, 768)
        ..maxSize = Size(1920, 1080)  // Optional max size
        ..size = Size(1280, 720)      // Initial size
        ..alignment = Alignment.center
        ..title = "Maqbool Fashion"
        ..show();
    });
  }
}

class MaqboolFabricApp extends StatelessWidget {
  const MaqboolFabricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => LaborProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'Maqbool Fabric - Premium POS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/dashboard': (context) => const DashboardScreen(),
            },
          );
        },
      ),
    );
  }
}