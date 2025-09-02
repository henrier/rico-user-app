// 卡牌效果字段模板聚合 - 数据模型和类型定义
//
// 对应后端 CardEffectFields 聚合的数据结构
// 与 TypeScript 版本保持同步: docs/api/cardeffectfields/data.ts

import '../audit_metadata.dart';

/// 动态字段类型枚举
/// 对应前端 DynamicFieldTemplate 的字段类型
enum DynamicFieldType {
  /// 文本
  text('text'),

  /// 数字
  number('number'),

  /// 布尔值
  boolean('boolean'),

  /// 选择
  select('select'),

  /// 多选
  multiSelect('multiSelect'),

  /// 日期
  date('date'),

  /// 时间
  datetime('datetime');

  const DynamicFieldType(this.value);
  final String value;

  static DynamicFieldType fromString(String value) {
    return DynamicFieldType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DynamicFieldType.text,
    );
  }
}

/// 动态字段选项
/// 对应前端 DynamicFieldTemplate 的选项
class DynamicFieldOption {
  /// 标签
  final String label;

  /// 值
  final String value;

  const DynamicFieldOption({
    required this.label,
    required this.value,
  });

  factory DynamicFieldOption.fromJson(Map<String, dynamic> json) {
    return DynamicFieldOption(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

/// 动态字段模板
/// 对应前端 DynamicFieldTemplate 类型
class DynamicFieldTemplate {
  /// 字段名
  final String fieldName;

  /// 字段类型
  final DynamicFieldType fieldType;

  /// 显示名称
  final String displayName;

  /// 是否必填
  final bool required;

  /// 选项列表（用于 select 和 multiSelect 类型）
  final List<DynamicFieldOption>? options;

  /// 占位符
  final String? placeholder;

  /// 帮助文本
  final String? helpText;

  /// 字段描述
  final String? description;

  const DynamicFieldTemplate({
    required this.fieldName,
    required this.fieldType,
    required this.displayName,
    this.required = false,
    this.options,
    this.placeholder,
    this.helpText,
    this.description,
  });

  factory DynamicFieldTemplate.fromJson(Map<String, dynamic> json) {
    return DynamicFieldTemplate(
      fieldName: json['fieldName'] ?? '',
      fieldType: DynamicFieldType.fromString(json['fieldType'] ?? 'text'),
      displayName: json['displayName'] ?? '',
      required: json['required'] ?? false,
      options: (json['options'] as List<dynamic>?)
          ?.map((option) =>
              DynamicFieldOption.fromJson(option as Map<String, dynamic>))
          .toList(),
      placeholder: json['placeholder'],
      helpText: json['helpText'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'fieldType': fieldType.value,
      'displayName': displayName,
      'required': required,
      if (options != null)
        'options': options!.map((option) => option.toJson()).toList(),
      if (placeholder != null) 'placeholder': placeholder,
      if (helpText != null) 'helpText': helpText,
      if (description != null) 'description': description,
    };
  }

  DynamicFieldTemplate copyWith({
    String? fieldName,
    DynamicFieldType? fieldType,
    String? displayName,
    bool? required,
    List<DynamicFieldOption>? options,
    String? placeholder,
    String? helpText,
    String? description,
  }) {
    return DynamicFieldTemplate(
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      displayName: displayName ?? this.displayName,
      required: required ?? this.required,
      options: options ?? this.options,
      placeholder: placeholder ?? this.placeholder,
      helpText: helpText ?? this.helpText,
      description: description ?? this.description,
    );
  }
}

/// 动态字段（带值）
/// 基于模板创建的具体字段实例
class DynamicField {
  /// 字段名
  final String fieldName;

  /// 字段类型
  final DynamicFieldType fieldType;

  /// 显示名称
  final String displayName;

  /// 字段值
  final dynamic fieldValue;

  /// 是否必填
  final bool required;

  /// 选项列表（用于 select 和 multiSelect 类型）
  final List<DynamicFieldOption>? options;

  /// 占位符
  final String? placeholder;

  /// 帮助文本
  final String? helpText;

  const DynamicField({
    required this.fieldName,
    required this.fieldType,
    required this.displayName,
    this.fieldValue,
    this.required = false,
    this.options,
    this.placeholder,
    this.helpText,
  });

  factory DynamicField.fromJson(Map<String, dynamic> json) {
    return DynamicField(
      fieldName: json['fieldName'] ?? '',
      fieldType: DynamicFieldType.fromString(json['fieldType'] ?? 'text'),
      displayName: json['displayName'] ?? '',
      fieldValue: json['fieldValue'],
      required: json['required'] ?? false,
      options: (json['options'] as List<dynamic>?)
          ?.map((option) =>
              DynamicFieldOption.fromJson(option as Map<String, dynamic>))
          .toList(),
      placeholder: json['placeholder'],
      helpText: json['helpText'],
    );
  }

  /// 从模板创建字段实例
  factory DynamicField.fromTemplate(DynamicFieldTemplate template,
      {dynamic fieldValue}) {
    return DynamicField(
      fieldName: template.fieldName,
      fieldType: template.fieldType,
      displayName: template.displayName,
      fieldValue: fieldValue,
      required: template.required,
      options: template.options,
      placeholder: template.placeholder,
      helpText: template.helpText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'fieldType': fieldType.value,
      'displayName': displayName,
      'fieldValue': fieldValue,
      'required': required,
      if (options != null)
        'options': options!.map((option) => option.toJson()).toList(),
      if (placeholder != null) 'placeholder': placeholder,
      if (helpText != null) 'helpText': helpText,
    };
  }

  DynamicField copyWith({
    String? fieldName,
    DynamicFieldType? fieldType,
    String? displayName,
    dynamic fieldValue,
    bool? required,
    List<DynamicFieldOption>? options,
    String? placeholder,
    String? helpText,
  }) {
    return DynamicField(
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      displayName: displayName ?? this.displayName,
      fieldValue: fieldValue ?? this.fieldValue,
      required: required ?? this.required,
      options: options ?? this.options,
      placeholder: placeholder ?? this.placeholder,
      helpText: helpText ?? this.helpText,
    );
  }
}

/// 卡牌效果字段模板详情视图对象
/// 对应 TypeScript: CardEffectFieldsVO
class CardEffectFields {
  /// 主键
  final String id;

  /// 效果字段模板
  final List<DynamicFieldTemplate> effectFields;

  /// 模板名
  final String templateName;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const CardEffectFields({
    required this.id,
    this.effectFields = const [],
    required this.templateName,
    required this.auditMetadata,
  });

  factory CardEffectFields.fromJson(Map<String, dynamic> json) {
    return CardEffectFields(
      id: json['id'] ?? '',
      effectFields: (json['effectFields'] as List<dynamic>?)
              ?.map((field) =>
                  DynamicFieldTemplate.fromJson(field as Map<String, dynamic>))
              .toList() ??
          [],
      templateName: json['templateName'] ?? '',
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'effectFields': effectFields.map((field) => field.toJson()).toList(),
      'templateName': templateName,
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  CardEffectFields copyWith({
    String? id,
    List<DynamicFieldTemplate>? effectFields,
    String? templateName,
    AuditMetadata? auditMetadata,
  }) {
    return CardEffectFields(
      id: id ?? this.id,
      effectFields: effectFields ?? this.effectFields,
      templateName: templateName ?? this.templateName,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取字段数量
  int get fieldCount => effectFields.length;

  /// 便捷方法：判断是否有字段
  bool get hasFields => effectFields.isNotEmpty;

  /// 便捷方法：根据字段名查找字段模板
  DynamicFieldTemplate? getFieldByName(String fieldName) {
    try {
      return effectFields.firstWhere((field) => field.fieldName == fieldName);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardEffectFields && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CardEffectFields(id: $id, templateName: $templateName, fieldCount: $fieldCount)';
  }
}

// ============================================================================
// API 请求参数类型定义
// ============================================================================

/// 创建卡牌效果模板参数
/// 对应 TypeScript: CreateCardEffectFieldsParams
class CreateCardEffectFieldsParams {
  /// 模板名
  final String templateName;

  const CreateCardEffectFieldsParams({
    required this.templateName,
  });

  Map<String, dynamic> toJson() {
    return {
      'templateName': templateName,
    };
  }
}

/// 创建卡牌效果模板（全参数）参数
/// 对应 TypeScript: CreateCardEffectFieldsWithAllFieldsParams
class CreateCardEffectFieldsWithAllFieldsParams {
  /// 效果字段模板
  final List<DynamicFieldTemplate>? effectFields;

  /// 模板名
  final String templateName;

  const CreateCardEffectFieldsWithAllFieldsParams({
    this.effectFields,
    required this.templateName,
  });

  Map<String, dynamic> toJson() {
    return {
      if (effectFields != null)
        'effectFields': effectFields!.map((field) => field.toJson()).toList(),
      'templateName': templateName,
    };
  }
}

/// 修改模板名参数
/// 对应 TypeScript: UpdateCardEffectFieldsTemplateNameParams
class UpdateCardEffectFieldsTemplateNameParams {
  /// 模板名
  final String templateName;

  const UpdateCardEffectFieldsTemplateNameParams({
    required this.templateName,
  });

  Map<String, dynamic> toJson() {
    return {
      'templateName': templateName,
    };
  }
}

/// 修改效果字段模板参数
/// 对应 TypeScript: UpdateCardEffectFieldsEffectFieldsParams
class UpdateCardEffectFieldsEffectFieldsParams {
  /// 效果字段模板
  final List<DynamicFieldTemplate> effectFields;

  const UpdateCardEffectFieldsEffectFieldsParams({
    required this.effectFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'effectFields': effectFields.map((field) => field.toJson()).toList(),
    };
  }
}

/// 分页查询卡牌效果模板参数
/// 对应 TypeScript: CardEffectFieldsPageParams
class CardEffectFieldsPageParams {
  /// 当前页
  final int current;

  /// 分页大小
  final int pageSize;

  /// 字段名（模糊查询）
  final String? fieldName;

  /// 字段类型
  final String? fieldType;

  /// 显示名称（模糊查询）
  final String? displayName;

  /// 是否必填
  final bool? required;

  /// 字段描述（模糊查询）
  final String? description;

  /// 模板名
  final String? templateName;

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

  const CardEffectFieldsPageParams({
    this.current = 1,
    this.pageSize = 20,
    this.fieldName,
    this.fieldType,
    this.displayName,
    this.required,
    this.description,
    this.templateName,
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
      if (fieldName != null) 'fieldName': fieldName,
      if (fieldType != null) 'fieldType': fieldType,
      if (displayName != null) 'displayName': displayName,
      if (required != null) 'required': required,
      if (description != null) 'description': description,
      if (templateName != null) 'templateName': templateName,
      if (createdAtStart != null) 'createdAtStart': createdAtStart,
      if (createdAtEnd != null) 'createdAtEnd': createdAtEnd,
      if (updatedAtStart != null) 'updatedAtStart': updatedAtStart,
      if (updatedAtEnd != null) 'updatedAtEnd': updatedAtEnd,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}
