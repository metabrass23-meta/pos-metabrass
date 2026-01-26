import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/providers/return_provider.dart';
import '../../../src/models/sales/return_model.dart';
import '../../widgets/sales/create_return_dialog.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.returnManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.returns, icon: const Icon(Icons.assignment_return)),
            Tab(text: l10n.refunds, icon: const Icon(Icons.payment)),
            Tab(text: l10n.statistics, icon: const Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReturnProvider>().refresh(),
            tooltip: l10n.refresh,
          )
        ],
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            _buildReturnsTab(),
            _buildRefundsTab(),
            _buildStatisticsTab()
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReturnDialog(context),
        tooltip: l10n.createReturn,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReturnsTab() {
    final l10n = AppLocalizations.of(context)!;

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
                Text(l10n.error(provider.error!)),
                ElevatedButton(onPressed: () => provider.refresh(), child: Text(l10n.retry)),
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
                      hintText: l10n.searchByReturnCustomerInvoice,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => provider.setFilters(search: value),
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
                      DropdownMenuItem(value: 'PENDING', child: Text(l10n.pending)),
                      DropdownMenuItem(value: 'APPROVED', child: Text(l10n.approved)),
                      DropdownMenuItem(value: 'PROCESSED', child: Text(l10n.processed)),
                      DropdownMenuItem(value: 'REJECTED', child: Text(l10n.rejected)),
                      DropdownMenuItem(value: 'CANCELLED', child: Text(l10n.cancelled)),
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

                // Reason Dropdown
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedReason.isEmpty ? null : _selectedReason,
                    decoration: InputDecoration(
                      labelText: l10n.reason,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    items: [
                      DropdownMenuItem(value: '', child: Text(l10n.allReasons)),
                      DropdownMenuItem(value: 'DEFECTIVE', child: Text(l10n.defective)),
                      DropdownMenuItem(value: 'WRONG_SIZE', child: Text(l10n.wrongSize)),
                      DropdownMenuItem(value: 'WRONG_COLOR', child: Text(l10n.wrongColor)),
                      DropdownMenuItem(value: 'QUALITY_ISSUE', child: Text(l10n.qualityIssue)),
                      DropdownMenuItem(value: 'CUSTOMER_CHANGE_MIND', child: Text(l10n.customerChangedMind)),
                      DropdownMenuItem(value: 'DAMAGED_IN_TRANSIT', child: Text(l10n.damagedInTransit)),
                      DropdownMenuItem(value: 'OTHER', child: Text(l10n.other)),
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

            // Clear Filters Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = '';
                      _selectedReason = '';
                    });
                    provider.clearFilters();
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

  Widget _buildReturnsList(ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final returns = provider.filteredReturns;

    if (returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_return, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noReturnsFound, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.createNewReturnUsingButton, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final returnItem = returns[index];
        return _buildReturnCard(returnItem, provider);
      },
    );
  }

  Widget _buildReturnCard(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(returnItem.status),
          child: Icon(_getStatusIcon(returnItem.status), color: Colors.white),
        ),
        title: Text(returnItem.returnNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${l10n.customer}: ${returnItem.customerName}'),
            Text('${l10n.invoice}: ${returnItem.saleInvoiceNumber}'),
            Text(
              '${l10n.reason}: ${returnItem.reason.replaceAll('_', ' ')}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${l10n.amount}: \$${returnItem.totalReturnAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(returnItem.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getStatusColor(returnItem.status)),
                  ),
                  child: Text(
                    returnItem.status,
                    style: TextStyle(color: _getStatusColor(returnItem.status), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
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
    final l10n = AppLocalizations.of(context)!;
    final actions = <PopupMenuEntry<String>>[];

    if (returnItem.canBeApproved) {
      actions.add(
        PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.approve),
            ],
          ),
        ),
      );
    }

    if (returnItem.canBeProcessed) {
      actions.add(
        PopupMenuItem(
          value: 'process',
          child: Row(
            children: [
              const Icon(Icons.play_circle, color: Colors.blue),
              const SizedBox(width: 8),
              Text(l10n.process),
            ],
          ),
        ),
      );
    }

    if (returnItem.canBeCancelled) {
      actions.add(
        PopupMenuItem(
          value: 'cancel',
          child: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.cancel),
            ],
          ),
        ),
      );
    }

    actions.addAll([
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            const Icon(Icons.edit, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.edit),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ReturnProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final refunds = provider.refunds;

        if (refunds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.noRefundsFound, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.refundsWillAppearHere, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRefundStatusColor(refund.status),
          child: Icon(_getRefundStatusIcon(refund.status), color: Colors.white),
        ),
        title: Text(refund.refundNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${l10n.amount}: \$${refund.amount.toStringAsFixed(2)}'),
            Text('${l10n.method}: ${refund.method.replaceAll('_', ' ')}'),
            Text('${l10n.status}: ${refund.status}'),
            if (refund.referenceNumber != null) Text('${l10n.reference}: ${refund.referenceNumber}'),
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
      case 'PENDING': return Colors.orange;
      case 'PROCESSED': return Colors.green;
      case 'FAILED': return Colors.red;
      case 'CANCELLED': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _getRefundStatusIcon(String status) {
    switch (status) {
      case 'PENDING': return Icons.schedule;
      case 'PROCESSED': return Icons.check_circle;
      case 'FAILED': return Icons.error;
      case 'CANCELLED': return Icons.cancel;
      default: return Icons.help;
    }
  }

  List<PopupMenuEntry<String>> _buildRefundActionMenu(RefundModel refund) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <PopupMenuEntry<String>>[];

    if (refund.status == 'PENDING') {
      actions.add(
        PopupMenuItem(
          value: 'process',
          child: Row(
            children: [
              const Icon(Icons.play_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.process),
            ],
          ),
        ),
      );
    }

    actions.addAll([
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            const Icon(Icons.edit, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.edit),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;

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
              Text(l10n.returnStatistics, style: Theme.of(context).textTheme.headlineSmall),
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
    final l10n = AppLocalizations.of(context)!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 750 ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(l10n.totalReturns, statistics['total_returns']?.toString() ?? '0', Icons.assignment_return, Colors.blue),
        _buildStatCard(l10n.pendingReturns, statistics['pending_returns']?.toString() ?? '0', Icons.schedule, Colors.orange),
        _buildStatCard(l10n.approvedReturns, statistics['approved_returns']?.toString() ?? '0', Icons.check_circle, Colors.green),
        _buildStatCard(l10n.totalRefunds, statistics['total_refunds']?.toString() ?? '0', Icons.payment, Colors.purple),
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
            Icon(icon, size: 36, color: color),
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statusBreakdown, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildStatusRow(l10n.pending, provider.pendingReturns.length, Colors.orange),
            _buildStatusRow(l10n.approved, provider.approvedReturns.length, Colors.blue),
            _buildStatusRow(l10n.processed, provider.processedReturns.length, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(status, style: const TextStyle(fontSize: 16))),
          Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _showCreateReturnDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateReturnDialog());
  }

  void _showReturnDetails(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.returnDetails(returnItem.returnNumber)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(l10n.returnNumber, returnItem.returnNumber),
                _buildDetailRow(l10n.saleInvoice, returnItem.saleInvoiceNumber),
                _buildDetailRow(l10n.customer, returnItem.customerName),
                const Divider(),
                _buildDetailRow(l10n.returnDate, returnItem.formattedReturnDate),
                _buildDetailRow(l10n.status, returnItem.status),
                _buildDetailRow(l10n.reason, returnItem.reason),
                if (returnItem.reasonDetails?.isNotEmpty == true)
                  _buildDetailRow(l10n.reasonDetails, returnItem.reasonDetails!),
                const Divider(),
                _buildDetailRow(l10n.itemsCount as String, '${returnItem.returnItemsCount}'),
                _buildDetailRow(l10n.totalAmount, 'PKR ${returnItem.totalReturnAmount.toStringAsFixed(2)}'),
                if (returnItem.approvedAt != null)
                  _buildDetailRow(l10n.approvedAt, '${returnItem.approvedAt!.day}/${returnItem.approvedAt!.month}/${returnItem.approvedAt!.year}'),
                if (returnItem.processedAt != null)
                  _buildDetailRow(l10n.processedAt, '${returnItem.processedAt!.day}/${returnItem.processedAt!.month}/${returnItem.processedAt!.year}'),
                if (returnItem.notes?.isNotEmpty == true)
                  _buildDetailRow(l10n.notes, returnItem.notes!),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close))],
      ),
    );
  }

  void _showRefundDetails(RefundModel refund, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.refundDetails(refund.refundNumber)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(l10n.refundNumber, refund.refundNumber),
              _buildDetailRow(l10n.returnId, refund.returnRequestId),
              const Divider(),
              _buildDetailRow(l10n.amount, 'PKR ${refund.amount.toStringAsFixed(2)}'),
              _buildDetailRow(l10n.method, refund.method),
              _buildDetailRow(l10n.status, refund.status),
              _buildDetailRow(l10n.createdAt, '${refund.createdAt.day}/${refund.createdAt.month}/${refund.createdAt.year}'),
              if (refund.processedAt != null)
                _buildDetailRow(l10n.processedAt, '${refund.processedAt!.day}/${refund.processedAt!.month}/${refund.processedAt!.year}'),
              if (refund.referenceNumber?.isNotEmpty == true) _buildDetailRow(l10n.reference, refund.referenceNumber!),
              if (refund.notes?.isNotEmpty == true) _buildDetailRow(l10n.notes, refund.notes!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close))],
      ),
    );
  }

  void _showApproveReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.approveReturn(returnItem.returnNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureApproveReturn),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.approvalReasonOptional,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.approveReturn(
                id: returnItem.id,
                reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.returnApprovedSuccessfully), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.approve),
          ),
        ],
      ),
    );
  }

  void _showProcessReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final refundAmountController = TextEditingController(text: returnItem.totalReturnAmount.toString());
    final refundMethodController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.processReturn(returnItem.returnNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.processReturnAndInitiateRefund),
            const SizedBox(height: 16),
            TextField(
              controller: refundAmountController,
              decoration: InputDecoration(labelText: l10n.refundAmount, border: const OutlineInputBorder(), prefixText: 'PKR '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: refundMethodController,
              decoration: InputDecoration(
                labelText: l10n.refundMethod,
                border: const OutlineInputBorder(),
                hintText: l10n.refundMethodHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final refundAmount = double.tryParse(refundAmountController.text.trim());
              final refundMethod = refundMethodController.text.trim();

              if (refundAmount != null && refundMethod.isNotEmpty) {
                final success = await provider.processReturn(id: returnItem.id, refundAmount: refundAmount, refundMethod: refundMethod);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.returnProcessedSuccessfully), backgroundColor: Colors.green),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.provideValidRefundAmountAndMethod), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(l10n.process),
          ),
        ],
      ),
    );
  }

  void _showCancelReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelReturn(returnItem.returnNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureCancelReturn),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.cancellationReasonRequired,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.no)),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.provideCancellationReason), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.of(context).pop();
              final success = await provider.rejectReturn(id: returnItem.id, reason: reasonController.text.trim());
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.returnCancelledSuccessfully), backgroundColor: Colors.orange),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.cancelReturn(returnItem.returnNumber).split(' - ')[0]),
          ),
        ],
      ),
    );
  }

  void _showEditReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController(text: returnItem.reason);
    final reasonDetailsController = TextEditingController(text: returnItem.reasonDetails);
    final notesController = TextEditingController(text: returnItem.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editReturn(returnItem.returnNumber)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: l10n.returnReason, border: const OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonDetailsController,
                decoration: InputDecoration(labelText: '${l10n.reasonDetails} (${l10n.notesOptional})', border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: l10n.notesOptional, border: const OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.returnUpdatedSuccessfully), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  void _showDeleteReturnDialog(ReturnModel returnItem, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReturn(returnItem.returnNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureDeleteReturn),
            const SizedBox(height: 8),
            Text(l10n.thisActionCannotBeUndone, style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteReturn(returnItem.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.returnDeletedSuccessfully), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProcessRefundDialog(RefundModel refund, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final referenceController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.processRefund(refund.refundNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.amount}: PKR ${refund.amount.toStringAsFixed(2)}'),
            Text('${l10n.method}: ${refund.method}'),
            const SizedBox(height: 16),
            TextField(
              controller: referenceController,
              decoration: InputDecoration(labelText: l10n.referenceNumberOptional, border: const OutlineInputBorder()),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(labelText: l10n.processingNotesOptional, border: const OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.processRefund(
                id: refund.id,
                referenceNumber: referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.refundProcessedSuccessfully), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.processRefundAction),
          ),
        ],
      ),
    );
  }

  void _showEditRefundDialog(RefundModel refund, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final methodController = TextEditingController(text: refund.method);
    final notesController = TextEditingController(text: refund.notes);
    final referenceController = TextEditingController(text: refund.referenceNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editRefund(refund.refundNumber)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.amountCannotBeChanged(refund.amount.toStringAsFixed(2))),
              const SizedBox(height: 16),
              TextField(
                controller: methodController,
                decoration: InputDecoration(labelText: l10n.refundMethod, border: const OutlineInputBorder()),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: referenceController,
                decoration: InputDecoration(labelText: l10n.referenceNumberOptional, border: const OutlineInputBorder()),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: l10n.notesOptional, border: const OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.refundUpdatedSuccessfully), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  void _showDeleteRefundDialog(RefundModel refund, ReturnProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRefund(refund.refundNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureDeleteRefund),
            const SizedBox(height: 8),
            Text('${l10n.amount}: PKR ${refund.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(l10n.thisActionCannotBeUndone, style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.deleteRefund(refund.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.refundDeletedSuccessfully), backgroundColor: Colors.green),
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