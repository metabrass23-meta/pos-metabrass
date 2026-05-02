import 'package:flutter/material.dart';
import 'package:frontend/src/utils/responsive_breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../src/models/payment/payment_model.dart';
import '../../../src/models/vendor/vendor_model.dart';
import '../../../src/providers/payment_provider.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class PaymentTable extends StatelessWidget {
  final Function(PaymentModel) onEdit;
  final Function(PaymentModel) onDelete;
  final Function(PaymentModel) onViewReceipt;

  const PaymentTable({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minTableWidth = _getTableMinWidth(context);
        final double tableWidth = constraints.maxWidth > minTableWidth
            ? constraints.maxWidth
            : minTableWidth;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(context.borderRadius('large')),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: context.shadowBlur(),
                offset: Offset(0, context.smallPadding),
              ),
            ],
          ),
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.cardPadding,
                        horizontal: context.cardPadding / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(context.borderRadius('large')),
                          topRight: Radius.circular(context.borderRadius('large')),
                        ),
                      ),
                      child: _buildHeaderRow(context, tableWidth),
                    ),
                    
                    // Body
                    Expanded(
                      child: Consumer<PaymentProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryMaroon,
                              ),
                            );
                          }

                          if (provider.payments.isEmpty) {
                            return _buildEmptyState(context);
                          }

                          return ListView.builder(
                            itemCount: provider.payments.length,
                            itemBuilder: (context, index) {
                              final payment = provider.payments[index];
                              return _buildTableRow(context, payment, index, tableWidth);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getTableMinWidth(BuildContext context) {
    return 1600.0;
  }

  Widget _buildHeaderRow(BuildContext context, double totalWidth) {
    final l10n = AppLocalizations.of(context)!;
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Row(
      children: [
        SizedBox(width: columnWidths[0], child: _buildHeaderCell(context, l10n.id)),
        SizedBox(width: columnWidths[1], child: _buildHeaderCell(context, 'Payer Details')),
        SizedBox(width: columnWidths[2], child: _buildHeaderCell(context, l10n.amount)),
        SizedBox(width: columnWidths[3], child: _buildHeaderCell(context, l10n.paymentInfo)),
        SizedBox(width: columnWidths[4], child: _buildHeaderCell(context, l10n.dateAndTime)),
        SizedBox(width: columnWidths[5], child: _buildHeaderCell(context, l10n.receipt)),
        SizedBox(width: columnWidths[6], child: _buildHeaderCell(context, l10n.status)),
        SizedBox(width: columnWidths[7], child: _buildHeaderCell(context, l10n.actions)),
      ],
    );
  }

  List<double> _getColumnWidths(BuildContext context, double totalWidth) {
    final double idWidth = 100.0;
    final double amountWidth = 180.0;
    final double infoWidth = 220.0;
    final double dateWidth = 220.0;
    final double receiptWidth = 150.0;
    final double statusWidth = 180.0;
    final double actionsWidth = 320.0;
    
    final double fixedSum = idWidth + amountWidth + infoWidth + dateWidth + receiptWidth + statusWidth + actionsWidth;
    final double payerWidth = totalWidth - fixedSum;

    return [
      idWidth,
      payerWidth > 250.0 ? payerWidth : 250.0,
      amountWidth,
      infoWidth,
      dateWidth,
      receiptWidth,
      statusWidth,
      actionsWidth,
    ];
  }

  Widget _buildHeaderCell(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontSize: context.bodyFontSize,
          fontWeight: FontWeight.w600,
          color: AppTheme.charcoalGray,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    PaymentModel payment,
    int index,
    double totalWidth,
  ) {
    final columnWidths = _getColumnWidths(context, totalWidth);

    return Container(
      padding: EdgeInsets.symmetric(vertical: context.cardPadding / 2),
      decoration: BoxDecoration(
        color: index.isEven
            ? AppTheme.pureWhite
            : AppTheme.lightGray.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // ID
          SizedBox(
            width: columnWidths[0],
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    context.borderRadius('small'),
                  ),
                ),
                child: Text(
                  payment.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: context.captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryMaroon,
                  ),
                ),
              ),
            ),
          ),

          // Payer Details
          SizedBox(
            width: columnWidths[1],
            child: Consumer<VendorProvider>(
              builder: (context, vendorProvider, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
                  child: Text(
                    _getPayerDisplayName(payment, vendorProvider),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                );
              },
            ),
          ),

          // Amount
          SizedBox(
            width: columnWidths[2],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    context.borderRadius('small'),
                  ),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'PKR ${payment.netAmount.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: context.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Payment Info
          SizedBox(
            width: columnWidths[3],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Row(
                children: [
                  Icon(
                    payment.paymentMethodIcon,
                    color: payment.paymentMethodColor,
                    size: context.iconSize('small'),
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Expanded(
                    child: Text(
                      payment.paymentMethod,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: context.subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: payment.paymentMethodColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Date and Time
          SizedBox(
            width: columnWidths[4],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Row(
                children: [
                  Text(
                    _formatDate(payment.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: context.subtitleFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoalGray,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '(${payment.formattedTime})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Receipt
          SizedBox(
            width: columnWidths[5],
            child: Center(
              child: payment.hasReceipt
                  ? Icon(Icons.receipt_rounded, color: Colors.green, size: context.iconSize('small'))
                  : Icon(Icons.receipt_long_outlined, color: Colors.red, size: context.iconSize('small')),
            ),
          ),

          // Status
          SizedBox(
            width: columnWidths[6],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: payment.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius('small')),
                  border: Border.all(color: payment.statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: payment.statusColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: context.captionFontSize,
                          fontWeight: FontWeight.w500,
                          color: payment.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: columnWidths[7],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.smallPadding),
              child: _buildStandardActions(context, payment),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActions(BuildContext context, PaymentModel payment) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit(payment);
        } else if (value == 'delete') {
          onDelete(payment);
        } else if (value == 'receipt') {
          onViewReceipt(payment);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                l10n.edit,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'receipt',
          child: Row(
            children: [
              Icon(
                payment.hasReceipt
                    ? Icons.visibility_outlined
                    : Icons.add_photo_alternate_outlined,
                color: payment.hasReceipt ? Colors.green : Colors.orange,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                payment.hasReceipt ? l10n.viewReceipt : l10n.addReceipt,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  color: payment.hasReceipt ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: context.iconSize('small'),
              ),
              SizedBox(width: context.smallPadding),
              Text(
                l10n.delete,
                style: TextStyle(
                  fontSize: context.captionFontSize,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(context.smallPadding),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(context.borderRadius('small')),
        ),
        child: Icon(
          Icons.more_vert,
          size: context.iconSize('small'),
          color: AppTheme.charcoalGray,
        ),
      ),
    );
  }

  Widget _buildStandardActions(BuildContext context, PaymentModel payment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onEdit(payment),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  context.borderRadius('small'),
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),
        SizedBox(width: context.smallPadding),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onViewReceipt(payment),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: payment.hasReceipt
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  context.borderRadius('small'),
                ),
              ),
              child: Icon(
                payment.hasReceipt
                    ? Icons.visibility_outlined
                    : Icons.add_photo_alternate_outlined,
                color: payment.hasReceipt ? Colors.green : Colors.orange,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),
        SizedBox(width: context.smallPadding),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDelete(payment),
            borderRadius: BorderRadius.circular(context.borderRadius('small')),
            child: Container(
              padding: EdgeInsets.all(context.smallPadding * 0.5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  context.borderRadius('small'),
                ),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: context.iconSize('small'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedActions(BuildContext context, PaymentModel payment) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onEdit(payment),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      l10n.edit,
                      style: TextStyle(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.smallPadding / 2),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onViewReceipt(payment),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: payment.hasReceipt
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      payment.hasReceipt
                          ? Icons.visibility_outlined
                          : Icons.add_photo_alternate_outlined,
                      color: payment.hasReceipt ? Colors.green : Colors.orange,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      payment.hasReceipt ? l10n.view : l10n.add,
                      style: TextStyle(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: payment.hasReceipt
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.smallPadding / 2),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDelete(payment),
              borderRadius: BorderRadius.circular(context.borderRadius()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.smallPadding,
                  vertical: context.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: context.iconSize('small'),
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      l10n.delete,
                      style: TextStyle(
                        fontSize: context.captionFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveBreakpoints.responsive(
              context,
              tablet: 5.w,
              small: 5.w,
              medium: 5.w,
              large: 5.w,
              ultrawide: 5.w,
            ),
            height: ResponsiveBreakpoints.responsive(
              context,
              tablet: 5.w,
              small: 5.w,
              medium: 5.w,
              large: 5.w,
              ultrawide: 5.w,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(context.borderRadius('xl')),
            ),
            child: Icon(
              Icons.payments_outlined,
              size: context.iconSize('xl'),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: context.mainPadding),
          Text(
            l10n.noPaymentRecordsFound,
            style: TextStyle(
              fontSize: context.headerFontSize * 0.8,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
          ),
          SizedBox(height: context.smallPadding),
          Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveBreakpoints.responsive(
                context,
                tablet: 80.w,
                small: 70.w,
                medium: 60.w,
                large: 50.w,
                ultrawide: 40.w,
              ),
            ),
            child: Text(
              l10n.startByAddingFirstPaymentRecord,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getPayerDisplayName(
    PaymentModel payment,
    VendorProvider vendorProvider,
  ) {
    if (payment.payerType.toUpperCase() == 'VENDOR') {
      try {
        final vendor = vendorProvider.vendors.firstWhere(
          (v) => v.id == payment.vendorId,
        );
        return vendor.name;
      } catch (e) {
        return 'Unknown Vendor';
      }
    } else if (payment.payerType.toUpperCase() == 'LABOR') {
      return payment.laborName ?? 'Labour';
    } else if (payment.payerType.toUpperCase() == 'SALE') {
      return 'Sale Payment';
    } else if (payment.payerType.toUpperCase() == 'ORDER') {
      return 'Order Payment';
    }
    return payment.payerType;
  }

  String _getPayerSubInfo(PaymentModel payment, VendorProvider vendorProvider) {
    if (payment.payerType.toUpperCase() == 'VENDOR') {
      try {
        final vendor = vendorProvider.vendors.firstWhere(
          (v) => v.id == payment.vendorId,
        );
        return vendor.phone.isNotEmpty ? vendor.phone : 'No Phone';
      } catch (e) {
        return 'No Phone';
      }
    } else if (payment.payerType.toUpperCase() == 'LABOR') {
      return payment.laborRole ?? 'No Role';
    } else if (payment.payerType.toUpperCase() == 'SALE') {
      return 'Sale: ${payment.saleId?.substring(0, 8) ?? 'N/A'}';
    } else if (payment.payerType.toUpperCase() == 'ORDER') {
      return 'Order: ${payment.orderId?.substring(0, 8) ?? 'N/A'}';
    }
    return payment.payerType;
  }
}
