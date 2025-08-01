import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/profit_loss_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../widgets/profit loss/profit_loss_metrics_section.dart';
import '../../widgets/profit loss/profit_loss_period_selector.dart';

class ProfitLossPage extends StatefulWidget {
  const ProfitLossPage({super.key});

  @override
  State<ProfitLossPage> createState() => _ProfitLossPageState();
}

class _ProfitLossPageState extends State<ProfitLossPage> {
  @override
  void initState() {
    super.initState();
    // Initialize with current month data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfitLossProvider>(context, listen: false);
      provider.setPeriodType('monthly');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isMinimumSupported) {
      return _buildUnsupportedScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Consumer<ProfitLossProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.all(context.mainPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveBreakpoints.responsive(
                  context,
                  tablet: _buildTabletHeader(provider),
                  small: _buildMobileHeader(provider),
                  medium: _buildDesktopHeader(provider),
                  large: _buildDesktopHeader(provider),
                  ultrawide: _buildDesktopHeader(provider),
                ),
                SizedBox(height: context.mainPadding),

                // Period Selector Component
                ProfitLossPeriodSelector(),
                SizedBox(height: context.cardPadding),

                // Main Content
                Expanded(
                  child: provider.isLoading
                      ? _buildLoadingState()
                      : provider.currentProfitLoss == null
                      ? _buildEmptyState()
                      : _buildProfitLossContent(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnsupportedScreen() {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.screen_rotation_outlined,
                size: 15.w,
                color: Colors.grey[400],
              ),
              SizedBox(height: 3.h),
              Text(
                'Screen Too Small',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 6.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoalGray,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'This application requires a minimum screen width of 750px for optimal experience. Please use a larger screen or rotate your device.',
                style: GoogleFonts.inter(
                  fontSize: 3.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(ProfitLossProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: AppTheme.primaryMaroon,
                    size: context.iconSize('large'),
                  ),
                  SizedBox(width: context.cardPadding),
                  Text(
                    'Profit & Loss Statement',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: context.headerFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.charcoalGray,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.cardPadding / 4),
              Text(
                'Financial performance analysis and profitability tracking',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              if (provider.currentProfitLoss != null) ...[
                SizedBox(height: context.smallPadding),
                Text(
                  'Period: ${provider.currentProfitLoss!.formattedPeriod}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ],
            ],
          ),
        ),
        _buildExportButton(),
      ],
    );
  }

  Widget _buildTabletHeader(ProfitLossProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              color: AppTheme.primaryMaroon,
              size: context.iconSize('large'),
            ),
            SizedBox(width: context.cardPadding),
            Text(
              'Profit & Loss',
              style: GoogleFonts.playfairDisplay(
                fontSize: context.headerFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoalGray,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Financial performance analysis',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        if (provider.currentProfitLoss != null) ...[
          SizedBox(height: context.smallPadding),
          Text(
            'Period: ${provider.currentProfitLoss!.formattedPeriod}',
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryMaroon,
            ),
          ),
        ],
        SizedBox(height: context.cardPadding),
        SizedBox(
          width: double.infinity,
          child: _buildExportButton(),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(ProfitLossProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              color: AppTheme.primaryMaroon,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              'P&L',
              style: GoogleFonts.playfairDisplay(
                fontSize: context.headerFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoalGray,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: context.cardPadding / 4),
        Text(
          'Financial analysis',
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        if (provider.currentProfitLoss != null) ...[
          SizedBox(height: context.smallPadding),
          Text(
            provider.currentProfitLoss!.formattedPeriod,
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryMaroon,
            ),
          ),
        ],
        SizedBox(height: context.cardPadding),
        SizedBox(
          width: double.infinity,
          child: _buildExportButton(),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final provider = Provider.of<ProfitLossProvider>(context, listen: false);
            provider.exportProfitLossReport();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('P&L Report exported successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
          borderRadius: BorderRadius.circular(context.borderRadius()),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.cardPadding * 0.5,
              vertical: context.cardPadding / 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download_rounded,
                  color: AppTheme.accentGold,
                  size: context.iconSize('medium'),
                ),
                SizedBox(width: context.smallPadding),
                Text(
                  context.isTablet ? 'Export' : 'Export Report',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveBreakpoints.responsive(
              context,
              tablet: 8.w,
              small: 6.w,
              medium: 5.w,
              large: 4.w,
              ultrawide: 3.w,
            ),
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 8.w,
              small: 6.w,
              medium: 5.w,
              large: 4.w,
              ultrawide: 3.w,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryMaroon,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'Calculating Profit & Loss...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(
              context,
              tablet: 15.w,
              small: 20.w,
              medium: 12.w,
              large: 10.w,
              ultrawide: 8.w,
            ),
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 15.w,
              small: 20.w,
              medium: 12.w,
              large: 10.w,
              ultrawide: 8.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(context.borderRadius('xl')),
            ),
            child: Icon(
              Icons.trending_up_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            'No Financial Data Available',
            style: GoogleFonts.inter(
              fontSize: context.headerFontSize * 0.8,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Select a period to view profit and loss analysis',
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitLossContent(ProfitLossProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Metrics Section Component
          ProfitLossMetricsSection(),

          SizedBox(height: context.cardPadding),

          // Simple Expense Analysis
          _buildExpenseAnalysis(provider),
        ],
      ),
    );
  }

  Widget _buildExpenseAnalysis(ProfitLossProvider provider) {
    final data = provider.currentProfitLoss!;
    final breakdown = provider.getExpenseBreakdown();

    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(
                Icons.analytics_rounded,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Expense Breakdown',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),

          // Expense Items
          ...breakdown.map((item) => Padding(
            padding: EdgeInsets.only(bottom: context.smallPadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.smallPadding / 2),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  ),
                  child: Icon(
                    _getExpenseIcon(item['category']),
                    color: item['color'],
                    size: context.iconSize('small'),
                  ),
                ),
                SizedBox(width: context.cardPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['category'],
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                      Text(
                        '${(item['percentage'] as double).toStringAsFixed(1)}% of expenses',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'PKR ${(item['amount'] as double).toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: item['color'],
                  ),
                ),
              ],
            ),
          )).toList(),

          Divider(height: context.cardPadding * 2),

          // Total and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Expenses',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    data.formattedTotalExpenses,
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: (data.isProfitable ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Column(
                  children: [
                    Text(
                      data.isProfitable ? 'PROFITABLE' : 'LOSS',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w700,
                        color: data.isProfitable ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      data.formattedNetProfit,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w700,
                        color: data.isProfitable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getExpenseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'labor payments':
        return Icons.people_rounded;
      case 'vendor payments':
        return Icons.store_rounded;
      case 'other expenses':
        return Icons.receipt_long_rounded;
      case 'zakat':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.category_outlined;
    }
  }
}