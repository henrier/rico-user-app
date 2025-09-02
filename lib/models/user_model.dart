import 'dart:convert';

// 角色模型
class UserRole {
  final String id;
  final String name;
  final String description;

  const UserRole({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRole && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// 审计元数据模型
class AuditMetadata {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  const AuditMetadata({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory AuditMetadata.fromMap(Map<String, dynamic> map) {
    return AuditMetadata(
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: map['createdBy'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
    );
  }
}

class User {
  final String id;
  final String? openId;
  final String name;
  final String phone;
  final String? avatar;
  final List<UserRole> roles;
  final String? remark;
  final bool disabled;
  final AuditMetadata? auditMetadata;

  const User({
    required this.id,
    this.openId,
    required this.name,
    required this.phone,
    this.avatar,
    required this.roles,
    this.remark,
    this.disabled = false,
    this.auditMetadata,
  });

  String get displayName => name;

  // 获取用户的主要角色
  String get primaryRole {
    if (roles.isNotEmpty) {
      return roles.first.name;
    }
    return '普通用户';
  }

  // 检查用户是否有特定角色
  bool hasRole(String roleName) {
    return roles.any((role) => role.name == roleName);
  }

  User copyWith({
    String? id,
    String? openId,
    String? name,
    String? phone,
    String? avatar,
    List<UserRole>? roles,
    String? remark,
    bool? disabled,
    AuditMetadata? auditMetadata,
  }) {
    return User(
      id: id ?? this.id,
      openId: openId ?? this.openId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      remark: remark ?? this.remark,
      disabled: disabled ?? this.disabled,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'openId': openId,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'roles': roles.map((role) => role.toMap()).toList(),
      'remark': remark,
      'disabled': disabled,
      'auditMetadata': auditMetadata?.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      openId: map['openId'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['avatar'],
      roles: (map['roles'] as List<dynamic>?)
              ?.map((roleMap) =>
                  UserRole.fromMap(roleMap as Map<String, dynamic>))
              .toList() ??
          [],
      remark: map['remark'],
      disabled: map['disabled'] ?? false,
      auditMetadata: map['auditMetadata'] != null
          ? AuditMetadata.fromMap(map['auditMetadata'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, openId: $openId, name: $name, phone: $phone, avatar: $avatar, roles: $roles, remark: $remark, disabled: $disabled, auditMetadata: $auditMetadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.openId == openId &&
        other.name == name &&
        other.phone == phone &&
        other.avatar == avatar &&
        other.remark == remark &&
        other.disabled == disabled;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        openId.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        avatar.hashCode ^
        remark.hashCode ^
        disabled.hashCode;
  }
}
