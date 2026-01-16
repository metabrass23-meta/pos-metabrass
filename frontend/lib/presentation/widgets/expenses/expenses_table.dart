import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/expenses/expenses_model.dart';
import '../../../src/providers/expenses_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ExpensesTable extends StatefulWidget {
  final Function(Expense) onEdit;
  final Function(Expense) onDelete;
  final Function(Expense) onView;

  const ExpensesTable({super.key, required this.onEdit, required this.onDelete, required this.onView});

  @override
  State<ExpensesTable> createState() => _ExpensesTableState();
}

class _ExpensesTableState extends State<ExpensesTable> {
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _contentHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _headerHorizontalController.addListener(() {
      if (_contentHorizontalController.hasClients) {
        _contentHorizontalController.jumpTo(_headerHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerHorizontalController.dispose();
    _contentHorizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: context.shadowBlur(), offset: Offset(0, context.smallPadding))],
      ),
      child: Consumer<ExpensesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }

          if (provider.hasError) {
            return _buildErrorState(context, provider);
          }

          if (provider.expenses.isEmpty) {
            return _buildEmptyState(context);
          }

          return Scrollbar(
            controller: _headerHorizontalController,
            thumbVisibility: true,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(context.borderRadius('large')),
                      topRight: Radius.circular(context.borderRadius('large')),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _headerHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Container(width: _getTableWidth(context), padding: EdgeInsets.all(context.cardPadding), child: _buildTableHeader(context)),
                  ),
                ),

                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _contentHorizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        width: _getTableWidth(context),
                        child: ListView.builder(
                          controller: _verticalController,
                          itemCount: provider.expenses.length,
                          itemBuilder: (context, index) {
                            final expense = provider.expenses[index];
                            return _buildTableRow(context, expense, index);
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

  double _getTableWidth(BuildContext context) {
    return ResponsiveBreakpoints.responsive(context, tablet: 1500.0, small: 1600.0, medium: 1700.0, large: 1800.0, ultrawide: 1900.0);
  }

  Widget _buildTableHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context);

    return Row(
      children: [
        Container(width: columnWidths[0], child: _buildHeaderCell(context, l10n.expenseId)),
        Container(width: columnWidths[1], child: _buildHeaderCell(context, l10n.expense)),
        Container(width: columnWidths[2], child: _buildHeaderCell(context, l10n.description)),
        Container(width: columnWidths[3], child: _buildHeaderCell(context, l10n.amount)),
        Container(width: columnWidths[4], child: _buildHeaderCell(context, l10n.withdrawalBy)),
        Container(width: columnWidths[5], child: _buildHeaderCell(context, l10n.date)),
        Container(width: columnWidths[6], child: _buildHeaderCell(context, l10n.time)),
        Container(width: columnWidths[7], child: _buildHeaderCell(context, l10n.actions)),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context) {
    return [
      130.0,
      180.0,
      280.0,
      140.0,
      180.0,
      130.0,
      120.0,
      260.0,
    ];
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray, letterSpacing: 0.2),
    );
  }

  Widget _buildTableRow(BuildContext context, Expense expense, int index) {
    final columnWidths = _getColumnWidths(context);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.pureWhite : AppTheme.lightGray.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
      child: Row(
        children: [
          Container(
            width: columnWidths[0],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                expense.id,
                style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Text(
                expense.expense,
                style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: Colors.orange[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          Container(
            width: columnWidths[2],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              expense.description,
              style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Container(
            width: columnWidths[3],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 3),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Text(
                'PKR ${expense.amount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w700, color: Colors.red[700]),
              ),
            ),
          ),

          Container(
            width: columnWidths[4],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
              decoration: BoxDecoration(
                color: expense.personColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(color: expense.personColor, shape: BoxShape.circle),
                    child: Icon(Icons.person, color: AppTheme.pureWhite, size: 10),
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Expanded(
                    child: Text(
                      expense.withdrawalBy,
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: expense.personColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: columnWidths[5],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.formattedDate,
                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
                ),
                Text(
                  expense.relativeDate,
                  style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Container(
            width: columnWidths[6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding / 2, vertical: context.smallPadding / 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.blue, size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    expense.formattedTime,
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: columnWidths[7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: _buildActions(context, expense),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Expense expense) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onView(expense),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.visibility_outlined, color: Colors.purple, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onEdit(expense),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.edit_outlined, color: Colors.blue, size: context.iconSize('small')),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding / 2),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onDelete(expense),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Icon(Icons.delete_outline, color: Colors.red, size: context.iconSize('small')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.receipt_long_outlined, size: context.iconSize('xl'), color: Colors.grey[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            l10n.noExpenseRecordsFound,
            style: GoogleFonts.inter(fontSize: context.headerFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              l10n.startAddingFirstExpense,
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
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
                onTap: () {},
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        l10n.addFirstExpense,
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

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveBreakpoints.responsive(context, tablet: 8.w, small: 6.w, medium: 5.w, large: 4.w, ultrawide: 3.w),
        height: ResponsiveBreakpoints.responsive(context, tablet: 8.w, small: 6.w, medium: 5.w, large: 4.w, ultrawide: 3.w),
        child: const CircularProgressIndicator(color: AppTheme.primaryMaroon, strokeWidth: 3),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ExpensesProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            height: ResponsiveBreakpoints.responsive(context, tablet: 15.w, small: 20.w, medium: 12.w, large: 10.w, ultrawide: 8.w),
            decoration: BoxDecoration(color: AppTheme.lightGray, borderRadius: BorderRadius.circular(context.borderRadius('xl'))),
            child: Icon(Icons.error_outline, size: context.iconSize('xl'), color: Colors.red[400]),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            '${l10n.errorLoadingExpenses}: ${provider.errorMessage}',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize * 0.8, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.smallPadding),

          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 80.w, small: 70.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
            ),
            child: Text(
              l10n.pleaseTryAgainLater,
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
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
                  provider.loadExpenseRecords();
                },
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.cardPadding * 0.6, vertical: context.cardPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
                      SizedBox(width: context.smallPadding),
                      Text(
                        l10n.retryLoading,
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
}
