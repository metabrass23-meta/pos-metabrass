import 'package:flutter/material.dart';
import 'package:frontend/src/theme/app_theme.dart';
import '../../widgets/sales/return_management_widget.dart';

class ReturnManagementScreen extends StatelessWidget {
  const ReturnManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: const Text('Return Management'),
        backgroundColor: AppTheme.primaryMaroon,
        foregroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      body: const ReturnManagementWidget(),
    );
  }
}
