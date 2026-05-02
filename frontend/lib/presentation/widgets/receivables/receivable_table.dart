import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/receivables_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/models/receivables/receivable_model.dart';
import '../../../src/utils/permission_helper.dart';

class ReceivablesTable extends StatefulWidget {
  final Function(Receivable) onEdit;
  final Function(Receivable) onDelete;
  final Function(Receivable) onViewDetails;

  const ReceivablesTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  State<ReceivablesTable> createState() => _ReceivablesTableState();
}

class _ReceivablesTableState extends State<ReceivablesTable> {
  late ScrollController _headerScrollController;
  late ScrollController _contentHorizontalScrollController;
  late ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    _headerScrollController = ScrollController();
    _contentHorizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();

    _headerScrollController.addListener(() {
      if (_contentHorizontalScrollController.hasClients &&
          _headerScrollController.offset != _contentHorizontalScrollController.offset) {
        _contentHorizontalScrollController.jumpTo(_headerScrollController.offset);
      }
    });

    _contentHorizontalScrollController.addListener(() {
      if (_headerScrollController.hasClients &&
          _contentHorizontalScrollController.offset != _headerScrollController.offset) {
        _headerScrollController.jumpTo(_contentHorizontalScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _contentHorizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // Ultra-tight widths to eliminate gaps and ensure no overflow
  double _getTableMinWidth(BuildContext context) {
    if (context.shouldShowCompactLayout) return 1500.0;
    return 1900.0;
  }

  List<double> _getColumnWidths(BuildContext context, double totalWidth) {
    // Fixed widths for columns
    final double debtorWidth = 280.0;
    final double amountWidth = 220.0;
    final double datesWidth = 240.0;
    final double statusWidth = 160.0;
    final double actionsWidth = 250.0;

    final double fixedSum = debtorWidth + amountWidth + datesWidth + statusWidth + actionsWidth + 350.0; 
    
    final double extraSpace = (totalWidth - fixedSum) > 0 ? (totalWidth - fixedSum) : 0;
    final double extraPerColumn = extraSpace / 5; 

    return [
      debtorWidth + extraPerColumn, // 0
      amountWidth + extraPerColumn, // 1
      350.0 + extraPerColumn, // 2: Reason
      datesWidth + extraPerColumn, // 3
      statusWidth, // 4
      actionsWidth, // 5
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minTableWidth = _getTableMinWidth(context);
        final tableWidth = constraints.maxWidth > minTableWidth 
            ? constraints.maxWidth 
            : minTableWidth;

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
          clipBehavior: Clip.antiAlias,
          child: Scrollbar(
            controller: _headerScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                width: tableWidth,
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: AppTheme.lightGray.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: context.cardPadding / 2,
                      ),
                      child: _buildHeaderRow(context, tableWidth - context.cardPadding),
                    ),
                    
                    // Body
                    Expanded(
                      child: Consumer<ReceivablesProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryMaroon));
                          }

                          if (provider.receivables.isEmpty) {
                            return _buildEmptyState();
                          }

                          return Scrollbar(
                            controller: _verticalScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: provider.receivables.length,
                              itemBuilder: (context, index) {
                                return _buildTableRow(context, provider.receivables[index], index, tableWidth - context.cardPadding);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final widths = _getColumnWidths(context, totalWidth);
    return Row(
      children: [
        _buildHeaderCell(widths[0], l10n.debtor),
        _buildHeaderCell(widths[1], l10n.amounts),
        _buildHeaderCell(widths[2], l10n.reasonItem),
        _buildHeaderCell(widths[3], l10n.dates),
        _buildHeaderCell(widths[4], l10n.status, isCenter: true),
        _buildHeaderCell(widths[5], l10n.actions, isCenter: true),
      ],
    );
  }

  Widget _buildHeaderCell(double width, String title, {bool isCenter = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(right: 4),
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: context.bodyFontSize, 
          fontWeight: FontWeight.bold, 
          color: AppTheme.charcoalGray
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, Receivable receivable, int index, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final widths = _getColumnWidths(context, totalWidth);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: context.cardPadding / 2, // Matched with header
      ),
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          // Debtor
          Container(
            width: widths[0],
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                Text(
                  receivable.debtorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '(${receivable.debtorPhone})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: context.captionFontSize, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),

          // Amounts
          Container(
            width: widths[1],
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                Text(
                  'PKR ${receivable.amountGiven.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                ),
                if (receivable.balanceRemaining > 0) ...[
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '(Rem: ${receivable.balanceRemaining.toStringAsFixed(0)})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontSize: context.captionFontSize, color: Colors.red[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Reason
          Container(
            width: widths[2],
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              receivable.reasonOrItem,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(fontSize: context.subtitleFontSize),
            ),
          ),

          // Dates
          Container(
            width: widths[3],
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                Text(
                  receivable.formattedExpectedReturnDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: receivable.isOverdue ? Colors.red : AppTheme.charcoalGray),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '(Lent: ${receivable.formattedDateLent})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: context.captionFontSize, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            width: widths[4],
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: receivable.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: receivable.statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  receivable.statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: context.captionFontSize - 2, fontWeight: FontWeight.bold, color: receivable.statusColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Actions
          Container(
            width: widths[5],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (PermissionHelper.canEdit(context, 'Receivables'))
                  _buildAction(Icons.edit_outlined, Colors.blue, () => widget.onEdit(receivable)),
                if (PermissionHelper.canEdit(context, 'Receivables'))
                  const SizedBox(width: 4),
                _buildAction(Icons.visibility_outlined, Colors.green, () => widget.onViewDetails(receivable)),
                if (PermissionHelper.canDelete(context, 'Receivables'))
                  const SizedBox(width: 4),
                if (PermissionHelper.canDelete(context, 'Receivables'))
                  _buildAction(Icons.delete_outline, Colors.red, () => widget.onDelete(receivable)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('No receivables found', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
