import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/auth/login_screen.dart';
import 'package:frontend/presentation/screens/auth/signup_screen.dart';
import 'package:frontend/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:frontend/presentation/screens/splash/splash_screen.dart';
import 'package:frontend/src/providers/advance_payment_provider.dart';
import 'package:frontend/src/providers/app_provider.dart';
import 'package:frontend/src/providers/auth_provider.dart';
import 'package:frontend/src/providers/category_provider.dart';
import 'package:frontend/src/providers/customer_provider.dart';
import 'package:frontend/src/providers/dashboard_provider.dart';
import 'package:frontend/src/providers/expenses_provider.dart';
import 'package:frontend/src/providers/labor_provider.dart';
import 'package:frontend/src/providers/order_item_provider.dart';
import 'package:frontend/src/providers/order_provider.dart';
import 'package:frontend/src/providers/payables_provider.dart';
import 'package:frontend/src/providers/payment_provider.dart';
import 'package:frontend/src/providers/prinicipal_acc_provider.dart';
import 'package:frontend/src/providers/product_provider.dart';
import 'package:frontend/src/providers/profit_loss/profit_loss_provider.dart';
import 'package:frontend/src/providers/receivables_provider.dart';
import 'package:frontend/src/providers/sales_provider.dart';
import 'package:frontend/src/providers/tax_rates_provider.dart';
import 'package:frontend/src/providers/vendor_ledger_provider.dart';
import 'package:frontend/src/providers/vendor_provider.dart';
import 'package:frontend/src/providers/zakat_provider.dart';
import 'package:frontend/src/providers/return_provider.dart';
import 'package:frontend/src/providers/invoice_provider.dart';
import 'package:frontend/src/providers/receipt_provider.dart';
import 'package:frontend/src/providers/refund_provider.dart';
import 'package:frontend/src/services/api_client.dart';
import 'package:frontend/src/theme/app_theme.dart';
import 'package:frontend/src/utils/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService().init();
  ApiClient().init();

  runApp(const MaqboolFabricApp());

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = Size(1024, 768)
        ..maxSize = Size(1920, 1080)
        ..size = Size(1024, 768)
        ..alignment = Alignment.center
        ..title = "Al Noor Fashion"
        ..show();
    });
  }
}

class MaqboolFabricApp extends StatelessWidget {
  const MaqboolFabricApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaxRatesProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OrderItemProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => LaborProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => AdvancePaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReceivablesProvider()),
        ChangeNotifierProvider(create: (_) => PayablesProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
        ChangeNotifierProvider(create: (_) => VendorLedgerProvider()),
        ChangeNotifierProvider(create: (_) => ZakatProvider()),
        ChangeNotifierProvider(create: (_) => PrincipalAccountProvider()),
        ChangeNotifierProvider(create: (_) => ProfitLossProvider()),
        ChangeNotifierProvider(create: (_) => ReturnProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
        ChangeNotifierProvider(create: (_) => RefundProvider()),
      ],
      child: Consumer3<AuthProvider, ProfitLossProvider, AppProvider>(
        builder: (context, authProvider, profitLossProvider, appProvider, child) {
          
          // ✅ FIX 1: Initialize AppProvider (ADDED)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!appProvider.isInitialized) {
              appProvider.initialize();
            }
          });

          // Existing: Initialize AuthProvider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.state == AuthState.initial) {
              authProvider.initialize();
            }
          });

          // Existing: Initialize ProfitLossProvider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.state == AuthState.authenticated) {
              if (profitLossProvider.profitLossHistory.isEmpty &&
                  !profitLossProvider.isLoading) {
                profitLossProvider.initialize();
              }
            }
          });

          return Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                title: 'Al Noor Fashion - Premium POS',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.light,
                navigatorKey: navigatorKey,
                
                locale: appProvider.locale,
                
                supportedLocales: const [
                  Locale('ur'),
                  Locale('en'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                initialRoute: '/',
                onGenerateRoute: (settings) {
                  if (settings.name == '/dashboard') {
                    if (authProvider.state != AuthState.authenticated) {
                      return MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                        settings: settings,
                      );
                    }
                  }

                  if (settings.name == '/login' || settings.name == '/signup') {
                    if (authProvider.state == AuthState.authenticated) {
                      return MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                        settings: settings,
                      );
                    }
                  }

                  switch (settings.name) {
                    case '/':
                      return MaterialPageRoute(
                        builder: (_) => const SplashScreen(),
                        settings: settings,
                      );
                    case '/login':
                      return MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                        settings: settings,
                      );
                    case '/signup':
                      return MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                        settings: settings,
                      );
                    case '/dashboard':
                      return MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                        settings: settings,
                      );
                    default:
                      return MaterialPageRoute(
                        builder: (_) => const SplashScreen(),
                        settings: settings,
                      );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}