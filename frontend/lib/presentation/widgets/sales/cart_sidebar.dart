import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/sales_provider.dart';
import '../../../src/models/customer/customer_model.dart';
import '../../../src/theme/app_theme.dart';

class CartSidebar extends StatefulWidget {
  final VoidCallback onCheckout;
  final TextEditingController customerSearchController;

  const CartSidebar({
    super.key,
    required this.onCheckout,
    required this.customerSearchController,
  });

  @override
  State<CartSidebar> createState() => _CartSidebarState();
}

class _CartSidebarState extends State<CartSidebar> {
  bool _showCustomerDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: context.shadowBlur(),
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCartHeader(),
          _buildCustomerSelection(),
          Expanded(child: _buildCartItems()),
          _buildCartSummary(),
          _buildCheckoutButton(),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(context.cardPadding / 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.secondaryMaroon],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.smallPadding),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
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
                      l10n.cart,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: context.headerFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.pureWhite,
                      ),
                    ),
                    Text(
                      '${provider.cartTotalItems} ${l10n.items}',
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        color: AppTheme.pureWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.currentCart.isNotEmpty)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showClearCartDialog(context, provider),
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                    child: Container(
                      padding: EdgeInsets.all(context.smallPadding / 2),
                      child: Icon(
                        Icons.clear_all_rounded,
                        color: AppTheme.pureWhite.withOpacity(0.8),
                        size: context.iconSize('medium'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerSelection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(context.cardPadding / 2),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.customer,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalGray,
                ),
              ),
              SizedBox(height: context.smallPadding),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CustomerModel?>(
                    value: provider.selectedCustomer,
                    isExpanded: true,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.cardPadding / 2,
                      ),
                      child: Text(
                        l10n.selectCustomer,
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    onChanged: (customer) =>
                        provider.setSelectedCustomer(customer),
                    items: [
                      DropdownMenuItem<CustomerModel?>(
                        value: null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.cardPadding / 2,
                          ),
                          child: Text(
                            l10n.walkInCustomer,
                            style: GoogleFonts.inter(
                              fontSize: context.bodyFontSize,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ),
                      ),
                      ...provider.customers
                          .map(
                            (customer) => DropdownMenuItem<CustomerModel?>(
                          value: customer,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.cardPadding / 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  customer.name,
                                  style: GoogleFonts.inter(
                                    fontSize: context.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.charcoalGray,
                                  ),
                                ),
                                Text(
                                  customer.phone,
                                  style: GoogleFonts.inter(
                                    fontSize: context.captionFontSize,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ],
                  ),
                ),
              ),

              if (provider.selectedCustomer != null) ...[
                SizedBox(height: context.smallPadding),
                Container(
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMaroon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius()),
                    border: Border.all(
                      color: AppTheme.primaryMaroon.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: AppTheme.primaryMaroon,
                        size: context.iconSize('medium'),
                      ),
                      SizedBox(width: context.smallPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.selectedCustomer!.name,
                              style: GoogleFonts.inter(
                                fontSize: context.bodyFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoalGray,
                              ),
                            ),
                            Text(
                              provider.selectedCustomer!.phone,
                              style: GoogleFonts.inter(
                                fontSize: context.captionFontSize,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItems() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        if (provider.currentCart.isEmpty) {
          return _buildEmptyCart();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: context.smallPadding / 2),
          itemCount: provider.currentCart.length,
          itemBuilder: (context, index) {
            final item = provider.currentCart[index];
            return _buildCartItem(context, item, provider);
          },
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: ResponsiveBreakpoints.responsive(
              context,
              tablet: 12.w,
              small: 10.w,
              medium: 8.w,
              large: 6.w,
              ultrawide: 5.w,
            ),
            color: Colors.grey[300],
          ),
          SizedBox(height: context.cardPadding),
          Text(
            l10n.cartIsEmpty,
            style: GoogleFonts.inter(
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: context.smallPadding),
          Text(
            l10n.addProductsToStartSale,
            style: GoogleFonts.inter(
              fontSize: context.subtitleFontSize,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context,
      CartItem item,
      SalesProvider provider,
      ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.cardPadding / 2,
        vertical: context.smallPadding / 2,
      ),
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: context.shadowBlur('light'),
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: GoogleFonts.inter(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => provider.removeFromCart(item.id),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                  child: Container(
                    padding: EdgeInsets.all(context.smallPadding / 2),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                      size: context.iconSize('small'),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.smallPadding / 2),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unitPrice,
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'PKR ${item.unitPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.quantity > 1
                          ? () => provider.updateCartItemQuantity(
                        item.id,
                        item.quantity - 1,
                      )
                          : null,
                      borderRadius: BorderRadius.circular(
                        context.borderRadius('small'),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(context.smallPadding / 2),
                        decoration: BoxDecoration(
                          color: item.quantity > 1
                              ? AppTheme.primaryMaroon
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(
                            context.borderRadius('small'),
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: AppTheme.pureWhite,
                          size: context.iconSize('small'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: context.smallPadding,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.smallPadding,
                      vertical: context.smallPadding / 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(
                        context.borderRadius('small'),
                      ),
                    ),
                    child: Text(
                      item.quantity.toString(),
                      style: GoogleFonts.inter(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => provider.updateCartItemQuantity(
                        item.id,
                        item.quantity + 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        context.borderRadius('small'),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(context.smallPadding / 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMaroon,
                          borderRadius: BorderRadius.circular(
                            context.borderRadius('small'),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppTheme.pureWhite,
                          size: context.iconSize('small'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: context.smallPadding / 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.itemDiscount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallPadding / 2,
                    vertical: context.smallPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      context.borderRadius('small'),
                    ),
                  ),
                  child: Text(
                    '${l10n.discount}: PKR ${item.itemDiscount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[700],
                    ),
                  ),
                ),

              if (item.itemDiscount <= 0) const SizedBox.shrink(),

              Text(
                'PKR ${item.lineTotal.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryMaroon,
                ),
              ),
            ],
          ),

          if (item.customizationNotes != null &&
              item.customizationNotes!.isNotEmpty) ...[
            SizedBox(height: context.smallPadding / 2),
            Container(
              padding: EdgeInsets.all(context.smallPadding / 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  context.borderRadius('small'),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_outlined,
                    color: Colors.blue,
                    size: context.iconSize('small'),
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Expanded(
                    child: Text(
                      '${l10n.notes}: ${item.customizationNotes}',
                      style: GoogleFonts.inter(
                        fontSize: context.captionFontSize,
                        color: Colors.blue[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCartSummary() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        if (provider.currentCart.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withOpacity(0.3),
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.subtotal,
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    'PKR ${provider.cartSubtotal.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.smallPadding / 2),

              if (provider.overallDiscount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.discount,
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: Colors.orange[700],
                      ),
                    ),
                    Text(
                      '- PKR ${provider.overallDiscount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
              ],

              if (provider.gstPercentage > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GST (${provider.gstPercentage}%)',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'PKR ${provider.cartGstAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
              ],

              if (provider.taxPercentage > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.tax} (${provider.taxPercentage}%)',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                    Text(
                      'PKR ${provider.cartTaxAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.smallPadding / 2),
              ],

              Divider(color: Colors.grey.shade300, thickness: 1),

              SizedBox(height: context.smallPadding / 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.total,
                    style: GoogleFonts.inter(
                      fontSize: context.headerFontSize * 0.9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  Text(
                    'PKR ${provider.cartGrandTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: context.headerFontSize * 0.9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryMaroon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutButton() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        final isDisabled = provider.currentCart.isEmpty || provider.isLoading;

        return Container(
          padding: EdgeInsets.all(context.cardPadding / 2),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              )
                  : const LinearGradient(
                colors: [
                  AppTheme.primaryMaroon,
                  AppTheme.secondaryMaroon,
                ],
              ),
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onCheckout,
                borderRadius: BorderRadius.circular(context.borderRadius()),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: context.cardPadding / 2,
                  ),
                  child: provider.isLoading
                      ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.pureWhite,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_rounded,
                        color: AppTheme.pureWhite,
                        size: context.iconSize('medium'),
                      ),
                      SizedBox(width: context.smallPadding),
                      Text(
                        context.shouldShowCompactLayout
                            ? l10n.checkout
                            : l10n.proceedToCheckout,
                        style: GoogleFonts.inter(
                          fontSize: context.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.pureWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context, SalesProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius()),
        ),
        title: Text(
          l10n.clearCart,
          style: GoogleFonts.inter(
            fontSize: context.headerFontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoalGray,
          ),
        ),
        content: Text(
          l10n.clearCartQuestion,
          style: GoogleFonts.inter(
            fontSize: context.bodyFontSize,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(context.borderRadius()),
            ),
            child: TextButton(
              onPressed: () {
                provider.clearCart();
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.clearCart,
                style: GoogleFonts.inter(
                  fontSize: context.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
