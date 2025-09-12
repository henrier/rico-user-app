// 评级公司聚合 - 数据模型和类型定义
//
// 对应后端 RatingCompany 聚合的数据结构
// 与 TypeScript 版本保持同步: docs/api/ratingcompany/data.ts

import '../audit_metadata.dart';
import '../i18n_string.dart';

// ============================================================================
// 数据模型定义
// ============================================================================

/// 官网信息字段
/// 对应 TypeScript: OfficialWebsiteFieldVO
class OfficialWebsiteField {
  /// 名称
  final I18NString name;

  /// 爬虫选择器
  final String crawlerSelector;

  const OfficialWebsiteField({
    required this.name,
    required this.crawlerSelector,
  });

  /// 从JSON创建OfficialWebsiteField对象
  factory OfficialWebsiteField.fromJson(Map<String, dynamic> json) {
    return OfficialWebsiteField(
      name: I18NString.fromJson(json['name'] ?? {}),
      crawlerSelector: json['crawlerSelector'] ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'crawlerSelector': crawlerSelector,
    };
  }

  OfficialWebsiteField copyWith({
    I18NString? name,
    String? crawlerSelector,
  }) {
    return OfficialWebsiteField(
      name: name ?? this.name,
      crawlerSelector: crawlerSelector ?? this.crawlerSelector,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => name.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfficialWebsiteField &&
        other.name == name &&
        other.crawlerSelector == crawlerSelector;
  }

  @override
  int get hashCode => Object.hash(name, crawlerSelector);

  @override
  String toString() {
    return 'OfficialWebsiteField(name: ${name.toString()}, crawlerSelector: $crawlerSelector)';
  }
}

/// 评级公司详情视图对象
/// 对应 TypeScript: RatingCompanyVO
class RatingCompany {
  /// 主键
  final String id;

  /// 名称
  final String name;

  /// 分值
  final List<String> score;

  /// 官网URL
  final String officialWebsiteUrl;

  /// 官网信息字段
  final List<OfficialWebsiteField> officialWebsiteFields;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const RatingCompany({
    required this.id,
    required this.name,
    this.score = const [],
    this.officialWebsiteUrl = '',
    this.officialWebsiteFields = const [],
    required this.auditMetadata,
  });

