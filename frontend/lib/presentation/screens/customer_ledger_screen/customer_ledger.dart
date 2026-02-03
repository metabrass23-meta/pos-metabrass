import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/src/providers/customer_ledger_provider.dart';
import 'package:frontend/src/theme/app_theme.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';

import '../../../src/models/customer_ledger/customer_ledger_model.dart';

class CustomerLedgerScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerLedgerScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔵 CustomerLedgerScreen initialized with customerId: ${widget.customerId}, customerName: ${widget.customerName}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLedger();
    });
  }

  Future<void> _loadLedger() async {
    debugPrint('🔵 Loading ledger for customer: ${widget.customerId}');
    final provider = context.read<CustomerLedgerProvider>();
    await provider.loadCustomerLedger(
      customerId: widget.customerId,
      customerName: widget.customerName,
    );
    debugPrint('✅ Ledger loaded successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: _buildAppBar(context),
      body: Consumer<CustomerLedgerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.hasError) {
            return _buildErrorState(provider.errorMessage ?? 'An error occurred');
          }

          if (!provider.hasLedgerEntries) {
            return _buildEmptyState();
          }

          return _buildLedgerContent(provider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryMaroon,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.pureWhite),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Ledger',
            style: TextStyle(
              fontSize: context.headerFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.pureWhite,
            ),
          ),
          Text(
            widget.customerName,
            style: TextStyle(
              fontSize: context.captionFontSize,
              color: AppTheme.pureWhite.withOpacity(0.8),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list_rounded, color: AppTheme.pureWhite),
          onPressed: () => _showFilterDialog(),
        ),
        IconButton(
          icon: Icon(Icons.download_rounded, color: AppTheme.pureWhite),
          onPressed: () => _showExportDialog(),
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppTheme.pureWhite),
          onPressed: () => _loadLedger(),
        ),
        SizedBox(width: context.smallPadding),
      ],
    );
  }

  Widget _buildLedgerContent(CustomerLedgerProvider provider) {
    debugPrint('📊 Building ledger content with ${provider.ledgerEntries.length} entries');
    return Column(
      children: [
        // Summary Card
        if (provider.summary != null) _buildSummaryCard(provider.summary!),

        // Ledger Table
        Expanded(
          child: Container(
            margin: EdgeInsets.all(context.mainPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: context.shadowBlur('light'),
                  offset: Offset(0, context.smallPadding / 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                Expanded(
                  child: _buildLedgerTable(provider.ledgerEntries),
                ),
                _buildPagination(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(CustomerLedgerSummary summary) {
    return Container(
      margin: EdgeInsets.all(context.mainPadding),
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, context.smallPadding / 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryMaroon,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Sales',
                  summary.formattedTotalSales,
                  Icons.shopping_cart,
                  Colors.green,
                ),
              ),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: _buildSummaryItem(
                  'Total Payments',
                  summary.formattedTotalPayments,
                  Icons.payment,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Receivables',
                  summary.formattedTotalReceivables,
                  Icons.account_balance,
                  Colors.orange,
                ),
              ),
              SizedBox(width: context.smallPadding),
              Expanded(
                child: _buildSummaryItem(
                  'Outstanding Balance',
                  summary.formattedOutstandingBalance,
                  Icons.account_balance_wallet,
                  summary.outstandingBalance > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: context.iconSize('small')),
              SizedBox(width: context.smallPadding),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),
          Text(
            value,
            style: TextStyle(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius()),
          topRight: Radius.circular(context.borderRadius()),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryMaroon,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Description',
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryMaroon,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryMaroon,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Debit',
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryMaroon,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Credit',
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryMaroon,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Balance',
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryMaroon,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTable(List<CustomerLedgerEntry> entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLedgerRow(entry, index);
      },
    );
  }

  Widget _buildLedgerRow(CustomerLedgerEntry entry, int index) {
    final isEven = index % 2 == 0;
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[50] : AppTheme.pureWhite,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              entry.formattedDate,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.referenceNumber != null)
                  Text(
                    entry.referenceNumber!,
                    style: TextStyle(
                      fontSize: context.captionFontSize,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding,
              ),
              decoration: BoxDecoration(
                color: entry.isDebit 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                entry.transactionTypeDisplay,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: entry.isDebit ? Colors.red[700] : Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.formattedDebit,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: entry.isDebit ? FontWeight.w600 : FontWeight.normal,
                color: entry.isDebit ? Colors.red[700] : Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.formattedCredit,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: entry.isCredit ? FontWeight.w600 : FontWeight.normal,
                color: entry.isCredit ? Colors.green[700] : Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.formattedBalance,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: entry.balance >= 0 ? Colors.black87 : Colors.red[700],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(CustomerLedgerProvider provider) {
    if (provider.totalPages <= 1) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.borderRadius()),
          bottomRight: Radius.circular(context.borderRadius()),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${provider.currentPage} of ${provider.totalPages}',
            style: TextStyle(
              fontSize: context.bodyFontSize,
              color: Colors.grey[600],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: provider.hasPrevious
                    ? () => provider.loadPreviousPage()
                    : null,
                icon: Icon(Icons.chevron_left),
                color: provider.hasPrevious ? AppTheme.primaryMaroon : Colors.grey,
              ),
              IconButton(
                onPressed: provider.hasNext
                    ? () => provider.loadNextPage()
                    : null,
                icon: Icon(Icons.chevron_right),
                color: provider.hasNext ? AppTheme.primaryMaroon : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryMaroon,
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Loading ledger...',
            style: TextStyle(
              fontSize: context.bodyFontSize,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.iconSize('large'),
            color: Colors.red,
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'Error loading ledger',
            style: TextStyle(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            error,
            style: TextStyle(
              fontSize: context.bodyFontSize,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.smallPadding),
          ElevatedButton.icon(
            onPressed: () => _loadLedger(),
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryMaroon,
              foregroundColor: AppTheme.pureWhite,
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
          Icon(
            Icons.account_balance_wallet_outlined,
            size: context.iconSize('large'),
            color: Colors.grey[400],
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'No ledger entries',
            style: TextStyle(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            'This customer has no transactions yet',
            style: TextStyle(
              fontSize: context.bodyFontSize,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Ledger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter options coming soon...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Ledger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Export options coming soon...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
