import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/receipt_provider.dart';
import '../../../src/models/sales/sale_model.dart';
import 'create_receipt_dialog.dart';
import 'edit_receipt_dialog.dart';

class ReceiptManagementWidget extends StatefulWidget {
  const ReceiptManagementWidget({super.key});

  @override
  State<ReceiptManagementWidget> createState() => _ReceiptManagementWidgetState();
}

class _ReceiptManagementWidgetState extends State<ReceiptManagementWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptProvider>().initialize();
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
          Expanded(child: _buildReceiptsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReceiptDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Receipt',
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
                      hintText: 'Search by receipt number, customer, or payment',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => context.read<ReceiptProvider>().setFilters(search: value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus.isEmpty ? null : _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Statuses')),
                      const DropdownMenuItem(value: 'GENERATED', child: Text('Generated')),
                      const DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                      const DropdownMenuItem(value: 'VIEWED', child: Text('Viewed')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? '';
                      });
                      context.read<ReceiptProvider>().setFilters(status: value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = '';
                    });
                    context.read<ReceiptProvider>().clearFilters();
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

  Widget _buildReceiptsList() {
    return Consumer<ReceiptProvider>(
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

        final receipts = provider.filteredReceipts;

        if (receipts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No receipts found'),
                Text('Create a new receipt using the + button'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            final receipt = receipts[index];
            return _buildReceiptCard(receipt, provider);
          },
        );
      },
    );
  }

  Widget _buildReceiptCard(ReceiptModel receipt, ReceiptProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(receipt.status),
          child: Icon(_getStatusIcon(receipt.status), color: Colors.white),
        ),
        title: Text(receipt.receiptNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${receipt.formattedPaymentAmount}'),
            Text('Customer: ${receipt.customerName}'),
            Text('Status: ${receipt.statusDisplay}'),
            Text('Generated: ${receipt.formattedGeneratedDate}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleReceiptAction(value, receipt, provider),
          itemBuilder: (context) => _buildReceiptActionMenu(receipt),
        ),
        onTap: () => _showReceiptDetails(receipt, provider),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'GENERATED':
        return Colors.blue;
      case 'SENT':
        return Colors.orange;
      case 'VIEWED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'GENERATED':
        return Icons.receipt;
      case 'SENT':
        return Icons.send;
      case 'VIEWED':
        return Icons.visibility;
      default:
        return Icons.help;
    }
  }

  List<PopupMenuEntry<String>> _buildReceiptActionMenu(ReceiptModel receipt) {
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

  void _handleReceiptAction(String action, ReceiptModel receipt, ReceiptProvider provider) {
    switch (action) {
      case 'view':
        _showReceiptDetails(receipt, provider);
        break;
      case 'edit':
        _showEditReceiptDialog(receipt, provider);
        break;
      case 'delete':
        _showDeleteReceiptDialog(receipt, provider);
        break;
    }
  }

  void _showCreateReceiptDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateReceiptDialog());
  }

  void _showReceiptDetails(ReceiptModel receipt, ReceiptProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Receipt Details - ${receipt.receiptNumber}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Receipt Number', receipt.receiptNumber),
              _buildDetailRow('Amount', receipt.formattedPaymentAmount),
              _buildDetailRow('Status', receipt.statusDisplay),
              _buildDetailRow('Generated At', receipt.formattedGeneratedDate),
              if (receipt.customerName != null) _buildDetailRow('Customer', receipt.customerName!),
              if (receipt.notes?.isNotEmpty == true) _buildDetailRow('Notes', receipt.notes!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showEditReceiptDialog(ReceiptModel receipt, ReceiptProvider provider) {
    showDialog(
      context: context,
      builder: (context) => EditReceiptDialog(receipt: receipt),
    );
  }

  void _showDeleteReceiptDialog(ReceiptModel receipt, ReceiptProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Receipt - ${receipt.receiptNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this receipt?'),
            const SizedBox(height: 8),
            Text('Amount: ${receipt.formattedPaymentAmount}'),
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
              final success = await provider.deleteReceipt(receipt.id);
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Receipt deleted successfully'), backgroundColor: Colors.green));
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
