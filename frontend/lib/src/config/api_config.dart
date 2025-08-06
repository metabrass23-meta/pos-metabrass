class ApiConfig {
  // Base URL for your Django backend
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth Endpoints
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';

  // Category Endpoints
  static const String categories = '/categories/';
  static const String createCategory = '/categories/create/';
  static String getCategoryById(String id) => '/categories/$id/';
  static String updateCategory(String id) => '/categories/$id/update/';
  static String deleteCategory(String id) => '/categories/$id/delete/'; // Hard delete
  static String softDeleteCategory(String id) => '/categories/$id/soft-delete/'; // Soft delete
  static String restoreCategory(String id) => '/categories/$id/restore/';

  // Product Endpoints
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

  // Customer Endpoints
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

  // Customer Integration endpoints (future)
  static String customerOrders(String id) => '/customers/$id/orders/';
  static String customerSales(String id) => '/customers/$id/sales/';

  // Request timeouts
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
  static const int sendTimeout = 15000; // 15 seconds

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String categoriesCacheKey = 'cached_categories';
  static const String productsCacheKey = 'cached_products';
  static const String productStatsCacheKey = 'cached_product_stats';
  static const String customersCacheKey = 'cached_customers';
  static const String customerStatsCacheKey = 'cached_customer_stats';
}