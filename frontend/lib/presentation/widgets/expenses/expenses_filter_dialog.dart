import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import '../../../src/providers/expenses_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/custom_date_picker.dart';

class ExpensesFilterDialog extends StatefulWidget {
  const ExpensesFilterDialog({super.key});

  @override
  State<ExpensesFilterDialog> createState() => _ExpensesFilterDialogState();
}

class _ExpensesFilterDialogState extends State<ExpensesFilterDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Filter state variables
  String? _selectedWithdrawalBy;
  String? _selectedCategory;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _searchQuery = '';

  // Text controllers for custom inputs
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Predefined options
  final List<String> _withdrawalOptions = ['Mr. Sheikh Parveez Maqbool', 'Mr Sheikh Zain Maqbool'];

  final List<String> _commonCategories = ['Office', 'Utilities', 'Transport', 'Marketing', 'Maintenance', 'Supplies', 'Services'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Initialize with current filter values
    final provider = context.read<ExpensesProvider>();
    _selectedWithdrawalBy = provider.selectedWithdrawalBy;
    _selectedCategory = provider.selectedCategory;
    _dateFrom = provider.dateFrom;
    _dateTo = provider.dateTo;
    _searchQuery = provider.searchQuery;

    _categoryController.text = _selectedCategory ?? '';
    _searchController.text = _searchQuery;

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleApplyFilters() async {
    final provider = context.read<ExpensesProvider>();

    // Update category and search from text controllers
    final category = _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim();
    final search = _searchController.text.trim();

    // Apply filters using existing provider methods
    if (category != provider.selectedCategory) {
      await provider.setCategoryFilter(category);
    }
    if (_selectedWithdrawalBy != provider.selectedWithdrawalBy) {
      await provider.setWithdrawalByFilter(_selectedWithdrawalBy);
    }
    if (_dateFrom != provider.dateFrom || _dateTo != provider.dateTo) {
      await provider.setDateRangeFilter(_dateFrom, _dateTo);
    }
    if (search != provider.searchQuery) {
      await provider.searchExpenses(search);
    }

    _handleClose();
  }

  void _handleClearFilters() async {
    final provider = context.read<ExpensesProvider>();
    await provider.clearFilters();
    _handleClose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _selectDateRange() async {
    // Select start date using custom date picker
    final startDate = await _selectCustomDate(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      title: 'Select Start Date',
      minDate: DateTime(2000),
      maxDate: DateTime.now(),
    );

    if (startDate != null) {
      // Select end date using custom date picker
      final endDate = await _selectCustomDate(
        context: context,
        initialDate: _dateTo ?? startDate,
        title: 'Select End Date',
        minDate: startDate,
        maxDate: DateTime.now(),
      );

      if (endDate != null) {
        setState(() {
          _dateFrom = startDate;
          _dateTo = endDate;
        });
      }
    }
  }

  Future<DateTime?> _selectCustomDate({
    required BuildContext context,
    required DateTime initialDate,
    required String title,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final completer = Completer<DateTime?>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SyncfusionDateTimePicker(
          initialDate: initialDate,
          initialTime: TimeOfDay.now(),
          onDateTimeSelected: (date, time) {
            completer.complete(date);
          },
          title: title,
          minDate: minDate,
          maxDate: maxDate,
          showTimeInline: false, // Only show date picker for range selection
        );
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: ResponsiveBreakpoints.responsive(context, tablet: 85.w, small: 90.w, medium: 70.w, large: 60.w, ultrawide: 50.w),
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 85.h),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: context.shadowBlur('heavy'), offset: Offset(0, context.cardPadding)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
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
            decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(context.borderRadius())),
            child: Icon(Icons.filter_alt_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),

          SizedBox(width: context.cardPadding),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Expense Records',
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
                    'Refine your expense list with filters',
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

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleClose,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.all(context.smallPadding),
                child: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Filter
            _buildFilterSection(title: 'Search Expense Records', icon: Icons.search_outlined, child: _buildSearchFilter()),

            SizedBox(height: context.cardPadding),

            // Category Filter
            _buildFilterSection(title: 'Expense Category', icon: Icons.category_outlined, child: _buildCategoryFilter()),

            SizedBox(height: context.cardPadding),

            // Withdrawal By Filter
            _buildFilterSection(title: 'Withdrawal By', icon: Icons.verified_user_outlined, child: _buildWithdrawalByFilter()),

            SizedBox(height: context.cardPadding),

            // Date Range Filter
            _buildFilterSection(title: 'Date Range', icon: Icons.date_range_outlined, child: _buildDateRangeFilter()),

            SizedBox(height: context.mainPadding),

            // Action Buttons
            ResponsiveBreakpoints.responsive(
              context,
              tablet: _buildCompactButtons(),
              small: _buildCompactButtons(),
              medium: _buildDesktopButtons(),
              large: _buildDesktopButtons(),
              ultrawide: _buildDesktopButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          child,
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return TextFormField(
      controller: _searchController,
      style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
      decoration: InputDecoration(
        hintText: 'Search by expense name, description, or amount',
        hintStyle: GoogleFonts.inter(fontSize: context.bodyFontSize, color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: context.iconSize('medium')),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
          borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.cardPadding / 2),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      children: [
        TextFormField(
          controller: _categoryController,
          style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
          decoration: InputDecoration(
            hintText: 'Enter expense category',
            hintStyle: GoogleFonts.inter(fontSize: context.bodyFontSize, color: Colors.grey[500]),
            prefixIcon: Icon(Icons.category_outlined, color: Colors.grey[500], size: context.iconSize('medium')),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.borderRadius()),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.borderRadius()),
              borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.cardPadding / 2),
          ),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value.isEmpty ? null : value;
            });
          },
        ),
        SizedBox(height: context.smallPadding),
        Wrap(
          spacing: context.smallPadding / 2,
          runSpacing: context.smallPadding / 4,
          children: _commonCategories
              .map((category) => _buildQuickSelectChip(label: category, onTap: () => setState(() => _categoryController.text = category)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildWithdrawalByFilter() {
    return Column(
      children: [
        Text(
          'Select Withdrawal Authority',
          style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
        ),
        SizedBox(height: context.smallPadding),
        ...(_withdrawalOptions.map(
          (person) => RadioListTile<String>(
            value: person,
            groupValue: _selectedWithdrawalBy,
            onChanged: (value) {
              setState(() {
                _selectedWithdrawalBy = value;
              });
            },
            title: Text(
              person,
              style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
            ),
            activeColor: AppTheme.primaryMaroon,
            dense: true,
          ),
        )),
        // Option to clear withdrawal by filter
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedWithdrawalBy = null;
            });
          },
          icon: Icon(Icons.clear, color: Colors.grey[600], size: context.iconSize('small')),
          label: Text(
            'Clear Withdrawal Filter',
            style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Container(
                  padding: EdgeInsets.all(context.cardPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
                          SizedBox(width: context.smallPadding),
                          Text(
                            'Select Date Range',
                            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                          ),
                        ],
                      ),
                      SizedBox(height: context.smallPadding / 2),
                      Text(
                        _dateFrom != null && _dateTo != null
                            ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year} - ${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                            : 'No date range selected',
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          color: _dateFrom != null && _dateTo != null ? AppTheme.charcoalGray : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_dateFrom != null || _dateTo != null) ...[
          SizedBox(height: context.smallPadding),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _dateFrom = null;
                      _dateTo = null;
                    });
                  },
                  icon: Icon(Icons.clear, color: Colors.red[600], size: context.iconSize('small')),
                  label: Text(
                    'Clear Date Range',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.red[600]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuickSelectChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.borderRadius('small')),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
        decoration: BoxDecoration(
          color: AppTheme.primaryMaroon.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: AppTheme.primaryMaroon),
        ),
      ),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumButton(
          text: 'Apply Filters',
          onPressed: _handleApplyFilters,
          height: context.buttonHeight,
          icon: Icons.filter_alt_rounded,
          backgroundColor: AppTheme.primaryMaroon,
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Clear All Filters',
          onPressed: _handleClearFilters,
          height: context.buttonHeight,
          icon: Icons.clear_all_rounded,
          isOutlined: true,
          backgroundColor: Colors.red[600],
          textColor: Colors.red[600],
        ),
        SizedBox(height: context.smallPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleClose,
          height: context.buttonHeight,
          isOutlined: true,
          backgroundColor: Colors.grey[600],
          textColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleClose,
            height: context.buttonHeight / 1.5,
            isOutlined: true,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Clear All',
            onPressed: _handleClearFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.clear_all_rounded,
            isOutlined: true,
            backgroundColor: Colors.red[600],
            textColor: Colors.red[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 2,
          child: PremiumButton(
            text: 'Apply Filters',
            onPressed: _handleApplyFilters,
            height: context.buttonHeight / 1.5,
            icon: Icons.filter_alt_rounded,
            backgroundColor: AppTheme.primaryMaroon,
          ),
        ),
      ],
    );
  }
}
