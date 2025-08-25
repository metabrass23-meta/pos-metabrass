import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import '../../../src/providers/payables_provider.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/custom_date_picker.dart';
import '../globals/drop_down.dart';

class PayableFilterDialog extends StatefulWidget {
  const PayableFilterDialog({super.key});

  @override
  State<PayableFilterDialog> createState() => _PayableFilterDialogState();
}

class _PayableFilterDialogState extends State<PayableFilterDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Filter state variables
  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedVendor;
  DateTime? _dueAfter;
  DateTime? _dueBefore;
  DateTime? _borrowedAfter;
  DateTime? _borrowedBefore;
  String _searchQuery = '';

  // Text controllers for custom inputs
  final TextEditingController _searchController = TextEditingController();

  // Predefined options
  final List<String> _statusOptions = ['ACTIVE', 'PAID', 'OVERDUE', 'PARTIALLY_PAID', 'CANCELLED'];
  final List<String> _priorityOptions = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
  static const String _allValue = 'ALL';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Initialize with current filter values
    final provider = context.read<PayablesProvider>();
    _selectedStatus = provider.selectedStatus ?? _allValue;
    _selectedPriority = provider.selectedPriority ?? _allValue;
    _selectedVendor = provider.selectedVendor ?? _allValue;
    _dueAfter = provider.dueAfter;
    _dueBefore = provider.dueBefore;
    _borrowedAfter = provider.borrowedAfter;
    _borrowedBefore = provider.borrowedBefore;
    _searchQuery = provider.searchQuery;

    _searchController.text = _searchQuery;

    _animationController.forward();

    // Load vendors for selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorProvider = context.read<VendorProvider>();
      vendorProvider.loadVendors();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleApplyFilters() async {
    final provider = context.read<PayablesProvider>();

    // Update search from text controller
    final search = _searchController.text.trim();

    // Apply filters using existing provider methods
    if (search != provider.searchQuery) {
      provider.setSearchQuery(search);
    }
    if (_selectedStatus != provider.selectedStatus) {
      final status = _selectedStatus == _allValue ? null : _selectedStatus;
      provider.setStatusFilter(status);
    }
    if (_selectedPriority != provider.selectedPriority) {
      final priority = _selectedPriority == _allValue ? null : _selectedPriority;
      provider.setPriorityFilter(priority);
    }
    if (_selectedVendor != provider.selectedVendor) {
      final vendor = _selectedVendor == _allValue ? null : _selectedVendor;
      provider.setVendorFilter(vendor);
    }
    if (_dueAfter != provider.dueAfter || _dueBefore != provider.dueBefore) {
      provider.setDueDateRange(_dueAfter, _dueBefore);
    }
    if (_borrowedAfter != provider.borrowedAfter || _borrowedBefore != provider.borrowedBefore) {
      provider.setBorrowedDateRange(_borrowedAfter, _borrowedBefore);
    }

    _handleClose();
  }

  void _handleClearFilters() async {
    final provider = context.read<PayablesProvider>();
    provider.clearFilters();

    // Reset local state
    setState(() {
      _selectedStatus = _allValue;
      _selectedPriority = _allValue;
      _selectedVendor = _allValue;
      _dueAfter = null;
      _dueBefore = null;
      _borrowedAfter = null;
      _borrowedBefore = null;
      _searchQuery = '';
      _searchController.clear();
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
                  'Filter Payables',
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
                    'Apply filters to find specific payables',
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
            _buildStatusPrioritySection(),
            SizedBox(height: context.cardPadding),
            _buildVendorSection(),
            SizedBox(height: context.cardPadding),
            _buildDateRangeSection(),
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
              hintText: 'Search by creditor name, reason, notes...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryMaroon),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPrioritySection() {
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
            'Status & Priority',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: PremiumDropdownField<String>(
                  label: 'Status',
                  hint: 'Select status',
                  items: [
                    DropdownItem<String>(value: _allValue, label: 'All Statuses'),
                    ..._statusOptions.map((status) => DropdownItem<String>(value: status, label: status)),
                  ],
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: PremiumDropdownField<String>(
                  label: 'Priority',
                  hint: 'Select priority',
                  items: [
                    DropdownItem<String>(value: _allValue, label: 'All Priorities'),
                    ..._priorityOptions.map((priority) => DropdownItem<String>(value: priority, label: priority)),
                  ],
                  value: _selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorSection() {
    return Consumer<VendorProvider>(
      builder: (context, vendorProvider, child) {
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
                'Vendor',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
              SizedBox(height: context.cardPadding),
              PremiumDropdownField<String>(
                label: 'Vendor',
                hint: 'Select vendor',
                items: [
                  DropdownItem<String>(value: _allValue, label: 'All Vendors'),
                  ...vendorProvider.vendors.map(
                    (vendor) => DropdownItem<String>(value: vendor.id, label: vendor.businessName.isNotEmpty ? vendor.businessName : vendor.name),
                  ),
                ],
                value: _selectedVendor,
                onChanged: (value) {
                  setState(() {
                    _selectedVendor = value;
                  });
                },
              ),
            ],
          ),
        );
      },
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
            'Date Ranges',
            style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Due After',
                  selectedDate: _dueAfter,
                  onDateSelected: (date) {
                    setState(() {
                      _dueAfter = date;
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: _buildDatePicker(
                  label: 'Due Before',
                  selectedDate: _dueBefore,
                  onDateSelected: (date) {
                    setState(() {
                      _dueBefore = date;
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Borrowed After',
                  selectedDate: _borrowedAfter,
                  onDateSelected: (date) {
                    setState(() {
                      _borrowedAfter = date;
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                ),
              ),
              SizedBox(width: context.cardPadding),
              Expanded(
                child: _buildDatePicker(
                  label: 'Borrowed Before',
                  selectedDate: _borrowedBefore,
                  onDateSelected: (date) {
                    setState(() {
                      _borrowedBefore = date;
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
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
