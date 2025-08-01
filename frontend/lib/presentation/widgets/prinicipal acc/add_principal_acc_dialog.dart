import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/globals/custom_date_picker.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/prinicipal_acc_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class AddPrincipalAccountDialog extends StatefulWidget {
  const AddPrincipalAccountDialog({super.key});

  @override
  State<AddPrincipalAccountDialog> createState() => _AddPrincipalAccountDialogState();
}

class _AddPrincipalAccountDialogState extends State<AddPrincipalAccountDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _sourceIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSourceModule;
  String? _selectedTransactionType;
  String? _selectedHandledBy;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Use addPostFrameCallback to avoid rendering conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sourceIdController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSourceModule == null) {
        _showErrorSnackbar('Please select source module');
        return;
      }
      if (_selectedTransactionType == null) {
        _showErrorSnackbar('Please select transaction type');
        return;
      }

      final provider = Provider.of<PrincipalAccountProvider>(context, listen: false);

      await provider.addPrincipalAccount(
        date: _selectedDate,
        time: _selectedTime,
        sourceModule: _selectedSourceModule!,
        sourceId: _sourceIdController.text.trim().isEmpty ? null : _sourceIdController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedTransactionType!,
        amount: double.parse(_amountController.text.trim()),
        handledBy: _selectedHandledBy,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        _showSuccessSnackbar();
        Navigator.of(context).pop();
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              'Principal account entry added successfully!',
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.pureWhite,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_rounded,
              color: AppTheme.pureWhite,
              size: context.iconSize('medium'),
            ),
            SizedBox(width: context.smallPadding),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.pureWhite,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
      ),
    );
  }

  void _handleCancel() {
    if (_animationController.isCompleted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // Using the new reusable DateTime picker
  Future<void> _selectDateTime() async {
    await context.showSyncfusionDateTimePicker(
      initialDate: _selectedDate,
      initialTime: _selectedTime,
      title: 'Select Transaction Date & Time',
      minDate: DateTime(2000),
      maxDate: DateTime(2101),
      onDateTimeSelected: (date, time) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: context.dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: ResponsiveBreakpoints.responsive(
                    context,
                    tablet: 90.w,
                    small: 85.w,
                    medium: 75.w,
                    large: 65.w,
                    ultrawide: 55.w,
                  ),
                  maxHeight: 90.h,
                ),
                margin: EdgeInsets.all(context.mainPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius('large')),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: context.shadowBlur('heavy'),
                      offset: Offset(0, context.cardPadding),
                    ),
                  ],
                ),
                child: ResponsiveBreakpoints.responsive(
                  context,
                  tablet: _buildTabletLayout(),
                  small: _buildMobileLayout(),
                  medium: _buildDesktopLayout(),
                  large: _buildDesktopLayout(),
                  ultrawide: _buildDesktopLayout(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(isCompact: true),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(isCompact: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(isCompact: false),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
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
              Icons.account_balance_wallet_rounded,
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
                  context.shouldShowCompactLayout ? 'Add Entry' : 'Add Principal Account Entry',
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
                    'Record a new ledger transaction',
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
              onTap: _handleCancel,
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

  Widget _buildFormContent({required bool isCompact}) {
    return Padding(
      padding: EdgeInsets.all(context.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Source Module Selection
            Consumer<PrincipalAccountProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedSourceModule,
                  decoration: InputDecoration(
                    labelText: 'Source Module',
                    prefixIcon: const Icon(Icons.source_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                  items: provider.availableSourceModules
                      .map((module) => DropdownMenuItem<String>(
                    value: module,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getSourceModuleColor(module),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getSourceModuleIcon(module),
                            color: AppTheme.pureWhite,
                            size: context.iconSize('small'),
                          ),
                        ),
                        SizedBox(width: context.smallPadding),
                        Text(_getFormattedSourceModule(module)),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (module) {
                    setState(() {
                      _selectedSourceModule = module;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select source module';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: context.cardPadding),

            // Transaction Type Selection
            Consumer<PrincipalAccountProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedTransactionType,
                  decoration: InputDecoration(
                    labelText: 'Transaction Type',
                    prefixIcon: const Icon(Icons.swap_horiz_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                  items: provider.availableTransactionTypes
                      .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == 'credit' ? Icons.add_circle_outline : Icons.remove_circle_outline,
                          color: type == 'credit' ? Colors.green : Colors.red,
                          size: context.iconSize('medium'),
                        ),
                        SizedBox(width: context.smallPadding),
                        Text(
                          type == 'credit' ? 'Credit (Money In)' : 'Debit (Money Out)',
                          style: GoogleFonts.inter(
                            color: type == 'credit' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (type) {
                    setState(() {
                      _selectedTransactionType = type;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select transaction type';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Source ID',
              hint: isCompact ? 'Reference ID (optional)' : 'Reference ID from source module (optional)',
              controller: _sourceIdController,
              prefixIcon: Icons.tag_outlined,
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Description',
              hint: isCompact ? 'Enter description' : 'Enter transaction description',
              controller: _descriptionController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter description';
                }
                if (value!.length < 5) {
                  return 'Description must be at least 5 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Amount',
              hint: isCompact ? 'Enter amount' : 'Enter transaction amount (PKR)',
              controller: _amountController,
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            // Handled By Selection
            Consumer<PrincipalAccountProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedHandledBy,
                  decoration: InputDecoration(
                    labelText: 'Handled By (Optional)',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Not specified'),
                    ),
                    ...provider.availableHandlers
                        .map((handler) => DropdownMenuItem<String>(
                      value: handler,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getPersonColor(handler),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppTheme.pureWhite,
                              size: context.iconSize('small'),
                            ),
                          ),
                          SizedBox(width: context.smallPadding),
                          Text(handler),
                        ],
                      ),
                    ))
                  ],
                  onChanged: (handler) {
                    setState(() {
                      _selectedHandledBy = handler;
                    });
                  },
                );
              },
            ),
            SizedBox(height: context.cardPadding),

            // Enhanced Date and Time Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary Syncfusion DateTime Picker Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _selectDateTime,
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                    child: Container(
                      padding: EdgeInsets.all(context.cardPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryMaroon.withOpacity(0.1),
                            AppTheme.secondaryMaroon.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(context.borderRadius()),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.date_range_rounded,
                                color: AppTheme.primaryMaroon,
                                size: context.iconSize('medium'),
                              ),
                              SizedBox(width: context.smallPadding),
                              Text(
                                'Select Date & Time',
                                style: GoogleFonts.inter(
                                  fontSize: context.bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryMaroon,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.smallPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Date',
                                    style: GoogleFonts.inter(
                                      fontSize: context.subtitleFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.charcoalGray.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: GoogleFonts.inter(
                                      fontSize: context.bodyFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.charcoalGray,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Time',
                                    style: GoogleFonts.inter(
                                      fontSize: context.subtitleFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.charcoalGray.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    _selectedTime.format(context),
                                    style: GoogleFonts.inter(
                                      fontSize: context.bodyFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.charcoalGray,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Notes',
              hint: isCompact ? 'Additional notes (optional)' : 'Additional notes or details (optional)',
              controller: _notesController,
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),

            SizedBox(height: context.mainPadding),

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

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<PrincipalAccountProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Add Entry',
              onPressed: provider.isLoading ? null : _handleSubmit,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.add_rounded,
            );
          },
        ),
        SizedBox(height: context.cardPadding),
        PremiumButton(
          text: 'Cancel',
          onPressed: _handleCancel,
          isOutlined: true,
          height: context.buttonHeight,
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
            onPressed: _handleCancel,
            isOutlined: true,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: Colors.grey[600],
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          child: Consumer<PrincipalAccountProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Add Entry',
                onPressed: provider.isLoading ? null : _handleSubmit,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.add_rounded,
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getSourceModuleColor(String module) {
    switch (module.toLowerCase()) {
      case 'sales':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'advance_payment':
        return Colors.orange;
      case 'expenses':
        return Colors.red;
      case 'receivables':
        return Colors.purple;
      case 'payables':
        return Colors.brown;
      case 'zakat':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getSourceModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'sales':
        return Icons.point_of_sale_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'advance_payment':
        return Icons.schedule_send_rounded;
      case 'expenses':
        return Icons.receipt_long_rounded;
      case 'receivables':
        return Icons.account_balance_outlined;
      case 'payables':
        return Icons.money_off_outlined;
      case 'zakat':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  String _getFormattedSourceModule(String module) {
    switch (module.toLowerCase()) {
      case 'sales':
        return 'Sales';
      case 'payment':
        return 'Payment';
      case 'advance_payment':
        return 'Advance Payment';
      case 'expenses':
        return 'Expenses';
      case 'receivables':
        return 'Receivables';
      case 'payables':
        return 'Payables';
      case 'zakat':
        return 'Zakat';
      default:
        return module;
    }
  }

  Color _getPersonColor(String person) {
    switch (person) {
      case 'Parveez Maqbool':
        return Colors.blue;
      case 'Zain Maqbool':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}