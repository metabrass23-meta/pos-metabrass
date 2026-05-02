import 'package:flutter/material.dart';
import '../../../src/models/role_model.dart';
import '../../../src/services/user_management_service.dart';
import '../../widgets/globals/sidebar.dart';
import '../../widgets/globals/drop_down.dart';
import '../../widgets/globals/text_field.dart';
import '../../../src/utils/permission_helper.dart';

class RolePermissionScreen extends StatefulWidget {
  const RolePermissionScreen({super.key});

  @override
  State<RolePermissionScreen> createState() => _RolePermissionScreenState();
}

class _RolePermissionScreenState extends State<RolePermissionScreen> {
  final UserManagementService _userService = UserManagementService();
  List<RoleModel> _roles = [];
  RoleModel? _selectedRole;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    final res = await _userService.getRoles();
    if (mounted) {
      setState(() {
        _roles = res.data ?? [];
        if (_roles.isNotEmpty) {
          _selectedRole = _roles.first;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _savePermissions() async {
    if (_selectedRole == null || _selectedRole!.id == null) return;
    
    setState(() => _isSaving = true);
    final permissions = _selectedRole!.permissions.map((e) => e.toJson()).toList();
    final res = await _userService.updateRolePermissions(_selectedRole!.id!, permissions);
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? (res.success ? 'Permissions saved' : 'Error saving'))),
      );
    }
  }

  void _showAddRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateRoleDialog(onSuccess: _loadRoles),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!PermissionHelper.isAdmin(context)) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied: Admin privileges required.',
            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF4F7FE),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Role & Permission Matrix',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2559),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Define and manage access levels for each system role',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddRoleDialog,
                      icon: const Icon(Icons.security, color: Colors.white, size: 22),
                      label: const Text(
                        'ADD NEW ROLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4318FF),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: const Color(0xFF4318FF).withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: PremiumDropdownField<RoleModel>(
                        label: 'Select Active Role',
                        value: _selectedRole,
                        items: _roles.map((r) => DropdownItem(value: r, label: r.name)).toList(),
                        onChanged: (val) => setState(() => _selectedRole = val),
                        hint: 'Choose Role',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Matrix Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4318FF)))
                    : _buildPermissionTable(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Bottom Save Action
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePermissions,
                icon: _isSaving 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded, color: Colors.white),
                label: Text(
                  _isSaving ? 'SAVING...' : 'SAVE ALL PERMISSIONS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4318FF),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTable() {
    if (_selectedRole == null) return _buildEmptySelection();
    
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          color: const Color(0xFFF4F7FE).withOpacity(0.5),
          child: Row(
            children: [
              _headerCell('MODULE NAME', flex: 4),
              _headerCell('VIEW', center: true),
              _headerCell('ADD', center: true),
              _headerCell('EDIT', center: true),
              _headerCell('DELETE', center: true),
            ],
          ),
        ),
        
        // Table Body
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _selectedRole!.permissions.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final perm = _selectedRole!.permissions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        perm.moduleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2559),
                        ),
                      ),
                    ),
                    Expanded(child: _buildCheckbox(perm.canView, (val) => _updatePerm(index, 'view', val))),
                    Expanded(child: _buildCheckbox(perm.canAdd, (val) => _updatePerm(index, 'add', val))),
                    Expanded(child: _buildCheckbox(perm.canEdit, (val) => _updatePerm(index, 'edit', val))),
                    Expanded(child: _buildCheckbox(perm.canDelete, (val) => _updatePerm(index, 'delete', val))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'No Role Selected',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a role from the dropdown to manage its permissions',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFFA3AED0),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool value, Function(bool?) onChanged) {
    return Center(
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4318FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _updatePerm(int index, String type, bool? val) {
    if (val == null) return;
    setState(() {
      final perms = List<ModulePermissionModel>.from(_selectedRole!.permissions);
      final p = perms[index];
      perms[index] = p.copyWith(
        canView: type == 'view' ? val : p.canView,
        canAdd: type == 'add' ? val : p.canAdd,
        canEdit: type == 'edit' ? val : p.canEdit,
        canDelete: type == 'delete' ? val : p.canDelete,
      );
      _selectedRole = _selectedRole!.copyWith(permissions: perms);
      
      // Update in roles list as well to keep everything synced
      final roleIndex = _roles.indexWhere((r) => r.id == _selectedRole!.id);
      if (roleIndex != -1) {
        _roles[roleIndex] = _selectedRole!;
      }
    });
  }
}

class CreateRoleDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  const CreateRoleDialog({super.key, required this.onSuccess});

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF4318FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security, color: Colors.white, size: 28),
                  SizedBox(width: 16),
                  Text('Create New Role', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumTextField(label: 'Role Name', controller: _nameController, hint: 'e.g. Accountant', prefixIcon: Icons.badge_outlined),
                  const SizedBox(height: 24),
                  PremiumTextField(label: 'Description', controller: _descController, hint: 'Define user responsibilities', maxLines: 3, prefixIcon: Icons.description_outlined),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          side: const BorderSide(color: Color(0xFF4318FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Color(0xFF4318FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_nameController.text.isEmpty) return;
                          setState(() => _isLoading = true);
                          final res = await UserManagementService().createRole({
                            'name': _nameController.text,
                            'description': _descController.text,
                          });
                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (res.success) {
                              widget.onSuccess();
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4318FF),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('CREATE ROLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
