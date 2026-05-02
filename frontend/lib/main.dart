import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:frontend/src/providers/purchase_provider.dart';
import 'package:frontend/src/providers/receivables_provider.dart';
import 'package:frontend/src/providers/sales_provider.dart';
import 'package:frontend/src/providers/tax_rates_provider.dart';
import 'package:frontend/src/providers/vendor_ledger_provider.dart';
import 'package:frontend/src/providers/customer_ledger_provider.dart';
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

  runApp(const MetaBrassApp());

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = const Size(1000, 550)
        ..maxSize = const Size(2560, 1400)
        ..size = const Size(1200, 680)
        ..alignment = Alignment.center
        ..title = "META BRASS"
        ..show();
    });
  }
}

class MetaBrassApp extends StatelessWidget {
  const MetaBrassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OrderItemProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => TaxRatesProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => LaborProvider()),
        ChangeNotifierProvider(create: (_) => PayablesProvider()),
        ChangeNotifierProvider(create: (_) => ReceivablesProvider()),
        ChangeNotifierProvider(create: (_) => ProfitLossProvider()),
        ChangeNotifierProvider(create: (_) => AdvancePaymentProvider()),
        ChangeNotifierProvider(create: (_) => VendorLedgerProvider()),
        ChangeNotifierProvider(create: (_) => CustomerLedgerProvider()),
        ChangeNotifierProvider(create: (_) => PrincipalAccountProvider()),
        ChangeNotifierProvider(create: (_) => ZakatProvider()),
        ChangeNotifierProvider(create: (_) => ReturnProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
        ChangeNotifierProvider(create: (_) => RefundProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'META BRASS',
            theme: AppTheme.lightTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ur', ''), // Urdu
            ],
            locale: const Locale('en'), // Default locale
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
