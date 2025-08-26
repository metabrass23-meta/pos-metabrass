class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';

  static const String categories = '/categories/';
  static const String createCategory = '/categories/create/';

  static String getCategoryById(String id) => '/categories/$id/';
  static String updateCategory(String id) => '/categories/$id/update/';
  static String deleteCategory(String id) => '/categories/$id/delete/';
  static String softDeleteCategory(String id) => '/categories/$id/soft-delete/';
  static String restoreCategory(String id) => '/categories/$id/restore/';

  static const String products = '/products/';
  static const String createProduct = '/products/create/';

  static String getProductById(String id) => '/products/$id/';
  static String updateProduct(String id) => '/products/$id/update/';
  static String deleteProduct(String id) => '/products/$id/delete/';
  static String softDeleteProduct(String id) => '/products/$id/soft-delete/';
  static String restoreProduct(String id) => '/products/$id/restore/';

  static const String searchProducts = '/products/search/';
  static String productsByCategory(String categoryId) => '/products/category/$categoryId/';
  static const String lowStockProducts = '/products/low-stock/';
  static const String productStatistics = '/products/statistics/';

  static String updateProductQuantity(String id) => '/products/$id/quantity/';
  static const String bulkUpdateQuantities = '/products/bulk-update-quantities/';
  static String duplicateProduct(String id) => '/products/$id/duplicate/';

  static const String customers = '/customers/';
  static const String createCustomer = '/customers/create/';

  static String getCustomerById(String id) => '/customers/$id/';
  static String updateCustomer(String id) => '/customers/$id/update/';
  static String deleteCustomer(String id) => '/customers/$id/delete/';
  static String softDeleteCustomer(String id) => '/customers/$id/soft-delete/';
  static String restoreCustomer(String id) => '/customers/$id/restore/';

  static const String searchCustomers = '/customers/search/';
  static String customersByStatus(String status) => '/customers/status/$status/';
  static String customersByType(String type) => '/customers/type/$type/';
  static String customersByCity(String city) => '/customers/city/$city/';
  static String customersByCountry(String country) => '/customers/country/$country/';

  static const String pakistaniCustomers = '/customers/pakistani/';
  static const String internationalCustomers = '/customers/international/';
  static const String newCustomers = '/customers/new/';
  static const String recentCustomers = '/customers/recent/';

  static const String customerStatistics = '/customers/statistics/';

  static String updateCustomerContact(String id) => '/customers/$id/contact/';
  static String verifyCustomerContact(String id) => '/customers/$id/verify/';

  static String updateCustomerActivity(String id) => '/customers/$id/activity/';

  static const String bulkCustomerActions = '/customers/bulk-actions/';

  static String duplicateCustomer(String id) => '/customers/$id/duplicate/';

  static String customerOrders(String id) => '/customers/$id/orders/';
  static String customerSales(String id) => '/customers/$id/sales/';

  static const String vendors = '/vendors/';
  static const String createVendor = '/vendors/create/';

  static String getVendorById(String id) => '/vendors/$id/';
  static String updateVendor(String id) => '/vendors/$id/update/';
  static String deleteVendor(String id) => '/vendors/$id/delete/';

  static String softDeleteVendor(String id) => '/vendors/$id/soft-delete/';
  static String restoreVendor(String id) => '/vendors/$id/restore/';

  static const String searchVendors = '/vendors/search/';
  static String vendorsByCity(String cityName) => '/vendors/city/$cityName/';
  static String vendorsByArea(String areaName) => '/vendors/area/$areaName/';

  static const String newVendors = '/vendors/new/';
  static const String recentVendors = '/vendors/recent/';

  static const String vendorStatistics = '/vendors/statistics/';

  static String updateVendorContact(String id) => '/vendors/$id/contact/update/';

  static const String bulkVendorActions = '/vendors/bulk-actions/';

  static String duplicateVendor(String id) => '/vendors/$id/duplicate/';

  static String vendorPayments(String id) => '/vendors/$id/payments/';

  static const String labors = '/labors/';
  static const String createLabor = '/labors/create/';

  static String getLaborById(String id) => '/labors/$id/';
  static String updateLabor(String id) => '/labors/$id/update/';
  static String deleteLabor(String id) => '/labors/$id/delete/';

  static String softDeleteLabor(String id) => '/labors/$id/soft-delete/';
  static String restoreLabor(String id) => '/labors/$id/restore/';

  static const String searchLabors = '/labors/search/';
  static String laborsByCity(String cityName) => '/labors/city/$cityName/';
  static String laborsByArea(String areaName) => '/labors/area/$areaName/';
  static String laborsByDesignation(String designationName) => '/labors/designation/$designationName/';
  static String laborsByCaste(String casteName) => '/labors/caste/$casteName/';
  static String laborsByGender(String gender) => '/labors/gender/$gender/';
  static const String laborsBySalaryRange = '/labors/salary-range/';
  static const String laborsByAgeRange = '/labors/age-range/';

  static const String newLabors = '/labors/new/';
  static const String recentLabors = '/labors/recent/';

  static const String laborStatistics = '/labors/statistics/';
  static const String laborSalaryReport = '/labors/salary-report/';
  static const String laborDemographicsReport = '/labors/demographics-report/';
  static const String laborExperienceReport = '/labors/experience-report/';

  static String updateLaborContact(String id) => '/labors/$id/contact/update/';
  static String updateLaborSalary(String id) => '/labors/$id/salary/update/';

  static const String bulkLaborActions = '/labors/bulk-actions/';

  static String duplicateLabor(String id) => '/labors/$id/duplicate/';

  static String laborPayments(String id) => '/labors/$id/payments/';

  static String getSearchLabors() => searchLabors;
  static String getLaborsBySalaryRange() => laborsBySalaryRange;
  static String getLaborsByAgeRange() => laborsByAgeRange;
  static String getNewLabors() => newLabors;
  static String getRecentLabors() => recentLabors;
  static String getLaborStatistics() => laborStatistics;
  static String getLaborSalaryReport() => laborSalaryReport;
  static String getLaborDemographicsReport() => laborDemographicsReport;
  static String getLaborExperienceReport() => laborExperienceReport;
  static String getBulkLaborActions() => bulkLaborActions;

  static const String zakats = '/zakats/';
  static const String createZakat = '/zakats/';

  static String getZakatById(String id) => '/zakats/$id/';
  static String updateZakat(String id) => '/zakats/$id/update/';
  static String deleteZakat(String id) => '/zakats/$id/delete/';

  static const String searchZakats = '/zakats/search/';
  static String zakatsByBeneficiary(String beneficiaryName) => '/zakats/by-beneficiary/$beneficiaryName/';
  static String zakatsByAuthority(String authority) => '/zakats/by-authority/$authority/';
  static const String zakatsByDateRange = '/zakats/by-date-range/';

  static const String zakatStatistics = '/zakats/statistics/';
  static const String zakatMonthlySummary = '/zakats/monthly-summary/';
  static const String zakatBeneficiaryReport = '/zakats/beneficiary-report/';
  static const String recentZakats = '/zakats/recent/';

  static const String bulkZakatActions = '/zakats/bulk-actions/';

  static String duplicateZakat(String id) => '/zakats/$id/duplicate/';
  static String verifyZakat(String id) => '/zakats/$id/verify/';
  static String unverifyZakat(String id) => '/zakats/$id/unverify/';
  static String archiveZakat(String id) => '/zakats/$id/archive/';
  static String unarchiveZakat(String id) => '/zakats/$id/unarchive/';

  static const String orders = '/orders/';
  static const String createOrder = '/orders/create/';

  static String getOrderById(String id) => '/orders/$id/';
  static String updateOrder(String id) => '/orders/$id/update/';
  static String deleteOrder(String id) => '/orders/$id/delete/';
  static String softDeleteOrder(String id) => '/orders/$id/soft-delete/';
  static String restoreOrder(String id) => '/orders/$id/restore/';

  static const String searchOrders = '/orders/search/';
  static String ordersByStatus(String status) => '/orders/status/$status/';
  static String ordersByCustomer(String customerId) => '/orders/customer/$customerId/';

  static const String pendingOrders = '/orders/pending/';
  static const String overdueOrders = '/orders/overdue/';
  static const String unpaidOrders = '/orders/unpaid/';
  static const String recentOrders = '/orders/recent/';
  static const String dueTodayOrders = '/orders/due-today/';

  static const String orderStatistics = '/orders/statistics/';

  static String addOrderPayment(String id) => '/orders/$id/payment/';

  static String updateOrderStatus(String id) => '/orders/$id/status/';
  static const String bulkOrderActions = '/orders/bulk-actions/';

  static String recalculateOrderTotals(String id) => '/orders/$id/recalculate/';
  static String updateOrderCustomerInfo(String id) => '/orders/$id/customer-info/';
  static String duplicateOrder(String id) => '/orders/$id/duplicate/';

  static const String orderItems = '/order-items/';
  static const String createOrderItem = '/order-items/create/';

  static String getOrderItemById(String id) => '/order-items/$id/';
  static String updateOrderItem(String id) => '/order-items/$id/update/';
  static String deleteOrderItem(String id) => '/order-items/$id/delete/';
  static String softDeleteOrderItem(String id) => '/order-items/$id/soft-delete/';
  static String restoreOrderItem(String id) => '/order-items/$id/restore/';

  static const String searchOrderItems = '/order-items/search/';
  static String orderItemsByOrder(String orderId) => '/order-items/order/$orderId/';
  static String orderItemsByProduct(String productId) => '/order-items/product/$productId/';

  static const String expenses = '/expenses/';
  static const String createExpense = '/expenses/';

  static String getExpenseById(String id) => '/expenses/$id/';
  static String updateExpense(String id) => '/expenses/$id/update/';
  static String deleteExpense(String id) => '/expenses/$id/delete/';

  static String expensesByAuthority(String authority) => '/expenses/by-authority/$authority/';
  static String expensesByCategory(String category) => '/expenses/by-category/$category/';
  static const String expensesByDateRange = '/expenses/by-date-range/';

  static const String expenseStatistics = '/expenses/statistics/';
  static const String expenseMonthlySummary = '/expenses/monthly-summary/';
  static const String recentExpenses = '/expenses/recent/';

  static const String bulkExpenseActions = '/expenses/bulk-actions/';

  // Advance Payments API endpoints
  static const String advancePayments = '/advance-payments/';
  static const String createAdvancePayment = '/advance-payments/create/';
  static String getAdvancePaymentById(String id) => '/advance-payments/$id/';
  static String updateAdvancePayment(String id) => '/advance-payments/$id/update/';
  static String deleteAdvancePayment(String id) => '/advance-payments/$id/delete/';
  static String softDeleteAdvancePayment(String id) => '/advance-payments/$id/soft-delete/';
  static String restoreAdvancePayment(String id) => '/advance-payments/$id/restore/';
  static const String searchAdvancePayments = '/advance-payments/search/';
  static String paymentsByLabor(String laborId) => '/advance-payments/labor/$laborId/';
  static const String paymentsByDateRange = '/advance-payments/date-range/';
  static const String todayPayments = '/advance-payments/today/';
  static const String recentPayments = '/advance-payments/recent/';
  static const String advancePaymentStatistics = '/advance-payments/statistics/';
  static const String monthlyReport = '/advance-payments/monthly-report/';
  static const String laborAdvanceReport = '/advance-payments/labor-advance-report/';
  static const String bulkAdvancePaymentActions = '/advance-payments/bulk-actions/';
  static const String paymentsWithReceipts = '/advance-payments/with-receipts/';
  static const String paymentsWithoutReceipts = '/advance-payments/without-receipts/';
  static String laborAdvanceSummary(String laborId) => '/advance-payments/labor/$laborId/summary/';

  // Payments API endpoints
  static const String payments = '/payments/';
  static const String createPayment = '/payments/create/';
  static String getPaymentById(String id) => '/payments/$id/';
  static String updatePayment(String id) => '/payments/$id/update/';
  static String deletePayment(String id) => '/payments/$id/delete/';
  static String softDeletePayment(String id) => '/payments/$id/soft-delete/';
  static String restorePayment(String id) => '/payments/$id/restore/';
  static const String searchPayments = '/payments/search/';
  static String paymentsByLaborId(String laborId) => '/payments/by-labor/$laborId/';
  static String paymentsByVendorId(String vendorId) => '/payments/by-vendor/$vendorId/';
  static String paymentsByOrderId(String orderId) => '/payments/by-order/$orderId/';
  static String paymentsBySaleId(String saleId) => '/payments/by-sale/$saleId/';
  static const String paymentDateRange = '/payments/by-date-range/';
  static String paymentsByMethod(String method) => '/payments/by-payment-method/$method/';
  static const String paymentWithReceipts = '/payments/with-receipts/';
  static const String paymentWithoutReceipts = '/payments/without-receipts/';
  static const String paymentRecent = '/payments/recent/';
  static const String paymentToday = '/payments/today/';
  static const String paymentThisMonth = '/payments/this-month/';
  static const String paymentThisYear = '/payments/this-year/';
  static const String paymentStatistics = '/payments/statistics/';
  static String markAsFinalPayment(String id) => '/payments/$id/mark-final/';

  // Payables API endpoints
  static const String payables = '/payables/';
  static const String createPayable = '/payables/create/';
  static String getPayableById(String id) => '/payables/$id/';
  static String updatePayable(String id) => '/payables/$id/update/';
  static String deletePayable(String id) => '/payables/$id/delete/';
  static String softDeletePayable(String id) => '/payables/$id/soft-delete/';
  static String restorePayable(String id) => '/payables/$id/restore/';
  static const String searchPayables = '/payables/search/';
  static String payablesByCreditor(String creditorName) => '/payables/creditor/$creditorName/';
  static String payablesByVendor(String vendorId) => '/payables/vendor/$vendorId/';
  static const String overduePayables = '/payables/overdue/';
  static const String urgentPayables = '/payables/urgent/';
  static const String dueSoonPayables = '/payables/due-soon/';
  static const String recentPayables = '/payables/recent/';
  static const String payableStatistics = '/payables/statistics/';
  static const String paymentSchedule = '/payables/payment-schedule/';
  static const String creditorSummary = '/payables/creditor-summary/';
  static const String bulkPayableActions = '/payables/bulk-actions/';
  static String addPayablePayment(String id) => '/payables/$id/payment/';
  static String updatePayableContact(String id) => '/payables/$id/contact/update/';

  // Profit Loss endpoints
  static const String _profitLossBase = '$baseUrl/profit-loss';

  // Main profit loss endpoints
  static const String calculateProfitLoss = '$_profitLossBase/calculate/';
  static const String profitLossRecords = '$_profitLossBase/records/';
  static const String profitLossSummary = '$_profitLossBase/summary/';
  static const String productProfitability = '$_profitLossBase/product-profitability/';
  static const String profitLossDashboard = '$_profitLossBase/dashboard/';

  // Dynamic endpoints
  static String getProfitLossRecordById(String id) => '$_profitLossBase/records/$id/';

  // Cache keys
  static const String profitLossCacheKey = 'profit_loss_records_cache';
  static const String profitLossSummaryCacheKey = 'profit_loss_summary_cache';
  static const String profitLossDashboardCacheKey = 'profit_loss_dashboard_cache';

  // Cache keys for expenses
  static const String expensesCacheKey = 'cached_expenses';
  static const String expenseStatsCacheKey = 'cached_expense_stats';

  static const String itemsWithCustomization = '/order-items/customized/';

  static const String orderItemStatistics = '/order-items/statistics/';

  static String updateOrderItemQuantity(String id) => '/order-items/$id/quantity/';
  static const String bulkUpdateOrderItems = '/order-items/bulk-update/';

  static String duplicateOrderItem(String id) => '/order-items/$id/duplicate/';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  static const Map<String, String> defaultHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'};

  static Map<String, String> getAuthHeaders(String token) => {...defaultHeaders, 'Authorization': 'Bearer $token'};

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String categoriesCacheKey = 'cached_categories';
  static const String productsCacheKey = 'cached_products';
  static const String productStatsCacheKey = 'cached_product_stats';
  static const String customersCacheKey = 'cached_customers';
  static const String customerStatsCacheKey = 'cached_customer_stats';
  static const String vendorsCacheKey = 'cached_vendors';
  static const String vendorStatsCacheKey = 'cached_vendor_stats';
  static const String laborsCacheKey = 'cached_labors';
  static const String laborStatsCacheKey = 'cached_labor_stats';
  static const String laborSalaryReportCacheKey = 'cached_labor_salary_report';
  static const String laborDemographicsReportCacheKey = 'cached_labor_demographics_report';
  static const String zakatsCacheKey = 'cached_zakats';
  static const String zakatStatsCacheKey = 'cached_zakat_stats';
  static const String advancePaymentsCacheKey = 'cached_advance_payments';
  static const String advancePaymentStatsCacheKey = 'cached_advance_payment_stats';
  static const String paymentsCacheKey = 'cached_payments';
  static const String paymentStatsCacheKey = 'cached_payment_stats';
  static const String payablesCacheKey = 'cached_payables';
  static const String payableStatsCacheKey = 'cached_payable_stats';
  static const String ordersCacheKey = 'cached_orders';
  static const String orderStatsCacheKey = 'cached_order_stats';
  static const String orderItemsCacheKey = 'cached_order_items';

  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
