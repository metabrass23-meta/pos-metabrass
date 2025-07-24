import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/theme/app_theme.dart';

class LaborTable extends StatelessWidget {
  final Function(Labor) onEdit;
  final Function(Labor) onDelete;

  const LaborTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

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
      child: Column(
        children: [
          // Responsive Table Header
          Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.borderRadius('large')),
                topRight: Radius.circular(context.borderRadius('large')),
              ),
            ),
            child: _buildResponsiveHeaderRow(context),
          ),

          // Table Content
          Expanded(
            child: Consumer<LaborProvider>(
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
                      child: const CircularProgressIndicator(
                        color: AppTheme.primaryMaroon,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                }

                if (provider.labors.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  itemCount: provider.labors.length,
                  itemBuilder: (context, index) {
                    final labor = provider.labors[index];
                    return _buildResponsiveTableRow(context, labor, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeaderRow(BuildContext context) {
    final columnFlexes = context.tableColumnFlexes;

    return Row(
      children: [
        // ID Column
        Expanded(
          flex: columnFlexes[0],
          child: _buildHeaderCell(context, 'ID'),
        ),

        // Name Column
        Expanded(
          flex: columnFlexes[1],
          child: _buildHeaderCell(context, context.isTablet ? 'Name' : 'Labor Name'),
        ),

        // CNIC and Designation Columns (hidden on tablets and small screens)
        if (!context.shouldShowCompactLayout) ...[
          Expanded(
            flex: columnFlexes[2],
            child: _buildHeaderCell(context, 'CNIC'),
          ),
          Expanded(
            flex: columnFlexes[3],
            child: _buildHeaderCell(context, 'Designation'),
          ),
        ],

        // Joining Date and Salary Columns (responsive visibility)
        if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
          Expanded(
            flex: columnFlexes[4],
            child: _buildHeaderCell(context, context.shouldShowFullLayout ? 'Joining Date' : 'Joined'),
          ),
          Expanded(
            flex: columnFlexes[5],
            child: _buildHeaderCell(context, 'Salary'),
          ),
        ],

        // Advance Column (always visible)
        Expanded(
          flex: columnFlexes[context.shouldShowFullLayout ? 10 : context.isMediumDesktop ? 7 : context.shouldShowCompactLayout ? 2 : 6],
          child: _buildHeaderCell(context, 'Advance'),
        ),

        // Additional Columns (only on large screens)
        if (context.shouldShowFullLayout) ...[
          Expanded(
            flex: columnFlexes[6],
            child: _buildHeaderCell(context, 'Area'),
          ),
          Expanded(
            flex: columnFlexes[7],
            child: _buildHeaderCell(context, 'City'),
          ),
          Expanded(
            flex: columnFlexes[8],
            child: _buildHeaderCell(context, 'Gender'),
          ),
          Expanded(
            flex: columnFlexes[9],
            child: _buildHeaderCell(context, 'Age'),
          ),
        ],

        // Actions Column (always visible)
        Expanded(
          flex: columnFlexes[context.shouldShowFullLayout ? 11 : context.isMediumDesktop ? 8 : context.shouldShowCompactLayout ? 3 : 7],
          child: _buildHeaderCell(context, 'Actions'),
        ),
      ],
    );
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

  Widget _buildResponsiveTableRow(BuildContext context, Labor labor, int index) {
    final columnFlexes = context.tableColumnFlexes;

    return Container(
      padding: EdgeInsets.all(context.cardPadding / 2.5),
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
      child: Row(
        children: [
          // ID Column with responsive styling
          Expanded(
            flex: columnFlexes[0],
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallPadding,
                vertical: context.smallPadding / 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Text(
                labor.id,
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryMaroon,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(width: context.smallPadding),

          // Name Column with responsive layout
          Expanded(
            flex: columnFlexes[1],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labor.name,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Show CNIC and designation here on compact layouts
                if (context.shouldShowCompactLayout) ...[
                  SizedBox(height: context.smallPadding / 4),
                  Text(
                    '${labor.cnic} | ${labor.designation}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    maxLines: context.isTablet ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: context.smallPadding),

          // CNIC and Designation Columns (hidden on compact layouts)
          if (!context.shouldShowCompactLayout) ...[
            Expanded(
              flex: columnFlexes[2],
              child: Text(
                labor.cnic,
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              flex: columnFlexes[3],
              child: Text(
                labor.designation,
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Joining Date and Salary Columns (responsive visibility)
          if (context.isMediumDesktop || context.shouldShowFullLayout) ...[
            Expanded(
              flex: columnFlexes[4],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(labor.joiningDate),
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  if (context.shouldShowFullLayout) ...[
                    SizedBox(height: context.smallPadding / 4),
                    Text(
                      _formatTime(labor.joiningDate),
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              flex: columnFlexes[5],
              child: Text(
                'PKR ${labor.salary.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoalGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Advance Column (always visible)
          Expanded(
            flex: columnFlexes[context.shouldShowFullLayout ? 10 : context.isMediumDesktop ? 7 : context.shouldShowCompactLayout ? 2 : 6],
            child: Text(
              'PKR ${labor.advancePayment.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: context.smallPadding),

          // Additional Columns (only on large screens)
          if (context.shouldShowFullLayout) ...[
            Expanded(
              flex: columnFlexes[6],
              child: Text(
                labor.area,
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              flex: columnFlexes[7],
              child: Text(
                labor.city,
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              flex: columnFlexes[8],
              child: Text(
                labor.gender,
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
            Expanded(
              flex: columnFlexes[9],
              child: Text(
                labor.age.toString(),
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.smallPadding),
          ],

          // Actions Column with responsive button sizing
          Expanded(
            flex: columnFlexes[context.shouldShowFullLayout ? 11 : context.isMediumDesktop ? 8 : context.shouldShowCompactLayout ? 3 : 7],
            child: ResponsiveBreakpoints.responsive(
              context,
              tablet: _buildCompactActions(context, labor),
              small: _buildCompactActions(context, labor),
              medium: _buildStandardActions(context, labor),
              large: _buildExpandedActions(context, labor),
              ultrawide: _buildExpandedActions(context, labor),
            ),
          ),
        ],
      ),
    );
  }

  // Compact actions for tablets and small screens
  Widget _buildCompactActions(BuildContext context, Labor labor) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit(labor);
        } else if (value == 'delete') {
          onDelete(labor);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Edit',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontSize: context.captionFontSize,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(context.smallPadding),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
        ),
        child: Icon(
          Icons.more_vert,
          size: context.iconSize('small'),
          color: AppTheme.charcoalGray,
        ),
      ),
    );
  }

  // Standard actions for medium screens
  Widget _buildStandardActions(BuildContext context, Labor labor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onEdit(labor),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding),

        // Delete Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDelete(labor),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Expanded actions for large screens
  Widget _buildExpandedActions(BuildContext context, Labor labor) {
    return Row(
      children: [
        // Edit Button with label
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onEdit(labor),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: context.smallPadding),

        // Delete Button with label
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDelete(labor),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      'Delete',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
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
              tablet: 5.w,
              small: 5.w,
              medium: 5.w,
              large: 5.w,
              ultrawide: 5.w,
            ),
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 5.w,
              small: 5.w,
              medium: 5.w,
              large: 5.w,
              ultrawide: 5.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(context.borderRadius('xl')),
            ),
            child: Icon(
              Icons.person_outline,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),

          SizedBox(height: context.mainPadding),

          Text(
            'No Labor Records Found',
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
              'Start by adding your first labor to manage your workforce effectively',
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
              gradient: const LinearGradient(
                colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
              ),
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
                      Icon(
                        Icons.add_rounded,
                        color: AppTheme.pureWhite,
                        size: context.iconSize('medium'),
                      ),
                      SizedBox(width: context.smallPadding),
                      Text(
                        'Add First Labor',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}