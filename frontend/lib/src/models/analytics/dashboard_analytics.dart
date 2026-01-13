import 'package:flutter/material.dart';

class DashboardAnalytics {
  final SalesMetrics salesMetrics;
  final FinancialMetrics financialMetrics;
  final CustomerMetrics customerMetrics;
  final InventoryMetrics inventoryMetrics;
  final OperationalMetrics operationalMetrics;
  final List<ChartData> salesTrend;
  final List<ChartData> profitTrend;
  final List<ChartData> customerGrowth;
  final List<ChartData> topProducts;

  DashboardAnalytics({
    required this.salesMetrics,
    required this.financialMetrics,
    required this.customerMetrics,
    required this.inventoryMetrics,
    required this.operationalMetrics,
    required this.salesTrend,
    required this.profitTrend,
    required this.customerGrowth,
    required this.topProducts,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      salesMetrics: SalesMetrics.fromJson(json['sales_metrics'] ?? {}),
      financialMetrics: FinancialMetrics.fromJson(json['financial_metrics'] ?? {}),
      customerMetrics: CustomerMetrics.fromJson(json['customer_metrics'] ?? {}),
      inventoryMetrics: InventoryMetrics.fromJson(json['inventory_metrics'] ?? {}),
      operationalMetrics: OperationalMetrics.fromJson(json['operational_metrics'] ?? {}),
      salesTrend: (json['sales_trend'] as List<dynamic>?)?.map((item) => ChartData.fromJson(item)).toList() ?? [],
      profitTrend: (json['profit_trend'] as List<dynamic>?)?.map((item) => ChartData.fromJson(item)).toList() ?? [],
      customerGrowth: (json['customer_growth'] as List<dynamic>?)?.map((item) => ChartData.fromJson(item)).toList() ?? [],
      topProducts: (json['top_products'] as List<dynamic>?)?.map((item) => ChartData.fromJson(item)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_metrics': salesMetrics.toJson(),
      'financial_metrics': financialMetrics.toJson(),
      'customer_metrics': customerMetrics.toJson(),
      'inventory_metrics': inventoryMetrics.toJson(),
      'operational_metrics': operationalMetrics.toJson(),
      'sales_trend': salesTrend.map((item) => item.toJson()).toList(),
      'profit_trend': profitTrend.map((item) => item.toJson()).toList(),
      'customer_growth': customerGrowth.map((item) => item.toJson()).toList(),
      'top_products': topProducts.map((item) => item.toJson()).toList(),
    };
  }
}

class SalesMetrics {
  final double totalSales;
  final int salesCount;
  final double averageSaleValue;
  final double todaySales;
  final double thisWeekSales;
  final double thisMonthSales;
  final double growthRate;

  SalesMetrics({
    required this.totalSales,
    required this.salesCount,
    required this.averageSaleValue,
    required this.todaySales,
    required this.thisWeekSales,
    required this.thisMonthSales,
    required this.growthRate,
  });

  factory SalesMetrics.fromJson(Map<String, dynamic> json) {
    return SalesMetrics(
      totalSales: (json['total_sales'] ?? 0.0).toDouble(),
      salesCount: json['sales_count'] ?? 0,
      averageSaleValue: (json['average_sale_value'] ?? 0.0).toDouble(),
      todaySales: (json['today_sales'] ?? 0.0).toDouble(),
      thisWeekSales: (json['this_week_sales'] ?? 0.0).toDouble(),
      thisMonthSales: (json['this_month_sales'] ?? 0.0).toDouble(),
      growthRate: (json['growth_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'sales_count': salesCount,
      'average_sale_value': averageSaleValue,
      'today_sales': todaySales,
      'this_week_sales': thisWeekSales,
      'this_month_sales': thisMonthSales,
      'growth_rate': growthRate,
    };
  }

  String get formattedTotalSales => 'PKR ${totalSales.toStringAsFixed(2)}';
  String get formattedAverageSaleValue => 'PKR ${averageSaleValue.toStringAsFixed(2)}';
  String get formattedTodaySales => 'PKR ${todaySales.toStringAsFixed(2)}';
  String get formattedThisWeekSales => 'PKR ${thisWeekSales.toStringAsFixed(2)}';
  String get formattedThisMonthSales => 'PKR ${thisMonthSales.toStringAsFixed(2)}';
  String get formattedGrowthRate => '${growthRate.toStringAsFixed(1)}%';
}

class FinancialMetrics {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final double cashFlow;
  final double outstandingReceivables;
  final double outstandingPayables;

  FinancialMetrics({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.cashFlow,
    required this.outstandingReceivables,
    required this.outstandingPayables,
  });

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) {
    return FinancialMetrics(
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0.0).toDouble(),
      netProfit: (json['net_profit'] ?? 0.0).toDouble(),
      profitMargin: (json['profit_margin'] ?? 0.0).toDouble(),
      cashFlow: (json['cash_flow'] ?? 0.0).toDouble(),
      outstandingReceivables: (json['outstanding_receivables'] ?? 0.0).toDouble(),
      outstandingPayables: (json['outstanding_payables'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'net_profit': netProfit,
      'profit_margin': profitMargin,
      'cash_flow': cashFlow,
      'outstanding_receivables': outstandingReceivables,
      'outstanding_payables': outstandingPayables,
    };
  }

  String get formattedTotalRevenue => 'PKR ${totalRevenue.toStringAsFixed(2)}';
  String get formattedTotalExpenses => 'PKR ${totalExpenses.toStringAsFixed(2)}';
  String get formattedNetProfit => 'PKR ${netProfit.toStringAsFixed(2)}';
  String get formattedProfitMargin => '${profitMargin.toStringAsFixed(1)}%';
  String get formattedCashFlow => 'PKR ${cashFlow.toStringAsFixed(2)}';
  String get formattedOutstandingReceivables => 'PKR ${outstandingReceivables.toStringAsFixed(2)}';
  String get formattedOutstandingPayables => 'PKR ${outstandingPayables.toStringAsFixed(2)}';
}

class CustomerMetrics {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double averageCustomerValue;
  final double customerRetentionRate;
  final List<String> topCustomerSegments;

  CustomerMetrics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.averageCustomerValue,
    required this.customerRetentionRate,
    required this.topCustomerSegments,
  });

