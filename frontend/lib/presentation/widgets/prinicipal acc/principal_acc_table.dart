import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/prinicipal_acc_provider.dart';
import '../../../src/theme/app_theme.dart';

class PrincipalAccountTable extends StatefulWidget {
  final Function(PrincipalAccount) onEdit;
  final Function(PrincipalAccount) onDelete;
  final Function(PrincipalAccount) onView;

  const PrincipalAccountTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  State<PrincipalAccountTable> createState() => _PrincipalAccountTableState();
}

class _PrincipalAccountTableState extends State<PrincipalAccountTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, context.smallPadding),
          ),
        ],
      ),
      child: Consumer<PrincipalAccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: SizedBox(
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
                child: const CircularProgressIndicator(color: AppTheme.primaryMaroon, strokeWidth: 3),
              ),
            );
          }

          if (provider.accounts.isEmpty) {
            return _buildEmptyState(context);
          }

          return Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            child: Column(
              children: [
                // Current Balance Header
                _buildBalanceHeader(context, provider),

                // Table Header with Horizontal Scroll
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(context.borderRadius('large')),
                      topRight: Radius.circular(context.borderRadius('large')),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      width: _getTableWidth(context),
                      padding: EdgeInsets.all(context.cardPadding),
                      child: _buildTableHeader(context),
                    ),
                  ),
                ),

                // Table Content with Synchronized Scroll
                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        width: _getTableWidth(context),
                        child: ListView.builder(
                          controller: _verticalController,
                          itemCount: provider.accounts.length,
                          itemBuilder: (context, index) {
                            final account = provider.accounts[index];
                            return _buildTableRow(context, account, index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceHeader(BuildContext context, PrincipalAccountProvider provider) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.borderRadius('large')),
          topRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.pureWhite.withOpacity(0.9),
                  ),
                ),
                Text(
                  'PKR ${provider.currentBalance.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Text(
              '${provider.accounts.length} Transactions',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getTableWidth(BuildContext context) {
    // Fixed table width to ensure all columns are visible
    return ResponsiveBreakpoints.responsive(
      context,
      tablet: 1800.0,
      small: 1900.0,
      medium: 2000.0,
      large: 2100.0,
      ultrawide: 2200.0,
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        // Entry ID
        Container(width: columnWidths[0], child: _buildHeaderCell(context, 'Entry ID')),

        // Source Module
        Container(width: columnWidths[1], child: _buildHeaderCell(context, 'Source Module')),

        // Description
        Container(width: columnWidths[2], child: _buildHeaderCell(context, 'Description')),

        // Type
        Container(width: columnWidths[3], child: _buildHeaderCell(context, 'Type')),

        // Amount
        Container(width: columnWidths[4], child: _buildHeaderCell(context, 'Amount')),

        // Balance After
        Container(width: columnWidths[5], child: _buildHeaderCell(context, 'Balance After')),

        // Handled By
        Container(width: columnWidths[6], child: _buildHeaderCell(context, 'Handled By')),

        // Date
        Container(width: columnWidths[7], child: _buildHeaderCell(context, 'Date')),

        // Time
        Container(width: columnWidths[8], child: _buildHeaderCell(context, 'Time')),

        // Actions
        Container(width: columnWidths[9], child: _buildHeaderCell(context, 'Actions')),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context) {
    return [
      130.0, // Entry ID
      150.0, // Source Module
      300.0, // Description
      120.0, // Type
      140.0, // Amount
      150.0, // Balance After
      160.0, // Handled By
      130.0, // Date
      120.0, // Time
      260.0, // Actions
    ];
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: context.bodyFontSize,
        fontWeight: FontWeight.w600,
        color: AppTheme.charcoalGray,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, PrincipalAccount account, int index) {
    final columnWidths = _getColumnWidths(context);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
      child: Row(
        children: [
          // Entry ID
          Container(
            width: columnWidths[0],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding / 2,
                vertical: context.smallPadding / 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                account.id,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryMaroon,
                ),
              ),
            ),
          ),

          // Source Module
          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding / 2,
                vertical: context.smallPadding / 4,
              ),
              decoration: BoxDecoration(
                color: account.sourceModuleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSourceModuleIcon(account.sourceModule),
                    color: account.sourceModuleColor,
                    size: context.iconSize('small'),
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Expanded(
                    child: Text(
                      account.formattedSourceModule,
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w600,
                        color: account.sourceModuleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Description
          Container(
            width: columnWidths[2],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              account.description,
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Type
          Container(
            width: columnWidths[3],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding / 2,
                vertical: context.smallPadding / 4,
              ),
              decoration: BoxDecoration(
                color: account.typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(account.typeIcon, color: account.typeColor, size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    account.type.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w700,
                      color: account.typeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Amount
          Container(
            width: columnWidths[4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 3,
              ),
              decoration: BoxDecoration(
                color: account.typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                'PKR ${account.amount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w700,
                  color: account.typeColor,
                ),
              ),
            ),
          ),

          // Balance After
          Container(
            width: columnWidths[5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 3,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                'PKR ${account.balanceAfter.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),

          // Handled By
          Container(
            width: columnWidths[6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: account.handledBy != null
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.smallPadding / 2,
                      vertical: context.smallPadding / 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPersonColor(account.handledBy!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getPersonColor(account.handledBy!),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: AppTheme.pureWhite, size: 10),
                        ),
                        SizedBox(width: context.smallPadding / 2),
                        Expanded(
                          child: Text(
                            account.handledBy!,
                            style: GoogleFonts.inter(
                              fontSize: context.captionFontSize,
                              fontWeight: FontWeight.w600,
                              color: _getPersonColor(account.handledBy!),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    'Not specified',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),

          // Date
          Container(
            width: columnWidths[7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                Text(
                  account.relativeDate,
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Time
          Container(
            width: columnWidths[8],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding / 2,
                vertical: context.smallPadding / 4,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.purple, size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    account.formattedTime,
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            width: columnWidths[9],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: _buildActions(context, account),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, PrincipalAccount account) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onView(account),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(Icons.visibility_outlined, color: Colors.purple, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onEdit(account),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(Icons.edit_outlined, color: Colors.blue, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Print/Export Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export account entry ${account.id}'), backgroundColor: Colors.green),
              );
            },
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(Icons.download_outlined, color: Colors.green, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        // Delete Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onDelete(account),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red, size: context.iconSize('small')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              Icons.account_balance_wallet_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Principal Account Records Found',
            style: GoogleFonts.inter(
              fontSize: context.headerFontSize * 0.8,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(
                context,
                tablet: 80.w,
                small: 70.w,
                medium: 60.w,
                large: 50.w,
                ultrawide: 40.w,
              ),
            ),
            child: Text(
              'Start by adding your first principal account entry to track all cash movements',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: context.mainPadding),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon]),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // This will be handled by the parent widget
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.cardPadding * 0.6,
                    vertical: context.cardPadding / 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Add First Entry',
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.pureWhite,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSourceModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'sales':
        return Icons.point_of_sale_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'advance_payment':
        return Icons.schedule_send_rounded;
      case 'expenses':
        return Icons.receipt_long_rounded;
      case 'receivables':
        return Icons.account_balance_outlined;
      case 'payables':
        return Icons.money_off_outlined;
      case 'zakat':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  Color _getPersonColor(String person) {
    switch (person) {
      case 'Parveez Maqbool':
        return Colors.blue;
      case 'Zain Maqbool':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
