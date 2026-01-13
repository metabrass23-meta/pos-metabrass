import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/providers/return_provider.dart';
import '../../../src/models/sales/return_model.dart';
import 'create_return_dialog.dart';

class ReturnManagementWidget extends StatefulWidget {
  const ReturnManagementWidget({Key? key}) : super(key: key);

  @override
  State<ReturnManagementWidget> createState() => _ReturnManagementWidgetState();
}

class _ReturnManagementWidgetState extends State<ReturnManagementWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';
  String _selectedReason = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Returns', icon: Icon(Icons.assignment_return)),
            Tab(text: 'Refunds', icon: Icon(Icons.payment)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => context.read<ReturnProvider>().refresh())],
      ),
      body: TabBarView(controller: _tabController, children: [_buildReturnsTab(), _buildRefundsTab(), _buildStatisticsTab()]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReturnDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Return',
      ),
    );
  }

  Widget _buildReturnsTab() {
    return Consumer<ReturnProvider>(
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

        return Column(
          children: [
            _buildFilters(provider),
            Expanded(child: _buildReturnsList(provider)),
          ],
        );
      },
    );
  }

  Widget _buildFilters(ReturnProvider provider) {
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
                      hintText: 'Search by return number, customer, or invoice',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => provider.setFilters(search: value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus.isEmpty ? null : _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Statuses')),
                      const DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                      const DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                      const DropdownMenuItem(value: 'PROCESSED', child: Text('Processed')),
                      const DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                      const DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? '';
                      });
                      provider.setFilters(status: value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedReason.isEmpty ? null : _selectedReason,
                    decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Reasons')),
                      const DropdownMenuItem(value: 'DEFECTIVE', child: Text('Defective')),
                      const DropdownMenuItem(value: 'WRONG_SIZE', child: Text('Wrong Size')),
                      const DropdownMenuItem(value: 'WRONG_COLOR', child: Text('Wrong Color')),
                      const DropdownMenuItem(value: 'QUALITY_ISSUE', child: Text('Quality Issue')),
                      const DropdownMenuItem(value: 'CUSTOMER_CHANGE_MIND', child: Text('Customer Changed Mind')),
                      const DropdownMenuItem(value: 'DAMAGED_IN_TRANSIT', child: Text('Damaged in Transit')),
                      const DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value ?? '';
                      });
                      provider.setFilters(reason: value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = '';
                      _selectedReason = '';
                    });
                    provider.clearFilters();
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

  Widget _buildReturnsList(ReturnProvider provider) {
    final returns = provider.filteredReturns;

    if (returns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_return, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No returns found'),
            Text('Create a new return using the + button'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final returnItem = returns[index];
        return _buildReturnCard(returnItem, provider);
      },
    );
  }

  Widget _buildReturnCard(ReturnModel returnItem, ReturnProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(returnItem.status),
          child: Icon(_getStatusIcon(returnItem.status), color: Colors.white),
        ),
        title: Text(returnItem.returnNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${returnItem.customerName}'),
            Text('Invoice: ${returnItem.saleInvoiceNumber}'),
            Text('Reason: ${returnItem.reason.replaceAll('_', ' ')}'),
            Text('Amount: \$${returnItem.totalReturnAmount.toStringAsFixed(2)}'),
            Text('Status: ${returnItem.status}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleReturnAction(value, returnItem, provider),
          itemBuilder: (context) => _buildReturnActionMenu(returnItem),
        ),
        onTap: () => _showReturnDetails(returnItem, provider),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'PROCESSED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'APPROVED':
        return Icons.check_circle;
      case 'PROCESSED':
        return Icons.done_all;
      case 'REJECTED':
        return Icons.cancel;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  List<PopupMenuEntry<String>> _buildReturnActionMenu(ReturnModel returnItem) {
    final actions = <PopupMenuEntry<String>>[];

    if (returnItem.canBeApproved) {
      actions.add(
        const PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Approve'),
            ],
          ),
        ),
      );
    }

    if (returnItem.canBeProcessed) {
      actions.add(
        const PopupMenuItem(
          value: 'process',
          child: Row(
            children: [
              Icon(Icons.play_circle, color: Colors.blue),
              SizedBox(width: 8),
              Text('Process'),
            ],
          ),
        ),
      );
    }

    if (returnItem.canBeCancelled) {
      actions.add(
        const PopupMenuItem(
          value: 'cancel',
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 8),
              Text('Cancel'),
            ],
          ),
        ),
      );
    }

    actions.addAll([
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
    ]);

    return actions;
  }

  void _handleReturnAction(String action, ReturnModel returnItem, ReturnProvider provider) {
    switch (action) {
      case 'approve':
        _showApproveReturnDialog(returnItem, provider);
        break;
      case 'process':
        _showProcessReturnDialog(returnItem, provider);
        break;
      case 'cancel':
        _showCancelReturnDialog(returnItem, provider);
        break;
      case 'edit':
        _showEditReturnDialog(returnItem, provider);
        break;
      case 'delete':
        _showDeleteReturnDialog(returnItem, provider);
        break;
    }
  }

  Widget _buildRefundsTab() {
    return Consumer<ReturnProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final refunds = provider.refunds;

        if (refunds.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No refunds found'),
                Text('Refunds will appear here when returns are processed'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: refunds.length,
          itemBuilder: (context, index) {
            final refund = refunds[index];
            return _buildRefundCard(refund, provider);
          },
        );
      },
    );
  }

  Widget _buildRefundCard(RefundModel refund, ReturnProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRefundStatusColor(refund.status),
          child: Icon(_getRefundStatusIcon(refund.status), color: Colors.white),
        ),
        title: Text(refund.refundNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: \$${refund.amount.toStringAsFixed(2)}'),
            Text('Method: ${refund.method.replaceAll('_', ' ')}'),
            Text('Status: ${refund.status}'),
            if (refund.referenceNumber != null) Text('Reference: ${refund.referenceNumber}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleRefundAction(value, refund, provider),
          itemBuilder: (context) => _buildRefundActionMenu(refund),
        ),
        onTap: () => _showRefundDetails(refund, provider),
      ),
    );
  }

  Color _getRefundStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getRefundStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'PROCESSED':
        return Icons.check_circle;
      case 'FAILED':
        return Icons.error;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  List<PopupMenuEntry<String>> _buildRefundActionMenu(RefundModel refund) {
    final actions = <PopupMenuEntry<String>>[];

    if (refund.status == 'PENDING') {
      actions.add(
        const PopupMenuItem(
          value: 'process',
          child: Row(
            children: [
              Icon(Icons.play_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Process'),
            ],
          ),
        ),
      );
    }

    actions.addAll([
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
    ]);

    return actions;
  }

  void _handleRefundAction(String action, RefundModel refund, ReturnProvider provider) {
    switch (action) {
      case 'process':
        _showProcessRefundDialog(refund, provider);
        break;
      case 'edit':
        _showEditRefundDialog(refund, provider);
        break;
      case 'delete':
        _showDeleteRefundDialog(refund, provider);
        break;
    }
  }

  Widget _buildStatisticsTab() {
    return Consumer<ReturnProvider>(
      builder: (context, provider, child) {
        final statistics = provider.statistics;

        if (statistics == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Return Statistics', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              _buildStatisticsGrid(statistics),
              const SizedBox(height: 24),
              _buildStatusBreakdown(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> statistics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 750 ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Returns', statistics['total_returns']?.toString() ?? '0', Icons.assignment_return, Colors.blue),
        _buildStatCard('Pending Returns', statistics['pending_returns']?.toString() ?? '0', Icons.schedule, Colors.orange),
        _buildStatCard('Approved Returns', statistics['approved_returns']?.toString() ?? '0', Icons.check_circle, Colors.green),
        _buildStatCard('Total Refunds', statistics['total_refunds']?.toString() ?? '0', Icons.payment, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(ReturnProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildStatusRow('Pending', provider.pendingReturns.length, Colors.orange),
            _buildStatusRow('Approved', provider.approvedReturns.length, Colors.blue),
            _buildStatusRow('Processed', provider.processedReturns.length, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(status)),
          Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Dialog methods (to be implemented)
  void _showCreateReturnDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateReturnDialog());
  }

  void _showReturnDetails(ReturnModel returnItem, ReturnProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Return Details - ${returnItem.returnNumber}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Sale Invoice', returnItem.saleInvoiceNumber),
              _buildDetailRow('Customer', returnItem.customerName),
              _buildDetailRow('Return Date', returnItem.formattedReturnDate),
              _buildDetailRow('Status', returnItem.status),
              _buildDetailRow('Reason', returnItem.reason),
              if (returnItem.reasonDetails?.isNotEmpty == true) _buildDetailRow('Reason Details', returnItem.reasonDetails!),
              _buildDetailRow('Items Count', '${returnItem.returnItemsCount}'),
              _buildDetailRow('Total Amount', 'PKR ${returnItem.totalReturnAmount.toStringAsFixed(2)}'),
              if (returnItem.approvedAt != null)
                _buildDetailRow('Approved At', '${returnItem.approvedAt!.day}/${returnItem.approvedAt!.month}/${returnItem.approvedAt!.year}'),
              if (returnItem.processedAt != null)
                _buildDetailRow('Processed At', '${returnItem.processedAt!.day}/${returnItem.processedAt!.month}/${returnItem.processedAt!.year}'),
              if (returnItem.notes?.isNotEmpty == true) _buildDetailRow('Notes', returnItem.notes!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showRefundDetails(RefundModel refund, ReturnProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Refund Details - ${refund.refundNumber}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Refund Number', refund.refundNumber),
              _buildDetailRow('Return ID', refund.returnRequestId),
              _buildDetailRow('Amount', 'PKR ${refund.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Method', refund.method),
              _buildDetailRow('Status', refund.status),
              _buildDetailRow('Created At', '${refund.createdAt.day}/${refund.createdAt.month}/${refund.createdAt.year}'),
              if (refund.processedAt != null)
                _buildDetailRow('Processed At', '${refund.processedAt!.day}/${refund.processedAt!.month}/${refund.processedAt!.year}'),
              if (refund.referenceNumber?.isNotEmpty == true) _buildDetailRow('Reference', refund.referenceNumber!),
              if (refund.notes?.isNotEmpty == true) _buildDetailRow('Notes', refund.notes!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showApproveReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Return - ${returnItem.returnNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to approve this return?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Approval Reason (Optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.approveReturn(
                id: returnItem.id,
                reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Return approved successfully'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showProcessReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final refundAmountController = TextEditingController(text: returnItem.totalReturnAmount.toString());
    final refundMethodController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Return - ${returnItem.returnNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Process this return and initiate refund?'),
            const SizedBox(height: 16),
            TextField(
              controller: refundAmountController,
              decoration: const InputDecoration(labelText: 'Refund Amount', border: OutlineInputBorder(), prefixText: 'PKR '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: refundMethodController,
              decoration: const InputDecoration(
                labelText: 'Refund Method',
                border: OutlineInputBorder(),
                hintText: 'e.g., Cash, Bank Transfer, etc.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final refundAmount = double.tryParse(refundAmountController.text.trim());
              final refundMethod = refundMethodController.text.trim();

              if (refundAmount != null && refundMethod.isNotEmpty) {
                final success = await provider.processReturn(id: returnItem.id, refundAmount: refundAmount, refundMethod: refundMethod);
                if (success && mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Return processed successfully'), backgroundColor: Colors.green));
                }
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Please provide valid refund amount and method'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _showCancelReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Return - ${returnItem.returnNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this return?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Cancellation Reason (Required)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('No')),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Please provide a cancellation reason'), backgroundColor: Colors.red));
                return;
              }
              Navigator.of(context).pop();
              final success = await provider.rejectReturn(id: returnItem.id, reason: reasonController.text.trim());
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Return cancelled successfully'), backgroundColor: Colors.orange));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cancel Return'),
          ),
        ],
      ),
    );
  }

  void _showEditReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final reasonController = TextEditingController(text: returnItem.reason);
    final reasonDetailsController = TextEditingController(text: returnItem.reasonDetails);
    final notesController = TextEditingController(text: returnItem.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Return - ${returnItem.returnNumber}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Return Reason', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonDetailsController,
                decoration: const InputDecoration(labelText: 'Reason Details (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.updateReturn(
                id: returnItem.id,
                reason: reasonController.text.trim(),
                reasonDetails: reasonDetailsController.text.trim().isEmpty ? null : reasonDetailsController.text.trim(),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Return updated successfully'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Return - ${returnItem.returnNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this return?'),
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
              final success = await provider.deleteReturn(returnItem.id);
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Return deleted successfully'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProcessRefundDialog(RefundModel refund, ReturnProvider provider) {
    final referenceController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Refund - ${refund.refundNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: PKR ${refund.amount.toStringAsFixed(2)}'),
            Text('Method: ${refund.method}'),
            const SizedBox(height: 16),
            TextField(
              controller: referenceController,
              decoration: const InputDecoration(labelText: 'Reference Number (Optional)', border: OutlineInputBorder()),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Processing Notes (Optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.processRefund(
                id: refund.id,
                referenceNumber: referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Refund processed successfully'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  void _showEditRefundDialog(RefundModel refund, ReturnProvider provider) {
    final methodController = TextEditingController(text: refund.method);
    final notesController = TextEditingController(text: refund.notes);
    final referenceController = TextEditingController(text: refund.referenceNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Refund - ${refund.refundNumber}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: PKR ${refund.amount.toStringAsFixed(2)} (Cannot be changed)'),
              const SizedBox(height: 16),
              TextField(
                controller: methodController,
                decoration: const InputDecoration(labelText: 'Refund Method', border: OutlineInputBorder()),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(labelText: 'Reference Number (Optional)', border: OutlineInputBorder()),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.updateRefund(
                id: refund.id,
                method: methodController.text.trim(),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                referenceNumber: referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Refund updated successfully'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRefundDialog(RefundModel refund, ReturnProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Refund - ${refund.refundNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this refund?'),
            const SizedBox(height: 8),
            Text('Amount: PKR ${refund.amount.toStringAsFixed(2)}'),
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
              final success = await provider.deleteRefund(refund.id);
              if (success && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Refund deleted successfully'), backgroundColor: Colors.green));
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
