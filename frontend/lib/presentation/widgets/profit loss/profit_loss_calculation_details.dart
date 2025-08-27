import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/profit_loss/profit_loss_provider.dart';
import '../../../src/theme/app_theme.dart';

class ProfitLossCalculationDetails extends StatelessWidget {
  const ProfitLossCalculationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfitLossProvider>(
      builder: (context, provider, child) {
        if (provider.currentProfitLoss == null) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calculation Summary
            _buildCalculationSummary(context, provider.currentProfitLoss!),

            SizedBox(height: context.cardPadding),

            // Source Records Breakdown
            _buildSourceRecordsBreakdown(context, provider.currentProfitLoss!),

            SizedBox(height: context.cardPadding),

            // Calculation Formula
            _buildCalculationFormula(context, provider.currentProfitLoss!),

            SizedBox(height: context.cardPadding),

            // Period Information
            _buildPeriodInformation(context, provider.currentProfitLoss!),
          ],
        );
      },
    );
  }

  Widget _buildCalculationSummary(BuildContext context, dynamic profitLoss) {
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
              Icon(Icons.calculate_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Calculation Summary',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildMobileCalculationSummary(context, profitLoss),
            small: _buildMobileCalculationSummary(context, profitLoss),
            medium: _buildDesktopCalculationSummary(context, profitLoss),
            large: _buildDesktopCalculationSummary(context, profitLoss),
            ultrawide: _buildDesktopCalculationSummary(context, profitLoss),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCalculationSummary(BuildContext context, dynamic profitLoss) {
    return Row(
      children: [
        Expanded(
          child: _buildCalculationCard(
            context,
            'Income',
            profitLoss.formattedTotalIncome,
            Icons.trending_up_rounded,
            Colors.green,
            'Total sales revenue for the period',
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildCalculationCard(
            context,
            'Cost of Goods',
            'PKR ${profitLoss.totalCostOfGoodsSold.toStringAsFixed(0)}',
            Icons.inventory_2_rounded,
            Colors.orange,
            'Direct costs of products sold',
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildCalculationCard(
            context,
            'Gross Profit',
            profitLoss.formattedGrossProfit,
            Icons.analytics_rounded,
            profitLoss.grossProfit > 0 ? Colors.green : Colors.red,
            'Income minus cost of goods sold',
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildCalculationCard(
            context,
            'Net Profit',
            profitLoss.formattedNetProfit,
            Icons.account_balance_wallet_rounded,
            profitLoss.isProfitable ? Colors.green : Colors.red,
            'Final profit after all expenses',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCalculationSummary(BuildContext context, dynamic profitLoss) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCalculationCard(
                context,
                'Income',
                profitLoss.formattedTotalIncome,
                Icons.trending_up_rounded,
                Colors.green,
                'Total sales revenue',
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildCalculationCard(
                context,
                'Cost of Goods',
                'PKR ${profitLoss.totalCostOfGoodsSold.toStringAsFixed(0)}',
                Icons.inventory_2_rounded,
                Colors.orange,
                'Direct costs',
              ),
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),
        Row(
          children: [
            Expanded(
              child: _buildCalculationCard(
                context,
                'Gross Profit',
                profitLoss.formattedGrossProfit,
                Icons.analytics_rounded,
                profitLoss.grossProfit > 0 ? Colors.green : Colors.red,
                'Income - COGS',
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildCalculationCard(
                context,
                'Net Profit',
                profitLoss.formattedNetProfit,
                Icons.account_balance_wallet_rounded,
                profitLoss.isProfitable ? Colors.green : Colors.red,
                'Final profit',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculationCard(BuildContext context, String title, String value, IconData icon, Color color, String description) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: context.iconSize('small')),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w700, color: color),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceRecordsBreakdown(BuildContext context, dynamic profitLoss) {
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
              Icon(Icons.source_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Source Records Breakdown',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildMobileSourceBreakdown(context, profitLoss),
            small: _buildMobileSourceBreakdown(context, profitLoss),
            medium: _buildDesktopSourceBreakdown(context, profitLoss),
            large: _buildDesktopSourceBreakdown(context, profitLoss),
            ultrawide: _buildDesktopSourceBreakdown(context, profitLoss),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSourceBreakdown(BuildContext context, dynamic profitLoss) {
    return Row(
      children: [
        Expanded(
          child: _buildSourceRecordCard(
            context,
            'Sales Records',
            profitLoss.totalProductsSold.toString(),
            'PKR ${profitLoss.totalSalesIncome.toStringAsFixed(0)}',
            Icons.receipt_long_rounded,
            Colors.green,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildSourceRecordCard(
            context,
            'Labor Payments',
            'N/A', // Count not available in current model
            'PKR ${profitLoss.totalLaborPayments.toStringAsFixed(0)}',
            Icons.people_rounded,
            Colors.blue,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildSourceRecordCard(
            context,
            'Vendor Payments',
            'N/A', // Count not available in current model
            'PKR ${profitLoss.totalVendorPayments.toStringAsFixed(0)}',
            Icons.store_rounded,
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildSourceRecordCard(
            context,
            'Other Expenses',
            'N/A', // Count not available in current model
            'PKR ${profitLoss.totalExpenses.toStringAsFixed(0)}',
            Icons.receipt_long_rounded,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSourceBreakdown(BuildContext context, dynamic profitLoss) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSourceRecordCard(
                context,
                'Sales',
                profitLoss.totalProductsSold.toString(),
                'PKR ${profitLoss.totalSalesIncome.toStringAsFixed(0)}',
                Icons.receipt_long_rounded,
                Colors.green,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildSourceRecordCard(
                context,
                'Labor',
                'N/A',
                'PKR ${profitLoss.totalLaborPayments.toStringAsFixed(0)}',
                Icons.people_rounded,
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),
        Row(
          children: [
            Expanded(
              child: _buildSourceRecordCard(
                context,
                'Vendors',
                'N/A',
                'PKR ${profitLoss.totalVendorPayments.toStringAsFixed(0)}',
                Icons.store_rounded,
                Colors.orange,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildSourceRecordCard(
                context,
                'Expenses',
                'N/A',
                'PKR ${profitLoss.totalExpenses.toStringAsFixed(0)}',
                Icons.receipt_long_rounded,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceRecordCard(BuildContext context, String title, String count, String amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: context.iconSize('medium')),
          SizedBox(height: context.smallPadding),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            count,
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w700, color: color),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            amount,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationFormula(BuildContext context, dynamic profitLoss) {
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
              Icon(Icons.functions_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Calculation Formula',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          _buildFormulaStep(
            context,
            '1. Gross Profit',
            'Income - Cost of Goods Sold',
            'PKR ${profitLoss.totalSalesIncome.toStringAsFixed(0)} - PKR ${profitLoss.totalCostOfGoodsSold.toStringAsFixed(0)} = ${profitLoss.formattedGrossProfit}',
            Colors.green,
          ),

          SizedBox(height: context.smallPadding),

          _buildFormulaStep(
            context,
            '2. Total Expenses',
            'Labor + Vendor + Other + Zakat',
            'PKR ${profitLoss.totalLaborPayments.toStringAsFixed(0)} + PKR ${profitLoss.totalVendorPayments.toStringAsFixed(0)} + PKR ${profitLoss.totalExpenses.toStringAsFixed(0)} + PKR ${profitLoss.totalZakat.toStringAsFixed(0)} = ${profitLoss.formattedTotalExpenses}',
            Colors.red,
          ),

          SizedBox(height: context.smallPadding),

          _buildFormulaStep(
            context,
            '3. Net Profit',
            'Gross Profit - Total Expenses',
            '${profitLoss.formattedGrossProfit} - ${profitLoss.formattedTotalExpenses} = ${profitLoss.formattedNetProfit}',
            profitLoss.isProfitable ? Colors.green : Colors.red,
          ),

          SizedBox(height: context.cardPadding),

          // Profit Margins
          Row(
            children: [
              Expanded(
                child: _buildMarginCard(
                  context,
                  'Gross Profit Margin',
                  profitLoss.formattedGrossProfitMargin,
                  'Gross Profit / Income × 100',
                  Colors.green,
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: _buildMarginCard(
                  context,
                  'Net Profit Margin',
                  profitLoss.formattedProfitMargin,
                  'Net Profit / Income × 100',
                  profitLoss.isProfitable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaStep(BuildContext context, String step, String description, String calculation, Color color) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: color),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            calculation,
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginCard(BuildContext context, String title, String value, String formula, Color color) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w700, color: color),
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            formula,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodInformation(BuildContext context, dynamic profitLoss) {
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
              Icon(Icons.calendar_today_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Period Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildMobilePeriodInfo(context, profitLoss),
            small: _buildMobilePeriodInfo(context, profitLoss),
            medium: _buildDesktopPeriodInfo(context, profitLoss),
            large: _buildDesktopPeriodInfo(context, profitLoss),
            ultrawide: _buildDesktopPeriodInfo(context, profitLoss),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPeriodInfo(BuildContext context, dynamic profitLoss) {
    return Row(
      children: [
        Expanded(child: _buildPeriodInfoCard(context, 'Period Type', profitLoss.periodTypeDisplay, Icons.schedule_rounded, AppTheme.primaryMaroon)),
        SizedBox(width: context.cardPadding),
        Expanded(child: _buildPeriodInfoCard(context, 'Start Date', _formatDate(profitLoss.startDate), Icons.calendar_today_rounded, Colors.blue)),
        SizedBox(width: context.cardPadding),
        Expanded(child: _buildPeriodInfoCard(context, 'End Date', _formatDate(profitLoss.endDate), Icons.calendar_today_rounded, Colors.blue)),
        Expanded(
          child: _buildPeriodInfoCard(
            context,
            'Status',
            profitLoss.isProfitable ? 'Profitable' : 'Loss',
            Icons.trending_up_rounded,
            profitLoss.isProfitable ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePeriodInfo(BuildContext context, dynamic profitLoss) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPeriodInfoCard(context, 'Period', profitLoss.periodTypeDisplay, Icons.schedule_rounded, AppTheme.primaryMaroon)),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: _buildPeriodInfoCard(
                context,
                'Status',
                profitLoss.isProfitable ? 'Profitable' : 'Loss',
                Icons.trending_up_rounded,
                profitLoss.isProfitable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: context.smallPadding),
        Row(
          children: [
            Expanded(child: _buildPeriodInfoCard(context, 'From', _formatDate(profitLoss.startDate), Icons.calendar_today_rounded, Colors.blue)),
            SizedBox(width: context.smallPadding),
            Expanded(child: _buildPeriodInfoCard(context, 'To', _formatDate(profitLoss.endDate), Icons.calendar_today_rounded, Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: context.iconSize('small')),
          SizedBox(height: context.smallPadding),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.smallPadding / 2),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: color),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
            child: Icon(Icons.calculate_outlined, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'No Calculation Data Available',
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Calculation details will appear here once profit and loss data is available',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
