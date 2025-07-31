import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';

class SyncfusionDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final Function(DateTime date, TimeOfDay time) onDateTimeSelected;
  final String title;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool showTimeInline;

  const SyncfusionDateTimePicker({
    super.key,
    required this.initialDate,
    required this.initialTime,
    required this.onDateTimeSelected,
    this.title = 'Select Date & Time',
    this.minDate,
    this.maxDate,
    this.showTimeInline = true,
  });

  @override
  State<SyncfusionDateTimePicker> createState() => _SyncfusionDateTimePickerState();
}

class _SyncfusionDateTimePickerState extends State<SyncfusionDateTimePicker> {
  late DateTime _tempSelectedDate;
  late TimeOfDay _tempSelectedTime;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.initialDate;
    _tempSelectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveBreakpoints.responsive(
            context,
            tablet: MediaQuery.of(context).size.width * 0.8,
            small: MediaQuery.of(context).size.width * 0.9,
            medium: 500,
            large: 500,
            ultrawide: 500,
          ),
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                child: _buildContent(),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.cardPadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
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
              Icons.date_range_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
          ),
          SizedBox(width: context.smallPadding),
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: context.headerFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Syncfusion Date Picker
          Container(
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: SfDateRangePicker(
                initialSelectedDate: _tempSelectedDate,
                initialDisplayDate: _tempSelectedDate,
                minDate: widget.minDate ?? DateTime(2000),
                maxDate: widget.maxDate ?? DateTime(2101),
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is DateTime) {
                    setState(() {
                      _tempSelectedDate = args.value as DateTime;
                    });
                  }
                },
                monthCellStyle: DateRangePickerMonthCellStyle(
                  todayTextStyle: GoogleFonts.inter(
                    color: AppTheme.primaryMaroon,
                    fontWeight: FontWeight.w600,
                  ),
                  textStyle: GoogleFonts.inter(
                    color: AppTheme.charcoalGray,
                  ),
                  leadingDatesTextStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                  ),
                  trailingDatesTextStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                  ),
                ),
                selectionColor: AppTheme.primaryMaroon,
                todayHighlightColor: AppTheme.primaryMaroon,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1, // Monday
                  showTrailingAndLeadingDates: true,
                ),
                yearCellStyle: DateRangePickerYearCellStyle(
                  textStyle: GoogleFonts.inter(
                    color: AppTheme.charcoalGray,
                  ),
                  todayTextStyle: GoogleFonts.inter(
                    color: AppTheme.primaryMaroon,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          if (widget.showTimeInline) ...[
            SizedBox(height: context.cardPadding),
            _buildTimeSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                color: AppTheme.primaryMaroon,
                size: context.iconSize('medium'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                'Select Time',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
          SizedBox(height: context.smallPadding),

          // Custom inline time picker
          Container(
            padding: EdgeInsets.all(context.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(context.borderRadius()),
              border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Hour selection
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Hour',
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.charcoalGray.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: context.smallPadding / 2),
                      Container(
                        height: 100,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _tempSelectedTime = TimeOfDay(
                                hour: index,
                                minute: _tempSelectedTime.minute,
                              );
                            });
                          },
                          controller: FixedExtentScrollController(
                            initialItem: _tempSelectedTime.hour,
                          ),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= 24) return null;
                              final isSelected = index == _tempSelectedTime.hour;
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryMaroon.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(context.borderRadius()),
                                ),
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? AppTheme.primaryMaroon
                                        : AppTheme.charcoalGray,
                                  ),
                                ),
                              );
                            },
                            childCount: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Separator
                Container(
                  width: 1,
                  height: 80,
                  color: Colors.grey.shade300,
                ),

                // Minute selection
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Minute',
                        style: GoogleFonts.inter(
                          fontSize: context.subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.charcoalGray.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: context.smallPadding / 2),
                      Container(
                        height: 100,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _tempSelectedTime = TimeOfDay(
                                hour: _tempSelectedTime.hour,
                                minute: index * 5, // 5-minute intervals
                              );
                            });
                          },
                          controller: FixedExtentScrollController(
                            initialItem: (_tempSelectedTime.minute / 5).round(),
                          ),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= 12) return null; // 0-55 minutes (5-minute intervals)
                              final minute = index * 5;
                              final isSelected = minute == _tempSelectedTime.minute;
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryMaroon.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(context.borderRadius()),
                                ),
                                child: Text(
                                  minute.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? AppTheme.primaryMaroon
                                        : AppTheme.charcoalGray,
                                  ),
                                ),
                              );
                            },
                            childCount: 12, // 0, 5, 10, 15, ..., 55
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: context.smallPadding),

          // Current time display and fallback button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected: ${_tempSelectedTime.format(context)}',
                style: GoogleFonts.inter(
                  fontSize: context.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoalGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: context.cardPadding,
                vertical: context.smallPadding,
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: context.bodyFontSize,
              ),
            ),
          ),
          SizedBox(width: context.smallPadding),
          ElevatedButton(
            onPressed: () {
              widget.onDateTimeSelected(_tempSelectedDate, _tempSelectedTime);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryMaroon,
              foregroundColor: AppTheme.pureWhite,
              padding: EdgeInsets.symmetric(
                horizontal: context.cardPadding,
                vertical: context.smallPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.borderRadius()),
              ),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: context.bodyFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New method for precise time selection that works better in dialog context
  Future<void> _selectTimeDialog() async {
    // Close current dialog temporarily
    Navigator.of(context).pop();

    // Show time picker
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _tempSelectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryMaroon,
              onPrimary: AppTheme.pureWhite,
              surface: AppTheme.pureWhite,
              onSurface: AppTheme.charcoalGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _tempSelectedTime = picked;
    }

    // Reopen the dialog with updated time
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SyncfusionDateTimePicker(
          initialDate: _tempSelectedDate,
          initialTime: _tempSelectedTime,
          onDateTimeSelected: widget.onDateTimeSelected,
          title: widget.title,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          showTimeInline: widget.showTimeInline,
        );
      },
    );
  }
}

// Extension method to easily show the picker
extension SyncfusionDateTimePickerExtension on BuildContext {
  Future<void> showSyncfusionDateTimePicker({
    required DateTime initialDate,
    required TimeOfDay initialTime,
    required Function(DateTime date, TimeOfDay time) onDateTimeSelected,
    String title = 'Select Date & Time',
    DateTime? minDate,
    DateTime? maxDate,
    bool showTimeInline = true,
  }) {
    return showDialog<void>(
      context: this,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SyncfusionDateTimePicker(
          initialDate: initialDate,
          initialTime: initialTime,
          onDateTimeSelected: onDateTimeSelected,
          title: title,
          minDate: minDate,
          maxDate: maxDate,
          showTimeInline: showTimeInline,
        );
      },
    );
  }
}