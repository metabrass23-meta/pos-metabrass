import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/profit_loss/profit_loss_provider.dart';
import '../../../src/theme/app_theme.dart';

class ProfitLossProductAnalysis extends StatefulWidget {
  const ProfitLossProductAnalysis({super.key});

  @override
  State<ProfitLossProductAnalysis> createState() => _ProfitLossProductAnalysisState();
}

class _ProfitLossProductAnalysisState extends State<ProfitLossProductAnalysis> {
  String _sortBy = 'profitability_rank';
  bool _sortAscending = false;
  String _filterCategory = 'All';
  List<String> _availableCategories = ['All'];
  bool _categoriesInitialized = false;

  @override
  void initState() {
    super.initState();
    // Widget will rely on provider's initialized data
  }

  void _updateCategories(List<dynamic> products) {
    if (products.isNotEmpty) {
      final categories = products.map((p) => p.productCategory).toSet().toList();
      if (!listEquals(_availableCategories, ['All', ...categories])) {
        setState(() {
          _availableCategories = ['All', ...categories];
          _categoriesInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfitLossProvider>(
      builder: (context, provider, child) {
        // Update categories when data changes (only once)
        if (provider.productProfitability.isNotEmpty && !_categoriesInitialized) {
          _updateCategories(provider.productProfitability);
        }

        if (provider.isLoading) {
          return _buildLoadingState(context);
        }

        if (provider.hasError) {
          return _buildErrorState(context, provider);
        }

        if (provider.productProfitability.isEmpty) {
          // Show loading state if data is being fetched, otherwise show empty state
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }
          // If not loading and no data, show empty state with option to load
          return _buildEmptyState(context);
        }

        final filteredProducts = _getFilteredAndSortedProducts(provider.productProfitability);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with filters
            _buildHeader(context, provider),

            SizedBox(height: context.cardPadding),

            // Summary Statistics
            _buildSummaryStats(context, filteredProducts),

            SizedBox(height: context.cardPadding),

            // Product profitability table
            _buildProductTable(context, filteredProducts),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProfitLossProvider provider) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: context.shadowBlur(), offset: Offset(0, context.smallPadding))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Profitability Analysis',
                      style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                    ),
                    if (provider.productProfitability.isNotEmpty)
                      Text(
                        'Analyzing ${provider.productProfitability.length} products across different categories',
                        style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
                ),
                child: Text(
                  '${provider.productProfitability.length} Products',
                  style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                ),
              ),
            ],
          ),

          SizedBox(height: context.cardPadding),

