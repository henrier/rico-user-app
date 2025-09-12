// 用户商店聚合 - 数据模型和类型定义
//
// 对应后端 UserShop 聚合的数据结构
// 基础类型定义，用于支持其他聚合的依赖

import '../audit_metadata.dart';

/// 用户商店详情视图对象
/// 对应 TypeScript: UserShopVO
class UserShop {
  /// 主键
  final String id;

  /// 用户ID
  final String userId;

  /// 商店名称
  final String shopName;

  /// 商店描述
  final String description;

  /// 头像
  final String avatar;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const UserShop({
    required this.id,
    required this.userId,
    required this.shopName,
    this.description = '',
    this.avatar = '',
    required this.auditMetadata,
  });

  /// 从JSON创建UserShop对象
  factory UserShop.fromJson(Map<String, dynamic> json) {
    return UserShop(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      shopName: json['shopName'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopName': shopName,
      'description': description,
      'avatar': avatar,
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  UserShop copyWith({
    String? id,
    String? userId,
    String? shopName,
    String? description,
    String? avatar,
    AuditMetadata? auditMetadata,
  }) {
    return UserShop(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => shopName.isNotEmpty ? shopName : 'Shop $id';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserShop && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserShop(id: $id, userId: $userId, shopName: $shopName)';
  }
}
