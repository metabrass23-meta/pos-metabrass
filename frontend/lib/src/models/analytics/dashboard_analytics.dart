class DashboardAnalyticsModel {
  // Overview metrics
  final double totalSales;
  final int totalSalesCount;
  final int totalOrders;
  final int pendingOrders;
  final int totalCustomers;
  final int activeCustomers;
  final int totalVendors;
  final int activeVendors;
  final int totalProducts;
  final int lowStockProducts;

  // Financial metrics
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;

  // This month metrics
  final double thisMonthSales;
  final int thisMonthSalesCount;

  // Recent activity
  final int recentSalesCount;
  final int recentOrdersCount;

  // Collections
  final List<TopProduct> topSellingProducts;
  final List<SalesTrendData> salesTrend;
  final List<RecentTransaction> recentTransactions;
  final DateRanges dateRanges;

  DashboardAnalyticsModel({
    required this.totalSales,
    required this.totalSalesCount,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalVendors,
    required this.activeVendors,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.thisMonthSales,
    required this.thisMonthSalesCount,
    required this.recentSalesCount,
    required this.recentOrdersCount,
    required this.topSellingProducts,
    required this.salesTrend,
    required this.recentTransactions,
    required this.dateRanges,
  });

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsModel(
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalSalesCount: json['total_sales_count'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      totalCustomers: json['total_customers'] ?? 0,
      activeCustomers: json['active_customers'] ?? 0,
      totalVendors: json['total_vendors'] ?? 0,
      activeVendors: json['active_vendors'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      profitMargin: (json['profit_margin'] ?? 0).toDouble(),
      thisMonthSales: (json['this_month_sales'] ?? 0).toDouble(),
      thisMonthSalesCount: json['this_month_sales_count'] ?? 0,
      recentSalesCount: json['recent_sales_count'] ?? 0,
      recentOrdersCount: json['recent_orders_count'] ?? 0,
      topSellingProducts: (json['top_selling_products'] as List<dynamic>?)
              ?.map((item) => TopProduct.fromJson(item))
              .toList() ??
          [],
      salesTrend: (json['sales_trend'] as List<dynamic>?)
              ?.map((item) => SalesTrendData.fromJson(item))
              .toList() ??
          [],
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((item) => RecentTransaction.fromJson(item))
              .toList() ??
          [],
      dateRanges: DateRanges.fromJson(json['date_ranges'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'total_sales_count': totalSalesCount,
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'total_customers': totalCustomers,
      'active_customers': activeCustomers,
      'total_vendors': totalVendors,
      'active_vendors': activeVendors,
      'total_products': totalProducts,
      'low_stock_products': lowStockProducts,
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'net_profit': netProfit,
      'profit_margin': profitMargin,
      'this_month_sales': thisMonthSales,
      'this_month_sales_count': thisMonthSalesCount,
      'recent_sales_count': recentSalesCount,
      'recent_orders_count': recentOrdersCount,
      'top_selling_products': topSellingProducts.map((p) => p.toJson()).toList(),
      'sales_trend': salesTrend.map((t) => t.toJson()).toList(),
      'recent_transactions': recentTransactions.map((t) => t.toJson()).toList(),
      'date_ranges': dateRanges.toJson(),
    };
  }
}

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;

  TopProduct({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'revenue': revenue,
    };
  }
}

class SalesTrendData {
  final String month;
  final double sales;

  SalesTrendData({
    required this.month,
    required this.sales,
  });

  factory SalesTrendData.fromJson(Map<String, dynamic> json) {
    return SalesTrendData(
      month: json['month'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'sales': sales,
    };
  }
}

class RecentTransaction {
  final String id;
  final String type;
  final String customer;
  final double amount;
  final String date;
  final String status;

  RecentTransaction({
    required this.id,
    required this.type,
    required this.customer,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      customer: json['customer'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'customer': customer,
      'amount': amount,
      'date': date,
      'status': status,
    };
  }
}

class DateRanges {
  final String today;
  final String lastWeek;
  final String lastMonth;

  DateRanges({
    required this.today,
    required this.lastWeek,
    required this.lastMonth,
  });

  factory DateRanges.fromJson(Map<String, dynamic> json) {
    return DateRanges(
      today: json['today'] ?? '',
      lastWeek: json['last_week'] ?? '',
      lastMonth: json['last_month'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'last_week': lastWeek,
      'last_month': lastMonth,
    };
  }
}