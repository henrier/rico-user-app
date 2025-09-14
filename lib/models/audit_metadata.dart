import 'user_info.dart';

/// 审计信息
class AuditMetadata {
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserInfo? createdBy;
  final UserInfo? updatedBy;

  const AuditMetadata({
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory AuditMetadata.fromJson(Map<String, dynamic> json) {
    try {
      return AuditMetadata(
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        createdBy: json['createdBy'] != null
            ? UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>)
            : null,
        updatedBy: json['updatedBy'] != null
            ? UserInfo.fromJson(json['updatedBy'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      // 如果解析失败，返回默认值
      return AuditMetadata(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy?.toJson(),
      'updatedBy': updatedBy?.toJson(),
    };
  }
}
