import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/labor_provider.dart';
import '../../../src/models/labor/labor_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';

class DeleteLaborHeader extends StatelessWidget {
  final LaborModel labor;
  final bool isPermanentDelete;
  final VoidCallback onCancel;

  const DeleteLaborHeader({
    super.key,
    required this.labor,
    required this.isPermanentDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPermanentDelete
              ? [Colors.red, Colors.redAccent]
              : [Colors.orange, Colors.orangeAccent],
        ),
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
              isPermanentDelete ? Icons.delete_forever_rounded : Icons.visibility_off_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('large'),
            ),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPermanentDelete ? 'Delete Permanently' : 'Deactivate Labor',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: context.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.pureWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!context.isTablet) ...[
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    isPermanentDelete
                        ? 'This action cannot be undone'
                        : 'Labor can be restored later',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.pureWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallPadding,
              vertical: context.smallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Text(
              labor.id.length > 8 ? '${labor.id.substring(0, 8)}...' : labor.id,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
          SizedBox(width: context.smallPadding),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.pureWhite,
                  size: context.iconSize('medium'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteLaborContent extends StatelessWidget {
  final LaborModel labor;
  final bool isPermanentDelete;
  final bool confirmationChecked;
  final bool understandConsequences;
  final TextEditingController confirmationController;
  final Function(bool) onDeleteTypeChange;
  final Function(bool) onConfirmationCheckedChange;
  final Function(bool) onUnderstandConsequencesChange;
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final bool Function() validateDeletion;

  const DeleteLaborContent({
    super.key,
    required this.labor,
    required this.isPermanentDelete,
    required this.confirmationChecked,
    required this.understandConsequences,
    required this.confirmationController,
    required this.onDeleteTypeChange,
    required this.onConfirmationCheckedChange,
    required this.onUnderstandConsequencesChange,
    required this.onDelete,
    required this.onCancel,
    required this.validateDeletion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWarningMessage(context),
            SizedBox(height: context.cardPadding),
            _buildDeleteTypeToggle(context),
            SizedBox(height: context.cardPadding),
            _buildLaborDetailsCard(context),
            SizedBox(height: context.cardPadding),
            _buildConfirmationSection(context),
            SizedBox(height: context.mainPadding),
            ResponsiveBreakpoints.responsive(
              context,
              tablet: _buildCompactButtons(context),
              small: _buildCompactButtons(context),
              medium: _buildDesktopButtons(context),
              large: _buildDesktopButtons(context),
              ultrawide: _buildDesktopButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: (isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: isPermanentDelete ? Colors.red : Colors.orange,
            size: context.iconSize('large'),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPermanentDelete ? 'Permanent Deletion Warning' : 'Deactivation Notice',
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w700,
                    color: isPermanentDelete ? Colors.red[700] : Colors.orange[700],
                  ),
                ),
                SizedBox(height: context.smallPadding / 2),
                Text(
                  isPermanentDelete
                      ? 'This will permanently remove all labor data from the database. This action cannot be reversed.'
                      : 'This will deactivate the labor but preserve all data. The labor can be restored later if needed.',
                  style: GoogleFonts.inter(
                    fontSize: context.subtitleFontSize,
                    color: AppTheme.charcoalGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteTypeToggle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Choose deletion type:',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          ResponsiveBreakpoints.responsive(
            context,
            tablet: _buildDeleteOptionsColumn(context),
            small: _buildDeleteOptionsColumn(context),
            medium: _buildDeleteOptionsRow(context),
            large: _buildDeleteOptionsRow(context),
            ultrawide: _buildDeleteOptionsRow(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteOptionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDeleteOption(
            context,
            title: 'Permanent Delete',
            subtitle: 'Removes from database permanently',
            icon: Icons.delete_forever_rounded,
            color: Colors.red,
            isSelected: isPermanentDelete,
            onTap: () => onDeleteTypeChange(true),
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: _buildDeleteOption(
            context,
            title: 'Deactivate',
            subtitle: 'Hide but can be restored',
            icon: Icons.visibility_off_rounded,
            color: Colors.orange,
            isSelected: !isPermanentDelete,
            onTap: () => onDeleteTypeChange(false),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteOptionsColumn(BuildContext context) {
    return Column(
      children: [
        _buildDeleteOption(
          context,
          title: 'Permanent Delete',
          subtitle: 'Removes from database permanently',
          icon: Icons.delete_forever_rounded,
          color: Colors.red,
          isSelected: isPermanentDelete,
          onTap: () => onDeleteTypeChange(true),
        ),
        SizedBox(height: context.cardPadding),
        _buildDeleteOption(
          context,
          title: 'Deactivate',
          subtitle: 'Hide but can be restored',
          icon: Icons.visibility_off_rounded,
          color: Colors.orange,
          isSelected: !isPermanentDelete,
          onTap: () => onDeleteTypeChange(false),
        ),
      ],
    );
  }

  Widget _buildDeleteOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.cardPadding),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(context.borderRadius()),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.cardPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.grey,
                    ),
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      color: isSelected ? color.withOpacity(0.8) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaborDetailsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(
          color: (isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    labor.initials,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isPermanentDelete ? Colors.red[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labor.name,
                      style: GoogleFonts.inter(
                        fontSize: context.headerFontSize * 0.8,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.charcoalGray,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.smallPadding / 2),
                    Text(
                      labor.designation,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!context.isTablet) ...[
                      SizedBox(height: context.smallPadding / 2),
                      Text(
                        labor.cnic,
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: context.iconSize('small'),
                ),
                SizedBox(width: context.smallPadding),
                Expanded(
                  child: Text(
                    'Labor ID: ${labor.id}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: (isPermanentDelete ? Colors.red : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: confirmationChecked,
            onChanged: (value) => onConfirmationCheckedChange(value ?? false),
            title: Text(
              isPermanentDelete
                  ? 'I understand this will permanently delete the labor'
                  : 'I understand this will deactivate the labor',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w500,
                color: (isPermanentDelete ? Colors.red : Colors.orange)[700],
              ),
            ),
            activeColor: isPermanentDelete ? Colors.red : Colors.orange,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (isPermanentDelete) ...[
            CheckboxListTile(
              value: understandConsequences,
              onChanged: (value) => onUnderstandConsequencesChange(value ?? false),
              title: Text(
                'I understand this action cannot be undone and will affect related records',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
              activeColor: Colors.red,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: context.cardPadding),
            Text(
              'Type the labor name to confirm permanent deletion:',
              style: GoogleFonts.inter(
                fontSize: context.subtitleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: context.smallPadding),
            Container(
              child: TextFormField(
                controller: confirmationController,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  color: AppTheme.charcoalGray,
                ),
                decoration: InputDecoration(
                  hintText: labor.name,
                  hintStyle: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(context.cardPadding),
                ),
              ),
            ),
            SizedBox(height: context.smallPadding),
            Text(
              'Expected: ${labor.name}',
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumButton(
          text: 'Cancel',
          onPressed: onCancel,
          height: context.buttonHeight,
          backgroundColor: Colors.grey[600],
          textColor: AppTheme.pureWhite,
        ),
        SizedBox(height: context.cardPadding),
        Consumer<LaborProvider>(
          builder: (context, provider, child) {
            final canDelete = validateDeletion();
            return PremiumButton(
              text: isPermanentDelete ? 'Delete Permanently' : 'Deactivate Labor',
              onPressed: (provider.isLoading || !canDelete) ? null : onDelete,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: isPermanentDelete ? Icons.delete_forever_rounded : Icons.visibility_off_rounded,
              backgroundColor: isPermanentDelete ? Colors.red : Colors.orange,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Cancel',
            onPressed: onCancel,
            height: context.buttonHeight,
            backgroundColor: Colors.grey[600],
            textColor: AppTheme.pureWhite,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: Consumer<LaborProvider>(
            builder: (context, provider, child) {
              final canDelete = validateDeletion();
              return PremiumButton(
                text: isPermanentDelete ? 'Delete Permanently' : 'Deactivate Labor',
                onPressed: (provider.isLoading || !canDelete) ? null : onDelete,
                isLoading: provider.isLoading,
                height: context.buttonHeight,
                icon: isPermanentDelete ? Icons.delete_forever_rounded : Icons.visibility_off_rounded,
                backgroundColor: isPermanentDelete ? Colors.red : Colors.orange,
              );
            },
          ),
        ),
      ],
    );
  }
}