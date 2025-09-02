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
    return AuditMetadata(
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'] != null
          ? UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      updatedBy: json['updatedBy'] != null
          ? UserInfo.fromJson(json['updatedBy'] as Map<String, dynamic>)
          : null,
    );
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
