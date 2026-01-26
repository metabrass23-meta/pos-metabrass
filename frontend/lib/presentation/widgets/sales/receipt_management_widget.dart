import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // --- Filters ---
          _buildFilters(),

          // --- List ---
          Expanded(child: _buildReceiptsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReceiptDialog(context),
        tooltip: l10n.createReceipt,
        child: const Icon(Icons.add),
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
                      hintText: l10n.searchByReceiptCustomerPayment,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => context.read<ReceiptProvider>().setFilters(search: value),
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
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    items: [
                      DropdownMenuItem(value: '', child: Text(l10n.allStatuses)),
                      DropdownMenuItem(value: 'GENERATED', child: Text(l10n.generated)),
                      DropdownMenuItem(value: 'SENT', child: Text(l10n.sent)),
                      DropdownMenuItem(value: 'VIEWED', child: Text(l10n.viewed)),
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

                // Clear Filters
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = '';
                    });
                    context.read<ReceiptProvider>().clearFilters();
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

  Widget _buildReceiptsList() {
    final l10n = AppLocalizations.of(context)!;

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
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(l10n.error(provider.error!)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        final receipts = provider.filteredReceipts;

        if (receipts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.noReceiptsFound, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.createNewReceiptUsingButton, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return _buildReceiptCard(receipt, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildReceiptCard(ReceiptModel receipt, ReceiptProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(receipt.status),
          child: Icon(_getStatusIcon(receipt.status), color: Colors.white),
        ),
        title: Text(
            receipt.receiptNumber,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${l10n.customer}: ${receipt.customerName}'),
            Text(
              '${l10n.amount}: ${receipt.formattedPaymentAmount}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Text('${l10n.status}: ${receipt.statusDisplay}'),
                const SizedBox(width: 8),
                Text('|  ${l10n.generated}: ${receipt.formattedGeneratedDate}'),
              ],
            ),
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
      case 'GENERATED': return Colors.blue;
      case 'SENT': return Colors.orange;
      case 'VIEWED': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'GENERATED': return Icons.receipt;
      case 'SENT': return Icons.send;
      case 'VIEWED': return Icons.visibility;
      default: return Icons.help_outline;
    }
  }

  List<PopupMenuEntry<String>> _buildReceiptActionMenu(ReceiptModel receipt) {
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
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: Row(children: [const Icon(Icons.delete, color: Colors.red), const SizedBox(width: 8), Text(l10n.delete)]),
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.receiptDetails(receipt.receiptNumber)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(l10n.receiptNumber, receipt.receiptNumber),
                _buildDetailRow(l10n.amount, receipt.formattedPaymentAmount),
                _buildDetailRow(l10n.status, receipt.statusDisplay),
                _buildDetailRow(l10n.generatedAt, receipt.formattedGeneratedDate),
                const Divider(),
                if (receipt.customerName.isNotEmpty)
                  _buildDetailRow(l10n.customer, receipt.customerName),
                if (receipt.notes?.isNotEmpty == true)
                  _buildDetailRow(l10n.notes, receipt.notes!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          )
        ],
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReceipt(receipt.receiptNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureDeleteReceipt),
            const SizedBox(height: 8),
            Text(
              '${l10n.amount}: ${receipt.formattedPaymentAmount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.thisActionCannotBeUndone, style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteReceipt(receipt.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.receiptDeletedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
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