  factory CustomerMetrics.fromJson(Map<String, dynamic> json) {
    return CustomerMetrics(
      totalCustomers: json['total_customers'] ?? 0,
      newCustomers: json['new_customers'] ?? 0,
      returningCustomers: json['returning_customers'] ?? 0,
      averageCustomerValue: (json['average_customer_value'] ?? 0.0).toDouble(),
      customerRetentionRate: (json['customer_retention_rate'] ?? 0.0).toDouble(),
      topCustomerSegments: (json['top_customer_segments'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_customers': totalCustomers,
      'new_customers': newCustomers,
      'returning_customers': returningCustomers,
      'average_customer_value': averageCustomerValue,
      'customer_retention_rate': customerRetentionRate,
      'top_customer_segments': topCustomerSegments,
    };
  }

  String get formattedAverageCustomerValue => 'PKR ${averageCustomerValue.toStringAsFixed(2)}';
  String get formattedCustomerRetentionRate => '${customerRetentionRate.toStringAsFixed(1)}%';
}

class InventoryMetrics {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double inventoryValue;
  final double inventoryTurnoverRate;
  final List<String> topSellingCategories;

  InventoryMetrics({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.inventoryValue,
    required this.inventoryTurnoverRate,
    required this.topSellingCategories,
  });

  factory InventoryMetrics.fromJson(Map<String, dynamic> json) {
    return InventoryMetrics(
      totalProducts: json['total_products'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      outOfStockProducts: json['out_of_stock_products'] ?? 0,
      inventoryValue: (json['inventory_value'] ?? 0.0).toDouble(),
      inventoryTurnoverRate: (json['inventory_turnover_rate'] ?? 0.0).toDouble(),
      topSellingCategories: (json['top_selling_categories'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'low_stock_products': lowStockProducts,
      'out_of_stock_products': outOfStockProducts,
      'inventory_value': inventoryValue,
      'inventory_turnover_rate': inventoryTurnoverRate,
      'top_selling_categories': topSellingCategories,
    };
  }

  String get formattedInventoryValue => 'PKR ${inventoryValue.toStringAsFixed(2)}';
  String get formattedInventoryTurnoverRate => '${inventoryTurnoverRate.toStringAsFixed(1)}x';
}

class OperationalMetrics {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double averageOrderValue;
  final double averageFulfillmentTime;
  final double orderCompletionRate;

  OperationalMetrics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.averageOrderValue,
    required this.averageFulfillmentTime,
    required this.orderCompletionRate,
  });

  factory OperationalMetrics.fromJson(Map<String, dynamic> json) {
    return OperationalMetrics(
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      averageOrderValue: (json['average_order_value'] ?? 0.0).toDouble(),
      averageFulfillmentTime: (json['average_fulfillment_time'] ?? 0.0).toDouble(),
      orderCompletionRate: (json['order_completion_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'completed_orders': completedOrders,
      'average_order_value': averageOrderValue,
      'average_fulfillment_time': averageFulfillmentTime,
      'order_completion_rate': orderCompletionRate,
    };
  }

  String get formattedAverageOrderValue => 'PKR ${averageOrderValue.toStringAsFixed(2)}';
  String get formattedAverageFulfillmentTime => '${averageFulfillmentTime.toStringAsFixed(1)} days';
  String get formattedOrderCompletionRate => '${orderCompletionRate.toStringAsFixed(1)}%';
}

class ChartData {
  final String label;
  final double value;
  final String? color;
  final Map<String, dynamic>? additionalData;

  ChartData({required this.label, required this.value, this.color, this.additionalData});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      color: json['color'],
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'color': color, 'additional_data': additionalData};
  }

  String get formattedValue => 'PKR ${value.toStringAsFixed(2)}';
}