          // Filters Row
          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildMobileFilters(context),
            small: _buildMobileFilters(context),
            medium: _buildDesktopFilters(context),
            large: _buildDesktopFilters(context),
            ultrawide: _buildDesktopFilters(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters(BuildContext context) {
    return Row(
      children: [
        // Category Filter
        Expanded(flex: 2, child: _buildCategoryFilter(context)),
        SizedBox(width: context.cardPadding),

        // Sort Options
        Expanded(flex: 3, child: _buildSortOptions(context)),

        SizedBox(width: context.cardPadding),

        // Refresh Button
        Expanded(flex: 1, child: _buildRefreshButton(context)),
      ],
    );
  }

  Widget _buildMobileFilters(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCategoryFilter(context)),
            SizedBox(width: context.cardPadding),
            Expanded(child: _buildRefreshButton(context)),
          ],
        ),
        SizedBox(height: context.smallPadding),
        _buildSortOptions(context),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
        ),
        SizedBox(height: context.smallPadding / 2),
        DropdownButtonFormField<String>(
          value: _filterCategory,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: _availableCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category,
                style: GoogleFonts.inter(fontSize: context.captionFontSize),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _filterCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
        ),
        SizedBox(height: context.smallPadding / 2),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'profitability_rank',
                    child: Text('Rank', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ),
                  DropdownMenuItem(
                    value: 'gross_profit',
                    child: Text('Profit', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ),
                  DropdownMenuItem(
                    value: 'units_sold',
                    child: Text('Units Sold', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ),
                  DropdownMenuItem(
                    value: 'product_name',
                    child: Text('Name', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ),
                  DropdownMenuItem(
                    value: 'profit_margin',
                    child: Text('Margin %', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
            SizedBox(width: context.smallPadding),
            IconButton(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, color: AppTheme.primaryMaroon),
              tooltip: _sortAscending ? 'Sort Descending' : 'Sort Ascending',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.grey[600]),
        ),
        SizedBox(height: context.smallPadding / 2),
        Container(
          height: context.buttonHeight / 1.5,
          width: double.infinity,
          child: Consumer<ProfitLossProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isLoading ? null : () => provider.loadProductProfitability(),
                icon: provider.isLoading
                    ? SizedBox(
                        width: context.iconSize('small'),
                        height: context.iconSize('small'),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.refresh_rounded, size: context.iconSize('small')),
                label: Text(provider.isLoading ? 'Refreshing...' : 'Refresh', style: GoogleFonts.inter(fontSize: context.captionFontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
                  disabledBackgroundColor: AppTheme.primaryMaroon.withOpacity(0.6),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<dynamic> products) {
    if (products.isEmpty) return SizedBox.shrink();

    final totalRevenue = products.fold<double>(0.0, (sum, p) => sum + p.totalRevenue);
    final totalProfit = products.fold<double>(0.0, (sum, p) => sum + p.grossProfit);
    final totalCost = products.fold<double>(0.0, (sum, p) => sum + p.totalCost);
    final avgProfitMargin = products.fold<double>(0.0, (sum, p) => sum + p.profitMargin) / products.length;
    final profitableProducts = products.where((p) => p.isProfitable).length;

    return Container(
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: context.shadowBlur(), offset: Offset(0, context.smallPadding))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('small')),
              SizedBox(width: context.smallPadding / 2),
              Text(
                'Summary Statistics',
                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildMobileSummaryStats(context, totalRevenue, totalProfit, totalCost, avgProfitMargin, profitableProducts, products.length),
            small: _buildMobileSummaryStats(context, totalRevenue, totalProfit, totalCost, avgProfitMargin, profitableProducts, products.length),
            medium: _buildDesktopSummaryStats(context, totalRevenue, totalProfit, totalCost, avgProfitMargin, profitableProducts, products.length),
            large: _buildDesktopSummaryStats(context, totalRevenue, totalProfit, totalCost, avgProfitMargin, profitableProducts, products.length),
            ultrawide: _buildDesktopSummaryStats(context, totalRevenue, totalProfit, totalCost, avgProfitMargin, profitableProducts, products.length),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSummaryStats(
    BuildContext context,
    double totalRevenue,
    double totalProfit,
    double totalCost,
    double avgProfitMargin,
    int profitableProducts,
    int totalProducts,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(context, 'Total Revenue', 'PKR ${totalRevenue.toStringAsFixed(0)}', Icons.trending_up_rounded, Colors.green),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Profit',
            'PKR ${totalProfit.toStringAsFixed(0)}',
            Icons.analytics_rounded,
            totalProfit > 0 ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: _buildSummaryCard(context, 'Total Cost', 'PKR ${totalCost.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, Colors.orange),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Avg Profit Margin',
            '${avgProfitMargin.toStringAsFixed(1)}%',
            Icons.pie_chart_rounded,
            AppTheme.primaryMaroon,
          ),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: _buildSummaryCard(context, 'Profitable Products', '$profitableProducts/$totalProducts', Icons.check_circle_rounded, Colors.green),
        ),
      ],
    );
  }

  Widget _buildMobileSummaryStats(
    BuildContext context,
    double totalRevenue,
    double totalProfit,
    double totalCost,
    double avgProfitMargin,
    int profitableProducts,
    int totalProducts,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(context, 'Total Revenue', 'PKR ${totalRevenue.toStringAsFixed(0)}', Icons.trending_up_rounded, Colors.green),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Profit',
                'PKR ${totalProfit.toStringAsFixed(0)}',
                Icons.analytics_rounded,
                totalProfit > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Cost',
                'PKR ${totalCost.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                Colors.orange,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Avg Profit Margin',
                '${avgProfitMargin.toStringAsFixed(1)}%',
                Icons.pie_chart_rounded,
                AppTheme.primaryMaroon,
              ),
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),
        _buildSummaryCard(context, 'Profitable Products', '$profitableProducts/$totalProducts', Icons.check_circle_rounded, Colors.green),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: context.iconSize('small')),
          SizedBox(height: context.smallPadding / 2),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: context.captionFontSize * 0.9, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.smallPadding / 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: color),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(BuildContext context, List<dynamic> products) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: context.shadowBlur(), offset: Offset(0, context.smallPadding))],
      ),
      child: ResponsiveBreakpoints.responsive(
        context,
        tablet: _buildMobileProductList(context, products),
        small: _buildMobileProductList(context, products),
        medium: _buildDesktopProductTable(context, products),
        large: _buildDesktopProductTable(context, products),
        ultrawide: _buildDesktopProductTable(context, products),
      ),
    );
  }

  Widget _buildDesktopProductTable(BuildContext context, List<dynamic> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: context.cardPadding,
        headingTextStyle: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
        dataTextStyle: GoogleFonts.inter(fontSize: context.captionFontSize),
        columns: [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Units Sold')),
          DataColumn(label: Text('Revenue')),
          DataColumn(label: Text('Cost')),
          DataColumn(label: Text('Profit')),
          DataColumn(label: Text('Margin %')),
          DataColumn(label: Text('Status')),
        ],
        rows: products.map((product) {
          return DataRow(
            cells: [
              DataCell(Text('#${product.profitabilityRank}')),
              DataCell(Text(product.productName, style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
              DataCell(Text(product.productCategory)),
              DataCell(Text(product.unitsSold.toString())),
              DataCell(Text(product.formattedTotalRevenue)),
              DataCell(Text('PKR ${product.totalCost.toStringAsFixed(0)}')),
              DataCell(
                Text(
                  product.formattedGrossProfit,
                  style: GoogleFonts.inter(color: product.isProfitable ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Text(
                  product.formattedProfitMargin,
                  style: GoogleFonts.inter(color: product.isProfitable ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                  decoration: BoxDecoration(
                    color: (product.isProfitable ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Text(
                    product.isProfitable ? 'Profitable' : 'Loss',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: product.isProfitable ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileProductList(BuildContext context, List<dynamic> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: EdgeInsets.only(bottom: context.smallPadding),
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with rank and name
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                    decoration: BoxDecoration(color: AppTheme.primaryMaroon, borderRadius: BorderRadius.circular(context.borderRadius('small'))),
                    child: Text(
                      '#${product.profitabilityRank}',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: context.smallPadding),
                  Expanded(
                    child: Text(
                      product.productName,
                      style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                    decoration: BoxDecoration(
                      color: (product.isProfitable ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    ),
                    child: Text(
                      product.isProfitable ? 'Profitable' : 'Loss',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w600,
                        color: product.isProfitable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.smallPadding),

              // Category
              Text(
                product.productCategory,
                style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
              ),

              SizedBox(height: context.smallPadding),

              // Metrics Row
              Row(
                children: [
                  Expanded(child: _buildMetricItem(context, 'Units', product.unitsSold.toString(), Icons.inventory_2_rounded)),
                  Expanded(child: _buildMetricItem(context, 'Revenue', product.formattedTotalRevenue, Icons.trending_up_rounded)),
                  Expanded(child: _buildMetricItem(context, 'Profit', product.formattedGrossProfit, Icons.analytics_rounded)),
                ],
              ),

              SizedBox(height: context.smallPadding),

              // Profit margin
              Row(
                children: [
                  Text(
                    'Profit Margin: ',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
                  ),
                  Text(
                    product.formattedProfitMargin,
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: product.isProfitable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryMaroon, size: context.iconSize('small')),
        SizedBox(height: context.smallPadding / 2),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            child: CircularProgressIndicator(color: AppTheme.primaryMaroon, strokeWidth: 3),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'Loading Product Data...',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Please wait while we fetch the latest profitability information.',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ProfitLossProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.error_outline_rounded, size: context.iconSize('xl'), color: Colors.red[400]),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'Error Loading Data',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: Colors.red[600]),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            provider.errorMessage ?? 'An unexpected error occurred while loading product data.',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.cardPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => provider.recoverFromError(),
                icon: Icon(Icons.refresh_rounded),
                label: Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon, foregroundColor: Colors.white),
              ),
              SizedBox(width: context.cardPadding),
              OutlinedButton.icon(
                onPressed: () => provider.clearError(),
                icon: Icon(Icons.close_rounded),
                label: Text('Dismiss'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryMaroon,
                  side: BorderSide(color: AppTheme.primaryMaroon),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Consumer<ProfitLossProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMaroon));
                }
                return Icon(Icons.inventory_2_outlined, size: context.iconSize('xl'), color: Colors.grey[400]);
              },
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'Loading Product Data...',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Product profitability data is being loaded.\nThis includes revenue, costs, profit margins, and rankings.',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.cardPadding),
          Container(
            height: context.buttonHeight / 1.5,
            child: Consumer<ProfitLossProvider>(
              builder: (context, provider, child) {
                return ElevatedButton.icon(
                  onPressed: () => provider.loadProductProfitability(),
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: context.cardPadding),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredAndSortedProducts(List<dynamic> products) {
    // Apply category filter
    List<dynamic> filtered = products;
    if (_filterCategory != 'All') {
      filtered = products.where((p) => p.productCategory == _filterCategory).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (_sortBy) {
        case 'profitability_rank':
          aValue = a.profitabilityRank;
          bValue = b.profitabilityRank;
          break;
        case 'gross_profit':
          aValue = a.grossProfit;
          bValue = b.grossProfit;
          break;
        case 'units_sold':
          aValue = a.unitsSold;
          bValue = b.unitsSold;
          break;
        case 'product_name':
          aValue = a.productName.toLowerCase();
          bValue = b.productName.toLowerCase();
          break;
        case 'profit_margin':
          aValue = a.profitMargin;
          bValue = b.profitMargin;
          break;
        default:
          aValue = a.profitabilityRank;
          bValue = b.profitabilityRank;
      }

      if (_sortAscending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });

    return filtered;
  }
}
