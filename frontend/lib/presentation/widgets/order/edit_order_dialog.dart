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

class EditOrderDialog extends StatefulWidget {
  final OrderModel order;

  const EditOrderDialog({super.key, required this.order});

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _customerController;
  late TextEditingController _descriptionController;
  late TextEditingController _advancePaymentController;
  late TextEditingController _expectedDeliveryDateController;

  // Form state
  Customer? _selectedCustomer;
  OrderStatus _selectedStatus = OrderStatus.pending;
  DateTime? _selectedDeliveryDate;
  bool _isLoadingCustomerDetails = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Options
  final List<OrderStatus> _orderStatuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing order data
    _customerController = TextEditingController(text: widget.order.customerName);
    _descriptionController = TextEditingController(text: widget.order.description);
    _advancePaymentController = TextEditingController(text: widget.order.advancePayment.toString());
    _expectedDeliveryDateController = TextEditingController(
      text: widget.order.expectedDeliveryDate != null
          ? '${widget.order.expectedDeliveryDate!.day.toString().padLeft(2, '0')}/${widget.order.expectedDeliveryDate!.month.toString().padLeft(2, '0')}/${widget.order.expectedDeliveryDate!.year}'
          : '',
    );

    // Initialize form state with existing order data
    _selectedStatus = widget.order.status;
    _selectedDeliveryDate = widget.order.expectedDeliveryDate;

    // Initialize animations
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Load customer details
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    setState(() {
      _isLoadingCustomerDetails = true;
    });

    try {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final customer = customerProvider.customers.firstWhere(
        (c) => c.id == widget.order.customerId,
        orElse: () => Customer(
          id: widget.order.customerId,
          name: widget.order.customerName,
          phone: widget.order.customerPhone,
          email: widget.order.customerEmail,
          description: null,
          createdAt: DateTime.now(),
          lastPurchaseDate: null,
          lastPurchase: null,
          address: '',
          city: '',
          country: 'Pakistan',
          customerType: 'INDIVIDUAL',
          status: 'NEW',
          phoneVerified: false,
          emailVerified: false,
          businessName: null,
          taxNumber: null,
          isActive: true,
          displayName: widget.order.customerName,
          initials: widget.order.customerName.isNotEmpty ? widget.order.customerName[0].toUpperCase() : 'C',
          isNewCustomer: true,
          isRecentCustomer: false,
          totalSalesCount: 0,
          hasRecentSales: false,
          customerTypeDisplay: 'Individual',
          statusDisplay: 'New Customer',
          createdByEmail: null,
          lastOrderDate: null,
        ),
      );
      setState(() {
        _selectedCustomer = customer;
        _isLoadingCustomerDetails = false;
      });
    } catch (e) {
      debugPrint('Error loading customer details: $e');
      setState(() {
        _isLoadingCustomerDetails = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customerController.dispose();
    _descriptionController.dispose();
    _advancePaymentController.dispose();
    _expectedDeliveryDateController.dispose();
    super.dispose();
  }

  void _handleStatusChange(OrderStatus? status) {
    if (status != null) {
      setState(() {
        _selectedStatus = status;
      });
    }
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

  void _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check status transition validity
      if (!_isValidStatusTransition()) {
        _showStatusTransitionWarning();
        return;
      }

      final provider = Provider.of<OrderProvider>(context, listen: false);

      final success = await provider.updateOrder(
        id: widget.order.id,
        description: _descriptionController.text.trim(),
        advancePayment: double.tryParse(_advancePaymentController.text.trim()) ?? 0.0,
        expectedDeliveryDate: _selectedDeliveryDate,
        status: _selectedStatus.name.toUpperCase(), // Send status in uppercase
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackbar(_getUserFriendlyErrorMessage(provider.errorMessage ?? 'Failed to update order'));
        }
      }
    }
  }

  // Check if status transition is valid
  bool _isValidStatusTransition() {
    if (_selectedStatus == widget.order.status) return true; // No change
    final validNextStatuses = _getValidNextStatuses(widget.order.status);
    return validNextStatuses.contains(_selectedStatus);
  }

