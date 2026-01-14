import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Maqbool Fashion - Premium POS'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back to'**
  String get welcomeBack;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Maqbool Fashion'**
  String get brandName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Crafting elegance for your most precious moments.\nExperience luxury redefined through our premium bridal and groom collections.'**
  String get tagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @accessDashboard.
  ///
  /// In en, this message translates to:
  /// **'Access your premium dashboard'**
  String get accessDashboard;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Login successful.'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @labor.
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get labor;

  /// No description provided for @zakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get zakat;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get profitLoss;

  /// No description provided for @advancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment'**
  String get advancePayment;

  /// No description provided for @receivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get receivables;

  /// No description provided for @payables.
  ///
  /// In en, this message translates to:
  /// **'Payables'**
  String get payables;

  /// No description provided for @principalAccount.
  ///
  /// In en, this message translates to:
  /// **'Principal Account'**
  String get principalAccount;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @posSystem.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale System'**
  String get posSystem;

  /// No description provided for @selectProductsManageSales.
  ///
  /// In en, this message translates to:
  /// **'Select products and manage sales transactions'**
  String get selectProductsManageSales;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get todaySales;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @currentTime.
  ///
  /// In en, this message translates to:
  /// **'Current Time'**
  String get currentTime;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales Transaction History'**
  String get salesHistory;

  /// No description provided for @viewManageSales.
  ///
  /// In en, this message translates to:
  /// **'View and manage all sales transactions'**
  String get viewManageSales;

  /// No description provided for @searchSales.
  ///
  /// In en, this message translates to:
  /// **'Search sales by invoice, customer, phone...'**
  String get searchSales;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportingSalesData.
  ///
  /// In en, this message translates to:
  /// **'Exporting sales data...'**
  String get exportingSalesData;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @searchProductsExpanded.
  ///
  /// In en, this message translates to:
  /// **'Search products by name, color, fabric...'**
  String get searchProductsExpanded;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @screenTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Screen Too Small'**
  String get screenTooSmall;

  /// No description provided for @screenTooSmallMessage.
  ///
  /// In en, this message translates to:
  /// **'POS System requires a minimum screen width of 750px for optimal experience. Please use a larger screen or rotate your device.'**
  String get screenTooSmallMessage;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from Cart'**
  String get removeFromCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged out. See you soon!'**
  String get logoutSuccess;

  /// No description provided for @notEnoughStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock'**
  String get notEnoughStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is Empty'**
  String get cartIsEmpty;

  /// No description provided for @addProductsToStartSale.
  ///
  /// In en, this message translates to:
  /// **'Add products to start a sale'**
  String get addProductsToStartSale;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @clearCartQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from the cart?'**
  String get clearCartQuestion;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No Products Found'**
  String get noProductsFound;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Products Available'**
  String get noProductsAvailable;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter criteria'**
  String get tryAdjustingSearch;

  /// No description provided for @addProductsToInventory.
  ///
  /// In en, this message translates to:
  /// **'Add products to your inventory to start selling'**
  String get addProductsToInventory;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @productsManagement.
  ///
  /// In en, this message translates to:
  /// **'Products Management'**
  String get productsManagement;

  /// No description provided for @productManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage product inventory and details with comprehensive tools'**
  String get productManagementDescription;

  /// No description provided for @manageInventory.
  ///
  /// In en, this message translates to:
  /// **'Manage inventory'**
  String get manageInventory;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @exportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Export completed!'**
  String get exportCompleted;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products by ID, name, color, fabric, or pieces...'**
  String get searchProductsHint;

  /// No description provided for @customerManagement.
  ///
  /// In en, this message translates to:
  /// **'Customer Management'**
  String get customerManagement;

  /// No description provided for @customerManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize and manage your customer relationships with comprehensive tools'**
  String get customerManagementDescription;

  /// No description provided for @customerManagementShortDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage customer relationships'**
  String get customerManagementShortDescription;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @newThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New This Month'**
  String get newThisMonth;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @recentBuyers.
  ///
  /// In en, this message translates to:
  /// **'Recent Buyers'**
  String get recentBuyers;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCustomer;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @searchCustomersHint.
  ///
  /// In en, this message translates to:
  /// **'Search customers by name, phone, email...'**
  String get searchCustomersHint;

  /// No description provided for @searchCustomersShortHint.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomersShortHint;

  /// No description provided for @hideInactive.
  ///
  /// In en, this message translates to:
  /// **'Hide Inactive'**
  String get hideInactive;

  /// No description provided for @showInactive.
  ///
  /// In en, this message translates to:
  /// **'Show Inactive'**
  String get showInactive;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @customerDataExported.
  ///
  /// In en, this message translates to:
  /// **'Customer data exported successfully'**
  String get customerDataExported;

  /// No description provided for @failedToExportData.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get failedToExportData;

  /// No description provided for @loadingCustomers.
  ///
  /// In en, this message translates to:
  /// **'Loading customers...'**
  String get loadingCustomers;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or adding new customers.'**
  String get adjustFilters;

  /// No description provided for @failedToRefreshCustomers.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh customers'**
  String get failedToRefreshCustomers;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutMessage;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logged out locally due to an error.'**
  String get logoutError;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Premium POS'**
  String get brandTagline;

  /// No description provided for @welcomeToPos.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Maqbool Fabrics POS'**
  String get welcomeToPos;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Crafting Excellence in Every Stitch - Your Premium Fashion Management System'**
  String get welcomeTagline;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @activeCustomers.
  ///
  /// In en, this message translates to:
  /// **'Active Customers'**
  String get activeCustomers;

  /// No description provided for @activeVendors.
  ///
  /// In en, this message translates to:
  /// **'Active Vendors'**
  String get activeVendors;

  /// No description provided for @pendingReturns.
  ///
  /// In en, this message translates to:
  /// **'Pending Returns'**
  String get pendingReturns;

  /// No description provided for @salesOverview.
  ///
  /// In en, this message translates to:
  /// **'Sales Overview'**
  String get salesOverview;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months performance'**
  String get last6Months;

  /// No description provided for @revenueTarget.
  ///
  /// In en, this message translates to:
  /// **'Revenue Target'**
  String get revenueTarget;

  /// No description provided for @customerGrowth.
  ///
  /// In en, this message translates to:
  /// **'Customer Growth'**
  String get customerGrowth;

  /// No description provided for @vendorPartnerships.
  ///
  /// In en, this message translates to:
  /// **'Vendor Partnerships'**
  String get vendorPartnerships;

  /// No description provided for @conversionRate.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get conversionRate;

  /// No description provided for @topCustomers.
  ///
  /// In en, this message translates to:
  /// **'Top Customers'**
  String get topCustomers;

  /// No description provided for @vipCustomer.
  ///
  /// In en, this message translates to:
  /// **'VIP Customer'**
  String get vipCustomer;

  /// No description provided for @corporateClient.
  ///
  /// In en, this message translates to:
  /// **'Corporate Client'**
  String get corporateClient;

  /// No description provided for @regularCustomer.
  ///
  /// In en, this message translates to:
  /// **'Regular Customer'**
  String get regularCustomer;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @newCustomerRegistered.
  ///
  /// In en, this message translates to:
  /// **'New customer registered'**
  String get newCustomerRegistered;

  /// No description provided for @newVendorRegistered.
  ///
  /// In en, this message translates to:
  /// **'New vendor registered'**
  String get newVendorRegistered;

  /// No description provided for @customerPurchaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Customer purchase completed'**
  String get customerPurchaseCompleted;

  /// No description provided for @vendorDeliveryReceived.
  ///
  /// In en, this message translates to:
  /// **'Vendor delivery received'**
  String get vendorDeliveryReceived;

  /// No description provided for @underConstruction.
  ///
  /// In en, this message translates to:
  /// **'This page is under construction.'**
  String get underConstruction;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon with amazing features!'**
  String get comingSoon;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrder;

  /// No description provided for @processPayment.
  ///
  /// In en, this message translates to:
  /// **'Process payment'**
  String get processPayment;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get viewAnalytics;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @monthlyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Monthly Performance'**
  String get monthlyPerformance;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @searchProductsShortHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProductsShortHint;

  /// No description provided for @premiumCustomer.
  ///
  /// In en, this message translates to:
  /// **'Premium Customer'**
  String get premiumCustomer;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generated;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @viewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get viewed;

  /// No description provided for @issued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get issued;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @createReceipt.
  ///
  /// In en, this message translates to:
  /// **'Create Receipt'**
  String get createReceipt;

  /// No description provided for @updateReceipt.
  ///
  /// In en, this message translates to:
  /// **'Update Receipt'**
  String get updateReceipt;

  /// No description provided for @creatingOrder.
  ///
  /// In en, this message translates to:
  /// **'Creating Order...'**
  String get creatingOrder;

  /// No description provided for @noSalesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sales available'**
  String get noSalesAvailable;

  /// No description provided for @noReceiptsFound.
  ///
  /// In en, this message translates to:
  /// **'No receipts found'**
  String get noReceiptsFound;

  /// No description provided for @receiptCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receipt created successfully'**
  String get receiptCreatedSuccessfully;

  /// No description provided for @receiptUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receipt updated successfully'**
  String get receiptUpdatedSuccessfully;

  /// No description provided for @receiptDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted successfully'**
  String get receiptDeletedSuccessfully;

  /// No description provided for @selectSale.
  ///
  /// In en, this message translates to:
  /// **'Select Sale'**
  String get selectSale;

  /// No description provided for @chooseSaleToCreateReceipt.
  ///
  /// In en, this message translates to:
  /// **'Choose a sale to create receipt for'**
  String get chooseSaleToCreateReceipt;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @pleaseSelectSale.
  ///
  /// In en, this message translates to:
  /// **'Please select a sale'**
  String get pleaseSelectSale;

  /// No description provided for @additionalReceiptNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional receipt notes (optional)'**
  String get additionalReceiptNotes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
