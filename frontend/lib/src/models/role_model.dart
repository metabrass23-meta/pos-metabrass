class ModulePermissionModel {
  final int? id;
  final String moduleName;
  final bool canView;
  final bool canAdd;
  final bool canEdit;
  final bool canDelete;

  ModulePermissionModel({
    this.id,
    required this.moduleName,
    this.canView = false,
    this.canAdd = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  factory ModulePermissionModel.fromJson(Map<String, dynamic> json) {
    return ModulePermissionModel(
      id: json['id'] as int?,
      moduleName: json['module_name'] as String,
      canView: json['can_view'] as bool? ?? false,
      canAdd: json['can_add'] as bool? ?? false,
      canEdit: json['can_edit'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'module_name': moduleName,
      'can_view': canView,
      'can_add': canAdd,
      'can_edit': canEdit,
      'can_delete': canDelete,
    };
  }

  ModulePermissionModel copyWith({
    int? id,
    String? moduleName,
    bool? canView,
    bool? canAdd,
    bool? canEdit,
    bool? canDelete,
  }) {
    return ModulePermissionModel(
      id: id ?? this.id,
      moduleName: moduleName ?? this.moduleName,
      canView: canView ?? this.canView,
      canAdd: canAdd ?? this.canAdd,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModulePermissionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          moduleName == other.moduleName &&
          canView == other.canView &&
          canAdd == other.canAdd &&
          canEdit == other.canEdit &&
          canDelete == other.canDelete;

  @override
  int get hashCode =>
      id.hashCode ^
      moduleName.hashCode ^
      canView.hashCode ^
      canAdd.hashCode ^
      canEdit.hashCode ^
      canDelete.hashCode;
}

class RoleModel {
  final int? id;
  final String name;
  final String? description;
  final List<ModulePermissionModel> permissions;

  RoleModel({
    this.id,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      permissions: (json['permissions'] as List? ?? [])
          .map((e) => ModulePermissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }

  RoleModel copyWith({
    int? id,
    String? name,
    String? description,
    List<ModulePermissionModel>? permissions,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
