// Configuration class for API endpoints, timeouts, headers, and storage keys.

class ApiConfig {
  // Base URL for the Django backend
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // ===============================
  // Table of Contents
  // ===============================
  // 1. Authentication Endpoints
  // 2. Category Endpoints
  // 3. Product Endpoints
  // 4. Customer Endpoints
  // 5. Vendor Endpoints
  // 6. Labor Endpoints
  // 7. Request Timeouts
  // 8. Headers
  // 9. Storage Keys
  // 10. Utility Methods

  // ===============================
  // 1. Authentication Endpoints
  // ===============================
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';

  // ===============================
  // 2. Category Endpoints
  // ===============================
  static const String categories = '/categories/';
  static const String createCategory = '/categories/create/';

  static String getCategoryById(String id) => '/categories/$id/';
  static String updateCategory(String id) => '/categories/$id/update/';
  static String deleteCategory(String id) => '/categories/$id/delete/'; // Hard delete
  static String softDeleteCategory(String id) => '/categories/$id/soft-delete/'; // Soft delete
  static String restoreCategory(String id) => '/categories/$id/restore/';

  // ===============================
  // 3. Product Endpoints
  // ===============================
  // Basic CRUD Operations
  static const String products = '/products/';
  static const String createProduct = '/products/create/';

  static String getProductById(String id) => '/products/$id/';
  static String updateProduct(String id) => '/products/$id/update/';
  static String deleteProduct(String id) => '/products/$id/delete/'; // Hard delete
  static String softDeleteProduct(String id) => '/products/$id/soft-delete/'; // Soft delete
  static String restoreProduct(String id) => '/products/$id/restore/';

  // Product Search & Filtering
  static const String searchProducts = '/products/search/';
  static String productsByCategory(String categoryId) => '/products/category/$categoryId/';
  static const String lowStockProducts = '/products/low-stock/';
  static const String productStatistics = '/products/statistics/';

  // Product Operations
  static String updateProductQuantity(String id) => '/products/$id/quantity/';
  static const String bulkUpdateQuantities = '/products/bulk-update-quantities/';
  static String duplicateProduct(String id) => '/products/$id/duplicate/';

  // ===============================
  // 4. Customer Endpoints
  // ===============================
  // Basic CRUD Operations
  static const String customers = '/customers/';
  static const String createCustomer = '/customers/create/';

  static String getCustomerById(String id) => '/customers/$id/';
  static String updateCustomer(String id) => '/customers/$id/update/';
  static String deleteCustomer(String id) => '/customers/$id/delete/'; // Hard delete
  static String softDeleteCustomer(String id) => '/customers/$id/soft-delete/'; // Soft delete
  static String restoreCustomer(String id) => '/customers/$id/restore/';

  // Customer Search & Filtering
  static const String searchCustomers = '/customers/search/';
  static String customersByStatus(String status) => '/customers/status/$status/';
  static String customersByType(String type) => '/customers/type/$type/';
  static String customersByCity(String city) => '/customers/city/$city/';
  static String customersByCountry(String country) => '/customers/country/$country/';

  // Customer Segments
  static const String pakistaniCustomers = '/customers/pakistani/';
  static const String internationalCustomers = '/customers/international/';
  static const String newCustomers = '/customers/new/';
  static const String recentCustomers = '/customers/recent/';

  // Customer Statistics & Analytics
  static const String customerStatistics = '/customers/statistics/';

  // Customer Contact Management
  static String updateCustomerContact(String id) => '/customers/$id/contact/';
  static String verifyCustomerContact(String id) => '/customers/$id/verify/';

  // Customer Activity Tracking
  static String updateCustomerActivity(String id) => '/customers/$id/activity/';

  // Customer Bulk Operations
  static const String bulkCustomerActions = '/customers/bulk-actions/';

  // Customer Operations
  static String duplicateCustomer(String id) => '/customers/$id/duplicate/';

