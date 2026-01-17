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
  /// **'Al Noor Fashion'**
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
  /// **'This application requires a minimum screen width of 750px for optimal experience. Please use a larger screen or rotate your device.'**
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
  /// **'Create order'**
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

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

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

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'week ago'**
  String get weekAgo;

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'month ago'**
  String get monthAgo;

  /// No description provided for @yearAgo.
  ///
  /// In en, this message translates to:
  /// **'year ago'**
  String get yearAgo;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get characters;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @manageProductCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage product categories'**
  String get manageProductCategories;

  /// No description provided for @searchCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories by name, ID, or description'**
  String get searchCategoriesHint;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @cities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get cities;

  /// No description provided for @citiesCovered.
  ///
  /// In en, this message translates to:
  /// **'Cities Covered'**
  String get citiesCovered;

  /// No description provided for @searchVendorsHint.
  ///
  /// In en, this message translates to:
  /// **'Search vendors by name, business, CNIC, or phone'**
  String get searchVendorsHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @pleaseFixErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the following errors'**
  String get pleaseFixErrors;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get pleaseEnter;

  /// No description provided for @mustBeAtLeast.
  ///
  /// In en, this message translates to:
  /// **'must be at least'**
  String get mustBeAtLeast;

  /// No description provided for @mustBeLessThan.
  ///
  /// In en, this message translates to:
  /// **'must be less than'**
  String get mustBeLessThan;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @cnic.
  ///
  /// In en, this message translates to:
  /// **'CNIC'**
  String get cnic;

  /// No description provided for @cnicFormat.
  ///
  /// In en, this message translates to:
  /// **'XXXXX-XXXXXXX-X'**
  String get cnicFormat;

  /// No description provided for @pleaseEnterValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid'**
  String get pleaseEnterValid;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @phoneFormat.
  ///
  /// In en, this message translates to:
  /// **'+923001234567'**
  String get phoneFormat;

  /// No description provided for @locationInformation.
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// No description provided for @deletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'deleted permanently'**
  String get deletedPermanently;

  /// No description provided for @deactivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'deactivated successfully'**
  String get deactivatedSuccessfully;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @pleaseConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that you understand this action'**
  String get pleaseConfirmAction;

  /// No description provided for @pleaseConfirmConsequences.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that you understand the consequences of permanent deletion'**
  String get pleaseConfirmConsequences;

  /// No description provided for @pleaseTypeVendorName.
  ///
  /// In en, this message translates to:
  /// **'Please type the vendor name exactly to confirm permanent deletion'**
  String get pleaseTypeVendorName;

  /// No description provided for @pleaseCompleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Please complete all confirmation steps'**
  String get pleaseCompleteConfirmation;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @showing.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get showing;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get outOf;

  /// No description provided for @refineVendorList.
  ///
  /// In en, this message translates to:
  /// **'Refine your vendor list with filters'**
  String get refineVendorList;

  /// No description provided for @showInactiveVendorsOnly.
  ///
  /// In en, this message translates to:
  /// **'Show inactive vendors only'**
  String get showInactiveVendorsOnly;

  /// No description provided for @onlyDeactivatedVendorsShown.
  ///
  /// In en, this message translates to:
  /// **'Only deactivated vendors will be shown'**
  String get onlyDeactivatedVendorsShown;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @areYouSureDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate'**
  String get areYouSureDeactivate;

  /// No description provided for @actionCanBeReversed.
  ///
  /// In en, this message translates to:
  /// **'This action can be reversed'**
  String get actionCanBeReversed;

  /// No description provided for @failedToDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Failed to deactivate'**
  String get failedToDeactivate;

  /// No description provided for @areYouSureRestore.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore'**
  String get areYouSureRestore;

  /// No description provided for @failedToRestore.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore'**
  String get failedToRestore;

  /// No description provided for @restoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'restored successfully'**
  String get restoredSuccessfully;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load'**
  String get failedToLoad;

  /// No description provided for @noVendorsFound.
  ///
  /// In en, this message translates to:
  /// **'No Vendors Found'**
  String get noVendorsFound;

  /// No description provided for @startByAddingFirstVendor.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first vendor to manage your suppliers effectively'**
  String get startByAddingFirstVendor;

  /// No description provided for @firstVendor.
  ///
  /// In en, this message translates to:
  /// **'First Vendor'**
  String get firstVendor;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @since.
  ///
  /// In en, this message translates to:
  /// **'since'**
  String get since;

  /// No description provided for @daysOld.
  ///
  /// In en, this message translates to:
  /// **'days old'**
  String get daysOld;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @activitySummary.
  ///
  /// In en, this message translates to:
  /// **'Activity Summary'**
  String get activitySummary;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get failedToUpdate;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'updating'**
  String get updating;

  /// No description provided for @noChangesDetected.
  ///
  /// In en, this message translates to:
  /// **'No changes detected'**
  String get noChangesDetected;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get discardChangesMessage;

  /// No description provided for @continueEditing.
  ///
  /// In en, this message translates to:
  /// **'Continue Editing'**
  String get continueEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProduct;

  /// No description provided for @createNewProductEntry.
  ///
  /// In en, this message translates to:
  /// **'Create a new product entry'**
  String get createNewProductEntry;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @costPriceCannotExceedSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price cannot exceed selling price'**
  String get costPriceCannotExceedSellingPrice;

  /// No description provided for @costPriceInfo.
  ///
  /// In en, this message translates to:
  /// **'Setting cost price enables profit margin calculations and better financial analysis'**
  String get costPriceInfo;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @colorName.
  ///
  /// In en, this message translates to:
  /// **'Color Name'**
  String get colorName;

  /// No description provided for @fabricType.
  ///
  /// In en, this message translates to:
  /// **'Fabric Type'**
  String get fabricType;

  /// No description provided for @fabricName.
  ///
  /// In en, this message translates to:
  /// **'Fabric Name'**
  String get fabricName;

  /// No description provided for @pleaseSelectAtLeastOnePiece.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one piece'**
  String get pleaseSelectAtLeastOnePiece;

  /// No description provided for @failedToAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add'**
  String get failedToAdd;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'added successfully'**
  String get addedSuccessfully;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @pleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get pleaseSelect;

  /// No description provided for @labors.
  ///
  /// In en, this message translates to:
  /// **'Labors'**
  String get labors;

  /// No description provided for @laborManagement.
  ///
  /// In en, this message translates to:
  /// **'Labor Management'**
  String get laborManagement;

  /// No description provided for @laborManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize and manage your labor workforce with comprehensive tools'**
  String get laborManagementDescription;

  /// No description provided for @organizeAndManageLaborWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Organize and manage labor workforce'**
  String get organizeAndManageLaborWorkforce;

  /// No description provided for @manageLaborWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Manage labor workforce'**
  String get manageLaborWorkforce;

  /// No description provided for @failedToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh'**
  String get failedToRefresh;

  /// No description provided for @preparingExport.
  ///
  /// In en, this message translates to:
  /// **'Preparing export...'**
  String get preparingExport;

  /// No description provided for @dataExportCompleted.
  ///
  /// In en, this message translates to:
  /// **'data export completed successfully'**
  String get dataExportCompleted;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @searchLaborsHint.
  ///
  /// In en, this message translates to:
  /// **'Search labors by name, CNIC, phone, designation...'**
  String get searchLaborsHint;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @caste.
  ///
  /// In en, this message translates to:
  /// **'Caste'**
  String get caste;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @receivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivable;

  /// No description provided for @receivablesManagement.
  ///
  /// In en, this message translates to:
  /// **'Receivables Management'**
  String get receivablesManagement;

  /// No description provided for @receivablesManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage amounts lent to customers and suppliers'**
  String get receivablesManagementDescription;

  /// No description provided for @manageAmountsLent.
  ///
  /// In en, this message translates to:
  /// **'Manage amounts lent'**
  String get manageAmountsLent;

  /// No description provided for @amountsLent.
  ///
  /// In en, this message translates to:
  /// **'Amounts lent'**
  String get amountsLent;

  /// No description provided for @amountLent.
  ///
  /// In en, this message translates to:
  /// **'Amount Lent'**
  String get amountLent;

  /// No description provided for @amountReturned.
  ///
  /// In en, this message translates to:
  /// **'Amount Returned'**
  String get amountReturned;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @searchReceivablesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by debtor name, phone, reason, or notes...'**
  String get searchReceivablesHint;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @debtor.
  ///
  /// In en, this message translates to:
  /// **'Debtor'**
  String get debtor;

  /// No description provided for @debtorDetails.
  ///
  /// In en, this message translates to:
  /// **'Debtor Details'**
  String get debtorDetails;

  /// No description provided for @amounts.
  ///
  /// In en, this message translates to:
  /// **'Amounts'**
  String get amounts;

  /// No description provided for @reasonItem.
  ///
  /// In en, this message translates to:
  /// **'Reason/Item'**
  String get reasonItem;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @lent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lent;

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'days overdue'**
  String get daysOverdue;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @noReceivablesFound.
  ///
  /// In en, this message translates to:
  /// **'No Receivables Found'**
  String get noReceivablesFound;

  /// No description provided for @startByAddingFirstReceivable.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first receivable record to track amounts lent to customers and suppliers'**
  String get startByAddingFirstReceivable;

  /// No description provided for @firstReceivable.
  ///
  /// In en, this message translates to:
  /// **'First Receivable'**
  String get firstReceivable;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @deactivateVendor.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Vendor'**
  String get deactivateVendor;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get actionCannotBeUndone;

  /// No description provided for @vendorCanBeRestoredLater.
  ///
  /// In en, this message translates to:
  /// **'Vendor can be restored later'**
  String get vendorCanBeRestoredLater;

  /// No description provided for @permanentDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'Permanent Deletion Warning'**
  String get permanentDeletionWarning;

  /// No description provided for @deactivationNotice.
  ///
  /// In en, this message translates to:
  /// **'Deactivation Notice'**
  String get deactivationNotice;

  /// No description provided for @permanentDeletionWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all vendor data from the database. This action cannot be reversed.'**
  String get permanentDeletionWarningMessage;

  /// No description provided for @deactivationNoticeMessage.
  ///
  /// In en, this message translates to:
  /// **'This will deactivate the vendor but preserve all data. The vendor can be restored later if needed.'**
  String get deactivationNoticeMessage;

  /// No description provided for @chooseDeletionType.
  ///
  /// In en, this message translates to:
  /// **'Choose deletion type:'**
  String get chooseDeletionType;

  /// No description provided for @permanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete'**
  String get permanentDelete;

  /// No description provided for @removesFromDatabasePermanently.
  ///
  /// In en, this message translates to:
  /// **'Removes from database permanently'**
  String get removesFromDatabasePermanently;

  /// No description provided for @hideButCanBeRestored.
  ///
  /// In en, this message translates to:
  /// **'Hide but can be restored'**
  String get hideButCanBeRestored;

  /// No description provided for @vendorSince.
  ///
  /// In en, this message translates to:
  /// **'Vendor since'**
  String get vendorSince;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @understandPermanentDeletion.
  ///
  /// In en, this message translates to:
  /// **'I understand this will permanently delete the vendor'**
  String get understandPermanentDeletion;

  /// No description provided for @understandDeactivation.
  ///
  /// In en, this message translates to:
  /// **'I understand this will deactivate the vendor'**
  String get understandDeactivation;

  /// No description provided for @understandActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'I understand this action cannot be undone and will affect related records'**
  String get understandActionCannotBeUndone;

  /// No description provided for @typeVendorNameToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type the vendor name to confirm permanent deletion:'**
  String get typeVendorNameToConfirm;

  /// No description provided for @expected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expected;

  /// No description provided for @payable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payable;

  /// No description provided for @payablesManagement.
  ///
  /// In en, this message translates to:
  /// **'Payables Management'**
  String get payablesManagement;

  /// No description provided for @payablesManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage amounts owed to creditors efficiently'**
  String get payablesManagementDescription;

  /// No description provided for @manageCreditorPayables.
  ///
  /// In en, this message translates to:
  /// **'Manage creditor payables'**
  String get manageCreditorPayables;

  /// No description provided for @creditorPayables.
  ///
  /// In en, this message translates to:
  /// **'Creditor payables'**
  String get creditorPayables;

  /// No description provided for @totalPayables.
  ///
  /// In en, this message translates to:
  /// **'Total Payables'**
  String get totalPayables;

  /// No description provided for @totalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total Borrowed'**
  String get totalBorrowed;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @borrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowed;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @searchPayablesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by ID, creditor name, phone, reason, or status...'**
  String get searchPayablesHint;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @paymentManagement.
  ///
  /// In en, this message translates to:
  /// **'Payment Management'**
  String get paymentManagement;

  /// No description provided for @paymentManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage labor salary payments efficiently'**
  String get paymentManagementDescription;

  /// No description provided for @trackManageSalaryPayments.
  ///
  /// In en, this message translates to:
  /// **'Track and manage salary payments'**
  String get trackManageSalaryPayments;

  /// No description provided for @trackSalaryPayments.
  ///
  /// In en, this message translates to:
  /// **'Track salary payments'**
  String get trackSalaryPayments;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalRecords;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @searchPaymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by ID, labor name, payment method, month, or description...'**
  String get searchPaymentsHint;

  /// No description provided for @advancePaymentManagement.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment Management'**
  String get advancePaymentManagement;

  /// No description provided for @advancePaymentManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage labor advance payments efficiently'**
  String get advancePaymentManagementDescription;

  /// No description provided for @advancePayments.
  ///
  /// In en, this message translates to:
  /// **'Advance Payments'**
  String get advancePayments;

  /// No description provided for @manageLaborPayments.
  ///
  /// In en, this message translates to:
  /// **'Manage labor payments'**
  String get manageLaborPayments;

  /// No description provided for @totalPayments.
  ///
  /// In en, this message translates to:
  /// **'Total Payments'**
  String get totalPayments;

  /// No description provided for @withReceipts.
  ///
  /// In en, this message translates to:
  /// **'With Receipts'**
  String get withReceipts;

  /// No description provided for @loadingAdvancePayments.
  ///
  /// In en, this message translates to:
  /// **'Loading advance payments...'**
  String get loadingAdvancePayments;

  /// No description provided for @searchAdvancePaymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by ID, labor name, phone, role, or description...'**
  String get searchAdvancePaymentsHint;

  /// No description provided for @dataRefreshedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data refreshed successfully'**
  String get dataRefreshedSuccessfully;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @expensesManagement.
  ///
  /// In en, this message translates to:
  /// **'Expenses Management'**
  String get expensesManagement;

  /// No description provided for @expensesManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage business expenses efficiently'**
  String get expensesManagementDescription;

  /// No description provided for @trackBusinessExpenses.
  ///
  /// In en, this message translates to:
  /// **'Track business expenses'**
  String get trackBusinessExpenses;

  /// No description provided for @trackExpenses.
  ///
  /// In en, this message translates to:
  /// **'Track expenses'**
  String get trackExpenses;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @searchExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Search expenses by ID, type, description, amount, or person...'**
  String get searchExpensesHint;

  /// No description provided for @zakatManagement.
  ///
  /// In en, this message translates to:
  /// **'Zakat Management'**
  String get zakatManagement;

  /// No description provided for @zakatManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and manage zakat contributions efficiently'**
  String get zakatManagementDescription;

  /// No description provided for @trackZakatContributions.
  ///
  /// In en, this message translates to:
  /// **'Track zakat contributions'**
  String get trackZakatContributions;

  /// No description provided for @trackContributions.
  ///
  /// In en, this message translates to:
  /// **'Track contributions'**
  String get trackContributions;

  /// No description provided for @searchZakatHint.
  ///
  /// In en, this message translates to:
  /// **'Search zakat by ID, title, beneficiary, or amount...'**
  String get searchZakatHint;

  /// No description provided for @profitLossStatement.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss Statement'**
  String get profitLossStatement;

  /// No description provided for @profitLossStatementDescription.
  ///
  /// In en, this message translates to:
  /// **'Financial performance analysis and profitability tracking'**
  String get profitLossStatementDescription;

  /// No description provided for @profitLossShort.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get profitLossShort;

  /// No description provided for @financialPerformanceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Financial performance analysis'**
  String get financialPerformanceAnalysis;

  /// No description provided for @financialAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Financial analysis'**
  String get financialAnalysis;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @calculatingProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Calculating Profit & Loss...'**
  String get calculatingProfitLoss;

  /// No description provided for @noFinancialDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Financial Data Available'**
  String get noFinancialDataAvailable;

  /// No description provided for @selectPeriodToViewAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Select a period to view profit and loss analysis'**
  String get selectPeriodToViewAnalysis;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @ofExpenses.
  ///
  /// In en, this message translates to:
  /// **'of expenses'**
  String get ofExpenses;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @profitable.
  ///
  /// In en, this message translates to:
  /// **'PROFITABLE'**
  String get profitable;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'LOSS'**
  String get loss;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @clearErrors.
  ///
  /// In en, this message translates to:
  /// **'Clear Errors'**
  String get clearErrors;

  /// No description provided for @operationCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get operationCompletedSuccessfully;

  /// No description provided for @taxManagement.
  ///
  /// In en, this message translates to:
  /// **'Tax Management'**
  String get taxManagement;

  /// No description provided for @taxManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage tax rates and configurations'**
  String get taxManagementDescription;

  /// No description provided for @addTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Add Tax Rate'**
  String get addTaxRate;

  /// No description provided for @searchTaxRatesHint.
  ///
  /// In en, this message translates to:
  /// **'Search tax rates...'**
  String get searchTaxRatesHint;

  /// No description provided for @taxRates.
  ///
  /// In en, this message translates to:
  /// **'Tax Rates'**
  String get taxRates;

  /// No description provided for @noTaxRatesFound.
  ///
  /// In en, this message translates to:
  /// **'No Tax Rates Found'**
  String get noTaxRatesFound;

  /// No description provided for @addFirstTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Add your first tax rate to get started'**
  String get addFirstTaxRate;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalTaxRates.
  ///
  /// In en, this message translates to:
  /// **'Total Tax Rates'**
  String get totalTaxRates;

  /// No description provided for @activeRates.
  ///
  /// In en, this message translates to:
  /// **'Active Rates'**
  String get activeRates;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deleteTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Delete Tax Rate'**
  String get deleteTaxRate;

  /// No description provided for @deleteTaxRateConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteTaxRateConfirmation;

  /// No description provided for @editTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Edit Tax Rate'**
  String get editTaxRate;

  /// No description provided for @taxName.
  ///
  /// In en, this message translates to:
  /// **'Tax Name'**
  String get taxName;

  /// No description provided for @taxType.
  ///
  /// In en, this message translates to:
  /// **'Tax Type'**
  String get taxType;

  /// No description provided for @taxPercentage.
  ///
  /// In en, this message translates to:
  /// **'Tax Percentage (%)'**
  String get taxPercentage;

  /// No description provided for @pleaseEnterTaxName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a tax name'**
  String get pleaseEnterTaxName;

  /// No description provided for @pleaseEnterTaxPercentage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a tax percentage'**
  String get pleaseEnterTaxPercentage;

  /// No description provided for @pleaseEnterValidPercentage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid percentage (0-100)'**
  String get pleaseEnterValidPercentage;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @returnManagement.
  ///
  /// In en, this message translates to:
  /// **'Return Management'**
  String get returnManagement;

  /// No description provided for @titleReceiptManagement.
  ///
  /// In en, this message translates to:
  /// **'Receipt Management'**
  String get titleReceiptManagement;

  /// No description provided for @receivableDetails.
  ///
  /// In en, this message translates to:
  /// **'Receivable Details'**
  String get receivableDetails;

  /// No description provided for @viewCompleteReceivableInformation.
  ///
  /// In en, this message translates to:
  /// **'View complete receivable information'**
  String get viewCompleteReceivableInformation;

  /// No description provided for @debtorInformation.
  ///
  /// In en, this message translates to:
  /// **'Debtor Information'**
  String get debtorInformation;

  /// No description provided for @amountBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Amount Breakdown'**
  String get amountBreakdown;

  /// No description provided for @amountGiven.
  ///
  /// In en, this message translates to:
  /// **'Amount Given:'**
  String get amountGiven;

  /// No description provided for @balanceRemaining.
  ///
  /// In en, this message translates to:
  /// **'Balance Remaining:'**
  String get balanceRemaining;

  /// No description provided for @returnProgress.
  ///
  /// In en, this message translates to:
  /// **'Return Progress'**
  String get returnProgress;

  /// No description provided for @dateLent.
  ///
  /// In en, this message translates to:
  /// **'Date Lent'**
  String get dateLent;

  /// No description provided for @expectedReturnDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Return Date'**
  String get expectedReturnDate;

  /// No description provided for @expectedReturn.
  ///
  /// In en, this message translates to:
  /// **'Expected Return'**
  String get expectedReturn;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @editReceivable.
  ///
  /// In en, this message translates to:
  /// **'Edit Receivable'**
  String get editReceivable;

  /// No description provided for @editReceivableDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Receivable Details'**
  String get editReceivableDetails;

  /// No description provided for @updateReceivableInformation.
  ///
  /// In en, this message translates to:
  /// **'Update receivable information'**
  String get updateReceivableInformation;

  /// No description provided for @debtorName.
  ///
  /// In en, this message translates to:
  /// **'Debtor Name'**
  String get debtorName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @enterDebtorFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter debtor full name'**
  String get enterDebtorFullName;

  /// No description provided for @pleaseEnterDebtorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter debtor name'**
  String get pleaseEnterDebtorName;

  /// No description provided for @nameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMustBeAtLeast2Characters;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone'**
  String get enterPhone;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number (+92XXXXXXXXXX)'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @amountGivenPkr.
  ///
  /// In en, this message translates to:
  /// **'Amount Given (PKR)'**
  String get amountGivenPkr;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @amountReturnedPkr.
  ///
  /// In en, this message translates to:
  /// **'Amount Returned (PKR)'**
  String get amountReturnedPkr;

  /// No description provided for @enterReturned.
  ///
  /// In en, this message translates to:
  /// **'Enter returned'**
  String get enterReturned;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter valid amount'**
  String get enterValidAmount;

  /// No description provided for @cannotExceedAmountGiven.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed amount given'**
  String get cannotExceedAmountGiven;

  /// No description provided for @reasonForLending.
  ///
  /// In en, this message translates to:
  /// **'Reason for lending'**
  String get reasonForLending;

  /// No description provided for @enterReasonForLendingOrItemDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for lending or item description'**
  String get enterReasonForLendingOrItemDescription;

  /// No description provided for @pleaseEnterReasonOrItem.
  ///
  /// In en, this message translates to:
  /// **'Please enter reason or item'**
  String get pleaseEnterReasonOrItem;

  /// No description provided for @pleaseProvideMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide more details'**
  String get pleaseProvideMoreDetails;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get additionalNotes;

  /// No description provided for @enterAdditionalNotesOrTerms.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes or terms'**
  String get enterAdditionalNotesOrTerms;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @updateReceivable.
  ///
  /// In en, this message translates to:
  /// **'Update Receivable'**
  String get updateReceivable;

  /// No description provided for @receivableUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receivable updated successfully!'**
  String get receivableUpdatedSuccessfully;

  /// No description provided for @amountReturnedCannotExceedAmountGiven.
  ///
  /// In en, this message translates to:
  /// **'Amount returned cannot exceed amount given'**
  String get amountReturnedCannotExceedAmountGiven;

  /// No description provided for @expectedReturnDateCannotBeBeforeDateLent.
  ///
  /// In en, this message translates to:
  /// **'Expected return date cannot be before date lent'**
  String get expectedReturnDateCannotBeBeforeDateLent;

  /// No description provided for @addReceivable.
  ///
  /// In en, this message translates to:
  /// **'Add Receivable'**
  String get addReceivable;

  /// No description provided for @addNewReceivable.
  ///
  /// In en, this message translates to:
  /// **'Add New Receivable'**
  String get addNewReceivable;

  /// No description provided for @recordAmountLentToCustomerOrSupplier.
  ///
  /// In en, this message translates to:
  /// **'Record amount lent to customer or supplier'**
  String get recordAmountLentToCustomerOrSupplier;

  /// No description provided for @amountDetails.
  ///
  /// In en, this message translates to:
  /// **'Amount Details'**
  String get amountDetails;

  /// No description provided for @enterAmountGivenToDebtor.
  ///
  /// In en, this message translates to:
  /// **'Enter amount given to debtor'**
  String get enterAmountGivenToDebtor;

  /// No description provided for @pleaseEnterAmountGiven.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount given'**
  String get pleaseEnterAmountGiven;

  /// No description provided for @optionalIfAnyAmountAlreadyReturned.
  ///
  /// In en, this message translates to:
  /// **'Optional - if any amount already returned'**
  String get optionalIfAnyAmountAlreadyReturned;

  /// No description provided for @dateInformation.
  ///
  /// In en, this message translates to:
  /// **'Date Information'**
  String get dateInformation;

  /// No description provided for @lendingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Lending period:'**
  String get lendingPeriod;

  /// No description provided for @pleaseSelectValidReturnDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid return date'**
  String get pleaseSelectValidReturnDate;

  /// No description provided for @receivableAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receivable added successfully!'**
  String get receivableAddedSuccessfully;

  /// No description provided for @addLabor.
  ///
  /// In en, this message translates to:
  /// **'Add Labor'**
  String get addLabor;

  /// No description provided for @addNewLabor.
  ///
  /// In en, this message translates to:
  /// **'Add New Labor'**
  String get addNewLabor;

  /// No description provided for @createNewLaborRecord.
  ///
  /// In en, this message translates to:
  /// **'Create a new labor record'**
  String get createNewLaborRecord;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameRequired;

  /// No description provided for @enterWorkersFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter worker\'s full name'**
  String get enterWorkersFullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @nameMustBeLessThan50Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be less than 50 characters'**
  String get nameMustBeLessThan50Characters;

  /// No description provided for @cnicRequired.
  ///
  /// In en, this message translates to:
  /// **'CNIC *'**
  String get cnicRequired;

  /// No description provided for @enterCnic.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC'**
  String get enterCnic;

  /// No description provided for @enterCnicFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC (e.g., 42101-1234567-1)'**
  String get enterCnicFormat;

  /// No description provided for @pleaseEnterCnic.
  ///
  /// In en, this message translates to:
  /// **'Please enter a CNIC'**
  String get pleaseEnterCnic;

  /// No description provided for @pleaseEnterValidCnicFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid CNIC (XXXXX-XXXXXXX-X)'**
  String get pleaseEnterValidCnicFormat;

  /// No description provided for @enterCaste.
  ///
  /// In en, this message translates to:
  /// **'Enter caste'**
  String get enterCaste;

  /// No description provided for @enterCasteOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter caste (optional)'**
  String get enterCasteOptional;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneNumberRequired;

  /// No description provided for @enterPhoneNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number (e.g., +923001234567)'**
  String get enterPhoneNumberFormat;

  /// No description provided for @pleaseEnterValidPhoneNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number (+92XXXXXXXXXX)'**
  String get pleaseEnterValidPhoneNumberFormat;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get cityRequired;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @pleaseEnterCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter city'**
  String get pleaseEnterCity;

  /// No description provided for @areaRequired.
  ///
  /// In en, this message translates to:
  /// **'Area *'**
  String get areaRequired;

  /// No description provided for @enterArea.
  ///
  /// In en, this message translates to:
  /// **'Enter area'**
  String get enterArea;

  /// No description provided for @pleaseEnterArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter area'**
  String get pleaseEnterArea;

  /// No description provided for @employmentInformation.
  ///
  /// In en, this message translates to:
  /// **'Employment Information'**
  String get employmentInformation;

  /// No description provided for @designationRequired.
  ///
  /// In en, this message translates to:
  /// **'Designation *'**
  String get designationRequired;

  /// No description provided for @enterDesignation.
  ///
  /// In en, this message translates to:
  /// **'Enter designation'**
  String get enterDesignation;

  /// No description provided for @enterJobDesignation.
  ///
  /// In en, this message translates to:
  /// **'Enter job designation (e.g., Tailor, Operator)'**
  String get enterJobDesignation;

  /// No description provided for @pleaseEnterDesignation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a designation'**
  String get pleaseEnterDesignation;

  /// No description provided for @joiningDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Joining Date *'**
  String get joiningDateRequired;

  /// No description provided for @selectJoiningDate.
  ///
  /// In en, this message translates to:
  /// **'Select joining date'**
  String get selectJoiningDate;

  /// No description provided for @monthlySalaryRequired.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary *'**
  String get monthlySalaryRequired;

  /// No description provided for @enterSalary.
  ///
  /// In en, this message translates to:
  /// **'Enter salary'**
  String get enterSalary;

  /// No description provided for @enterMonthlySalaryInPkr.
  ///
  /// In en, this message translates to:
  /// **'Enter monthly salary in PKR'**
  String get enterMonthlySalaryInPkr;

  /// No description provided for @pleaseEnterSalary.
  ///
  /// In en, this message translates to:
  /// **'Please enter a salary'**
  String get pleaseEnterSalary;

  /// No description provided for @pleaseEnterValidSalary.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid salary'**
  String get pleaseEnterValidSalary;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender *'**
  String get genderRequired;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get pleaseSelectGender;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age *'**
  String get ageRequired;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAge;

  /// No description provided for @enterAgeMinimum18Years.
  ///
  /// In en, this message translates to:
  /// **'Enter age (minimum 18 years)'**
  String get enterAgeMinimum18Years;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter an age'**
  String get pleaseEnterAge;

  /// No description provided for @ageMustBeAtLeast18.
  ///
  /// In en, this message translates to:
  /// **'Age must be at least 18'**
  String get ageMustBeAtLeast18;

  /// No description provided for @ageMustBeLessThan65.
  ///
  /// In en, this message translates to:
  /// **'Age must be less than 65'**
  String get ageMustBeLessThan65;

  /// No description provided for @laborCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Labor created successfully!'**
  String get laborCreatedSuccessfully;

  /// No description provided for @failedToCreateLabor.
  ///
  /// In en, this message translates to:
  /// **'Failed to create labor'**
  String get failedToCreateLabor;

  /// No description provided for @errorCreatingLabor.
  ///
  /// In en, this message translates to:
  /// **'Error creating labor:'**
  String get errorCreatingLabor;

  /// No description provided for @pleaseFixFollowingErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the following errors:'**
  String get pleaseFixFollowingErrors;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @cnicIsRequired.
  ///
  /// In en, this message translates to:
  /// **'CNIC is required'**
  String get cnicIsRequired;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// No description provided for @casteIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Caste is required'**
  String get casteIsRequired;

  /// No description provided for @designationIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Designation is required'**
  String get designationIsRequired;

  /// No description provided for @areaIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Area is required'**
  String get areaIsRequired;

  /// No description provided for @cityIsRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityIsRequired;

  /// No description provided for @genderIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get genderIsRequired;

  /// No description provided for @joiningDateCannotBeInFuture.
  ///
  /// In en, this message translates to:
  /// **'Joining date cannot be in the future'**
  String get joiningDateCannotBeInFuture;

  /// No description provided for @salaryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Salary is required'**
  String get salaryIsRequired;

  /// No description provided for @pleaseEnterValidSalaryAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid salary amount'**
  String get pleaseEnterValidSalaryAmount;

  /// No description provided for @ageIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageIsRequired;

  /// No description provided for @pleaseEnterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get pleaseEnterValidAge;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined Date'**
  String get joinedDate;

  /// No description provided for @recentLabel.
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get recentLabel;

  /// No description provided for @laborStatusUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Labor status updated successfully!'**
  String get laborStatusUpdatedSuccessfully;

  /// No description provided for @failedToUpdateLaborStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update labor status'**
  String get failedToUpdateLaborStatus;

  /// No description provided for @errorUpdatingLaborStatus.
  ///
  /// In en, this message translates to:
  /// **'Error updating labor status:'**
  String get errorUpdatingLaborStatus;

  /// No description provided for @loadingLaborDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading labor details...'**
  String get loadingLaborDetails;

  /// No description provided for @laborDetails.
  ///
  /// In en, this message translates to:
  /// **'Labor Details'**
  String get laborDetails;

  /// No description provided for @completeLaborInformation.
  ///
  /// In en, this message translates to:
  /// **'Complete labor information'**
  String get completeLaborInformation;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @daysExperience.
  ///
  /// In en, this message translates to:
  /// **'days experience'**
  String get daysExperience;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @workInformation.
  ///
  /// In en, this message translates to:
  /// **'Work Information'**
  String get workInformation;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @joiningDate.
  ///
  /// In en, this message translates to:
  /// **'Joining Date'**
  String get joiningDate;

  /// No description provided for @financialInformation.
  ///
  /// In en, this message translates to:
  /// **'Financial Information'**
  String get financialInformation;

  /// No description provided for @monthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary'**
  String get monthlySalary;

  /// No description provided for @totalAdvances.
  ///
  /// In en, this message translates to:
  /// **'Total Advances'**
  String get totalAdvances;

  /// No description provided for @remainingMonthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Remaining Monthly Salary'**
  String get remainingMonthlySalary;

  /// No description provided for @remainingAdvanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Advance Amount'**
  String get remainingAdvanceAmount;

  /// No description provided for @totalAdvancesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total Advances This Month'**
  String get totalAdvancesThisMonth;

  /// No description provided for @paymentRecords.
  ///
  /// In en, this message translates to:
  /// **'Payment Records'**
  String get paymentRecords;

  /// No description provided for @lastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last Payment'**
  String get lastPayment;

  /// No description provided for @statusInformation.
  ///
  /// In en, this message translates to:
  /// **'Status Information'**
  String get statusInformation;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get createdBy;

  /// No description provided for @newLabor.
  ///
  /// In en, this message translates to:
  /// **'New Labor'**
  String get newLabor;

  /// No description provided for @restoreLabor.
  ///
  /// In en, this message translates to:
  /// **'Restore Labor'**
  String get restoreLabor;

  /// No description provided for @deactivateLabor.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Labor'**
  String get deactivateLabor;

  /// No description provided for @areYouSureDeactivateLabor.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate {name}? This action can be reversed.'**
  String areYouSureDeactivateLabor(String name);

  /// No description provided for @areYouSureRestoreLabor.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore {name}?'**
  String areYouSureRestoreLabor(String name);

  /// No description provided for @failedToDeactivateLabor.
  ///
  /// In en, this message translates to:
  /// **'Failed to deactivate labor'**
  String get failedToDeactivateLabor;

  /// No description provided for @laborDeactivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Labor deactivated successfully'**
  String get laborDeactivatedSuccessfully;

  /// No description provided for @failedToRestoreLabor.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore labor'**
  String get failedToRestoreLabor;

  /// No description provided for @laborRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Labor restored successfully'**
  String get laborRestoredSuccessfully;

  /// No description provided for @failedToLoadLabors.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Labors'**
  String get failedToLoadLabors;

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedErrorOccurred;

  /// No description provided for @noLaborsFound.
  ///
  /// In en, this message translates to:
  /// **'No Labors Found'**
  String get noLaborsFound;

  /// No description provided for @startByAddingFirstLabor.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first labor to manage your workforce effectively'**
  String get startByAddingFirstLabor;

  /// No description provided for @addFirstLabor.
  ///
  /// In en, this message translates to:
  /// **'Add First Labor'**
  String get addFirstLabor;

  /// No description provided for @filterLabors.
  ///
  /// In en, this message translates to:
  /// **'Filter Labors'**
  String get filterLabors;

  /// No description provided for @refineYourLaborList.
  ///
  /// In en, this message translates to:
  /// **'Refine your labor list with filters'**
  String get refineYourLaborList;

  /// No description provided for @searchLabors.
  ///
  /// In en, this message translates to:
  /// **'Search Labors'**
  String get searchLabors;

  /// No description provided for @laborStatus.
  ///
  /// In en, this message translates to:
  /// **'Labor Status'**
  String get laborStatus;

  /// No description provided for @searchByNameCnicPhoneDesignation.
  ///
  /// In en, this message translates to:
  /// **'Search by name, CNIC, phone, or designation'**
  String get searchByNameCnicPhoneDesignation;

  /// No description provided for @showInactiveLaborsOnly.
  ///
  /// In en, this message translates to:
  /// **'Show inactive labors only'**
  String get showInactiveLaborsOnly;

  /// No description provided for @onlyDeactivatedLaborsWillBeShown.
  ///
  /// In en, this message translates to:
  /// **'Only deactivated labors will be shown'**
  String get onlyDeactivatedLaborsWillBeShown;

  /// No description provided for @enterCityName.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get enterCityName;

  /// No description provided for @enterAreaName.
  ///
  /// In en, this message translates to:
  /// **'Enter area name'**
  String get enterAreaName;

  /// No description provided for @principalAccountLedger.
  ///
  /// In en, this message translates to:
  /// **'Principal Account Ledger'**
  String get principalAccountLedger;

  /// No description provided for @trackAllCashMovements.
  ///
  /// In en, this message translates to:
  /// **'Track all cash movements and maintain financial balance'**
  String get trackAllCashMovements;

  /// No description provided for @trackCashMovementsAndBalance.
  ///
  /// In en, this message translates to:
  /// **'Track cash movements and balance'**
  String get trackCashMovementsAndBalance;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @cashMovements.
  ///
  /// In en, this message translates to:
  /// **'Cash movements'**
  String get cashMovements;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @addLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Ledger Entry'**
  String get addLedgerEntry;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get totalEntries;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// No description provided for @totalDebits.
  ///
  /// In en, this message translates to:
  /// **'Total Debits'**
  String get totalDebits;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @debits.
  ///
  /// In en, this message translates to:
  /// **'Debits'**
  String get debits;

  /// No description provided for @searchLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'Search ledger entries...'**
  String get searchLedgerEntries;

  /// No description provided for @searchByIdDescriptionAmount.
  ///
  /// In en, this message translates to:
  /// **'Search by ID, description, amount, source module, or handler...'**
  String get searchByIdDescriptionAmount;

  /// No description provided for @receivableDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receivable deleted successfully!'**
  String get receivableDeletedSuccessfully;

  /// No description provided for @deleteReceivable.
  ///
  /// In en, this message translates to:
  /// **'Delete Receivable'**
  String get deleteReceivable;

  /// No description provided for @deleteReceivableRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Receivable Record'**
  String get deleteReceivableRecord;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// No description provided for @areYouSureDeleteReceivable.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receivable?'**
  String get areYouSureDeleteReceivable;

  /// No description provided for @areYouAbsolutelySureDeleteReceivable.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this receivable record?'**
  String get areYouAbsolutelySureDeleteReceivable;

  /// No description provided for @amountGivenLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount Given:'**
  String get amountGivenLabel;

  /// No description provided for @balanceRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance Remaining:'**
  String get balanceRemainingLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get phoneLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get statusLabel;

  /// No description provided for @expectedReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected Return:'**
  String get expectedReturnLabel;

  /// No description provided for @daysOverdueLabel.
  ///
  /// In en, this message translates to:
  /// **'Days Overdue:'**
  String get daysOverdueLabel;

  /// No description provided for @reasonItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason/Item:'**
  String get reasonItemLabel;

  /// No description provided for @willPermanentlyDeleteReceivable.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the receivable record.'**
  String get willPermanentlyDeleteReceivable;

  /// No description provided for @willPermanentlyDeleteReceivableAndData.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the receivable record and all associated data. This action cannot be undone.'**
  String get willPermanentlyDeleteReceivableAndData;

  /// No description provided for @filterAndSortProducts.
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort Products'**
  String get filterAndSortProducts;

  /// No description provided for @refineYourProductList.
  ///
  /// In en, this message translates to:
  /// **'Refine your product list with advanced filters'**
  String get refineYourProductList;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Product Category'**
  String get productCategory;

  /// No description provided for @productAttributes.
  ///
  /// In en, this message translates to:
  /// **'Product Attributes'**
  String get productAttributes;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevel;

  /// No description provided for @priceRangePKR.
  ///
  /// In en, this message translates to:
  /// **'Price Range (PKR)'**
  String get priceRangePKR;

  /// No description provided for @sortOptions.
  ///
  /// In en, this message translates to:
  /// **'Sort Options'**
  String get sortOptions;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @allColors.
  ///
  /// In en, this message translates to:
  /// **'All Colors'**
  String get allColors;

  /// No description provided for @allFabrics.
  ///
  /// In en, this message translates to:
  /// **'All Fabrics'**
  String get allFabrics;

  /// No description provided for @allStockLevels.
  ///
  /// In en, this message translates to:
  /// **'All Stock Levels'**
  String get allStockLevels;

  /// No description provided for @inStockHigh.
  ///
  /// In en, this message translates to:
  /// **'In Stock (High)'**
  String get inStockHigh;

  /// No description provided for @mediumStock.
  ///
  /// In en, this message translates to:
  /// **'Medium Stock'**
  String get mediumStock;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPrice;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

  /// No description provided for @dateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Date Updated'**
  String get dateUpdated;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @minPriceCannotBeGreaterThanMax.
  ///
  /// In en, this message translates to:
  /// **'Minimum price cannot be greater than maximum price'**
  String get minPriceCannotBeGreaterThanMax;

  /// No description provided for @filtersAppliedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Filters applied successfully'**
  String get filtersAppliedSuccessfully;

  /// No description provided for @filtersCleared.
  ///
  /// In en, this message translates to:
  /// **'Filters cleared'**
  String get filtersCleared;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// No description provided for @enterProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter product details'**
  String get enterProductDetails;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @enterColor.
  ///
  /// In en, this message translates to:
  /// **'Enter color'**
  String get enterColor;

  /// No description provided for @enterFabric.
  ///
  /// In en, this message translates to:
  /// **'Enter fabric'**
  String get enterFabric;

  /// No description provided for @enterMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter minimum price'**
  String get enterMinPrice;

  /// No description provided for @enterVendorName.
  ///
  /// In en, this message translates to:
  /// **'Enter vendor name'**
  String get enterVendorName;

  /// No description provided for @enterBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Enter business name'**
  String get enterBusinessName;

  /// No description provided for @enterCnicNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC number'**
  String get enterCnicNumber;

  /// No description provided for @enterPhoneWithCode.
  ///
  /// In en, this message translates to:
  /// **'Enter phone (+92XXXXXXXXXX)'**
  String get enterPhoneWithCode;

  /// No description provided for @enterFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter full address'**
  String get enterFullAddress;

  /// No description provided for @enterAdditionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes'**
  String get enterAdditionalNotes;

  /// No description provided for @addZakat.
  ///
  /// In en, this message translates to:
  /// **'Add Zakat'**
  String get addZakat;

  /// No description provided for @addNewZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Add New Zakat Record'**
  String get addNewZakatRecord;

  /// No description provided for @recordYourZakatContribution.
  ///
  /// In en, this message translates to:
  /// **'Record your zakat contribution'**
  String get recordYourZakatContribution;

  /// No description provided for @titleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (Optional)'**
  String get titleOptional;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @enterZakatContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter zakat contribution title'**
  String get enterZakatContributionTitle;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @enterDescriptionPurposeOfZakat.
  ///
  /// In en, this message translates to:
  /// **'Enter description/purpose of zakat'**
  String get enterDescriptionPurposeOfZakat;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get pleaseEnterDescription;

  /// No description provided for @descriptionMustBeAtLeast5Characters.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 5 characters'**
  String get descriptionMustBeAtLeast5Characters;

  /// No description provided for @amountPkr.
  ///
  /// In en, this message translates to:
  /// **'Amount (PKR)'**
  String get amountPkr;

  /// No description provided for @enterZakatAmountInPkr.
  ///
  /// In en, this message translates to:
  /// **'Enter zakat amount in PKR'**
  String get enterZakatAmountInPkr;

  /// No description provided for @pleaseEnterValidAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than zero'**
  String get pleaseEnterValidAmountGreaterThanZero;

  /// No description provided for @beneficiaryName.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Name'**
  String get beneficiaryName;

  /// No description provided for @enterBeneficiaryName.
  ///
  /// In en, this message translates to:
  /// **'Enter beneficiary name'**
  String get enterBeneficiaryName;

  /// No description provided for @enterNameOfRecipientBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Enter name of recipient/beneficiary'**
  String get enterNameOfRecipientBeneficiary;

  /// No description provided for @pleaseEnterBeneficiaryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter beneficiary name'**
  String get pleaseEnterBeneficiaryName;

  /// No description provided for @beneficiaryNameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary name must be at least 2 characters'**
  String get beneficiaryNameMustBeAtLeast2Characters;

  /// No description provided for @beneficiaryContactOptional.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Contact (Optional)'**
  String get beneficiaryContactOptional;

  /// No description provided for @enterContact.
  ///
  /// In en, this message translates to:
  /// **'Enter contact'**
  String get enterContact;

  /// No description provided for @enterBeneficiaryContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter beneficiary contact number'**
  String get enterBeneficiaryContactNumber;

  /// No description provided for @authorizedBy.
  ///
  /// In en, this message translates to:
  /// **'Authorized By'**
  String get authorizedBy;

  /// No description provided for @selectAuthorizingPerson.
  ///
  /// In en, this message translates to:
  /// **'Select authorizing person'**
  String get selectAuthorizingPerson;

  /// No description provided for @pleaseSelectAuthorizedPerson.
  ///
  /// In en, this message translates to:
  /// **'Please select an authorized person'**
  String get pleaseSelectAuthorizedPerson;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @additionalNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (Optional)'**
  String get additionalNotesOptional;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter notes'**
  String get enterNotes;

  /// No description provided for @enterAdditionalNotesOrReligiousConsiderations.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes or religious considerations'**
  String get enterAdditionalNotesOrReligiousConsiderations;

  /// No description provided for @addZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Zakat Record'**
  String get addZakatRecord;

  /// No description provided for @zakatRecordAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Zakat record added successfully!'**
  String get zakatRecordAddedSuccessfully;

  /// No description provided for @failedToAddZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Failed to add zakat record'**
  String get failedToAddZakatRecord;

  /// No description provided for @zakatContribution.
  ///
  /// In en, this message translates to:
  /// **'Zakat Contribution'**
  String get zakatContribution;

  /// No description provided for @zakatId.
  ///
  /// In en, this message translates to:
  /// **'Zakat ID'**
  String get zakatId;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @beneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get beneficiary;

  /// No description provided for @authority.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get authority;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// No description provided for @showingZakatRecords.
  ///
  /// In en, this message translates to:
  /// **'Showing {start}-{end} of {total} zakat records'**
  String showingZakatRecords(int start, int end, int total);

  /// No description provided for @pageOfPages.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String pageOfPages(int current, int total);

  /// No description provided for @filterZakatRecords.
  ///
  /// In en, this message translates to:
  /// **'Filter Zakat Records'**
  String get filterZakatRecords;

  /// No description provided for @refineYourZakatList.
  ///
  /// In en, this message translates to:
  /// **'Refine your zakat list with filters'**
  String get refineYourZakatList;

  /// No description provided for @searchZakatRecords.
  ///
  /// In en, this message translates to:
  /// **'Search Zakat Records'**
  String get searchZakatRecords;

  /// No description provided for @recordStatus.
  ///
  /// In en, this message translates to:
  /// **'Record Status'**
  String get recordStatus;

  /// No description provided for @authorizationAuthority.
  ///
  /// In en, this message translates to:
  /// **'Authorization Authority'**
  String get authorizationAuthority;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @searchByNameDescriptionBeneficiaryOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Search by name, description, beneficiary, or notes'**
  String get searchByNameDescriptionBeneficiaryOrNotes;

  /// No description provided for @showInactiveRecordsOnly.
  ///
  /// In en, this message translates to:
  /// **'Show inactive records only'**
  String get showInactiveRecordsOnly;

  /// No description provided for @onlyDeactivatedZakatRecordsWillBeShown.
  ///
  /// In en, this message translates to:
  /// **'Only deactivated zakat records will be shown'**
  String get onlyDeactivatedZakatRecordsWillBeShown;

  /// No description provided for @selectAuthorizationAuthority.
  ///
  /// In en, this message translates to:
  /// **'Select Authorization Authority'**
  String get selectAuthorizationAuthority;

  /// No description provided for @clearAuthorityFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Authority Filter'**
  String get clearAuthorityFilter;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @noDateRangeSelected.
  ///
  /// In en, this message translates to:
  /// **'No date range selected'**
  String get noDateRangeSelected;

  /// No description provided for @clearDateRange.
  ///
  /// In en, this message translates to:
  /// **'Clear Date Range'**
  String get clearDateRange;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @failedToLoadZakatRecords.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Zakat Records'**
  String get failedToLoadZakatRecords;

  /// No description provided for @noZakatRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No Zakat Records Found'**
  String get noZakatRecordsFound;

  /// No description provided for @startByAddingFirstZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first zakat record to track your contributions effectively'**
  String get startByAddingFirstZakatRecord;

  /// No description provided for @addFirstZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Add First Zakat Record'**
  String get addFirstZakatRecord;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @zakatDetails.
  ///
  /// In en, this message translates to:
  /// **'Zakat Details'**
  String get zakatDetails;

  /// No description provided for @viewCompleteZakatContributionInformation.
  ///
  /// In en, this message translates to:
  /// **'View complete zakat contribution information'**
  String get viewCompleteZakatContributionInformation;

  /// No description provided for @zakatTitle.
  ///
  /// In en, this message translates to:
  /// **'Zakat Title'**
  String get zakatTitle;

  /// No description provided for @zakatAmount.
  ///
  /// In en, this message translates to:
  /// **'Zakat Amount'**
  String get zakatAmount;

  /// No description provided for @contributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution Amount'**
  String get contributionAmount;

  /// No description provided for @beneficiaryInformation.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Information'**
  String get beneficiaryInformation;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @descriptionAndPurpose.
  ///
  /// In en, this message translates to:
  /// **'Description & Purpose'**
  String get descriptionAndPurpose;

  /// No description provided for @authorizationAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Authorization & Status'**
  String get authorizationAndStatus;

  /// No description provided for @editZakat.
  ///
  /// In en, this message translates to:
  /// **'Edit Zakat'**
  String get editZakat;

  /// No description provided for @editZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Zakat Record'**
  String get editZakatRecord;

  /// No description provided for @updateZakatInformation.
  ///
  /// In en, this message translates to:
  /// **'Update zakat information'**
  String get updateZakatInformation;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get pleaseEnterTitle;

  /// No description provided for @zakatRecordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Zakat record updated successfully!'**
  String get zakatRecordUpdatedSuccessfully;

  /// No description provided for @failedToUpdateZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Failed to update zakat record'**
  String get failedToUpdateZakatRecord;

  /// No description provided for @updateZakat.
  ///
  /// In en, this message translates to:
  /// **'Update Zakat'**
  String get updateZakat;

  /// No description provided for @deleteZakat.
  ///
  /// In en, this message translates to:
  /// **'Delete Zakat'**
  String get deleteZakat;

  /// No description provided for @deleteZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Zakat Record'**
  String get deleteZakatRecord;

  /// No description provided for @zakatRecordDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Zakat record deleted successfully!'**
  String get zakatRecordDeletedSuccessfully;

  /// No description provided for @failedToDeleteZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete zakat record'**
  String get failedToDeleteZakatRecord;

  /// No description provided for @areYouSureYouWantToDeleteThisZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this zakat record?'**
  String get areYouSureYouWantToDeleteThisZakatRecord;

  /// No description provided for @areYouAbsolutelySureYouWantToDeleteThisZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this zakat record?'**
  String get areYouAbsolutelySureYouWantToDeleteThisZakatRecord;

  /// No description provided for @thisWillPermanentlyDeleteTheZakatRecord.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the zakat record.'**
  String get thisWillPermanentlyDeleteTheZakatRecord;

  /// No description provided for @thisWillPermanentlyDeleteTheZakatRecordAndAllAssociatedData.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the zakat record and all associated data. This action cannot be undone.'**
  String get thisWillPermanentlyDeleteTheZakatRecordAndAllAssociatedData;

  /// No description provided for @calculationSummary.
  ///
  /// In en, this message translates to:
  /// **'Calculation Summary'**
  String get calculationSummary;

  /// No description provided for @costOfGoods.
  ///
  /// In en, this message translates to:
  /// **'Cost of Goods'**
  String get costOfGoods;

  /// No description provided for @totalSalesRevenueForThePeriod.
  ///
  /// In en, this message translates to:
  /// **'Total sales revenue for the period'**
  String get totalSalesRevenueForThePeriod;

  /// No description provided for @directCostsOfProductsSold.
  ///
  /// In en, this message translates to:
  /// **'Direct costs of products sold'**
  String get directCostsOfProductsSold;

  /// No description provided for @incomeMinusCostOfGoodsSold.
  ///
  /// In en, this message translates to:
  /// **'Income minus cost of goods sold'**
  String get incomeMinusCostOfGoodsSold;

  /// No description provided for @finalProfitAfterAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Final profit after all expenses'**
  String get finalProfitAfterAllExpenses;

  /// No description provided for @totalSalesRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total sales revenue'**
  String get totalSalesRevenue;

  /// No description provided for @directCosts.
  ///
  /// In en, this message translates to:
  /// **'Direct costs'**
  String get directCosts;

  /// No description provided for @incomeMinusCogs.
  ///
  /// In en, this message translates to:
  /// **'Income - COGS'**
  String get incomeMinusCogs;

  /// No description provided for @finalProfit.
  ///
  /// In en, this message translates to:
  /// **'Final profit'**
  String get finalProfit;

  /// No description provided for @sourceRecordsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Source Records Breakdown'**
  String get sourceRecordsBreakdown;

  /// No description provided for @salesRecords.
  ///
  /// In en, this message translates to:
  /// **'Sales Records'**
  String get salesRecords;

  /// No description provided for @laborPayments.
  ///
  /// In en, this message translates to:
  /// **'Labor Payments'**
  String get laborPayments;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @vendorPayments.
  ///
  /// In en, this message translates to:
  /// **'Vendor Payments'**
  String get vendorPayments;

  /// No description provided for @otherExpenses.
  ///
  /// In en, this message translates to:
  /// **'Other Expenses'**
  String get otherExpenses;

  /// No description provided for @vendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendors;

  /// No description provided for @calculationFormula.
  ///
  /// In en, this message translates to:
  /// **'Calculation Formula'**
  String get calculationFormula;

  /// No description provided for @stepOneGrossProfit.
  ///
  /// In en, this message translates to:
  /// **'1. Gross Profit'**
  String get stepOneGrossProfit;

  /// No description provided for @stepTwoTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'2. Total Expenses'**
  String get stepTwoTotalExpenses;

  /// No description provided for @laborPlusVendorPlusOtherPlusZakat.
  ///
  /// In en, this message translates to:
  /// **'Labor + Vendor + Other + Zakat'**
  String get laborPlusVendorPlusOtherPlusZakat;

  /// No description provided for @stepThreeNetProfit.
  ///
  /// In en, this message translates to:
  /// **'3. Net Profit'**
  String get stepThreeNetProfit;

  /// No description provided for @grossProfitMinusTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit - Total Expenses'**
  String get grossProfitMinusTotalExpenses;

  /// No description provided for @grossProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit Margin'**
  String get grossProfitMargin;

  /// No description provided for @grossProfitDivideIncomeMultiply100.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit / Income × 100'**
  String get grossProfitDivideIncomeMultiply100;

  /// No description provided for @netProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Net Profit Margin'**
  String get netProfitMargin;

  /// No description provided for @netProfitDivideIncomeMultiply100.
  ///
  /// In en, this message translates to:
  /// **'Net Profit / Income × 100'**
  String get netProfitDivideIncomeMultiply100;

  /// No description provided for @periodInformation.
  ///
  /// In en, this message translates to:
  /// **'Period Information'**
  String get periodInformation;

  /// No description provided for @periodType.
  ///
  /// In en, this message translates to:
  /// **'Period Type'**
  String get periodType;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @noCalculationDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Calculation Data Available'**
  String get noCalculationDataAvailable;

  /// No description provided for @calculationDetailsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Calculation details will appear here once profit and loss data is available'**
  String get calculationDetailsWillAppearHere;

  /// No description provided for @loadingDashboardData.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard data...'**
  String get loadingDashboardData;

  /// No description provided for @salesGrowth.
  ///
  /// In en, this message translates to:
  /// **'Sales Growth'**
  String get salesGrowth;

  /// No description provided for @expenseGrowth.
  ///
  /// In en, this message translates to:
  /// **'Expense Growth'**
  String get expenseGrowth;

  /// No description provided for @profitGrowth.
  ///
  /// In en, this message translates to:
  /// **'Profit Growth'**
  String get profitGrowth;

  /// No description provided for @increased.
  ///
  /// In en, this message translates to:
  /// **'Increased'**
  String get increased;

  /// No description provided for @decreased.
  ///
  /// In en, this message translates to:
  /// **'Decreased'**
  String get decreased;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No Change'**
  String get noChange;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @businessTrends.
  ///
  /// In en, this message translates to:
  /// **'Business Trends'**
  String get businessTrends;

  /// No description provided for @salesTrend.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend'**
  String get salesTrend;

  /// No description provided for @profitTrend.
  ///
  /// In en, this message translates to:
  /// **'Profit Trend'**
  String get profitTrend;

  /// No description provided for @increasing.
  ///
  /// In en, this message translates to:
  /// **'Increasing'**
  String get increasing;

  /// No description provided for @decreasing.
  ///
  /// In en, this message translates to:
  /// **'Decreasing'**
  String get decreasing;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @grossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get grossProfit;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @chooseTheFormatForYourProfitAndLossReport.
  ///
  /// In en, this message translates to:
  /// **'Choose the format for your Profit & Loss report:'**
  String get chooseTheFormatForYourProfitAndLossReport;

  /// No description provided for @pdfReport.
  ///
  /// In en, this message translates to:
  /// **'PDF Report'**
  String get pdfReport;

  /// No description provided for @professionalDocumentWithChartsAndFormatting.
  ///
  /// In en, this message translates to:
  /// **'Professional document with charts and formatting'**
  String get professionalDocumentWithChartsAndFormatting;

  /// No description provided for @excelSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Excel Spreadsheet'**
  String get excelSpreadsheet;

  /// No description provided for @dataInSpreadsheetFormatForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Data in spreadsheet format for analysis'**
  String get dataInSpreadsheetFormatForAnalysis;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get profitMargin;

  /// No description provided for @netLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Loss'**
  String get netLoss;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @applyRange.
  ///
  /// In en, this message translates to:
  /// **'Apply Range'**
  String get applyRange;

  /// No description provided for @productProfitabilityAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Product Profitability Analysis'**
  String get productProfitabilityAnalysis;

  /// No description provided for @analyzingProductsAcrossDifferentCategories.
  ///
  /// In en, this message translates to:
  /// **'Analyzing {count} products across different categories'**
  String analyzingProductsAcrossDifferentCategories(int count);

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Products'**
  String productsCount(int count);

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @unitsSold.
  ///
  /// In en, this message translates to:
  /// **'Units Sold'**
  String get unitsSold;

  /// No description provided for @marginPercent.
  ///
  /// In en, this message translates to:
  /// **'Margin %'**
  String get marginPercent;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Sort Descending'**
  String get sortDescending;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Sort Ascending'**
  String get sortAscending;

  /// No description provided for @summaryStatistics.
  ///
  /// In en, this message translates to:
  /// **'Summary Statistics'**
  String get summaryStatistics;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @avgProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Avg Profit Margin'**
  String get avgProfitMargin;

  /// No description provided for @profitableProducts.
  ///
  /// In en, this message translates to:
  /// **'Profitable Products'**
  String get profitableProducts;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @loadingProductData.
  ///
  /// In en, this message translates to:
  /// **'Loading Product Data...'**
  String get loadingProductData;

  /// No description provided for @pleaseWaitWhileWeFetchTheLatestProfitabilityInformation.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we fetch the latest profitability information.'**
  String get pleaseWaitWhileWeFetchTheLatestProfitabilityInformation;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Data'**
  String get errorLoadingData;

  /// No description provided for @anUnexpectedErrorOccurredWhileLoadingProductData.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while loading product data.'**
  String get anUnexpectedErrorOccurredWhileLoadingProductData;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @productProfitabilityDataIsBeingLoaded.
  ///
  /// In en, this message translates to:
  /// **'Product profitability data is being loaded.\nThis includes revenue, costs, profit margins, and rankings.'**
  String get productProfitabilityDataIsBeingLoaded;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @addPayable.
  ///
  /// In en, this message translates to:
  /// **'Add Payable'**
  String get addPayable;

  /// No description provided for @addNewPayable.
  ///
  /// In en, this message translates to:
  /// **'Add New Payable'**
  String get addNewPayable;

  /// No description provided for @recordAmountOwedToCreditor.
  ///
  /// In en, this message translates to:
  /// **'Record amount owed to creditor'**
  String get recordAmountOwedToCreditor;

  /// No description provided for @creditorInformation.
  ///
  /// In en, this message translates to:
  /// **'Creditor Information'**
  String get creditorInformation;

  /// No description provided for @creditorName.
  ///
  /// In en, this message translates to:
  /// **'Creditor Name'**
  String get creditorName;

  /// No description provided for @enterCreditorFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter creditor full name'**
  String get enterCreditorFullName;

  /// No description provided for @pleaseEnterCreditorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter creditor name'**
  String get pleaseEnterCreditorName;

  /// No description provided for @enterPhoneNumberWithFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number (+92XXXXXXXXXX)'**
  String get enterPhoneNumberWithFormat;

  /// No description provided for @pleaseEnterAValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterAValidPhoneNumber;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptional;

  /// No description provided for @enterCreditorEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter creditor email address'**
  String get enterCreditorEmailAddress;

  /// No description provided for @amountBorrowedPKR.
  ///
  /// In en, this message translates to:
  /// **'Amount Borrowed (PKR)'**
  String get amountBorrowedPKR;

  /// No description provided for @enterAmountBorrowedFromCreditor.
  ///
  /// In en, this message translates to:
  /// **'Enter amount borrowed from creditor'**
  String get enterAmountBorrowedFromCreditor;

  /// No description provided for @pleaseEnterAmountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount borrowed'**
  String get pleaseEnterAmountBorrowed;

  /// No description provided for @pleaseEnterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterAValidAmount;

  /// No description provided for @amountPaidPKR.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid (PKR)'**
  String get amountPaidPKR;

  /// No description provided for @optionalIfAnyAmountAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Optional - if any amount already paid'**
  String get optionalIfAnyAmountAlreadyPaid;

  /// No description provided for @cannotExceedAmountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed amount borrowed'**
  String get cannotExceedAmountBorrowed;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @enterReasonForBorrowingOrItemDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for borrowing or item description'**
  String get enterReasonForBorrowingOrItemDescription;

  /// No description provided for @pleaseEnterReasonOrItemDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter reason or item description'**
  String get pleaseEnterReasonOrItemDescription;

  /// No description provided for @vendorOptional.
  ///
  /// In en, this message translates to:
  /// **'Vendor (Optional)'**
  String get vendorOptional;

  /// No description provided for @selectVendorIfCreditorIsARegisteredVendor.
  ///
  /// In en, this message translates to:
  /// **'Select vendor if creditor is a registered vendor'**
  String get selectVendorIfCreditorIsARegisteredVendor;

  /// No description provided for @noVendor.
  ///
  /// In en, this message translates to:
  /// **'No vendor'**
  String get noVendor;

  /// No description provided for @priorityLevel.
  ///
  /// In en, this message translates to:
  /// **'Priority Level'**
  String get priorityLevel;

  /// No description provided for @selectPriorityLevelForThisPayable.
  ///
  /// In en, this message translates to:
  /// **'Select priority level for this payable'**
  String get selectPriorityLevelForThisPayable;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @enterAdditionalNotesOrPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes or payment history'**
  String get enterAdditionalNotesOrPaymentHistory;

  /// No description provided for @dateBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Date Borrowed'**
  String get dateBorrowed;

  /// No description provided for @expectedRepaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Repayment Date'**
  String get expectedRepaymentDate;

  /// No description provided for @selectBorrowedDate.
  ///
  /// In en, this message translates to:
  /// **'Select Borrowed Date'**
  String get selectBorrowedDate;

  /// No description provided for @selectExpectedRepaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Select Expected Repayment Date'**
  String get selectExpectedRepaymentDate;

  /// No description provided for @borrowingPeriodDays.
  ///
  /// In en, this message translates to:
  /// **'Borrowing period: {days} days'**
  String borrowingPeriodDays(int days);

  /// No description provided for @pleaseSelectAValidRepaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid repayment date'**
  String get pleaseSelectAValidRepaymentDate;

  /// No description provided for @expectedRepaymentDateCannotBeBeforeDateBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Expected repayment date cannot be before date borrowed'**
  String get expectedRepaymentDateCannotBeBeforeDateBorrowed;

  /// No description provided for @failedToAddPayablePleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to add payable. Please try again.'**
  String get failedToAddPayablePleaseTryAgain;

  /// No description provided for @payableAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payable added successfully!'**
  String get payableAddedSuccessfully;

  /// No description provided for @enterReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason'**
  String get enterReason;

  /// No description provided for @deletePayable.
  ///
  /// In en, this message translates to:
  /// **'Delete Payable'**
  String get deletePayable;

  /// No description provided for @deletePayableRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Payable Record'**
  String get deletePayableRecord;

  /// No description provided for @areYouSureYouWantToDeleteThisPayable.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payable?'**
  String get areYouSureYouWantToDeleteThisPayable;

  /// No description provided for @areYouAbsolutelySureYouWantToDeleteThisPayableRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this payable record?'**
  String get areYouAbsolutelySureYouWantToDeleteThisPayableRecord;

  /// No description provided for @amountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Amount Borrowed'**
  String get amountBorrowed;

  /// No description provided for @expectedRepayment.
  ///
  /// In en, this message translates to:
  /// **'Expected Repayment'**
  String get expectedRepayment;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @thisWillPermanentlyDeleteThePayableRecord.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the payable record.'**
  String get thisWillPermanentlyDeleteThePayableRecord;

  /// No description provided for @thisWillPermanentlyDeleteThePayableRecordAndAllAssociatedData.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the payable record and all associated data. This action cannot be undone.'**
  String get thisWillPermanentlyDeleteThePayableRecordAndAllAssociatedData;

  /// No description provided for @payableDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payable deleted successfully!'**
  String get payableDeletedSuccessfully;

  /// No description provided for @editPayable.
  ///
  /// In en, this message translates to:
  /// **'Edit Payable'**
  String get editPayable;

  /// No description provided for @editPayableDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Payable Details'**
  String get editPayableDetails;

  /// No description provided for @updatePayableInformation.
  ///
  /// In en, this message translates to:
  /// **'Update payable information'**
  String get updatePayableInformation;

  /// No description provided for @enterCreditorEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter creditor email'**
  String get enterCreditorEmail;

  /// No description provided for @additionalAmountToPayPKR.
  ///
  /// In en, this message translates to:
  /// **'Additional Amount to Pay (PKR)'**
  String get additionalAmountToPayPKR;

  /// No description provided for @enterAdditionalAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter additional amount'**
  String get enterAdditionalAmount;

  /// No description provided for @totalPaymentCannotExceedAmountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total payment cannot exceed amount borrowed'**
  String get totalPaymentCannotExceedAmountBorrowed;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @currentPaid.
  ///
  /// In en, this message translates to:
  /// **'Current Paid'**
  String get currentPaid;

  /// No description provided for @additionalPayment.
  ///
  /// In en, this message translates to:
  /// **'Additional Payment'**
  String get additionalPayment;

  /// No description provided for @totalAfterUpdate.
  ///
  /// In en, this message translates to:
  /// **'Total After Update'**
  String get totalAfterUpdate;

  /// No description provided for @reasonForBorrowing.
  ///
  /// In en, this message translates to:
  /// **'Reason for borrowing'**
  String get reasonForBorrowing;

  /// No description provided for @updatePayable.
  ///
  /// In en, this message translates to:
  /// **'Update Payable'**
  String get updatePayable;

  /// No description provided for @amountPaidCannotExceedAmountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Amount paid cannot exceed amount borrowed'**
  String get amountPaidCannotExceedAmountBorrowed;

  /// No description provided for @payableUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payable updated successfully!'**
  String get payableUpdatedSuccessfully;

  /// No description provided for @payableId.
  ///
  /// In en, this message translates to:
  /// **'Payable ID'**
  String get payableId;

  /// No description provided for @creditor.
  ///
  /// In en, this message translates to:
  /// **'Creditor'**
  String get creditor;

  /// No description provided for @showingPayableRecords.
  ///
  /// In en, this message translates to:
  /// **'Showing {start}-{end} of {total} payable records'**
  String showingPayableRecords(int start, int end, int total);

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @filterPayables.
  ///
  /// In en, this message translates to:
  /// **'Filter Payables'**
  String get filterPayables;

  /// No description provided for @applyFiltersToFindSpecificPayables.
  ///
  /// In en, this message translates to:
  /// **'Apply filters to find specific payables'**
  String get applyFiltersToFindSpecificPayables;

  /// No description provided for @searchByCreditorNameReasonNotes.
  ///
  /// In en, this message translates to:
  /// **'Search by creditor name, reason, notes...'**
  String get searchByCreditorNameReasonNotes;

  /// No description provided for @statusAndPriority.
  ///
  /// In en, this message translates to:
  /// **'Status & Priority'**
  String get statusAndPriority;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidStatus;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partiallyPaid;

  /// No description provided for @selectPriority.
  ///
  /// In en, this message translates to:
  /// **'Select priority'**
  String get selectPriority;

  /// No description provided for @allPriorities.
  ///
  /// In en, this message translates to:
  /// **'All Priorities'**
  String get allPriorities;

  /// No description provided for @selectVendor.
  ///
  /// In en, this message translates to:
  /// **'Select vendor'**
  String get selectVendor;

  /// No description provided for @allVendors.
  ///
  /// In en, this message translates to:
  /// **'All Vendors'**
  String get allVendors;

  /// No description provided for @dateRanges.
  ///
  /// In en, this message translates to:
  /// **'Date Ranges'**
  String get dateRanges;

  /// No description provided for @dueAfter.
  ///
  /// In en, this message translates to:
  /// **'Due After'**
  String get dueAfter;

  /// No description provided for @dueBefore.
  ///
  /// In en, this message translates to:
  /// **'Due Before'**
  String get dueBefore;

  /// No description provided for @borrowedAfter.
  ///
  /// In en, this message translates to:
  /// **'Borrowed After'**
  String get borrowedAfter;

  /// No description provided for @borrowedBefore.
  ///
  /// In en, this message translates to:
  /// **'Borrowed Before'**
  String get borrowedBefore;

  /// No description provided for @creditorDetails.
  ///
  /// In en, this message translates to:
  /// **'Creditor Details'**
  String get creditorDetails;

  /// No description provided for @repaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Repayment Date'**
  String get repaymentDate;

  /// No description provided for @pkrRemaining.
  ///
  /// In en, this message translates to:
  /// **'PKR {amount} remaining'**
  String pkrRemaining(String amount);

  /// No description provided for @daysOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days overdue'**
  String daysOverdueCount(int count);

  /// No description provided for @noPayablesFound.
  ///
  /// In en, this message translates to:
  /// **'No Payables Found'**
  String get noPayablesFound;

  /// No description provided for @startByAddingYourFirstPayableRecord.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first payable record to track amounts borrowed from suppliers and creditors'**
  String get startByAddingYourFirstPayableRecord;

  /// No description provided for @addFirstPayable.
  ///
  /// In en, this message translates to:
  /// **'Add First Payable'**
  String get addFirstPayable;

  /// No description provided for @failedToLoadPayables.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Payables'**
  String get failedToLoadPayables;

  /// No description provided for @anUnexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get anUnexpectedErrorOccurred;

  /// No description provided for @startByAddingYourFirstPayableRecordToTrackYourBorrowingsEffectively.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first payable record to track your borrowings effectively'**
  String
  get startByAddingYourFirstPayableRecordToTrackYourBorrowingsEffectively;

  /// No description provided for @addFirstPayableRecord.
  ///
  /// In en, this message translates to:
  /// **'Add First Payable Record'**
  String get addFirstPayableRecord;

  /// No description provided for @fullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully Paid'**
  String get fullyPaid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @payableDetails.
  ///
  /// In en, this message translates to:
  /// **'Payable Details'**
  String get payableDetails;

  /// No description provided for @viewCompletePayableInformation.
  ///
  /// In en, this message translates to:
  /// **'View complete payable information'**
  String get viewCompletePayableInformation;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @paymentProgress.
  ///
  /// In en, this message translates to:
  /// **'Payment Progress'**
  String get paymentProgress;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPrice;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @fabric.
  ///
  /// In en, this message translates to:
  /// **'Fabric'**
  String get fabric;

  /// No description provided for @stockStatus.
  ///
  /// In en, this message translates to:
  /// **'Stock Status'**
  String get stockStatus;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get createdDate;

  /// No description provided for @noDetails.
  ///
  /// In en, this message translates to:
  /// **'No details'**
  String get noDetails;

  /// No description provided for @noPieces.
  ///
  /// In en, this message translates to:
  /// **'No pieces'**
  String get noPieces;

  /// No description provided for @noProductRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No Product Records Found'**
  String get noProductRecordsFound;

  /// No description provided for @startByAddingYourFirstProductToManageInventoryEfficiently.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first product to manage inventory efficiently'**
  String get startByAddingYourFirstProductToManageInventoryEfficiently;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add First Product'**
  String get addFirstProduct;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @oneWeekAgo.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get oneWeekAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(int count);

  /// No description provided for @oneMonthAgo.
  ///
  /// In en, this message translates to:
  /// **'1 month ago'**
  String get oneMonthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(int count);

  /// No description provided for @oneYearAgo.
  ///
  /// In en, this message translates to:
  /// **'1 year ago'**
  String get oneYearAgo;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String yearsAgo(int count);

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @viewCompleteProductInformation.
  ///
  /// In en, this message translates to:
  /// **'View complete product information'**
  String get viewCompleteProductInformation;

  /// No description provided for @unnamedProduct.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Product'**
  String get unnamedProduct;

  /// No description provided for @noDetailsProvided.
  ///
  /// In en, this message translates to:
  /// **'No details provided'**
  String get noDetailsProvided;

  /// No description provided for @setCostPriceToCalculateProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Set cost price to calculate profit margin'**
  String get setCostPriceToCalculateProfitMargin;

  /// No description provided for @unitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String unitsCount(int count);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @productPieces.
  ///
  /// In en, this message translates to:
  /// **'Product Pieces'**
  String get productPieces;

  /// No description provided for @noPiecesSpecified.
  ///
  /// In en, this message translates to:
  /// **'No pieces specified'**
  String get noPiecesSpecified;

  /// No description provided for @productActive.
  ///
  /// In en, this message translates to:
  /// **'Product Active'**
  String get productActive;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @editProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Product Details'**
  String get editProductDetails;

  /// No description provided for @updateProductInformation.
  ///
  /// In en, this message translates to:
  /// **'Update product information'**
  String get updateProductInformation;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get productUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to update product'**
  String get failedToUpdateProduct;

  /// No description provided for @productDetail.
  ///
  /// In en, this message translates to:
  /// **'Product Detail'**
  String get productDetail;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter details'**
  String get enterDetails;

  /// No description provided for @enterProductDescriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter product description/details'**
  String get enterProductDescriptionDetails;

  /// No description provided for @pleaseEnterProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter product details'**
  String get pleaseEnterProductDetails;

  /// No description provided for @productDetailMustBeAtLeast5Characters.
  ///
  /// In en, this message translates to:
  /// **'Product detail must be at least 5 characters'**
  String get productDetailMustBeAtLeast5Characters;

  /// No description provided for @enterPricePkr.
  ///
  /// In en, this message translates to:
  /// **'Enter price (PKR)'**
  String get enterPricePkr;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get pleaseEnterPrice;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// No description provided for @enterCost.
  ///
  /// In en, this message translates to:
  /// **'Enter cost'**
  String get enterCost;

  /// No description provided for @enterCostPricePkrOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter cost price (PKR) - Optional'**
  String get enterCostPricePkrOptional;

  /// No description provided for @pleaseEnterValidCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid cost price'**
  String get pleaseEnterValidCostPrice;

  /// No description provided for @enterQty.
  ///
  /// In en, this message translates to:
  /// **'Enter qty'**
  String get enterQty;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get pleaseEnterQuantity;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @loadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get loadingCategories;

  /// No description provided for @noCategoriesAvailablePleaseAddCategoriesFirst.
  ///
  /// In en, this message translates to:
  /// **'No categories available. Please add categories first.'**
  String get noCategoriesAvailablePleaseAddCategoriesFirst;

  /// No description provided for @noId.
  ///
  /// In en, this message translates to:
  /// **'No ID'**
  String get noId;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @selectProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Select product category'**
  String get selectProductCategory;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @enterColorName.
  ///
  /// In en, this message translates to:
  /// **'Enter color name (e.g., Red, Blue, Turquoise)'**
  String get enterColorName;

  /// No description provided for @pleaseEnterColor.
  ///
  /// In en, this message translates to:
  /// **'Please enter a color'**
  String get pleaseEnterColor;

  /// No description provided for @colorNameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Color name must be at least 2 characters'**
  String get colorNameMustBeAtLeast2Characters;

  /// No description provided for @enterFabricType.
  ///
  /// In en, this message translates to:
  /// **'Enter fabric type (e.g., Cotton, Silk, Chiffon)'**
  String get enterFabricType;

  /// No description provided for @pleaseEnterFabric.
  ///
  /// In en, this message translates to:
  /// **'Please enter a fabric'**
  String get pleaseEnterFabric;

  /// No description provided for @fabricNameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Fabric name must be at least 2 characters'**
  String get fabricNameMustBeAtLeast2Characters;

  /// No description provided for @productNameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Product name must be at least 2 characters'**
  String get productNameMustBeAtLeast2Characters;

  /// No description provided for @pleaseEnterProductName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get pleaseEnterProductName;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @addLaborPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Labor Payment'**
  String get addLaborPayment;

  /// No description provided for @recordNewPaymentWithReceipt.
  ///
  /// In en, this message translates to:
  /// **'Record new payment to labor with receipt'**
  String get recordNewPaymentWithReceipt;

  /// No description provided for @paymentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment added successfully!'**
  String get paymentAddedSuccessfully;

  /// No description provided for @pleaseSelectAtLeastOneEntity.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one entity (labor, vendor, order, or sale)'**
  String get pleaseSelectAtLeastOneEntity;

  /// No description provided for @pleaseSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get pleaseSelectPaymentMethod;

  /// No description provided for @pleaseSelectPaymentMonth.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment month'**
  String get pleaseSelectPaymentMonth;

  /// No description provided for @netAmountCannotExceedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Net amount cannot exceed remaining amount of PKR {amount}'**
  String netAmountCannotExceedRemaining(String amount);

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @receiptImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Receipt Image (Optional)'**
  String get receiptImageOptional;

  /// No description provided for @uploadReceiptForBetterRecordKeeping.
  ///
  /// In en, this message translates to:
  /// **'Upload receipt image for better record keeping'**
  String get uploadReceiptForBetterRecordKeeping;

  /// No description provided for @entityType.
  ///
  /// In en, this message translates to:
  /// **'Entity Type'**
  String get entityType;

  /// No description provided for @selectEntityType.
  ///
  /// In en, this message translates to:
  /// **'Select entity type'**
  String get selectEntityType;

  /// No description provided for @pleaseSelectEntityType.
  ///
  /// In en, this message translates to:
  /// **'Please select entity type'**
  String get pleaseSelectEntityType;

  /// No description provided for @selectLabor.
  ///
  /// In en, this message translates to:
  /// **'Select Labor'**
  String get selectLabor;

  /// No description provided for @chooseLaborForPayment.
  ///
  /// In en, this message translates to:
  /// **'Choose labor for payment'**
  String get chooseLaborForPayment;

  /// No description provided for @pleaseSelectLabor.
  ///
  /// In en, this message translates to:
  /// **'Please select a labor'**
  String get pleaseSelectLabor;

  /// No description provided for @vendorId.
  ///
  /// In en, this message translates to:
  /// **'Vendor ID'**
  String get vendorId;

  /// No description provided for @pleaseEnterVendorId.
  ///
  /// In en, this message translates to:
  /// **'Please enter vendor ID'**
  String get pleaseEnterVendorId;

  /// No description provided for @customerType.
  ///
  /// In en, this message translates to:
  /// **'Customer Type'**
  String get customerType;

  /// No description provided for @selectCustomerType.
  ///
  /// In en, this message translates to:
  /// **'Select customer type'**
  String get selectCustomerType;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @enterOrderSaleId.
  ///
  /// In en, this message translates to:
  /// **'Enter {type} ID'**
  String enterOrderSaleId(String type);

  /// No description provided for @paymentMonth.
  ///
  /// In en, this message translates to:
  /// **'Payment Month'**
  String get paymentMonth;

  /// No description provided for @selectPaymentMonth.
  ///
  /// In en, this message translates to:
  /// **'Select payment month'**
  String get selectPaymentMonth;

  /// No description provided for @paymentAmountPkr.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount (PKR)'**
  String get paymentAmountPkr;

  /// No description provided for @enterPaymentAmountPkr.
  ///
  /// In en, this message translates to:
  /// **'Enter payment amount (PKR)'**
  String get enterPaymentAmountPkr;

  /// No description provided for @pleaseEnterPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter payment amount'**
  String get pleaseEnterPaymentAmount;

  /// No description provided for @bonusPkr.
  ///
  /// In en, this message translates to:
  /// **'Bonus (PKR)'**
  String get bonusPkr;

  /// No description provided for @optionalBonus.
  ///
  /// In en, this message translates to:
  /// **'Optional bonus'**
  String get optionalBonus;

  /// No description provided for @pleaseEnterValidBonusAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid bonus amount'**
  String get pleaseEnterValidBonusAmount;

  /// No description provided for @deductionPkr.
  ///
  /// In en, this message translates to:
  /// **'Deduction (PKR)'**
  String get deductionPkr;

  /// No description provided for @optionalDeduction.
  ///
  /// In en, this message translates to:
  /// **'Optional deduction'**
  String get optionalDeduction;

  /// No description provided for @pleaseEnterValidDeductionAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid deduction amount'**
  String get pleaseEnterValidDeductionAmount;

  /// No description provided for @enterPaymentDescriptionOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter payment description or notes'**
  String get enterPaymentDescriptionOrNotes;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @finalPaymentForMonth.
  ///
  /// In en, this message translates to:
  /// **'Final Payment for Month'**
  String get finalPaymentForMonth;

  /// No description provided for @thisCompletesPaymentForSelectedMonth.
  ///
  /// In en, this message translates to:
  /// **'This completes the payment for the selected month'**
  String get thisCompletesPaymentForSelectedMonth;

  /// No description provided for @markThisAsFinalPaymentForMonth.
  ///
  /// In en, this message translates to:
  /// **'Mark this as the final payment for the month'**
  String get markThisAsFinalPaymentForMonth;

  /// No description provided for @netPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Payment Amount'**
  String get netPaymentAmount;

  /// No description provided for @remainingAfterPayment.
  ///
  /// In en, this message translates to:
  /// **'Remaining after payment: PKR {amount}'**
  String remainingAfterPayment(String amount);

  /// No description provided for @paymentReceiptOptional.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt (Optional)'**
  String get paymentReceiptOptional;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select payment method'**
  String get selectPaymentMethod;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment'**
  String get editPayment;

  /// No description provided for @editPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Details'**
  String get editPaymentDetails;

  /// No description provided for @updatePaymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Update payment information'**
  String get updatePaymentInformation;

  /// No description provided for @paymentUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment updated successfully!'**
  String get paymentUpdatedSuccessfully;

  /// No description provided for @netAmountCannotExceedAvailable.
  ///
  /// In en, this message translates to:
  /// **'Net amount cannot exceed available amount of PKR {amount}'**
  String netAmountCannotExceedAvailable(String amount);

  /// No description provided for @selectLaborForPayment.
  ///
  /// In en, this message translates to:
  /// **'Select labor for payment'**
  String get selectLaborForPayment;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @enterValidBonus.
  ///
  /// In en, this message translates to:
  /// **'Enter valid bonus'**
  String get enterValidBonus;

  /// No description provided for @enterValidDeduction.
  ///
  /// In en, this message translates to:
  /// **'Enter valid deduction'**
  String get enterValidDeduction;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// No description provided for @receiptImageSelected.
  ///
  /// In en, this message translates to:
  /// **'Receipt image selected'**
  String get receiptImageSelected;

  /// No description provided for @tapToSelectReceiptImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to select receipt image'**
  String get tapToSelectReceiptImage;

  /// No description provided for @updatePayment.
  ///
  /// In en, this message translates to:
  /// **'Update Payment'**
  String get updatePayment;

  /// No description provided for @paymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentId;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get desc;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @paymentFilters.
  ///
  /// In en, this message translates to:
  /// **'Payment Filters'**
  String get paymentFilters;

  /// No description provided for @searchByLaborVendorDescription.
  ///
  /// In en, this message translates to:
  /// **'Search by labor name, vendor, description...'**
  String get searchByLaborVendorDescription;

  /// No description provided for @entityFilters.
  ///
  /// In en, this message translates to:
  /// **'Entity Filters'**
  String get entityFilters;

  /// No description provided for @allLabors.
  ///
  /// In en, this message translates to:
  /// **'All Labors'**
  String get allLabors;

  /// No description provided for @payerType.
  ///
  /// In en, this message translates to:
  /// **'Payer Type'**
  String get payerType;

  /// No description provided for @selectPayerType.
  ///
  /// In en, this message translates to:
  /// **'Select payer type'**
  String get selectPayerType;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @allMethods.
  ///
  /// In en, this message translates to:
  /// **'All Methods'**
  String get allMethods;

  /// No description provided for @finalPayment.
  ///
  /// In en, this message translates to:
  /// **'Final Payment'**
  String get finalPayment;

  /// No description provided for @selectFinalPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Select final payment status'**
  String get selectFinalPaymentStatus;

  /// No description provided for @finalOnly.
  ///
  /// In en, this message translates to:
  /// **'Final Only'**
  String get finalOnly;

  /// No description provided for @partialOnly.
  ///
  /// In en, this message translates to:
  /// **'Partial Only'**
  String get partialOnly;

  /// No description provided for @hasReceipt.
  ///
  /// In en, this message translates to:
  /// **'Has Receipt'**
  String get hasReceipt;

  /// No description provided for @selectReceiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Select receipt status'**
  String get selectReceiptStatus;

  /// No description provided for @withReceipt.
  ///
  /// In en, this message translates to:
  /// **'With Receipt'**
  String get withReceipt;

  /// No description provided for @withoutReceipt.
  ///
  /// In en, this message translates to:
  /// **'Without Receipt'**
  String get withoutReceipt;

  /// No description provided for @selectVisibility.
  ///
  /// In en, this message translates to:
  /// **'Select visibility'**
  String get selectVisibility;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @activeOnly.
  ///
  /// In en, this message translates to:
  /// **'Active Only'**
  String get activeOnly;

  /// No description provided for @paymentDateFrom.
  ///
  /// In en, this message translates to:
  /// **'Payment Date From'**
  String get paymentDateFrom;

  /// No description provided for @paymentDateTo.
  ///
  /// In en, this message translates to:
  /// **'Payment Date To'**
  String get paymentDateTo;

  /// No description provided for @paymentMonthFrom.
  ///
  /// In en, this message translates to:
  /// **'Payment Month From'**
  String get paymentMonthFrom;

  /// No description provided for @paymentMonthTo.
  ///
  /// In en, this message translates to:
  /// **'Payment Month To'**
  String get paymentMonthTo;

  /// No description provided for @amountRangePkr.
  ///
  /// In en, this message translates to:
  /// **'Amount Range (PKR)'**
  String get amountRangePkr;

  /// No description provided for @minimumAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum Amount'**
  String get minimumAmount;

  /// No description provided for @maximumAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum Amount'**
  String get maximumAmount;

  /// No description provided for @selectSortField.
  ///
  /// In en, this message translates to:
  /// **'Select sort field'**
  String get selectSortField;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @laborName.
  ///
  /// In en, this message translates to:
  /// **'Labor Name'**
  String get laborName;

  /// No description provided for @selectSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Select sort order'**
  String get selectSortOrder;

  /// No description provided for @receiptImage.
  ///
  /// In en, this message translates to:
  /// **'Receipt Image'**
  String get receiptImage;

  /// No description provided for @paymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get paymentReceipt;

  /// No description provided for @baseAmount.
  ///
  /// In en, this message translates to:
  /// **'Base Amount'**
  String get baseAmount;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @deduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get deduction;

  /// No description provided for @noReceiptAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Receipt Available'**
  String get noReceiptAvailable;

  /// No description provided for @noReceiptAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'No receipt available. Add one for better records.'**
  String get noReceiptAvailableShort;

  /// No description provided for @noReceiptAvailableLong.
  ///
  /// In en, this message translates to:
  /// **'No receipt image was uploaded for this payment. Consider adding a receipt for better record keeping.'**
  String get noReceiptAvailableLong;

  /// No description provided for @addReceiptImage.
  ///
  /// In en, this message translates to:
  /// **'Add Receipt Image'**
  String get addReceiptImage;

  /// No description provided for @receiptUploadedSaveToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Receipt uploaded! Please save the payment to update.'**
  String get receiptUploadedSaveToUpdate;

  /// No description provided for @paymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment Info'**
  String get paymentInfo;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceipt;

  /// No description provided for @addReceipt.
  ///
  /// In en, this message translates to:
  /// **'Add Receipt'**
  String get addReceipt;

  /// No description provided for @noPaymentRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No Payment Records Found'**
  String get noPaymentRecordsFound;

  /// No description provided for @startByAddingFirstPaymentRecord.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first payment record to track labor payments efficiently'**
  String get startByAddingFirstPaymentRecord;

  /// No description provided for @addFirstPayment.
  ///
  /// In en, this message translates to:
  /// **'Add First Payment'**
  String get addFirstPayment;

  /// No description provided for @failedToLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Payments'**
  String get failedToLoadPayments;

  /// No description provided for @noPaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No Payments Found'**
  String get noPaymentsFound;

  /// No description provided for @startByAddingFirstPaymentToTrack.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first payment record to track your transactions effectively'**
  String get startByAddingFirstPaymentToTrack;

  /// No description provided for @withBonus.
  ///
  /// In en, this message translates to:
  /// **'With Bonus'**
  String get withBonus;

  /// No description provided for @withDeduction.
  ///
  /// In en, this message translates to:
  /// **'With Deduction'**
  String get withDeduction;

  /// No description provided for @regularPayment.
  ///
  /// In en, this message translates to:
  /// **'Regular Payment'**
  String get regularPayment;

  /// No description provided for @viewPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'View Payment Details'**
  String get viewPaymentDetails;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @paymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInformation;

  /// No description provided for @payerInformation.
  ///
  /// In en, this message translates to:
  /// **'Payer Information'**
  String get payerInformation;

  /// No description provided for @payerId.
  ///
  /// In en, this message translates to:
  /// **'Payer ID'**
  String get payerId;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @saleId.
  ///
  /// In en, this message translates to:
  /// **'Sale ID'**
  String get saleId;

  /// No description provided for @isFinalPayment.
  ///
  /// In en, this message translates to:
  /// **'Is Final Payment'**
  String get isFinalPayment;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @systemInformation.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInformation;

  /// No description provided for @amountIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountIsRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @paymentMethodIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Payment method is required'**
  String get paymentMethodIsRequired;

  /// No description provided for @payerTypeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Payer type is required'**
  String get payerTypeIsRequired;

  /// No description provided for @receiptAvailable.
  ///
  /// In en, this message translates to:
  /// **'Receipt Available'**
  String get receiptAvailable;

  /// No description provided for @failedToUpdatePayment.
  ///
  /// In en, this message translates to:
  /// **'Failed to update payment'**
  String get failedToUpdatePayment;

  /// No description provided for @errorUpdatingPayment.
  ///
  /// In en, this message translates to:
  /// **'Error updating payment'**
  String get errorUpdatingPayment;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @viewPaymentDetailsAndReceipt.
  ///
  /// In en, this message translates to:
  /// **'View payment details and receipt'**
  String get viewPaymentDetailsAndReceipt;

  /// No description provided for @addReceiptForThisPayment.
  ///
  /// In en, this message translates to:
  /// **'Add receipt for this payment'**
  String get addReceiptForThisPayment;

  /// No description provided for @laborRole.
  ///
  /// In en, this message translates to:
  /// **'Labor Role'**
  String get laborRole;

  /// No description provided for @laborPhone.
  ///
  /// In en, this message translates to:
  /// **'Labor Phone'**
  String get laborPhone;

  /// No description provided for @paymentDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted successfully!'**
  String get paymentDeletedSuccessfully;

  /// No description provided for @deletePayment.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment'**
  String get deletePayment;

  /// No description provided for @deletePaymentRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment Record'**
  String get deletePaymentRecord;

  /// No description provided for @areYouSureDeletePayment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payment?'**
  String get areYouSureDeletePayment;

  /// No description provided for @areYouAbsolutelySureDeletePayment.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this payment record?'**
  String get areYouAbsolutelySureDeletePayment;

  /// No description provided for @thisWillPermanentlyDeletePayment.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the payment record.'**
  String get thisWillPermanentlyDeletePayment;

  /// No description provided for @thisWillPermanentlyDeletePaymentLong.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the payment record and all associated data. This action cannot be undone.'**
  String get thisWillPermanentlyDeletePaymentLong;

  /// No description provided for @failedToDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get failedToDeleteProduct;

  /// No description provided for @productDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Product deleted permanently!'**
  String get productDeletedPermanently;

  /// No description provided for @productDeactivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deactivated successfully!'**
  String get productDeactivatedSuccessfully;

  /// No description provided for @productCanBeRestoredLater.
  ///
  /// In en, this message translates to:
  /// **'Product can be restored later'**
  String get productCanBeRestoredLater;

  /// No description provided for @completelyRemovesFromDatabase.
  ///
  /// In en, this message translates to:
  /// **'Completely removes from database'**
  String get completelyRemovesFromDatabase;

  /// No description provided for @hidesButCanBeRestored.
  ///
  /// In en, this message translates to:
  /// **'Hides but can be restored'**
  String get hidesButCanBeRestored;

  /// No description provided for @totalInventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Total Inventory Value'**
  String get totalInventoryValue;

  /// No description provided for @iUnderstandPermanentDelete.
  ///
  /// In en, this message translates to:
  /// **'I understand this will permanently delete the product and cannot be undone'**
  String get iUnderstandPermanentDelete;

  /// No description provided for @iUnderstandDeactivate.
  ///
  /// In en, this message translates to:
  /// **'I understand this will deactivate the product'**
  String get iUnderstandDeactivate;

  /// No description provided for @deactivateProduct.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Product'**
  String get deactivateProduct;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Order'**
  String get editOrder;

  /// No description provided for @updateOrderInformation.
  ///
  /// In en, this message translates to:
  /// **'Update order information'**
  String get updateOrderInformation;

  /// No description provided for @orderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully!'**
  String get orderUpdatedSuccessfully;

  /// No description provided for @orderUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Order Update Failed'**
  String get orderUpdateFailed;

  /// No description provided for @invalidStatusTransition.
  ///
  /// In en, this message translates to:
  /// **'Invalid Status Transition'**
  String get invalidStatusTransition;

  /// No description provided for @cannotChangeStatusFrom.
  ///
  /// In en, this message translates to:
  /// **'You cannot change the status from'**
  String get cannotChangeStatusFrom;

  /// No description provided for @validNextStatusesAre.
  ///
  /// In en, this message translates to:
  /// **'Valid next statuses are'**
  String get validNextStatusesAre;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @serverErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again or contact support.'**
  String get serverErrorOccurred;

  /// No description provided for @invalidStatusSelected.
  ///
  /// In en, this message translates to:
  /// **'Invalid status selected. Please choose a valid status.'**
  String get invalidStatusSelected;

  /// No description provided for @invalidDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format. Please select a valid delivery date.'**
  String get invalidDateFormat;

  /// No description provided for @deliveryDateCannotBeBeforeOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery date cannot be before the order date.'**
  String get deliveryDateCannotBeBeforeOrderDate;

  /// No description provided for @advancePaymentCannotExceedTotal.
  ///
  /// In en, this message translates to:
  /// **'Advance payment cannot exceed the total order amount.'**
  String get advancePaymentCannotExceedTotal;

  /// No description provided for @orderCannotBeModified.
  ///
  /// In en, this message translates to:
  /// **'This order cannot be modified in its current status.'**
  String get orderCannotBeModified;

  /// No description provided for @orderCannotHaveStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'This order cannot have its status changed.'**
  String get orderCannotHaveStatusChanged;

  /// No description provided for @invalidStatusTransitionFrom.
  ///
  /// In en, this message translates to:
  /// **'Invalid status transition. From'**
  String get invalidStatusTransitionFrom;

  /// No description provided for @youCanOnlyChangeTo.
  ///
  /// In en, this message translates to:
  /// **'you can only change to'**
  String get youCanOnlyChangeTo;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @customerSince.
  ///
  /// In en, this message translates to:
  /// **'Customer since'**
  String get customerSince;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderDescription.
  ///
  /// In en, this message translates to:
  /// **'Order Description'**
  String get orderDescription;

  /// No description provided for @describeOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Describe the order details (e.g., products, specifications)'**
  String get describeOrderDetails;

  /// No description provided for @pleaseEnterOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter order description'**
  String get pleaseEnterOrderDescription;

  /// No description provided for @descriptionMustBeAtLeast10Characters.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters'**
  String get descriptionMustBeAtLeast10Characters;

  /// No description provided for @descriptionMustBeLessThan500Characters.
  ///
  /// In en, this message translates to:
  /// **'Description must be less than 500 characters'**
  String get descriptionMustBeLessThan500Characters;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @validNextStatuses.
  ///
  /// In en, this message translates to:
  /// **'Valid next statuses'**
  String get validNextStatuses;

  /// No description provided for @totalAmountPKR.
  ///
  /// In en, this message translates to:
  /// **'Total Amount (PKR)'**
  String get totalAmountPKR;

  /// No description provided for @totalOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Total order amount'**
  String get totalOrderAmount;

  /// No description provided for @advancePaymentPKR.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment (PKR)'**
  String get advancePaymentPKR;

  /// No description provided for @enterAdvancePaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter advance payment amount'**
  String get enterAdvancePaymentAmount;

  /// No description provided for @pleaseEnterAdvancePayment.
  ///
  /// In en, this message translates to:
  /// **'Please enter advance payment'**
  String get pleaseEnterAdvancePayment;

  /// No description provided for @remainingAmountPKR.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount (PKR)'**
  String get remainingAmountPKR;

  /// No description provided for @remainingAmountToBePaid.
  ///
  /// In en, this message translates to:
  /// **'Remaining amount to be paid'**
  String get remainingAmountToBePaid;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @dateWhenOrderWasPlaced.
  ///
  /// In en, this message translates to:
  /// **'Date when order was placed'**
  String get dateWhenOrderWasPlaced;

  /// No description provided for @selectExpectedDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Select Expected Delivery Date'**
  String get selectExpectedDeliveryDate;

  /// No description provided for @expectedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery'**
  String get expectedDelivery;

  /// No description provided for @updateOrder.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get updateOrder;

  /// No description provided for @inProduction.
  ///
  /// In en, this message translates to:
  /// **'In Production'**
  String get inProduction;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @orderItemsManagement.
  ///
  /// In en, this message translates to:
  /// **'Order Items Management'**
  String get orderItemsManagement;

  /// No description provided for @searchOrderItemsByProductDescriptionOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Search order items by product, description, or notes...'**
  String get searchOrderItemsByProductDescriptionOrNotes;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @activeItems.
  ///
  /// In en, this message translates to:
  /// **'Active Items'**
  String get activeItems;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity'**
  String get totalQuantity;

  /// No description provided for @loadingOrderItems.
  ///
  /// In en, this message translates to:
  /// **'Loading order items...'**
  String get loadingOrderItems;

  /// No description provided for @errorLoadingOrderItems.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Order Items'**
  String get errorLoadingOrderItems;

  /// No description provided for @noOrderItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No Order Items Found'**
  String get noOrderItemsFound;

  /// No description provided for @orderDoesntHaveItemsYet.
  ///
  /// In en, this message translates to:
  /// **'This order doesn\'t have any items yet. Add your first order item to get started.'**
  String get orderDoesntHaveItemsYet;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add First Item'**
  String get addFirstItem;

  /// No description provided for @activeSearch.
  ///
  /// In en, this message translates to:
  /// **'Active Search'**
  String get activeSearch;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @orderItemsRefreshedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order items refreshed successfully'**
  String get orderItemsRefreshedSuccessfully;

  /// No description provided for @advancePaymentCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Advance payment cannot be negative'**
  String get advancePaymentCannotBeNegative;

  /// No description provided for @orderID.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderID;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @addItemsToSeeTotal.
  ///
  /// In en, this message translates to:
  /// **'Add items to see total'**
  String get addItemsToSeeTotal;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @errorDisplayingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error displaying order'**
  String get errorDisplayingOrder;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @startProduction.
  ///
  /// In en, this message translates to:
  /// **'Start Production'**
  String get startProduction;

  /// No description provided for @markAsReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markAsReady;

  /// No description provided for @markAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markAsDelivered;

  /// No description provided for @changeOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Order Status'**
  String get changeOrderStatus;

  /// No description provided for @areYouSureChangeStatusTo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change the status of order'**
  String get areYouSureChangeStatusTo;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// No description provided for @failedToUpdateOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update order status'**
  String get failedToUpdateOrderStatus;

  /// No description provided for @orderStatusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Order status updated to'**
  String get orderStatusUpdatedTo;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'successfully'**
  String get successfully;

  /// No description provided for @deactivateOrder.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Order'**
  String get deactivateOrder;

  /// No description provided for @areYouSureDeactivateOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate order'**
  String get areYouSureDeactivateOrder;

  /// No description provided for @thisActionCanBeReversed.
  ///
  /// In en, this message translates to:
  /// **'This action can be reversed.'**
  String get thisActionCanBeReversed;

  /// No description provided for @failedToDeactivateOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to deactivate order'**
  String get failedToDeactivateOrder;

  /// No description provided for @orderDeactivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order deactivated successfully'**
  String get orderDeactivatedSuccessfully;

  /// No description provided for @restoreOrder.
  ///
  /// In en, this message translates to:
  /// **'Restore Order'**
  String get restoreOrder;

  /// No description provided for @areYouSureRestoreOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore order'**
  String get areYouSureRestoreOrder;

  /// No description provided for @failedToRestoreOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore order'**
  String get failedToRestoreOrder;

  /// No description provided for @orderRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order restored successfully'**
  String get orderRestoredSuccessfully;

  /// No description provided for @failedToLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Orders'**
  String get failedToLoadOrders;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No Orders Found'**
  String get noOrdersFound;

  /// No description provided for @startManagingCustomerOrders.
  ///
  /// In en, this message translates to:
  /// **'Start managing your customer orders by creating your first order. Track deliveries, manage payments, and keep customers informed.'**
  String get startManagingCustomerOrders;

  /// No description provided for @createNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Create New Order'**
  String get createNewOrder;

  /// No description provided for @noOrdersMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No orders match your search criteria'**
  String get noOrdersMatchSearch;

  /// No description provided for @tryAdjustingSearchTerms.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or filters to find what you\'re looking for.'**
  String get tryAdjustingSearchTerms;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @selectProductForOrder.
  ///
  /// In en, this message translates to:
  /// **'Select Product for Order'**
  String get selectProductForOrder;

  /// No description provided for @chooseProductToAddToOrder.
  ///
  /// In en, this message translates to:
  /// **'Choose a product to add to the order'**
  String get chooseProductToAddToOrder;

  /// No description provided for @pleaseSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Please select a product'**
  String get pleaseSelectProduct;

  /// No description provided for @searchProductsShort.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProductsShort;

  /// No description provided for @searchProductsByNameFabricOrColor.
  ///
  /// In en, this message translates to:
  /// **'Search products by name, fabric, or color...'**
  String get searchProductsByNameFabricOrColor;

  /// No description provided for @availableProducts.
  ///
  /// In en, this message translates to:
  /// **'Available Products'**
  String get availableProducts;

  /// No description provided for @tryAdjustingYourSearchTerms.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get tryAdjustingYourSearchTerms;

  /// No description provided for @selectedProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Selected Product Details'**
  String get selectedProductDetails;

  /// No description provided for @customizationNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Customization Notes (Optional)'**
  String get customizationNotesOptional;

  /// No description provided for @specialInstructionsOrCustomizationNotes.
  ///
  /// In en, this message translates to:
  /// **'Special instructions or customization notes'**
  String get specialInstructionsOrCustomizationNotes;

  /// No description provided for @notesMustBeLessThan500Characters.
  ///
  /// In en, this message translates to:
  /// **'Notes must be less than 500 characters'**
  String get notesMustBeLessThan500Characters;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @quantityMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than 0'**
  String get quantityMustBeGreaterThanZero;

  /// No description provided for @only.
  ///
  /// In en, this message translates to:
  /// **'Only'**
  String get only;

  /// No description provided for @unitsAvailable.
  ///
  /// In en, this message translates to:
  /// **'units available'**
  String get unitsAvailable;

  /// No description provided for @addToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add to Order'**
  String get addToOrder;

  /// No description provided for @viewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get viewOrder;

  /// No description provided for @completeOrderInformation.
  ///
  /// In en, this message translates to:
  /// **'Complete order information'**
  String get completeOrderInformation;

  /// No description provided for @orderInformation.
  ///
  /// In en, this message translates to:
  /// **'Order Information'**
  String get orderInformation;

  /// No description provided for @paymentPercentage.
  ///
  /// In en, this message translates to:
  /// **'Payment Percentage'**
  String get paymentPercentage;

  /// No description provided for @orderItemsManagedSeparately.
  ///
  /// In en, this message translates to:
  /// **'Order items are managed separately. Use the Order Items module to view and manage products in this order.'**
  String get orderItemsManagedSeparately;

  /// No description provided for @daysSinceOrdered.
  ///
  /// In en, this message translates to:
  /// **'Days Since Ordered'**
  String get daysSinceOrdered;

  /// No description provided for @daysUntilDelivery.
  ///
  /// In en, this message translates to:
  /// **'Days Until Delivery'**
  String get daysUntilDelivery;

  /// No description provided for @isOverdue.
  ///
  /// In en, this message translates to:
  /// **'Is Overdue'**
  String get isOverdue;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @conversionStatus.
  ///
  /// In en, this message translates to:
  /// **'Conversion Status'**
  String get conversionStatus;

  /// No description provided for @convertedSalesAmount.
  ///
  /// In en, this message translates to:
  /// **'Converted Sales Amount'**
  String get convertedSalesAmount;

  /// No description provided for @conversionDate.
  ///
  /// In en, this message translates to:
  /// **'Conversion Date'**
  String get conversionDate;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Is Active'**
  String get isActive;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @editLabor.
  ///
  /// In en, this message translates to:
  /// **'Edit Labor'**
  String get editLabor;

  /// No description provided for @editLaborDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Labor Details'**
  String get editLaborDetails;

  /// No description provided for @updateWorkerInformation.
  ///
  /// In en, this message translates to:
  /// **'Update worker information'**
  String get updateWorkerInformation;

  /// No description provided for @laborUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Labor updated successfully!'**
  String get laborUpdatedSuccessfully;

  /// No description provided for @failedToUpdateLabor.
  ///
  /// In en, this message translates to:
  /// **'Failed to update labor'**
  String get failedToUpdateLabor;

  /// No description provided for @errorUpdatingLabor.
  ///
  /// In en, this message translates to:
  /// **'Error updating labor'**
  String get errorUpdatingLabor;

  /// No description provided for @updateLabor.
  ///
  /// In en, this message translates to:
  /// **'Update Labor'**
  String get updateLabor;

  /// No description provided for @enterWorkerFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter worker\'s full name'**
  String get enterWorkerFullName;

  /// No description provided for @enterCNIC.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC'**
  String get enterCNIC;

  /// No description provided for @enterCNICFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter CNIC (e.g., 42101-1234567-1)'**
  String get enterCNICFormat;

  /// No description provided for @pleaseEnterCNIC.
  ///
  /// In en, this message translates to:
  /// **'Please enter a CNIC'**
  String get pleaseEnterCNIC;

  /// No description provided for @pleaseEnterValidCNIC.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid CNIC (XXXXX-XXXXXXX-X)'**
  String get pleaseEnterValidCNIC;

  /// No description provided for @enterMonthlySalaryInPKR.
  ///
  /// In en, this message translates to:
  /// **'Enter monthly salary in PKR'**
  String get enterMonthlySalaryInPKR;

  /// No description provided for @laborCanBeRestoredLater.
  ///
  /// In en, this message translates to:
  /// **'Labor can be restored later'**
  String get laborCanBeRestoredLater;

  /// No description provided for @laborID.
  ///
  /// In en, this message translates to:
  /// **'Labor ID'**
  String get laborID;

  /// No description provided for @iUnderstandActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'I understand this action cannot be undone and will affect related records'**
  String get iUnderstandActionCannotBeUndone;

  /// No description provided for @typeLaborNameToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type the labor name to confirm permanent deletion:'**
  String get typeLaborNameToConfirm;

  /// No description provided for @laborDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Labor deleted permanently!'**
  String get laborDeletedPermanently;

  /// No description provided for @failedToDeleteLabor.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete labor'**
  String get failedToDeleteLabor;

  /// No description provided for @pleaseConfirmYouUnderstandThisAction.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that you understand this action'**
  String get pleaseConfirmYouUnderstandThisAction;

  /// No description provided for @pleaseConfirmYouUnderstandConsequences.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that you understand the consequences of permanent deletion'**
  String get pleaseConfirmYouUnderstandConsequences;

  /// No description provided for @pleaseTypeLaborNameExactly.
  ///
  /// In en, this message translates to:
  /// **'Please type the labor name exactly to confirm permanent deletion'**
  String get pleaseTypeLaborNameExactly;

  /// No description provided for @pleaseCompleteAllConfirmationSteps.
  ///
  /// In en, this message translates to:
  /// **'Please complete all confirmation steps'**
  String get pleaseCompleteAllConfirmationSteps;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @pleaseTryAgainOrContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Please try again later or contact support.'**
  String get pleaseTryAgainOrContactSupport;

  /// No description provided for @failedToDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category'**
  String get failedToDeleteCategory;

  /// No description provided for @categoryDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Category deleted permanently!'**
  String get categoryDeletedPermanently;

  /// No description provided for @categoryDeactivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category deactivated successfully!'**
  String get categoryDeactivatedSuccessfully;

  /// No description provided for @deactivateCategory.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Category'**
  String get deactivateCategory;

  /// No description provided for @categoryCanBeRestoredLater.
  ///
  /// In en, this message translates to:
  /// **'Category can be restored later'**
  String get categoryCanBeRestoredLater;

  /// No description provided for @iUnderstandPermanentDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'I understand this will permanently delete the category and cannot be undone'**
  String get iUnderstandPermanentDeleteCategory;

  /// No description provided for @iUnderstandDeactivateCategory.
  ///
  /// In en, this message translates to:
  /// **'I understand this will deactivate the category'**
  String get iUnderstandDeactivateCategory;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully!'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @updateCategoryInformation.
  ///
  /// In en, this message translates to:
  /// **'Update category information'**
  String get updateCategoryInformation;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @enterCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name (e.g., Bridal Dresses)'**
  String get enterCategoryNameHint;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @categoryNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Category name must be at least 2 characters'**
  String get categoryNameMinLength;

  /// No description provided for @categoryNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Category name must be less than 50 characters'**
  String get categoryNameMaxLength;

  /// No description provided for @enterDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get enterDescriptionOptional;

  /// No description provided for @enterCategoryDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter category description (optional)'**
  String get enterCategoryDescriptionOptional;

  /// No description provided for @descriptionMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be less than 200 characters'**
  String get descriptionMaxLength;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get updateCategory;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products, orders, customers...'**
  String get searchPlaceholder;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @lastSixMonthsPerformance.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months performance'**
  String get lastSixMonthsPerformance;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get sixMonths;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @activeProducts.
  ///
  /// In en, this message translates to:
  /// **'Active Products'**
  String get activeProducts;

  /// No description provided for @dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get dailySales;

  /// No description provided for @monthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales'**
  String get monthlySales;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @addNewExpense.
  ///
  /// In en, this message translates to:
  /// **'Add New Expense'**
  String get addNewExpense;

  /// No description provided for @recordNewExpenseEntry.
  ///
  /// In en, this message translates to:
  /// **'Record a new expense entry'**
  String get recordNewExpenseEntry;

  /// No description provided for @enterExpense.
  ///
  /// In en, this message translates to:
  /// **'Enter expense'**
  String get enterExpense;

  /// No description provided for @enterExpenseTypeCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter expense type/category'**
  String get enterExpenseTypeCategory;

  /// No description provided for @pleaseEnterExpenseType.
  ///
  /// In en, this message translates to:
  /// **'Please enter expense type'**
  String get pleaseEnterExpenseType;

  /// No description provided for @expenseMinLength.
  ///
  /// In en, this message translates to:
  /// **'Expense must be at least 2 characters'**
  String get expenseMinLength;

  /// No description provided for @enterExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter expense description/details'**
  String get enterExpenseDescription;

  /// No description provided for @descriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 5 characters'**
  String get descriptionMinLength;

  /// No description provided for @enterAmountPKR.
  ///
  /// In en, this message translates to:
  /// **'Enter amount (PKR)'**
  String get enterAmountPKR;

  /// No description provided for @withdrawalBy.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal By'**
  String get withdrawalBy;

  /// No description provided for @selectWhoMadeWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Select who made the withdrawal'**
  String get selectWhoMadeWithdrawal;

  /// No description provided for @pleaseSelectWhoMadeWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Please select who made the withdrawal'**
  String get pleaseSelectWhoMadeWithdrawal;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateTime;

  /// No description provided for @selectExpenseDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Expense Date & Time'**
  String get selectExpenseDateTime;

  /// No description provided for @expenseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully!'**
  String get expenseAddedSuccessfully;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense Record'**
  String get deleteExpenseRecord;

  /// No description provided for @confirmDeleteExpenseShort.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense record?'**
  String get confirmDeleteExpenseShort;

  /// No description provided for @confirmDeleteExpenseLong.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete this expense record?'**
  String get confirmDeleteExpenseLong;

  /// No description provided for @deleteWarningShort.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the expense record.'**
  String get deleteWarningShort;

  /// No description provided for @deleteWarningLong.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the expense record and all associated data. This action cannot be undone.'**
  String get deleteWarningLong;

  /// No description provided for @expenseDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully!'**
  String get expenseDeletedSuccessfully;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @editExpenseRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense Record'**
  String get editExpenseRecord;

  /// No description provided for @updateExpenseInformation.
  ///
  /// In en, this message translates to:
  /// **'Update expense information'**
  String get updateExpenseInformation;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @expenseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully!'**
  String get expenseUpdatedSuccessfully;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and conditions'**
  String get pleaseAcceptTerms;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome to Al Noor Fashion.'**
  String get accountCreatedSuccessfully;

  /// No description provided for @registrationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please check the details below.'**
  String get registrationFailedMessage;

  /// No description provided for @joinOur.
  ///
  /// In en, this message translates to:
  /// **'Join Our'**
  String get joinOur;

  /// No description provided for @premiumFamily.
  ///
  /// In en, this message translates to:
  /// **'Premium Family'**
  String get premiumFamily;

  /// No description provided for @signupWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Begin your journey with us and discover the epitome of luxury fashion. \nCreate your account to access exclusive collections and personalized service.'**
  String get signupWelcomeMessage;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinExclusiveCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our exclusive community'**
  String get joinExclusiveCommunity;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @createStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createStrongPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMustContain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase, lowercase, and number'**
  String get passwordMustContain;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registrationFailed;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @filterExpenseRecords.
  ///
  /// In en, this message translates to:
  /// **'Filter Expense Records'**
  String get filterExpenseRecords;

  /// No description provided for @refineExpenseList.
  ///
  /// In en, this message translates to:
  /// **'Refine your expense list with filters'**
  String get refineExpenseList;

  /// No description provided for @searchExpenseRecords.
  ///
  /// In en, this message translates to:
  /// **'Search Expense Records'**
  String get searchExpenseRecords;

  /// No description provided for @searchByExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'Search by expense name, description, or amount'**
  String get searchByExpenseHint;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @enterExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter expense category'**
  String get enterExpenseCategory;

  /// No description provided for @selectWithdrawalAuthority.
  ///
  /// In en, this message translates to:
  /// **'Select Withdrawal Authority'**
  String get selectWithdrawalAuthority;

  /// No description provided for @clearWithdrawalFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Withdrawal Filter'**
  String get clearWithdrawalFilter;

  /// No description provided for @expenseId.
  ///
  /// In en, this message translates to:
  /// **'Expense ID'**
  String get expenseId;

  /// No description provided for @noExpenseRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No Expense Records Found'**
  String get noExpenseRecordsFound;

  /// No description provided for @startAddingFirstExpense.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first expense record to track business spending'**
  String get startAddingFirstExpense;

  /// No description provided for @addFirstExpense.
  ///
  /// In en, this message translates to:
  /// **'Add First Expense'**
  String get addFirstExpense;

  /// No description provided for @errorLoadingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Error loading expenses'**
  String get errorLoadingExpenses;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later or check your internet connection.'**
  String get pleaseTryAgainLater;

  /// **'Retry Loading'**
  String get retryLoading;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Application'**
  String get aboutApp;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDarkThemeForApplication.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme for the application'**
  String get enableDarkThemeForApplication;

  /// No description provided for @alNoorFashionPOS.
  ///
  /// In en, this message translates to:
  /// **'Al Noor Fashion POS'**
  String get alNoorFashionPOS;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @aPremiumPointOfSaleSolution.
  ///
  /// In en, this message translates to:
  /// **'A premium Point of Sale solution designed for high-end fashion boutiques and tailoring services.'**
  String get aPremiumPointOfSaleSolution;
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
