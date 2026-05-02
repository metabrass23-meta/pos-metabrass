import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role_model.dart';

class PermissionHelper {
  /// Check if the current user has permission for a specific module and action
  static bool hasPermission(
    BuildContext context,
    String moduleName,
    String action, // 'view', 'add', 'edit', 'delete'
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Admin has all permissions
    if (user?.roleName == 'Admin') return true;

    if (user == null || user.roleData == null) return false;

    // Find the module permission
    final permission = user.roleData!.permissions.firstWhere(
      (p) => p.moduleName.toUpperCase() == moduleName.toUpperCase(),
      orElse: () => ModulePermissionModel(moduleName: moduleName, canView: false),
    );

    switch (action.toLowerCase()) {
      case 'view':
        return permission.canView;
      case 'add':
        return permission.canAdd;
      case 'edit':
        return permission.canEdit;
      case 'delete':
        return permission.canDelete;
      default:
        return false;
    }
  }

  /// Helper methods for common modules
  static bool canView(BuildContext context, String module) => hasPermission(context, module, 'view');
  static bool canAdd(BuildContext context, String module) => hasPermission(context, module, 'add');
  static bool canEdit(BuildContext context, String module) => hasPermission(context, module, 'edit');
  static bool canDelete(BuildContext context, String module) => hasPermission(context, module, 'delete');

  /// Check if current user is Admin
  static bool isAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.roleName == 'Admin';
  }
}