  // Show status transition warning
  void _showStatusTransitionWarning() {
    final validNextStatuses = _getValidNextStatuses(widget.order.status);
    final validStatusTexts = validNextStatuses.map((s) => _getStatusText(s)).join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Invalid Status Transition'),
          ],
        ),
        content: Text(
          'You cannot change the status from "${_getStatusText(widget.order.status)}" to "${_getStatusText(_selectedStatus)}".\n\n'
          'Valid next statuses are: $validStatusTexts',
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
      ),
    );
  }

  // Get user-friendly error message
  String _getUserFriendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains('Invalid status transition')) {
      return _getStatusTransitionErrorMessage();
    } else if (errorMessage.contains('maximum recursion depth exceeded')) {
      return 'Server error occurred. Please try again or contact support.';
    } else if (errorMessage.contains('not a valid choice')) {
      return 'Invalid status selected. Please choose a valid status.';
    } else if (errorMessage.contains('Date has wrong format')) {
      return 'Invalid date format. Please select a valid delivery date.';
    } else if (errorMessage.contains('cannot be before order date')) {
      return 'Delivery date cannot be before the order date.';
    } else if (errorMessage.contains('cannot exceed total amount')) {
      return 'Advance payment cannot exceed the total order amount.';
    } else if (errorMessage.contains('cannot be negative')) {
      return 'Advance payment cannot be negative.';
    } else if (errorMessage.contains('cannot be modified')) {
      return 'This order cannot be modified in its current status.';
    }
    return errorMessage;
  }

  // Get specific status transition error message
  String _getStatusTransitionErrorMessage() {
    final currentStatus = widget.order.status;
    final selectedStatus = _selectedStatus;

    // Get valid next statuses
    final validNextStatuses = _getValidNextStatuses(currentStatus);

    if (validNextStatuses.isEmpty) {
      return 'This order cannot have its status changed.';
    }

    final validStatusTexts = validNextStatuses.map((status) => _getStatusText(status)).join(', ');

    return 'Invalid status transition. From ${_getStatusText(currentStatus)}, you can only change to: $validStatusTexts';
  }

  // Get valid next statuses based on current status
  List<OrderStatus> _getValidNextStatuses(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed:
        return [OrderStatus.inProduction, OrderStatus.cancelled];
      case OrderStatus.inProduction:
        return [OrderStatus.ready, OrderStatus.cancelled];
      case OrderStatus.ready:
        return [OrderStatus.delivered, OrderStatus.cancelled];
      case OrderStatus.delivered:
        return []; // Terminal state
      case OrderStatus.cancelled:
        return []; // Terminal state
    }
  }

  // Get valid status options for UI display
  List<OrderStatus> _getValidStatusOptions() {
    // Include current status and valid next statuses
    final validOptions = <OrderStatus>[widget.order.status];
    validOptions.addAll(_getValidNextStatuses(widget.order.status));

    // Also include current selected status if it's not in the list
    if (!validOptions.contains(_selectedStatus)) {
      validOptions.add(_selectedStatus);
    }

    // Sort by priority (current status first, then logical progression)
    validOptions.sort((a, b) {
      if (a == widget.order.status) return -1;
      if (b == widget.order.status) return 1;
      return _getStatusPriority(a).compareTo(_getStatusPriority(b));
    });

    return validOptions;
  }

  // Get status priority for sorting
  int _getStatusPriority(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 1;
      case OrderStatus.confirmed:
        return 2;
      case OrderStatus.inProduction:
        return 3;
      case OrderStatus.ready:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return 6;
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.pureWhite, size: context.iconSize('medium')),
            SizedBox(width: context.smallPadding),
            Text(
              'Order updated successfully!',
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Update Failed',
                    style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.inter(fontSize: context.subtitleFontSize, fontWeight: FontWeight.w400, color: AppTheme.pureWhite),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.borderRadius())),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.pureWhite,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
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
                width: ResponsiveBreakpoints.responsive(context, tablet: 85.w, small: 75.w, medium: 60.w, large: 50.w, ultrawide: 40.w),
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
                    Expanded(child: _buildFormContent()),
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
        gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
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
            child: Icon(Icons.edit_outlined, color: AppTheme.pureWhite, size: context.iconSize('large')),
          ),
          SizedBox(width: context.cardPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Order',
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
                    'Update order information',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.pureWhite.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.pureWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          widget.order.id,
                          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
                        ),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.order.status).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(widget.order.status),
                          style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: AppTheme.pureWhite),
                        ),
                      ),
                    ],
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.cardPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer Information Section
                _buildCustomerInfoSection(),
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
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Customer Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          if (_isLoadingCustomerDetails)
            const Center(child: CircularProgressIndicator())
          else if (_selectedCustomer != null) ...[
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      _selectedCustomer!.initials,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blue[700]),
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
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(context.borderRadius('small')),
                            ),
                            child: Text(
                              _selectedCustomer!.id,
                              style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w600, color: Colors.blue),
                            ),
                          ),
                          SizedBox(width: context.smallPadding),
                          Expanded(
                            child: Text(
                              _selectedCustomer!.name,
                              style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
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
            SizedBox(height: context.cardPadding),
            Container(
              padding: EdgeInsets.all(context.smallPadding),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(context.borderRadius('small'))),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.green, size: context.iconSize('small')),
                  SizedBox(width: context.smallPadding),
                  Text(
                    'Customer since: ${_formatDate(_selectedCustomer!.createdAt)}',
                    style: GoogleFonts.inter(fontSize: context.captionFontSize, fontWeight: FontWeight.w500, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Colors.green, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Order Details',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
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
          // Show current status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.smallPadding, vertical: context.smallPadding / 2),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.borderRadius('small')),
              border: Border.all(color: _getStatusColor(widget.order.status)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: _getStatusColor(widget.order.status), size: 16),
                SizedBox(width: context.smallPadding / 2),
                Text(
                  'Current Status: ${_getStatusText(widget.order.status)}',
                  style: GoogleFonts.inter(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(widget.order.status),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.smallPadding),
          Wrap(
            spacing: context.smallPadding,
            runSpacing: context.smallPadding / 2,
            children: _getValidStatusOptions()
                .map(
                  (status) => InkWell(
                    onTap: () => _handleStatusChange(status),
                    borderRadius: BorderRadius.circular(context.borderRadius('small')),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: context.cardPadding / 2, vertical: context.smallPadding),
                      decoration: BoxDecoration(
                        color: _selectedStatus == status ? _getStatusColor(status).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(context.borderRadius('small')),
                        border: Border.all(
                          color: _selectedStatus == status ? _getStatusColor(status) : Colors.grey.shade300,
                          width: _selectedStatus == status ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: GoogleFonts.inter(
                          fontSize: context.captionFontSize,
                          fontWeight: _selectedStatus == status ? FontWeight.w600 : FontWeight.w500,
                          color: _selectedStatus == status ? _getStatusColor(status) : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Show status transition info
          if (_getValidNextStatuses(widget.order.status).isNotEmpty) ...[
            SizedBox(height: context.smallPadding),
            Container(
              padding: EdgeInsets.all(context.smallPadding),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: context.smallPadding / 2),
                  Expanded(
                    child: Text(
                      'Valid next statuses: ${_getValidNextStatuses(widget.order.status).map((s) => _getStatusText(s)).join(', ')}',
                      style: GoogleFonts.inter(fontSize: context.captionFontSize, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.orange, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Financial Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Total Amount (PKR)',
            hint: 'Total order amount',
            controller: TextEditingController(text: 'PKR ${widget.order.totalAmount.toStringAsFixed(2)}'),
            prefixIcon: Icons.attach_money_rounded,
            enabled: false,
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Advance Payment (PKR) *',
            hint: 'Enter advance payment amount',
            controller: _advancePaymentController,
            prefixIcon: Icons.payment_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter advance payment';
              }
              if (double.tryParse(value!) == null) {
                return 'Please enter a valid amount';
              }
              final advance = double.parse(value);
              if (advance < 0) {
                return 'Advance payment cannot be negative';
              }
              if (advance > widget.order.totalAmount) {
                return 'Advance payment cannot exceed total amount';
              }
              return null;
            },
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Remaining Amount (PKR)',
            hint: 'Remaining amount to be paid',
            controller: TextEditingController(text: 'PKR ${widget.order.remainingAmount.toStringAsFixed(2)}'),
            prefixIcon: Icons.account_balance_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.purple, size: context.iconSize('medium')),
              SizedBox(width: context.smallPadding),
              Text(
                'Delivery Information',
                style: GoogleFonts.inter(fontSize: context.bodyFontSize, fontWeight: FontWeight.w600, color: AppTheme.charcoalGray),
              ),
            ],
          ),
          SizedBox(height: context.cardPadding),
          PremiumTextField(
            label: 'Order Date',
            hint: 'Date when order was placed',
            controller: TextEditingController(
              text:
                  '${widget.order.dateOrdered.day.toString().padLeft(2, '0')}/${widget.order.dateOrdered.month.toString().padLeft(2, '0')}/${widget.order.dateOrdered.year}',
            ),
            prefixIcon: Icons.calendar_today_outlined,
            enabled: false,
          ),
          SizedBox(height: context.cardPadding),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDeliveryDate ?? DateTime.now().add(const Duration(days: 1)),
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
                  Icon(Icons.calendar_today_outlined, color: Colors.purple, size: context.iconSize('medium')),
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

  Widget _buildCompactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return PremiumButton(
              text: 'Update Order',
              onPressed: provider.isLoading ? null : _handleUpdate,
              isLoading: provider.isLoading,
              height: context.buttonHeight,
              icon: Icons.save_rounded,
              backgroundColor: Colors.blue,
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
          flex: 2,
          child: PremiumButton(
            text: 'Cancel',
            onPressed: _handleCancel,
            height: context.buttonHeight / 1.5,
            backgroundColor: Colors.grey[600],
            textColor: AppTheme.pureWhite,
          ),
        ),
        SizedBox(width: context.cardPadding),
        Expanded(
          flex: 1,
          child: Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return PremiumButton(
                text: 'Update',
                onPressed: provider.isLoading ? null : _handleUpdate,
                isLoading: provider.isLoading,
                height: context.buttonHeight / 1.5,
                icon: Icons.save_rounded,
                backgroundColor: Colors.blue,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
