import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/advance_payment_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/custom_date_picker.dart';
import '../globals/drop_down.dart';

class AdvancePaymentFilterDialog extends StatefulWidget {
  const AdvancePaymentFilterDialog({super.key});

  @override
  State<AdvancePaymentFilterDialog> createState() => _AdvancePaymentFilterDialogState();
}

class _AdvancePaymentFilterDialogState extends State<AdvancePaymentFilterDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Filter state variables - only fields from provider
  String? _selectedLaborId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  double? _minAmount;
  double? _maxAmount;
  String? _hasReceipt;
  String _sortBy = 'date';
  bool _sortAscending = false;
  bool _showInactive = false;
  String _searchQuery = '';

  // Text controllers for custom inputs
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  // Predefined options based on provider
  static const String _allValue = 'ALL';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Initialize with current filter values from provider
    final provider = context.read<AdvancePaymentProvider>();
    _selectedLaborId = provider.selectedLaborId ?? _allValue;
    _dateFrom = provider.dateFrom;
    _dateTo = provider.dateTo;
    _minAmount = provider.minAmount;
    _maxAmount = provider.maxAmount;
    _hasReceipt = provider.hasReceipt ?? _allValue;
    _sortBy = provider.sortBy;
    _sortAscending = provider.sortAscending;
    _showInactive = provider.showInactive;
    _searchQuery = provider.searchQuery;

    _searchController.text = _searchQuery;
    if (_minAmount != null) _minAmountController.text = _minAmount.toString();
    if (_maxAmount != null) _maxAmountController.text = _maxAmount.toString();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _handleApplyFilters() async {
    final provider = context.read<AdvancePaymentProvider>();

    // Update search from text controller
    final search = _searchController.text.trim();
    if (search != provider.searchQuery) {
      await provider.searchAdvancePayments(search);
    }

    // Apply labor filter
    if (_selectedLaborId != provider.selectedLaborId) {
      final laborId = _selectedLaborId == _allValue ? null : _selectedLaborId;
      await provider.setLaborFilter(laborId);
    }

    // Apply date range filter
    if (_dateFrom != provider.dateFrom || _dateTo != provider.dateTo) {
      await provider.setDateRangeFilter(_dateFrom, _dateTo);
    }

    // Apply amount range filter
    final minAmount = _minAmountController.text.trim().isEmpty ? null : double.tryParse(_minAmountController.text.trim());
    final maxAmount = _maxAmountController.text.trim().isEmpty ? null : double.tryParse(_maxAmountController.text.trim());

    if (minAmount != provider.minAmount || maxAmount != provider.maxAmount) {
      await provider.setAmountRangeFilter(minAmount, maxAmount);
    }

    // Apply receipt filter
    if (_hasReceipt != provider.hasReceipt) {
      final receiptFilter = _hasReceipt == _allValue ? null : _hasReceipt;
      await provider.setReceiptFilter(receiptFilter);
    }

    // Apply sorting
    if (_sortBy != provider.sortBy) {
      await provider.setSortBy(_sortBy);
    }

    // Apply inactive filter
    if (_showInactive != provider.showInactive) {
      await provider.setShowInactiveFilter(_showInactive);
    }

    _handleClose();
  }

  void _handleClearFilters() async {
    final provider = context.read<AdvancePaymentProvider>();
    await provider.clearFilters();

    // Reset local state
    setState(() {
      _selectedLaborId = _allValue;
      _dateFrom = null;
      _dateTo = null;
      _minAmount = null;
      _maxAmount = null;
      _hasReceipt = _allValue;
      _sortBy = 'date';
      _sortAscending = false;
      _showInactive = false;
      _searchQuery = '';
      _searchController.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: context.dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 95.w, small: 90.w, medium: 80.w, large: 70.w, ultrawide: 60.w),
                  maxHeight: ResponsiveBreakpoints.responsive(context, tablet: 90.h, small: 95.h, medium: 85.h, large: 80.h, ultrawide: 75.h),
                ),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: context.shadowBlur('heavy'), offset: Offset(0, context.cardPadding)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(child: _buildFilterContent()),
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
            child: Icon(Icons.filter_list_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Advance Payments',
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
                    'Apply filters to find specific advance payments',
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

  Widget _buildFilterContent() {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchSection(),
            SizedBox(height: context.cardPadding),
            _buildLaborSection(),
            SizedBox(height: context.cardPadding),
            _buildAmountRangeSection(),
            SizedBox(height: context.cardPadding),
            _buildReceiptAndSortSection(),
            SizedBox(height: context.cardPadding),
            _buildDateRangeSection(),
            SizedBox(height: context.cardPadding),
            _buildAdvancedOptionsSection(),
            SizedBox(height: context.mainPadding),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search advance payments...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryMaroon),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaborSection() {
    return Consumer<AdvancePaymentProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.borderRadius()),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Labor',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
              SizedBox(height: context.cardPadding),
              PremiumDropdownField<String>(
                label: 'Labor',
                hint: 'Select labor',
                items: [
                  DropdownItem<String>(value: _allValue, label: 'All Laborers'),
                  ...provider.laborers.map((labor) => DropdownItem<String>(value: labor.id, label: '${labor.name} - ${labor.designation}')),
                ],
                value: _selectedLaborId,
                onChanged: (value) {
                  setState(() {
                    _selectedLaborId = value;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountRangeSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money_rounded, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Amount Range (PKR)',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
                  decoration: InputDecoration(
                    labelText: 'Minimum Amount',
                    labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize * 0.9, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      borderSide: BorderSide(color: AppTheme.primaryMaroon, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.smallPadding),
                  ),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
                  decoration: InputDecoration(
                    labelText: 'Maximum Amount',
                    labelStyle: GoogleFonts.inter(fontSize: context.bodyFontSize * 0.9, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                      borderSide: BorderSide(color: AppTheme.primaryMaroon, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: context.cardPadding, vertical: context.smallPadding),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptAndSortSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receipt & Sorting',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumDropdownField<String>(
                  label: 'Has Receipt',
                  hint: 'Select receipt status',
                  items: [
                    DropdownItem<String>(value: _allValue, label: 'All'),
                    DropdownItem<String>(value: 'yes', label: 'With Receipt'),
                    DropdownItem<String>(value: 'no', label: 'Without Receipt'),
                  ],
                  value: _hasReceipt,
                  onChanged: (value) {
                    setState(() {
                      _hasReceipt = value;
                    });
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumDropdownField<String>(
                  label: 'Sort By',
                  hint: 'Select sort field',
                  items: [
                    DropdownItem<String>(value: 'date', label: 'Date'),
                    DropdownItem<String>(value: 'amount', label: 'Amount'),
                    DropdownItem<String>(value: 'laborName', label: 'Labor Name'),
                  ],
                  value: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'date';
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Checkbox(
                value: _sortAscending,
                onChanged: (value) {
                  setState(() {
                    _sortAscending = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryMaroon,
              ),
              Text(
                'Sort Ascending',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Date From',
                  selectedDate: _dateFrom,
                  onDateSelected: (date) {
                    setState(() {
                      _dateFrom = date;
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: _buildDatePicker(
                  label: 'Date To',
                  selectedDate: _dateTo,
                  onDateSelected: (date) {
                    setState(() {
                      _dateTo = date;
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Options',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Checkbox(
                value: _showInactive,
                onChanged: (value) {
                  setState(() {
                    _showInactive = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryMaroon,
              ),
              Expanded(
                child: Text(
                  'Show Inactive Records',
                  style: GoogleFonts.inter(fontSize: context.bodyFontSize, color: AppTheme.charcoalGray),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
        ),
        SizedBox(height: context.smallPadding),
        InkWell(
          onTap: () async {
            await context.showSyncfusionDateTimePicker(
              initialDate: selectedDate ?? DateTime.now(),
              initialTime: const TimeOfDay(hour: 0, minute: 0),
              onDateTimeSelected: (date, time) {
                onDateSelected(date);
              },
              title: 'Select Date',
              minDate: firstDate,
              maxDate: lastDate,
              showTimeInline: false,
            );
          },
          child: Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryMaroon, size: 16),
                SizedBox(width: context.smallPadding),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
                        : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      color: selectedDate != null ? AppTheme.charcoalGray : Colors.grey.shade500,
                    ),
                  ),
                ),
                if (selectedDate != null)
                  InkWell(
                    onTap: () => onDateSelected(null),
                    child: Icon(Icons.clear, color: Colors.grey.shade400, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PremiumButton(
            text: 'Clear All',
            onPressed: _handleClearFilters,
            backgroundColor: Colors.grey.shade300,
            textColor: AppTheme.charcoalGray,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: PremiumButton(
            text: 'Apply Filters',
            onPressed: _handleApplyFilters,
            backgroundColor: AppTheme.primaryMaroon,
            textColor: AppTheme.pureWhite,
          ),
        ),
      ],
    );
  }
}
