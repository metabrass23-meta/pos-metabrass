import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/app_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    return Container(
      padding: context.pagePadding / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: GoogleFonts.playfairDisplay(
              fontSize: context.headingFontSize,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.formFieldSpacing * 2),

          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader(context, l10n.language),
                _buildLanguageCard(context, appProvider),

                SizedBox(height: context.formFieldSpacing * 3),

                _buildSectionHeader(context, l10n.appearance),
                _buildThemeCard(context, appProvider, l10n),

                SizedBox(height: context.formFieldSpacing * 3),

                _buildSectionHeader(context, l10n.aboutApp),
                _buildAboutCard(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.smallPadding),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: context.headerFontSize,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryMaroon,
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Column(
        children: [
          _buildLanguageTile(
            context,
            'اردو',
            'Urdu',
            'ur',
            appProvider.currentLanguage == 'ur',
            () => appProvider.setLanguage('ur'),
          ),
          const Divider(height: 1),
          _buildLanguageTile(
            context,
            'English',
            'English',
            'en',
            appProvider.currentLanguage == 'en',
            () => appProvider.setLanguage('en'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String title,
    String subtitle,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(context.smallPadding / 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMaroon.withOpacity(0.1)
              : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Text(
          code.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppTheme.primaryMaroon : Colors.grey,
          ),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: context.bodyFontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: context.captionFontSize,
          color: Colors.grey,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryMaroon,
            )
          : null,
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: SwitchListTile(
        activeColor: AppTheme.primaryMaroon,
        title: Text(
          l10n.darkMode,
          style: GoogleFonts.inter(fontSize: context.bodyFontSize),
        ),
        subtitle: Text(
          l10n.enableDarkThemeForApplication,
          style: GoogleFonts.inter(fontSize: context.captionFontSize),
        ),
        value: appProvider.isDarkMode,
        onChanged: (value) => appProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius()),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryMaroon,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                SizedBox(width: context.smallPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.alNoorFashionPOS,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${l10n.version} 1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.smallPadding),
            Text(
              l10n.aPremiumPointOfSaleSolution,
              style: GoogleFonts.inter(
                fontSize: context.captionFontSize,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
