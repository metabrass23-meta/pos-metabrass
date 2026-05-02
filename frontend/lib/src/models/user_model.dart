import 'role_model.dart';

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final bool isActive;
  final int? roleId;
  final String? roleName;
  final RoleModel? roleData;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.dateJoined,
    this.lastLogin,
    this.isActive = true,
    this.roleId,
    this.roleName,
    this.roleData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      isActive: json['is_active'] as bool? ?? true,
      roleId: json['role'] as int?,
      roleName: json['role_name'] as String?,
      roleData: json['role_data'] != null
          ? RoleModel.fromJson(json['role_data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'role': roleId,
      'role_name': roleName,
      'role_data': roleData?.toJson(),
    };
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    DateTime? dateJoined,
    DateTime? lastLogin,
    bool? isActive,
    int? roleId,
    String? roleName,
    RoleModel? roleData,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      roleData: roleData ?? this.roleData,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, roleName: $roleName)';
  }
}
