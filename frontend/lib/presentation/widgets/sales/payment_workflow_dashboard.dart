import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../src/providers/sales_provider.dart';
import '../../../src/theme/app_theme.dart';

class PaymentWorkflowDashboard extends StatefulWidget {
  final VoidCallback? onRefresh;

  const PaymentWorkflowDashboard({super.key, this.onRefresh});

  @override
  State<PaymentWorkflowDashboard> createState() => _PaymentWorkflowDashboardState();
}

class _PaymentWorkflowDashboardState extends State<PaymentWorkflowDashboard> {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<SalesProvider>(context, listen: false);
      // This would typically load aggregated workflow data
      // For now, we'll simulate some data
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _dashboardData = {
            'total_sales': 156,
            'pending_payments': 23,
            'partial_payments': 12,
            'completed_payments': 121,
            'total_revenue': 2450000.0,
            'collected_revenue': 1980000.0,
            'pending_revenue': 470000.0,
            'payment_completion_rate': 80.8,
            'average_payment_time': 3.2,
            'recent_workflow_activities': [
              {
                'type': 'payment',
                'description': 'Payment received for INV-2025-0001',
                'amount': 45000.0,
                'timestamp': DateTime.now().subtract(Duration(hours: 2)),
                'status': 'completed',
              },
              {
                'type': 'status_update',
                'description': 'Sale INV-2025-0002 marked as delivered',
                'timestamp': DateTime.now().subtract(Duration(hours: 4)),
                'status': 'completed',
              },
              {
                'type': 'payment',
                'description': 'Partial payment for INV-2025-0003',
                'amount': 25000.0,
                'timestamp': DateTime.now().subtract(Duration(hours: 6)),
                'status': 'partial',
              },
            ],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Workflow Dashboard',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
              ),
              IconButton(
                onPressed: _loadDashboardData,
                icon: Icon(Icons.refresh, color: AppTheme.primaryMaroon),
                tooltip: 'Refresh Dashboard',
              ),
            ],
          ),

          SizedBox(height: 20),

          if (_isLoading)
            Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMaroon)))
          else if (_dashboardData != null)
            Column(
              children: [
                // Key Metrics Row
                _buildKeyMetricsRow(),

                SizedBox(height: 24),

                // Payment Progress Chart
                _buildPaymentProgressChart(),

                SizedBox(height: 24),

                // Recent Activities
                _buildRecentActivities(),
              ],
            )
          else
            Center(
              child: Text('No data available', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Sales',
            value: _dashboardData!['total_sales'].toString(),
            icon: Icons.shopping_cart,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Pending Payments',
            value: _dashboardData!['pending_payments'].toString(),
            icon: Icons.pending,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Completed',
            value: _dashboardData!['completed_payments'].toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Completion Rate',
            value: '${_dashboardData!['payment_completion_rate'].toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: AppTheme.primaryMaroon,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: color),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProgressChart() {
    final totalRevenue = _dashboardData!['total_revenue'] as double;
    final collectedRevenue = _dashboardData!['collected_revenue'] as double;
    final pendingRevenue = _dashboardData!['pending_revenue'] as double;
    final completionRate = _dashboardData!['payment_completion_rate'] as double;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Progress Overview',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
          ),
          SizedBox(height: 16),

          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Completion', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  Text(
                    '${completionRate.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMaroon),
                minHeight: 10,
              ),
            ],
          ),

          SizedBox(height: 20),

          // Revenue Breakdown
          Row(
            children: [
              Expanded(
                child: _buildRevenueItem(
                  label: 'Collected',
                  amount: collectedRevenue,
                  color: Colors.green,
                  percentage: (collectedRevenue / totalRevenue) * 100,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildRevenueItem(
                  label: 'Pending',
                  amount: pendingRevenue,
                  color: Colors.orange,
                  percentage: (pendingRevenue / totalRevenue) * 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem({required String label, required double amount, required Color color, required double percentage}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
          SizedBox(height: 4),
          Text(
            'PKR ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: color),
          ),
          Text('${percentage.toStringAsFixed(1)}%', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = _dashboardData!['recent_workflow_activities'] as List;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Workflow Activities',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryMaroon),
          ),
          SizedBox(height: 16),

          ...activities.map((activity) => _buildActivityItem(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final description = activity['description'] as String;
    final timestamp = activity['timestamp'] as DateTime;
    final status = activity['status'] as String;
    final amount = activity['amount'] as double?;

    IconData icon;
    Color color;

    switch (type) {
      case 'payment':
        icon = Icons.payment;
        color = status == 'completed' ? Colors.green : Colors.orange;
        break;
      case 'status_update':
        icon = Icons.update;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                if (amount != null)
                  Text(
                    'PKR ${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.primaryMaroon, fontWeight: FontWeight.w600),
                  ),
                Text(_formatTimestamp(timestamp), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

