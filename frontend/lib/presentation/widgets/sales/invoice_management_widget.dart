import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _selectedCustomer = '';

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildInvoicesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateInvoiceDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Invoice',
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search by invoice number, customer, or sale',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => context.read<InvoiceProvider>().setFilters(search: value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus.isEmpty ? null : _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Statuses')),
                      const DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                      const DropdownMenuItem(value: 'ISSUED', child: Text('Issued')),
                      const DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                      const DropdownMenuItem(value: 'VIEWED', child: Text('Viewed')),
                      const DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                      const DropdownMenuItem(value: 'OVERDUE', child: Text('Overdue')),
                      const DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
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
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = '';
                      _selectedCustomer = '';
                    });
                    context.read<InvoiceProvider>().clearFilters();
                  },
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
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
                Text('Error: ${provider.error}'),
                ElevatedButton(onPressed: () => provider.refresh(), child: const Text('Retry')),
              ],
            ),
          );
        }

        final invoices = provider.filteredInvoices;

        if (invoices.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No invoices found'),
                Text('Create a new invoice using the + button'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return _buildInvoiceCard(invoice, provider);
          },
        );
      },
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice, InvoiceProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: invoice.statusColor,
          child: Icon(_getStatusIcon(invoice.status), color: Colors.white),
        ),
        title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: PKR ${invoice.grandTotal.toStringAsFixed(2)}'),
            Text('Customer: ${invoice.customerName}'),
            Text('Status: ${invoice.statusDisplay}'),
            Text('Issue Date: ${invoice.formattedIssueDate}'),
            if (invoice.dueDate != null) Text('Due Date: ${invoice.formattedDueDate}'),
            if (invoice.isOverdue)
              Text(
                'OVERDUE!',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
      case 'DRAFT':
        return Icons.edit;
      case 'ISSUED':
        return Icons.receipt_long;
      case 'SENT':
        return Icons.send;
      case 'VIEWED':
        return Icons.visibility;
      case 'PAID':
        return Icons.check_circle;
      case 'OVERDUE':
        return Icons.warning;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  List<PopupMenuEntry<String>> _buildInvoiceActionMenu(InvoiceModel invoice) {
    return [
      const PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility, color: Colors.blue),
            SizedBox(width: 8),
            Text('View'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, color: Colors.orange),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'generate_pdf',
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.green),
            SizedBox(width: 8),
            Text('Generate PDF'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete'),
          ],
        ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice Details - ${invoice.invoiceNumber}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Invoice Number', invoice.invoiceNumber),
              _buildDetailRow('Sale Invoice Number', invoice.saleInvoiceNumber),
              _buildDetailRow('Customer', invoice.customerName),
              _buildDetailRow('Amount', 'PKR ${invoice.grandTotal.toStringAsFixed(2)}'),
              _buildDetailRow('Status', invoice.statusDisplay),
              _buildDetailRow('Issue Date', invoice.formattedIssueDate),
              if (invoice.dueDate != null) _buildDetailRow('Due Date', invoice.formattedDueDate),
              if (invoice.notes?.isNotEmpty == true) _buildDetailRow('Notes', invoice.notes!),
              if (invoice.termsConditions?.isNotEmpty == true) _buildDetailRow('Terms & Conditions', invoice.termsConditions!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
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
    final success = await provider.generateInvoicePdf(invoice.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice PDF generated successfully'), backgroundColor: Colors.green));
    }
  }

  void _showDeleteInvoiceDialog(InvoiceModel invoice, InvoiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Invoice - ${invoice.invoiceNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this invoice?'),
            const SizedBox(height: 8),
            Text('Amount: PKR ${invoice.grandTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('This action cannot be undone.', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteInvoice(invoice.id);
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Invoice deleted successfully'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
