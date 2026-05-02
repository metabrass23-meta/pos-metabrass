import 'package:flutter/material.dart';
import '../../../src/models/user_model.dart';
import '../../../src/models/role_model.dart';
import '../../../src/services/user_management_service.dart';
import '../../widgets/globals/text_field.dart';
import '../../widgets/globals/drop_down.dart';
import '../../widgets/globals/sidebar.dart';
import '../../widgets/globals/confirmation_dialog.dart';
import '../../../src/utils/permission_helper.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserManagementService _userService = UserManagementService();
  List<UserModel> _users = [];
  List<RoleModel> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final usersRes = await _userService.getUsers();
    final rolesRes = await _userService.getRoles();
    
    if (mounted) {
      setState(() {
        if (usersRes.success) _users = usersRes.data ?? [];
        if (rolesRes.success) _roles = rolesRes.data ?? [];
        _isLoading = false;
      });
    }
  }

  void _showUserDialog([UserModel? user]) {
    showDialog(
      context: context,
      builder: (context) => UserActionDialog(
        user: user,
        roles: _roles,
        onSuccess: _loadData,
      ),
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
                      'User Management',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2559),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your team members and their access levels',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUserDialog(),
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  label: const Text(
                    'ADD NEW USER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4318FF),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: const Color(0xFF4318FF).withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Table Section
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
                    : _users.isEmpty
                        ? _buildEmptyState()
                        : _buildUserTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FE),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_alt_rounded, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Users Found',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
          ),
          const SizedBox(height: 12),
          Text(
            'Start by adding a new team member to the system.',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _showUserDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4318FF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add First User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          color: const Color(0xFFF4F7FE).withOpacity(0.5),
          child: Row(
            children: [
              _headerCell('NAME', flex: 4),
              _headerCell('EMAIL', flex: 5),
              _headerCell('ROLE', flex: 3),
              _headerCell('STATUS', flex: 3),
              _headerCell('ACTIONS', flex: 2, center: true),
            ],
          ),
        ),
        
        // Table Body
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _users.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final user = _users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Row(
                  children: [
                    // Name
                    Expanded(
                      flex: 4,
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2559),
                        ),
                      ),
                    ),
                    
                    // Email
                    Expanded(
                      flex: 5,
                      child: Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Role
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.roleName).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.roleName ?? 'No Role',
                            style: TextStyle(
                              fontSize: 13,
                              color: _getRoleColor(user.roleName),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Status
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: user.isActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 14,
                              color: user.isActive ? Colors.green[700] : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Actions
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionButton(
                            icon: Icons.edit_note_rounded,
                            color: const Color(0xFF4318FF),
                            onPressed: () => _showUserDialog(user),
                          ),
                          const SizedBox(width: 8),
                          _actionButton(
                            icon: Icons.delete_sweep_rounded,
                            color: Colors.red[400]!,
                            onPressed: () => _confirmDelete(user),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin': return const Color(0xFF4318FF);
      case 'manager': return Colors.orange[700]!;
      default: return Colors.blueGrey;
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Remove Team Member',
        message: 'Are you sure you want to remove ${user.fullName} from the system?',
        actionText: 'REMOVE',
        actionColor: Colors.red,
      ),
    );
    if (confirm == true) {
      await _userService.deleteUser(user.id);
      _loadData();
    }
  }
}

class UserActionDialog extends StatefulWidget {
  final UserModel? user;
  final List<RoleModel> roles;
  final VoidCallback onSuccess;

  const UserActionDialog({super.key, this.user, required this.roles, required this.onSuccess});

  @override
  State<UserActionDialog> createState() => _UserActionDialogState();
}

class _UserActionDialogState extends State<UserActionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  int? _selectedRoleId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName);
    _emailController = TextEditingController(text: widget.user?.email);
    _passwordController = TextEditingController();
    _selectedRoleId = widget.user?.roleId;
    _isActive = widget.user?.isActive ?? true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final data = {
      'full_name': _nameController.text,
      'email': _emailController.text,
      'role': _selectedRoleId,
      'is_active': _isActive,
    };
    if (_passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
    }

    final res = widget.user == null
        ? await UserManagementService().createUser(data)
        : await UserManagementService().updateUser(widget.user!.id, data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (res.success) {
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Error saving user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user == null ? 'Create New User' : 'Edit User',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              PremiumTextField(
                label: 'Full Name',
                controller: _nameController,
                hint: 'Enter full name (e.g. Ali Ahmed)',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              PremiumTextField(
                label: 'Email Address',
                controller: _emailController,
                hint: 'Enter email (e.g. user@example.com)',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              PremiumTextField(
                label: 'Password',
                controller: _passwordController,
                hint: widget.user == null ? 'Enter secure password' : 'Leave empty to keep current',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              PremiumDropdownField<int>(
                label: 'Select User Role',
                value: _selectedRoleId,
                items: widget.roles.map((r) => DropdownItem(value: r.id!, label: r.name)).toList(),
                onChanged: (val) => setState(() => _selectedRoleId = val),
                hint: 'Select Role',
                prefixIcon: Icons.security,
              ),
              if (widget.user != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC6F6D5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isActive ? 'Account Status: Active' : 'Account Status: Blocked',
                          style: TextStyle(
                            color: _isActive ? const Color(0xFF22543D) : Colors.red[900],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeColor: const Color(0xFF48BB78),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4318FF),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            widget.user == null ? 'ADD NEW USER' : 'SAVE CHANGES',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
