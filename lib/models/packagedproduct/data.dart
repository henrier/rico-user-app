// 打包商品聚合 - 数据模型和类型定义
//
// 对应后端 PackagedProduct 聚合的数据结构
// 基础类型定义，用于支持其他聚合的依赖

import '../audit_metadata.dart';
import '../i18n_string.dart';

/// 打包商品详情视图对象
/// 对应 TypeScript: PackagedProductVO
class PackagedProduct {
  /// 主键
  final String id;

  /// 名称
  final I18NString name;

  /// 描述
  final String description;

  /// 图片
  final List<String> images;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const PackagedProduct({
    required this.id,
    required this.name,
    this.description = '',
    this.images = const [],
    required this.auditMetadata,
  });

  /// 从JSON创建PackagedProduct对象
  factory PackagedProduct.fromJson(Map<String, dynamic> json) {
    return PackagedProduct(
      id: json['id'] ?? '',
      name: I18NString.fromJson(json['name'] ?? {}),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'description': description,
      'images': images,
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  PackagedProduct copyWith({
    String? id,
    I18NString? name,
    String? description,
    List<String>? images,
    AuditMetadata? auditMetadata,
  }) {
    return PackagedProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => name.toString();

  /// 便捷方法：判断是否有图片
  bool get hasImages => images.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackagedProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PackagedProduct(id: $id, name: ${name.toString()})';
  }
}
