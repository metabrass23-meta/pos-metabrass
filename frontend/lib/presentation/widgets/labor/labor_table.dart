import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/labor/labor_model.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'labor_table_helpers.dart';

class EnhancedLaborTable extends StatefulWidget {
  final Function(LaborModel) onEdit;
  final Function(LaborModel) onDelete;
  final Function(LaborModel) onView;

  const EnhancedLaborTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  State<EnhancedLaborTable> createState() => _EnhancedLaborTableState();
}

class _EnhancedLaborTableState extends State<EnhancedLaborTable> {
  // Separate controllers for synchronized scrolling
  late ScrollController _headerHorizontalController;
  late ScrollController _contentHorizontalController;
  late ScrollController _verticalController;
  late LaborTableHelpers _helpers;

  @override
  void initState() {
    super.initState();
    // Initialize ALL controllers immediately
    _headerHorizontalController = ScrollController();
    _contentHorizontalController = ScrollController();
    _verticalController = ScrollController();

    _helpers = LaborTableHelpers(
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onView: widget.onView,
    );

    // Link the header and content horizontal scrolling (Two-way sync)
    _headerHorizontalController.addListener(() {
      if (_contentHorizontalController.hasClients &&
          _headerHorizontalController.offset != _contentHorizontalController.offset) {
        _contentHorizontalController.jumpTo(_headerHorizontalController.offset);
      }
    });

    _contentHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _contentHorizontalController.offset != _headerHorizontalController.offset) {
        _headerHorizontalController.jumpTo(_contentHorizontalController.offset);
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: context.shadowBlur(),
            offset: Offset(0, context.smallPadding),
          ),
        ],
      ),
      child: Consumer<LaborProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }

          if (provider.hasError) {
            return _helpers.buildErrorState(context, provider);
          }

          if (provider.labors.isEmpty) {
            return _helpers.buildEmptyState(context);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final minTableWidth = _getTableMinWidth(context);
              // Ensure table is at least as wide as the screen, but can be wider for scrolling
              final tableWidth = constraints.maxWidth > minTableWidth 
                  ? constraints.maxWidth 
                  : minTableWidth;

              return Scrollbar(
                thumbVisibility: true,
                trackVisibility: true, // Made it more visible like product screen
                controller: _headerHorizontalController,
                child: SingleChildScrollView(
                  controller: _headerHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // 1. Table Header
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(context.borderRadius('large')),
                              topRight: Radius.circular(context.borderRadius('large')),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: context.cardPadding * 0.85,
                              horizontal: context.cardPadding / 2),
                          child: _buildTableHeader(context, tableWidth - context.cardPadding),
                        ),

                        // 2. Table Content
                        Expanded(
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: SingleChildScrollView(
                              controller: _verticalController,
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: provider.labors.asMap().entries.map((entry) {
                                  return _buildTableRow(context, entry.value, entry.key, tableWidth - context.cardPadding);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        if (provider.paginationInfo != null &&
                            provider.paginationInfo!.totalPages > 1)
                          _buildPaginationControls(context, provider),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: SizedBox(
        width: ResponsiveBreakpoints.responsive(
          context,
          tablet: 3.w,
          small: 6.w,
          medium: 3.w,
          large: 4.w,
          ultrawide: 3.w,
        ),
        height: ResponsiveBreakpoints.responsive(
          context,
          tablet: 3.w,
          small: 6.w,
          medium: 3.w,
          large: 4.w,
          ultrawide: 3.w,
        ),
        child: const CircularProgressIndicator(
          color: AppTheme.primaryMaroon,
          strokeWidth: 3,
        ),
      ),
    );
  }

  double _getTableMinWidth(BuildContext context) {
    if (context.shouldShowCompactLayout) return 1400.0;
    return 1800.0;
  }

  List<double> _getColumnWidths(BuildContext context, double totalWidth) {
    final bool isCompact = context.shouldShowCompactLayout;
    
    // Fixed widths for columns that shouldn't expand
    final double phoneWidth = 180.0;
    final double cnicWidth = 200.0;
    final double designationWidth = 200.0;
    final double salaryWidth = 160.0;
    final double cityWidth = 160.0;
    final double statusWidth = 140.0;
    final double dateWidth = 200.0;
    final double actionsWidth = 320.0;

    double fixedSum = phoneWidth + cnicWidth + designationWidth + statusWidth + dateWidth + actionsWidth;
    if (!isCompact) {
      fixedSum += salaryWidth + cityWidth;
    }

    // Name column gets the remaining space
    final double nameWidth = totalWidth - fixedSum;

    if (isCompact) {
      return [
        nameWidth, // Name
        phoneWidth,
        cnicWidth,
        designationWidth,
        statusWidth,
        dateWidth,
        actionsWidth,
      ];
    } else {
      return [
        nameWidth, // Name
        phoneWidth,
        cnicWidth,
        designationWidth,
        salaryWidth,
        cityWidth,
        statusWidth,
        dateWidth,
        actionsWidth,
      ];
    }
  }

  Widget _buildTableHeader(BuildContext context, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Row(
      children: [
        Container(
          width: columnWidths[0],
          child: _buildSortableHeaderCell(context, l10n.name, 'name'),
        ),
        Container(
          width: columnWidths[1],
          child: _buildHeaderCell(context, l10n.phone),
        ),
        Container(
          width: columnWidths[2],
          child: _buildHeaderCell(context, l10n.cnic),
        ),
        Container(
          width: columnWidths[3],
          child: _buildSortableHeaderCell(context, l10n.designation, 'designation'),
        ),
        if (!context.shouldShowCompactLayout)
          Container(
            width: columnWidths[4],
            child: _buildSortableHeaderCell(context, l10n.salary, 'salary', isCenter: true),
          ),
        if (!context.shouldShowCompactLayout)
          Container(
            width: columnWidths[5],
            child: _buildHeaderCell(context, l10n.city),
          ),
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 4 : 6],
          child: _buildHeaderCell(context, l10n.status, isCenter: true),
        ),
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 5 : 7],
          child: _buildSortableHeaderCell(context, l10n.joinedDate, 'joining_date', isCenter: true),
        ),
        Container(
          width: columnWidths[context.shouldShowCompactLayout ? 6 : 8],
          child: _buildHeaderCell(context, l10n.actions, isCenter: true),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title, {bool isCenter = false}) {
    return Container(
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: context.bodyFontSize,
          fontWeight: FontWeight.w600,
          color: AppTheme.charcoalGray,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSortableHeaderCell(
      BuildContext context, String title, String sortKey, {bool isCenter = false}) {
    return Consumer<LaborProvider>(
      builder: (context, provider, child) {
        final isCurrentSort = provider.sortBy == sortKey;

        return InkWell(
          onTap: () => provider.setSortBy(sortKey),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: 4),
            child: Row(
              mainAxisAlignment: isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: isCenter ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: isCurrentSort ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  isCurrentSort
                      ? (provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                      : Icons.sort,
                  size: 16,
                  color: isCurrentSort ? AppTheme.primaryMaroon : Colors.grey[500],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableRow(BuildContext context, LaborModel labor, int index, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven
            ? AppTheme.pureWhite
            : AppTheme.lightGray.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.cardPadding / 2,
        horizontal: context.cardPadding / 2, // Matched with header padding
      ),
      child: Row(
        children: [
          Container(
            width: columnWidths[0],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                if (labor.isNewLabor || labor.isRecentLabor) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Row(
                    children: [
                      if (labor.isNewLabor)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.newLabel,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      if (labor.isRecentLabor && !labor.isNewLabor) ...[
                        if (labor.isNewLabor) SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.recentLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: columnWidths[1],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              labor.formattedPhone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
          Container(
            width: columnWidths[2],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              labor.cnic ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
          Container(
            width: columnWidths[3],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Text(
              labor.designation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[4],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Center(
                child: Text(
                  'PKR ${labor.salary.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ),
            ),
          if (!context.shouldShowCompactLayout)
            Container(
              width: columnWidths[5],
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Text(
                labor.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ),
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 4 : 6],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: _helpers.getStatusColor(labor.isActive ? 'Active' : 'Inactive').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(
                    color: _helpers.getStatusColor(labor.isActive ? 'Active' : 'Inactive').withOpacity(0.3),
                  ),
                ),
                child: Text(
                  labor.isActive ? l10n.active : l10n.inactive,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: ResponsiveBreakpoints.getDashboardCaptionFontSize(context),
                    fontWeight: FontWeight.w600,
                    color: _helpers.getStatusColor(labor.isActive ? 'Active' : 'Inactive'),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 5 : 7],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(
              child: Text(
                _formatDate(labor.joiningDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ),
          ),
          Container(
            width: columnWidths[context.shouldShowCompactLayout ? 6 : 8],
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
            child: Center(child: _helpers.buildActionsRow(context, labor)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, LaborProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final pagination = provider.paginationInfo!;

    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.borderRadius('large')),
          bottomRight: Radius.circular(context.borderRadius('large')),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${l10n.showing} ${((pagination.currentPage - 1) * pagination.pageSize) + 1}-${pagination.currentPage * pagination.pageSize > pagination.totalCount ? pagination.totalCount : pagination.currentPage * pagination.pageSize} ${l10n.outOf} ${pagination.totalCount} ${l10n.labors}',
            style: TextStyle(
              fontSize: context.subtitleFontSize,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: pagination.hasPrevious ? provider.loadPreviousPage : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: pagination.hasPrevious ? AppTheme.primaryMaroon : Colors.grey[400],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.cardPadding,
                  vertical: context.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                ),
                child: Text(
                  '${pagination.currentPage} ${l10n.outOf} ${pagination.totalPages}',
                  style: TextStyle(
                    fontSize: context.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),
              IconButton(
                onPressed: pagination.hasNext ? provider.loadNextPage : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: pagination.hasNext ? AppTheme.primaryMaroon : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
