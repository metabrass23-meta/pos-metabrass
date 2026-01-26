import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/invoice_provider.dart';
import '../../../src/models/sales/sale_model.dart';
import 'create_invoice_dialog.dart';
import 'edit_invoice_dialog.dart';

class InvoiceManagementWidget extends StatefulWidget {
  const InvoiceManagementWidget({super.key});

  @override
  State<InvoiceManagementWidget> createState() => _InvoiceManagementWidgetState();
}

class _InvoiceManagementWidgetState extends State<InvoiceManagementWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    // Initialize data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // --- Filters Section ---
          _buildFilters(),

          // --- Invoices List ---
          Expanded(child: _buildInvoicesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateInvoiceDialog(context),
        child: const Icon(Icons.add),
        tooltip: l10n.createInvoice,
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filters, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                // Search Field
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: l10n.search,
                      hintText: l10n.searchByInvoiceNumberCustomerOrSale,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) => context.read<InvoiceProvider>().setFilters(search: value),
                  ),
                ),
                const SizedBox(width: 16),

                // Status Dropdown
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus.isEmpty ? null : _selectedStatus,
                    decoration: InputDecoration(
                      labelText: l10n.status,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem(value: '', child: Text(l10n.allStatuses)),
                      DropdownMenuItem(value: 'DRAFT', child: Text(l10n.draft)),
                      DropdownMenuItem(value: 'ISSUED', child: Text(l10n.issued)),
                      DropdownMenuItem(value: 'SENT', child: Text(l10n.sent)),
                      DropdownMenuItem(value: 'VIEWED', child: Text(l10n.viewed)),
                      DropdownMenuItem(value: 'PAID', child: Text(l10n.paid)),
                      DropdownMenuItem(value: 'OVERDUE', child: Text(l10n.overdue)),
                      DropdownMenuItem(value: 'CANCELLED', child: Text(l10n.cancelled)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? '';
                      });
                      context.read<InvoiceProvider>().setFilters(status: value);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Clear Filters Button
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = '';
                    });
                    context.read<InvoiceProvider>().clearFilters();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: Text(l10n.clearFilters),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('${l10n.error}: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: Text(l10n.retry)
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
                const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.noInvoicesFound, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.createNewInvoiceUsingButton, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return _buildInvoiceCard(invoice, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice, InvoiceProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: invoice.statusColor,
          child: Icon(_getStatusIcon(invoice.status), color: Colors.white),
        ),
        title: Text(
            invoice.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${l10n.customer}: ${invoice.customerName}'),
            Text(
              '${l10n.amount}: PKR ${invoice.grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Text('${l10n.status}: ${invoice.statusDisplay}'),
                const SizedBox(width: 8),
                Text('|  ${l10n.issueDate}: ${invoice.formattedIssueDate}'),
              ],
            ),
            if (invoice.isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.overdue,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleInvoiceAction(value, invoice, provider),
          itemBuilder: (context) => _buildInvoiceActionMenu(invoice),
        ),
        onTap: () => _showInvoiceDetails(invoice, provider),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DRAFT': return Icons.edit_note;
      case 'ISSUED': return Icons.receipt_long;
      case 'SENT': return Icons.send;
      case 'VIEWED': return Icons.visibility;
      case 'PAID': return Icons.check_circle;
      case 'OVERDUE': return Icons.warning;
      case 'CANCELLED': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  List<PopupMenuEntry<String>> _buildInvoiceActionMenu(InvoiceModel invoice) {
    final l10n = AppLocalizations.of(context)!;

    return [
      PopupMenuItem(
        value: 'view',
        child: Row(children: [const Icon(Icons.visibility, color: Colors.blue), const SizedBox(width: 8), Text(l10n.view)]),
      ),
      PopupMenuItem(
        value: 'edit',
        child: Row(children: [const Icon(Icons.edit, color: Colors.orange), const SizedBox(width: 8), Text(l10n.edit)]),
      ),
      PopupMenuItem(
        value: 'generate_pdf',
        child: Row(children: [const Icon(Icons.picture_as_pdf, color: Colors.green), const SizedBox(width: 8), Text(l10n.generatePdf)]),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: Row(children: [const Icon(Icons.delete, color: Colors.red), const SizedBox(width: 8), Text(l10n.delete)]),
      ),
    ];
  }

  void _handleInvoiceAction(String action, InvoiceModel invoice, InvoiceProvider provider) {
    switch (action) {
      case 'view':
        _showInvoiceDetails(invoice, provider);
        break;
      case 'edit':
        _showEditInvoiceDialog(invoice, provider);
        break;
      case 'generate_pdf':
        _generateInvoicePdf(invoice, provider);
        break;
      case 'delete':
        _showDeleteInvoiceDialog(invoice, provider);
        break;
    }
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateInvoiceDialog());
  }

  void _showInvoiceDetails(InvoiceModel invoice, InvoiceProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.invoiceDetailsWithNumber(invoice.invoiceNumber)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(l10n.invoiceNumber, invoice.invoiceNumber),
                _buildDetailRow(l10n.saleInvoiceNumber, invoice.saleInvoiceNumber),
                _buildDetailRow(l10n.customer, invoice.customerName),
                _buildDetailRow(l10n.amount, 'PKR ${invoice.grandTotal.toStringAsFixed(2)}'),
                const Divider(),
                _buildDetailRow(l10n.status, invoice.statusDisplay),
                _buildDetailRow(l10n.issueDate, invoice.formattedIssueDate),
                if (invoice.dueDate != null) _buildDetailRow(l10n.dueDate, invoice.formattedDueDate),
                const Divider(),
                if (invoice.notes?.isNotEmpty == true)
                  _buildDetailRow(l10n.notes, invoice.notes!),
                if (invoice.termsConditions?.isNotEmpty == true)
                  _buildDetailRow(l10n.termsAndConditions, invoice.termsConditions!),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close))],
      ),
    );
  }

  void _showEditInvoiceDialog(InvoiceModel invoice, InvoiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => EditInvoiceDialog(invoice: invoice),
    );
  }

  void _generateInvoicePdf(InvoiceModel invoice, InvoiceProvider provider) async {
    final l10n = AppLocalizations.of(context)!;

    final success = await provider.generateInvoicePdf(invoice.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoicePdfGeneratedSuccessfully), backgroundColor: Colors.green),
      );
    }
  }

  void _showDeleteInvoiceDialog(InvoiceModel invoice, InvoiceProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteInvoiceWithNumber(invoice.invoiceNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureDeleteInvoice),
            const SizedBox(height: 8),
            Text(
              '${l10n.amount}: PKR ${invoice.grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.actionCannotBeUndone, style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteInvoice(invoice.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.invoiceDeletedSuccessfully), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
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
            width: 140,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}