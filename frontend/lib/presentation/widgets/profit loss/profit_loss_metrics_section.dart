import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../src/providers/profit_loss_provider.dart';
import '../../../src/theme/app_theme.dart';

class ProfitLossMetricsSection extends StatelessWidget {
  const ProfitLossMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfitLossProvider>(
      builder: (context, provider, child) {
        if (provider.currentProfitLoss == null) return SizedBox.shrink();

        final data = provider.currentProfitLoss!;
        final comparison = provider.getPeriodComparison();

        return ResponsiveBreakpoints.responsive(
          context,
          tablet: _buildMobileMetrics(context, data, comparison),
          small: _buildMobileMetrics(context, data, comparison),
          medium: _buildDesktopMetrics(context, data, comparison),
          large: _buildDesktopMetrics(context, data, comparison),
          ultrawide: _buildDesktopMetrics(context, data, comparison),
        );
      },
    );
  }

  Widget _buildDesktopMetrics(BuildContext context, ProfitLossData data, Map<String, dynamic> comparison) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Income',
            data.formattedTotalIncome,
            Icons.trending_up_rounded,
            Colors.green,
            comparison.isNotEmpty ? comparison['incomeChangePercent'] : null,
            comparison.isNotEmpty ? comparison['isIncomeUp'] : null,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Expenses',
            data.formattedTotalExpenses,
            Icons.trending_down_rounded,
            Colors.red,
            comparison.isNotEmpty ? comparison['expenseChangePercent'] : null,
            comparison.isNotEmpty ? comparison['isExpenseUp'] : null,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildProfitCard(
            context,
            data,
            comparison.isNotEmpty ? comparison['profitChangePercent'] : null,
            comparison.isNotEmpty ? comparison['isProfitUp'] : null,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildMetricCard(
            context,
            'Profit Margin',
            data.formattedProfitMargin,
            Icons.percent_rounded,
            data.isProfitable ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMetrics(BuildContext context, ProfitLossData data, Map<String, dynamic> comparison) {
    return Column(
      children: [
        // Profit Card - Full Width
        _buildProfitCard(
          context,
          data,
          comparison.isNotEmpty ? comparison['profitChangePercent'] : null,
          comparison.isNotEmpty ? comparison['isProfitUp'] : null,
          true,
        ),

        SizedBox(height: context.cardPadding),

        // Income and Expenses Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Income',
                data.formattedTotalIncome,
                Icons.trending_up_rounded,
                Colors.green,
                comparison.isNotEmpty ? comparison['incomeChangePercent'] : null,
                comparison.isNotEmpty ? comparison['isIncomeUp'] : null,
              ),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: _buildMetricCard(
                context,
                'Expenses',
                data.formattedTotalExpenses,
                Icons.trending_down_rounded,
                Colors.red,
                comparison.isNotEmpty ? comparison['expenseChangePercent'] : null,
                comparison.isNotEmpty ? comparison['isExpenseUp'] : null,
              ),
            ),
          ],
        ),

        SizedBox(height: context.cardPadding),

        // Profit Margin - Full Width
        _buildMetricCard(
          context,
          'Profit Margin',
          data.formattedProfitMargin,
          Icons.percent_rounded,
          data.isProfitable ? Colors.green : Colors.red,
          null,
          null,
          true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      [double? changePercent, bool? isPositive, bool isFullWidth = false]
      ) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, context.smallPadding / 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.smallPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.iconSize('medium'),
                ),
              ),
              if (changePercent != null && isPositive != null) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallPadding / 2,
                    vertical: context.smallPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: context.iconSize('small'),
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      Text(
                        '${changePercent.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: context.cardPadding),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: context.headerFontSize * 0.8,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitCard(
      BuildContext context,
      ProfitLossData data,
      [double? changePercent, bool? isPositive, bool isFullWidth = false]
      ) {
    final color = data.isProfitable ? Colors.green : Colors.red;

    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, context.smallPadding),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.cardPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Icon(
                  data.isProfitable ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: AppTheme.pureWhite,
                  size: context.iconSize('large'),
                ),
              ),
              if (changePercent != null && isPositive != null) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallPadding,
                    vertical: context.smallPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: context.iconSize('small'),
                        color: AppTheme.pureWhite,
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        '${changePercent.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: context.cardPadding),
          Text(
            data.formattedNetProfit,
            style: GoogleFonts.inter(
              fontSize: context.headerFontSize,
              fontWeight: FontWeight.w800,
              color: AppTheme.pureWhite,
            ),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            data.isProfitable ? 'Net Profit' : 'Net Loss',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.pureWhite.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}