  // Customer Integration Endpoints
  static String customerOrders(String id) => '/customers/$id/orders/';
  static String customerSales(String id) => '/customers/$id/sales/';

  // ===============================
  // 5. Vendor Endpoints
  // ===============================
  // Basic CRUD Operations
  static const String vendors = '/vendors/';
  static const String createVendor = '/vendors/create/';

  static String getVendorById(String id) => '/vendors/$id/';
  static String updateVendor(String id) => '/vendors/$id/update/';
  static String deleteVendor(String id) => '/vendors/$id/delete/';

  // Soft Delete Operations
  static String softDeleteVendor(String id) => '/vendors/$id/soft-delete/';
  static String restoreVendor(String id) => '/vendors/$id/restore/';

  // Search and Filtering
  static const String searchVendors = '/vendors/search/';
  static String vendorsByCity(String cityName) => '/vendors/city/$cityName/';
  static String vendorsByArea(String areaName) => '/vendors/area/$areaName/';

  // Time-based Filtering
  static const String newVendors = '/vendors/new/';
  static const String recentVendors = '/vendors/recent/';

  // Statistics and Analytics
  static const String vendorStatistics = '/vendors/statistics/';

  // Contact Management
  static String updateVendorContact(String id) => '/vendors/$id/contact/update/';

  // Bulk Operations
  static const String bulkVendorActions = '/vendors/bulk-actions/';

  // Utility Operations
  static String duplicateVendor(String id) => '/vendors/$id/duplicate/';

  // Payment Integration
  static String vendorPayments(String id) => '/vendors/$id/payments/';

  // ===============================
  // 6. Labor Endpoints
  // ===============================
  // Basic CRUD Operations
  static const String labors = '/labors/';
  static const String createLabor = '/labors/create/';

  static String getLaborById(String id) => '/labors/$id/';
  static String updateLabor(String id) => '/labors/$id/update/';
  static String deleteLabor(String id) => '/labors/$id/delete/';

  // Soft Delete Operations
  static String softDeleteLabor(String id) => '/labors/$id/soft-delete/';
  static String restoreLabor(String id) => '/labors/$id/restore/';

  // Search and Filtering
  static const String searchLabors = '/labors/search/';
  static String laborsByCity(String cityName) => '/labors/city/$cityName/';
  static String laborsByArea(String areaName) => '/labors/area/$areaName/';
  static String laborsByDesignation(String designationName) => '/labors/designation/$designationName/';
  static String laborsByCaste(String casteName) => '/labors/caste/$casteName/';
  static String laborsByGender(String gender) => '/labors/gender/$gender/';
  static const String laborsBySalaryRange = '/labors/salary-range/';
  static const String laborsByAgeRange = '/labors/age-range/';

  // Time-based Filtering
  static const String newLabors = '/labors/new/';
  static const String recentLabors = '/labors/recent/';

  // Statistics and Analytics
  static const String laborStatistics = '/labors/statistics/';
  static const String laborSalaryReport = '/labors/salary-report/';
  static const String laborDemographicsReport = '/labors/demographics-report/';
  static const String laborExperienceReport = '/labors/experience-report/';

  // Contact and Salary Management
  static String updateLaborContact(String id) => '/labors/$id/contact/update/';
  static String updateLaborSalary(String id) => '/labors/$id/salary/update/';

  // Bulk Operations
  static const String bulkLaborActions = '/labors/bulk-actions/';

  // Utility Operations
  static String duplicateLabor(String id) => '/labors/$id/duplicate/';

  // Payment Integration
  static String laborPayments(String id) => '/labors/$id/payments/';

  // Getters for remaining Labor endpoints
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

  // ===============================
  // 7. Request Timeouts
  // ===============================
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // ===============================
  // 8. Headers
  // ===============================
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Method to get auth headers with token
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // ===============================
  // 9. Storage Keys
  // ===============================
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

  // ===============================
  // 10. Utility Methods
  // ===============================
  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}