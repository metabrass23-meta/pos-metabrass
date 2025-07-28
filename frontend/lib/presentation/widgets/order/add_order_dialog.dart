import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../src/providers/order_provider.dart';
import '../../../src/providers/customer_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../globals/text_button.dart';
import '../globals/text_field.dart';

class AddOrderDialog extends StatefulWidget {
  const AddOrderDialog({super.key});

  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advancePaymentController = TextEditingController();
  final _descriptionController = TextEditingController();

  Customer? _selectedCustomer;
  DateTime _expectedDeliveryDate = DateTime.now().add(const Duration(days: 14));

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _productController.dispose();
    _totalAmountController.dispose();
    _advancePaymentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a customer'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      await orderProvider.addOrder(
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        customerPhone: _selectedCustomer!.phone,
        customerEmail: _selectedCustomer!.email,
        advancePayment: double.parse(_advancePaymentController.text.trim()),
        totalAmount: double.parse(_totalAmountController.text.trim()),
        expectedDeliveryDate: _expectedDeliveryDate,
        description: _descriptionController.text.trim(),
        product: _productController.text.trim(),
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
              'Order added successfully!',
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

  void _handleCancel() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedDeliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expectedDeliveryDate) {
      setState(() {
        _expectedDeliveryDate = picked;
      });
    }
  }

  double get remainingAmount {
    final total = double.tryParse(_totalAmountController.text) ?? 0;
    final advance = double.tryParse(_advancePaymentController.text) ?? 0;
    return total - advance;
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
              Icons.shopping_bag_rounded,
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
                  context.shouldShowCompactLayout ? 'Add Order' : 'Add New Order',
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
            // Customer Selection
            Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                return DropdownButtonFormField<Customer>(
                  value: _selectedCustomer,
                  decoration: InputDecoration(
                    labelText: 'Select Customer',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.borderRadius()),
                    ),
                  ),
                  items: customerProvider.customers
                      .map((customer) => DropdownMenuItem<Customer>(
                    value: customer,
                    child: Text('${customer.name} - ${customer.phone}'),
                  ))
                      .toList(),
                  onChanged: (customer) {
                    setState(() {
                      _selectedCustomer = customer;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a customer';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Product',
              hint: isCompact ? 'Enter product' : 'Enter product name/description',
              controller: _productController,
              prefixIcon: Icons.inventory_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a product';
                }
                if (value!.length < 2) {
                  return 'Product must be at least 2 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Total Amount',
              hint: isCompact ? 'Enter total' : 'Enter total amount (PKR)',
              controller: _totalAmountController,
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter total amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Advance Payment',
              hint: isCompact ? 'Enter advance' : 'Enter advance payment (PKR)',
              controller: _advancePaymentController,
              prefixIcon: Icons.payment_rounded,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter advance payment';
                }
                final advance = double.tryParse(value!);
                final total = double.tryParse(_totalAmountController.text) ?? 0;
                if (advance == null || advance < 0) {
                  return 'Please enter a valid amount';
                }
                if (advance > total) {
                  return 'Advance cannot exceed total amount';
                }
                return null;
              },
            ),
            SizedBox(height: context.cardPadding),

            // Remaining Amount Display
            if (_totalAmountController.text.isNotEmpty && _advancePaymentController.text.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(context.cardPadding),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate_rounded, color: Colors.blue),
                    SizedBox(width: context.smallPadding),
                    Text(
                      'Remaining Amount: PKR ${remainingAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.cardPadding),
            ],

            GestureDetector(
              onTap: () => _selectDate(context),
              child: PremiumTextField(
                label: 'Expected Delivery Date',
                hint: 'Select expected delivery date',
                controller: TextEditingController(
                    text: '${_expectedDeliveryDate.day}/${_expectedDeliveryDate.month}/${_expectedDeliveryDate.year}'),
                prefixIcon: Icons.calendar_today,
                enabled: false,
              ),
            ),
            SizedBox(height: context.cardPadding),

            PremiumTextField(
              label: 'Description',
              hint: isCompact ? 'Enter description' : 'Enter order description/notes',
              controller: _descriptionController,
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a description';
                }
                if (value!.length < 5) {
                  return 'Description must be at least 5 characters';
                }
                return null;
              },
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
        Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Add Order',
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
          child: Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Add Order',
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
}