import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/models/customer/customer_model.dart';
import '../../../src/models/order/order_model.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';
import '../globals/drop_down.dart';

class AddOrderDialog extends StatefulWidget {
  const AddOrderDialog({super.key});

  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _customerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advancePaymentController = TextEditingController();
  final _expectedDeliveryDateController = TextEditingController();

  // Form state
  Customer? _selectedCustomer;
  OrderStatus _selectedStatus = OrderStatus.pending;
  DateTime? _selectedDeliveryDate;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Options
  final List<OrderStatus> _orderStatuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customerController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _advancePaymentController.dispose();
    _expectedDeliveryDateController.dispose();
    super.dispose();
  }

  void _handleCustomerChange(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
      if (customer != null) {
        _customerController.text = customer.name;
      }
    });
  }

  void _handleStatusChange(OrderStatus status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _handleDeliveryDateChange(DateTime? date) {
    setState(() {
      _selectedDeliveryDate = date;
      if (date != null) {
        _expectedDeliveryDateController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } else {
        _expectedDeliveryDateController.text = '';
      }
    });
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomer == null) {
        _showErrorSnackbar('Please select a customer');
        return;
      }

      final provider = Provider.of<OrderProvider>(context, listen: false);

      final success = await provider.createOrder(
        customer: _selectedCustomer!.id,
        description: _descriptionController.text.trim(),
        advancePayment: double.tryParse(_advancePaymentController.text.trim()) ?? 0.0,
        dateOrdered: DateTime.now(),
        expectedDeliveryDate: _selectedDeliveryDate ?? DateTime.now().add(const Duration(days: 14)),
        status: _selectedStatus.name.toUpperCase(), // Send status in uppercase
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(_getUserFriendlyErrorMessage(provider.errorMessage ?? 'Failed to create order'));
        }
      }
    }
  }

  // Get user-friendly error message
  String _getUserFriendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains('Invalid customer')) {
      return 'Please select a valid customer for this order.';
    } else if (errorMessage.contains('Date has wrong format')) {
      return 'Invalid date format. Please select a valid delivery date.';
    } else if (errorMessage.contains('cannot be before order date')) {
      return 'Delivery date cannot be before the order date.';
    } else if (errorMessage.contains('cannot be negative')) {
      return 'Advance payment cannot be negative.';
    } else if (errorMessage.contains('not active')) {
      return 'The selected customer is not active. Please choose another customer.';
    } else if (errorMessage.contains('not a valid choice')) {
      return 'Invalid status selected. Please choose a valid status.';
    }
    return errorMessage;
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              'Order created successfully!',
              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w500, color: AppTheme.pureWhite),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
      ),
    );
  }

  void _handleCancel() {
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
                  maxWidth: ResponsiveBreakpoints.responsive(context, tablet: 90.w, small: 85.w, medium: 75.w, large: 65.w, ultrawide: 55.w),
                  maxHeight: 90.h,
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
                    Flexible(child: _buildFormContent()),
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
            child: Icon(Icons.shopping_cart_rounded, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.shouldShowCompactLayout ? 'Add Order' : 'Create New Order',
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
                    'Create a new customer order',
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
                child: Icon(Icons.close_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Selection Section
              _buildCustomerSelectionSection(),
              SizedBox(height: context.cardPadding),

              // Order Details Section
              _buildOrderDetailsSection(),
              SizedBox(height: context.cardPadding),

              // Financial Information Section
              _buildFinancialInfoSection(),
              SizedBox(height: context.cardPadding),

              // Delivery Information Section
              _buildDeliveryInfoSection(),
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
      ),
    );
  }

  Widget _buildCustomerSelectionSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Customer Selection', Icons.person_outline),
          SizedBox(height: context.cardPadding),
          Consumer<CustomerProvider>(
            builder: (context, customerProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumDropdownField<Customer>(
                    label: 'Select Customer *',
                    hint: context.shouldShowCompactLayout ? 'Choose a customer' : 'Choose a customer for this order',
                    items: customerProvider.customers
                        .map((customer) => DropdownItem<Customer>(value: customer, label: '${customer.name} (${customer.phone})'))
                        .toList(),
                    value: _selectedCustomer,
                    onChanged: _handleCustomerChange,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a customer';
                      }
                      return null;
                    },
                    prefixIcon: Icons.person_search_rounded,
                  ),
                  if (_selectedCustomer != null) ...[
                    SizedBox(height: context.cardPadding),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: AppTheme.primaryMaroon.withOpacity(0.2), shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              _selectedCustomer!.initials,
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryMaroon),
                            ),
                          ),
                        ),
                        SizedBox(width: context.cardPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryMaroon.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(context.borderRadius('small')),
                                    ),
                                    child: Text(
                                      _selectedCustomer!.id,
                                      style: GoogleFonts.inter(
                                        fontSize: context.captionFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryMaroon,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.smallPadding),
                                  Expanded(
                                    child: Text(
                                      _selectedCustomer!.name,
                                      style: GoogleFonts.inter(
                                        fontSize: context.bodyFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.charcoalGray,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (!context.isTablet) ...[
                                SizedBox(height: context.smallPadding),
                                Text(
                                  '${_selectedCustomer!.phone} • ${_selectedCustomer!.email}',
                                  style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Order Details', Icons.shopping_bag_outlined),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Order Description *',
            hint: context.shouldShowCompactLayout ? 'Enter description' : 'Describe the order details (e.g., products, specifications)',
            controller: _descriptionController,
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter order description';
              }
              if (value!.length < 10) {
                return 'Description must be at least 10 characters';
              }
              if (value.length > 500) {
                return 'Description must be less than 500 characters';
              }
              return null;
            },
          ),
          SizedBox(height: context.cardPadding),
          Text(
            'Order Status',
            style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w500, color: AppTheme.charcoalGray),
          ),
          SizedBox(height: context.smallPadding),
          Wrap(
            spacing: context.smallPadding / 2,
            runSpacing: context.smallPadding / 4,
            children: _orderStatuses
                .map(
                  (status) => _buildQuickSelectChip(
                    label: _getStatusText(status),
                    onTap: () => _handleStatusChange(status),
                    isSelected: _selectedStatus == status,
                    selectedColor: _getStatusColor(status),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Financial Information', Icons.account_balance_wallet_outlined),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Total Amount (PKR) *',
            hint: context.shouldShowCompactLayout ? 'Enter total amount' : 'Enter total order amount',
            controller: _totalAmountController,
            prefixIcon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter total amount';
              }
              if (double.tryParse(value!) == null) {
                return 'Please enter a valid amount';
              }
              if (double.parse(value) <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Advance Payment (PKR)',
            hint: context.shouldShowCompactLayout ? 'Enter advance payment' : 'Enter advance payment amount (optional)',
            controller: _advancePaymentController,
            prefixIcon: Icons.payment_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                final advance = double.parse(value);
                final total = double.tryParse(_totalAmountController.text) ?? 0;
                if (advance < 0) {
                  return 'Advance payment cannot be negative';
                }
                if (advance > total) {
                  return 'Advance payment cannot exceed total amount';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Delivery Information', Icons.local_shipping_outlined),
          SizedBox(height: context.cardPadding),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                _handleDeliveryDateChange(date);
              }
            },
            borderRadius: BorderRadius.circular(context.borderRadius()),
            child: Container(
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(context.borderRadius()),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
                  SizedBox(width: context.smallPadding),
                  Expanded(
                    child: Text(
                      _selectedDeliveryDate != null
                          ? 'Expected Delivery: ${_selectedDeliveryDate!.day.toString().padLeft(2, '0')}/${_selectedDeliveryDate!.month.toString().padLeft(2, '0')}/${_selectedDeliveryDate!.year}'
                          : 'Select Expected Delivery Date',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: _selectedDeliveryDate != null ? AppTheme.charcoalGray : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryMaroon, size: context.iconSize('medium')),
        SizedBox(width: context.smallPadding),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
        ),
      ],
    );
  }

  Widget _buildQuickSelectChip({
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    Color selectedColor = AppTheme.primaryMaroon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.borderRadius('small')),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.1) : AppTheme.accentGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
          border: Border.all(color: isSelected ? selectedColor : AppTheme.accentGold.withOpacity(0.3), width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: context.captionFontSize,
            fontWeight: FontWeight.w500,
            color: isSelected ? selectedColor : AppTheme.accentGold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Create Order',
              onPressed: provider.isLoading ? null : _handleSubmit,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.add_rounded,
              backgroundColor: AppTheme.primaryMaroon,
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
          flex: 2,
          child: Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Create Order',
                onPressed: provider.isLoading ? null : _handleSubmit,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.add_rounded,
                backgroundColor: AppTheme.primaryMaroon,
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.inProduction:
        return Colors.indigo;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.inProduction:
        return Icons.work_rounded;
      case OrderStatus.ready:
        return Icons.done_all_rounded;
      case OrderStatus.delivered:
        return Icons.local_shipping_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}