  /// 从JSON创建RatingCompany对象
  factory RatingCompany.fromJson(Map<String, dynamic> json) {
    return RatingCompany(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      score: List<String>.from(json['score'] ?? []),
      officialWebsiteUrl: json['officialWebsiteUrl'] ?? '',
      officialWebsiteFields: (json['officialWebsiteFields'] as List<dynamic>?)
              ?.map((field) =>
                  OfficialWebsiteField.fromJson(field as Map<String, dynamic>))
              .toList() ??
          [],
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'officialWebsiteUrl': officialWebsiteUrl,
      'officialWebsiteFields':
          officialWebsiteFields.map((field) => field.toJson()).toList(),
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  RatingCompany copyWith({
    String? id,
    String? name,
    List<String>? score,
    String? officialWebsiteUrl,
    List<OfficialWebsiteField>? officialWebsiteFields,
    AuditMetadata? auditMetadata,
  }) {
    return RatingCompany(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      officialWebsiteUrl: officialWebsiteUrl ?? this.officialWebsiteUrl,
      officialWebsiteFields: officialWebsiteFields ?? this.officialWebsiteFields,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => name;

  /// 便捷方法：判断是否有分值
  bool get hasScore => score.isNotEmpty;

  /// 便捷方法：判断是否有官网URL
  bool get hasOfficialWebsiteUrl => officialWebsiteUrl.isNotEmpty;

  /// 便捷方法：判断是否有官网信息字段
  bool get hasOfficialWebsiteFields => officialWebsiteFields.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingCompany && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RatingCompany(id: $id, name: $name, score: $score, officialWebsiteUrl: $officialWebsiteUrl)';
  }
}

// ============================================================================
// API 请求参数类型定义
// ============================================================================

/// 创建评级公司参数
/// 对应 TypeScript: CreateRatingCompanyParams
class CreateRatingCompanyParams {
  /// 名称
  final String name;

  const CreateRatingCompanyParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

/// 创建评级公司（全参数）参数
/// 对应 TypeScript: CreateRatingCompanyWithAllFieldsParams
class CreateRatingCompanyWithAllFieldsParams {
  /// 名称
  final String name;

  /// 分值
  final List<String>? score;

  /// 官网URL
  final String? officialWebsiteUrl;

  /// 官网信息字段
  final List<OfficialWebsiteField>? officialWebsiteFields;

  const CreateRatingCompanyWithAllFieldsParams({
    required this.name,
    this.score,
    this.officialWebsiteUrl,
    this.officialWebsiteFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (score != null) 'score': score,
      if (officialWebsiteUrl != null) 'officialWebsiteUrl': officialWebsiteUrl,
      if (officialWebsiteFields != null)
        'officialWebsiteFields':
            officialWebsiteFields!.map((field) => field.toJson()).toList(),
    };
  }
}

/// 修改名称参数
/// 对应 TypeScript: UpdateRatingCompanyNameParams
class UpdateRatingCompanyNameParams {
  /// 名称
  final String name;

  const UpdateRatingCompanyNameParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

/// 修改官网URL参数
/// 对应 TypeScript: UpdateRatingCompanyOfficialWebsiteUrlParams
class UpdateRatingCompanyOfficialWebsiteUrlParams {
  /// 官网URL
  final String officialWebsiteUrl;

  const UpdateRatingCompanyOfficialWebsiteUrlParams({
    required this.officialWebsiteUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'officialWebsiteUrl': officialWebsiteUrl,
    };
  }
}

/// 修改分值参数
/// 对应 TypeScript: UpdateRatingCompanyScoreParams
class UpdateRatingCompanyScoreParams {
  /// 分值
  final List<String> score;

  const UpdateRatingCompanyScoreParams({
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
    };
  }
}

/// 修改官网信息字段参数
/// 对应 TypeScript: UpdateRatingCompanyOfficialWebsiteFieldsParams
class UpdateRatingCompanyOfficialWebsiteFieldsParams {
  /// 官网信息字段
  final List<OfficialWebsiteField> officialWebsiteFields;

  const UpdateRatingCompanyOfficialWebsiteFieldsParams({
    required this.officialWebsiteFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'officialWebsiteFields':
          officialWebsiteFields.map((field) => field.toJson()).toList(),
    };
  }
}

/// 分页查询评级公司参数
/// 对应 TypeScript: RatingCompanyPageParams
class RatingCompanyPageParams {
  /// 当前页
  final int current;

  /// 分页大小
  final int pageSize;

  /// 名称
  final String? name;

  /// 分值
  final List<String>? score;

  /// 官网URL
  final String? officialWebsiteUrl;

  /// 官网信息字段 - 名称 - 中文
  final String? officialWebsiteFieldsNameChinese;

  /// 官网信息字段 - 名称 - 英文
  final String? officialWebsiteFieldsNameEnglish;

  /// 官网信息字段 - 名称 - 日文
  final String? officialWebsiteFieldsNameJapanese;

  /// 官网信息字段 - 爬虫选择器
  final String? officialWebsiteFieldsCrawlerSelector;

  /// 创建时间范围开始
  final String? createdAtStart;

  /// 创建时间范围结束
  final String? createdAtEnd;

  /// 更新时间范围开始
  final String? updatedAtStart;

  /// 更新时间范围结束
  final String? updatedAtEnd;

  /// 创建者（模糊查询）
  final String? createdBy;

  /// 更新者（模糊查询）
  final String? updatedBy;

  const RatingCompanyPageParams({
    this.current = 1,
    this.pageSize = 20,
    this.name,
    this.score,
    this.officialWebsiteUrl,
    this.officialWebsiteFieldsNameChinese,
    this.officialWebsiteFieldsNameEnglish,
    this.officialWebsiteFieldsNameJapanese,
    this.officialWebsiteFieldsCrawlerSelector,
    this.createdAtStart,
    this.createdAtEnd,
    this.updatedAtStart,
    this.updatedAtEnd,
    this.createdBy,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'pageSize': pageSize,
      if (name != null) 'name': name,
      if (score != null) 'score': score,
      if (officialWebsiteUrl != null) 'officialWebsiteUrl': officialWebsiteUrl,
      if (officialWebsiteFieldsNameChinese != null)
        'officialWebsiteFieldsNameChinese': officialWebsiteFieldsNameChinese,
      if (officialWebsiteFieldsNameEnglish != null)
        'officialWebsiteFieldsNameEnglish': officialWebsiteFieldsNameEnglish,
      if (officialWebsiteFieldsNameJapanese != null)
        'officialWebsiteFieldsNameJapanese': officialWebsiteFieldsNameJapanese,
      if (officialWebsiteFieldsCrawlerSelector != null)
        'officialWebsiteFieldsCrawlerSelector':
            officialWebsiteFieldsCrawlerSelector,
      if (createdAtStart != null) 'createdAtStart': createdAtStart,
      if (createdAtEnd != null) 'createdAtEnd': createdAtEnd,
      if (updatedAtStart != null) 'updatedAtStart': updatedAtStart,
      if (updatedAtEnd != null) 'updatedAtEnd': updatedAtEnd,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}
