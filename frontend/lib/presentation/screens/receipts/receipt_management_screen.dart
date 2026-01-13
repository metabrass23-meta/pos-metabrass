import 'package:flutter/material.dart';
import 'package:frontend/src/theme/app_theme.dart';
import '../../widgets/sales/receipt_management_widget.dart';

class ReceiptManagementScreen extends StatelessWidget {
  const ReceiptManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: const Text('Receipt Management'),
        backgroundColor: AppTheme.primaryMaroon,
        foregroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      body: const ReceiptManagementWidget(),
    );
  }
}
