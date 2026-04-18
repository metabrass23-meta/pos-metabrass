import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/providers/sales_provider.dart';
import '../../../src/models/sales/sale_model.dart';
import '../../../src/services/pdf_invoice_service.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../../widgets/globals/text_button.dart';
import 'create_invoice_dialog.dart';
import 'edit_invoice_dialog.dart';
import 'view_invoice_dialog.dart';

class InvoiceManagementWidget extends StatefulWidget {
  const InvoiceManagementWidget({super.key});

  @override
  State<InvoiceManagementWidget> createState() =>
      _InvoiceManagementWidgetState();
}

class _InvoiceManagementWidgetState extends State<InvoiceManagementWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';
  Timer? _searchDebounce;
  final Map<String, bool> _printingStatus = {}; // ✅ Track printing state per invoice

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceProvider>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Filters Section ---
            _buildFilters(l10n),
            const SizedBox(height: 16),
            // --- Invoices List ---
            Expanded(child: _buildInvoicesList(l10n)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateInvoiceDialog(context),
        backgroundColor: AppTheme.primaryMaroon,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: l10n.createInvoice ?? "Create Invoice",
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.filters ?? "Filters",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontFamily: AppTheme.englishFontFamily,
                    fontSize: context.bodyFontSize,
                    color: AppTheme.charcoalGray,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.search ?? "Search",
                    hintText: "Search by Invoice # or Customer...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(milliseconds: 500),
                      () {
                        if (mounted) {
                          context.read<InvoiceProvider>().setFilters(search: value);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Status Dropdown
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus.isEmpty ? null : _selectedStatus,
                  decoration: InputDecoration(
                    labelText: l10n.status ?? "Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.allStatuses ?? "All")),
                    DropdownMenuItem(value: 'DRAFT', child: Text(l10n.draft ?? "Draft")),
                    DropdownMenuItem(value: 'ISSUED', child: Text("Issued")),
                    DropdownMenuItem(value: 'PAID', child: Text(l10n.paid ?? "Paid")),
                    DropdownMenuItem(value: 'OVERDUE', child: Text(l10n.overdue ?? "Overdue")),
                    DropdownMenuItem(value: 'CANCELLED', child: Text("Cancelled")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value ?? '');
                    context.read<InvoiceProvider>().setFilters(status: value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedStatus = '');
                  context.read<InvoiceProvider>().clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: Text(l10n.clearFilters ?? "Clear"),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryMaroon),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.read<InvoiceProvider>().refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.refresh ?? "Refresh"),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryMaroon),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList(AppLocalizations l10n) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.invoices.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryMaroon));
        }
        if (provider.error != null && provider.invoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('${l10n.error ?? "Error"}: ${provider.error}'),
                const SizedBox(height: 16),
                PremiumButton(
                  text: l10n.retry ?? "Retry",
                  onPressed: () => provider.refresh(),
                  width: 120,
                ),
              ],
            ),
          );
        }
        final invoices = provider.filteredInvoices;
        if (invoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(l10n.noInvoicesFound ?? "No Invoices Found", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          color: AppTheme.primaryMaroon,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: invoices.length,
            itemBuilder: (context, index) => _buildInvoiceCard(invoices[index], provider, l10n),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceCard(
    InvoiceModel invoice,
    InvoiceProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(invoice.status),
          child: Icon(
            _getStatusIcon(invoice.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('${l10n.customer ?? "Customer"}: ${invoice.customerName}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'PKR ${invoice.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryMaroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    invoice.statusDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(invoice.status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _printingStatus[invoice.id] == true
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryMaroon),
              )
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) =>
                    _handleInvoiceAction(value, invoice, provider, l10n),
                itemBuilder: (context) => _buildInvoiceActionMenu(l10n),
              ),
        onTap: () => _showInvoiceDetails(invoice, l10n),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.grey;
      case 'ISSUED':
        return Colors.blue;
      case 'PAID':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      default:
        return AppTheme.primaryMaroon;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DRAFT':
        return Icons.edit_note;
      case 'ISSUED':
        return Icons.send;
      case 'PAID':
        return Icons.check_circle_outline;
      case 'OVERDUE':
        return Icons.warning_amber_rounded;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt;
    }
  }

  List<PopupMenuEntry<String>> _buildInvoiceActionMenu(AppLocalizations l10n) {
    return [
      PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            const Icon(Icons.visibility, color: Colors.blue, size: 20),
            const SizedBox(width: 10),
            Text(l10n.view ?? "View"),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            const Icon(Icons.edit, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(l10n.edit ?? "Edit"),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'print_pdf',
        child: Row(
          children: [
            const Icon(Icons.print, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            Text("Print PDF"),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Text(l10n.delete ?? "Delete"),
          ],
        ),
      ),
    ];
  }

  void _handleInvoiceAction(
    String action,
    InvoiceModel invoice,
    InvoiceProvider provider,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'view':
        _showInvoiceDetails(invoice, l10n);
        break;
      case 'edit':
        _showEditInvoiceDialog(invoice);
        break;
      case 'print_pdf':
        _printPdfInvoice(invoice, l10n);
        break;
      case 'delete':
        _showDeleteInvoiceDialog(invoice, provider, l10n);
        break;
    }
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateInvoiceDialog(),
    );
  }

  void _showInvoiceDetails(InvoiceModel invoice, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => ViewInvoiceDialog(invoice: invoice),
    );
  }

  void _showEditInvoiceDialog(InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => EditInvoiceDialog(invoice: invoice),
    );
  }

  void _printPdfInvoice(InvoiceModel invoice, AppLocalizations l10n) async {
    setState(() => _printingStatus[invoice.id] = true);
    try {
      final salesProvider = context.read<SalesProvider>();
      final sale = await salesProvider.getSaleById(invoice.saleId);

      if (sale == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load sale details'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await PdfInvoiceService.previewAndPrintInvoice(sale);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invoice PDF opened successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _printingStatus[invoice.id] = false);
    }
  }

  void _showDeleteInvoiceDialog(
    InvoiceModel invoice,
    InvoiceProvider provider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Invoice"),
        content: Text(
          'Are you sure you want to delete Invoice ${invoice.invoiceNumber}? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          PremiumButton(
            text: l10n.cancel ?? "Cancel",
            onPressed: () => Navigator.pop(context),
            isOutlined: true,
            width: 100,
          ),
          PremiumButton(
            text: "Delete",
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              final success = await provider.deleteInvoice(invoice.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invoice Deleted Successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to delete invoice"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            backgroundColor: Colors.red,
            width: 100,
          ),
        ],
      ),
    );
  }

  void _showThermalPrintDialog(
    Map<String, dynamic> thermalData,
    String invoiceNumber,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thermal Print - $invoiceNumber"),
        content: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      thermalData['company']?['name'] ?? 'Maqbool Fashion',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      thermalData['company']?['address'] ??
                          'Kacha Eminabadroad Siddique Colony Gujranwala',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      thermalData['company']?['phone'] ?? '055-8174471',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Invoice #: ${thermalData['invoice']?['invoice_number'] ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Date: ${thermalData['invoice']?['issue_date'] ?? 'N/A'}'),
              Text(
                'Customer: ${thermalData['invoice']?['customer_name'] ?? 'Walk-in Customer'}',
              ),
              if ((thermalData['invoice']?['customer_phone'] ?? '').isNotEmpty)
                Text('Phone: ${thermalData['invoice']?['customer_phone']}'),
              const Divider(),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: thermalData['items']?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = thermalData['items'][index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item['name'] ?? 'N/A')),
                          Text('${item['quantity'] ?? 0}x'),
                          Text(
                            'PKR ${(item['total'] ?? 0.0).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Text(
                'Subtotal: PKR ${(thermalData['totals']?['subtotal'] ?? 0.0).toStringAsFixed(2)}',
              ),
              Text(
                'Tax: PKR ${(thermalData['totals']?['tax'] ?? 0.0).toStringAsFixed(2)}',
              ),
              Text(
                'Discount: PKR ${(thermalData['totals']?['discount'] ?? 0.0).toStringAsFixed(2)}',
              ),
              Text(
                'TOTAL: PKR ${(thermalData['totals']?['total'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          PremiumButton(
            text: "Print",
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thermal printer integration coming soon!"),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            width: 100,
          ),
          PremiumButton(
            text: "Close",
            onPressed: () => Navigator.pop(context),
            isOutlined: true,
            width: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
