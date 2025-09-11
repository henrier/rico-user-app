// 商品信息聚合 - 数据模型和类型定义
//
// 对应后端 ProductInfo 聚合的数据结构
// 与 TypeScript 版本保持同步: docs/api/productinfo/data.ts

import '../audit_metadata.dart';
import '../cardeffectfields/data.dart';
import '../i18n_string.dart';
import '../productcategory/data.dart';

// ============================================================================
// 枚举类型定义
// ============================================================================

/// 卡片语言枚举
/// 对应 TypeScript: CardLanguageKey
enum CardLanguage {
  zh('ZH'),
  en('EN'),
  fr('FR'),
  ja('JA');

  const CardLanguage(this.value);
  final String value;

  /// 卡片语言枚举选项（用于UI显示）
  static const List<Map<String, String>> options = [
    {'label': '中', 'value': 'ZH'},
    {'label': '英', 'value': 'EN'},
    {'label': '法', 'value': 'FR'},
    {'label': '日', 'value': 'JA'},
  ];

  static CardLanguage fromString(String value) {
    return CardLanguage.values.firstWhere(
      (language) => language.value == value,
      orElse: () => CardLanguage.zh,
    );
  }

  @override
  String toString() => value;
}

/// 商品类型枚举
/// 对应 TypeScript: TypeKey
enum ProductType {
  raw('RAW'),
  sealed('SEALED');

  const ProductType(this.value);
  final String value;

  /// 类型枚举选项（用于UI显示）
  static const List<Map<String, String>> options = [
    {'label': '单卡', 'value': 'RAW'},
    {'label': '原盒', 'value': 'SEALED'},
  ];

  static ProductType fromString(String value) {
    return ProductType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProductType.raw,
    );
  }

  @override
  String toString() => value;
}

/// 商品信息详情视图对象
/// 对应 TypeScript: ProductInfoVO
class ProductInfo {
  /// 主键
  final String id;

  /// 名称
  final I18NString name;

  /// 编码
  final String code;

  /// 等级
  final String level;

  /// 建议售价
  final double suggestedPrice;

  /// 卡片语言
  final CardLanguage cardLanguage;

  /// 类型
  final ProductType type;

  /// 所属类目
  final List<ProductCategory> categories;

  /// 卡牌效果模板
  final CardEffectFields? cardEffectTemplate;

  /// 卡牌效果
  final List<DynamicField> cardEffects;

  /// 图片
  final List<String> images;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const ProductInfo({
    required this.id,
    required this.name,
    required this.code,
    this.level = '',
    this.suggestedPrice = 0.0,
    this.cardLanguage = CardLanguage.zh,
    this.type = ProductType.raw,
    this.categories = const [],
    this.cardEffectTemplate,
    this.cardEffects = const [],
    this.images = const [],
    required this.auditMetadata,
  });

  /// 从JSON创建ProductInfo对象
  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] ?? '',
      name: I18NString.fromJson(json['name'] ?? {}),
      code: json['code'] ?? '',
      level: json['level'] ?? '',
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble() ?? 0.0,
      cardLanguage: json['cardLanguage'] != null
          ? CardLanguage.fromString(json['cardLanguage'] as String)
          : CardLanguage.zh,
      type: json['type'] != null
          ? ProductType.fromString(json['type'] as String)
          : ProductType.raw,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) =>
                  ProductCategory.fromJson(category as Map<String, dynamic>))
              .toList() ??
          [],
      cardEffectTemplate: json['cardEffectTemplate'] != null
          ? CardEffectFields.fromJson(
              json['cardEffectTemplate'] as Map<String, dynamic>)
          : null,
      cardEffects: (json['cardEffects'] as List<dynamic>?)
              ?.map((effect) =>
                  DynamicField.fromJson(effect as Map<String, dynamic>))
              .toList() ??
          [],
      images: List<String>.from(json['images'] ?? []),
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'code': code,
      'level': level,
      'suggestedPrice': suggestedPrice,
      'cardLanguage': cardLanguage.value,
      'type': type.value,
      'categories': categories.map((category) => category.toJson()).toList(),
      if (cardEffectTemplate != null)
        'cardEffectTemplate': cardEffectTemplate!.toJson(),
      'cardEffects': cardEffects.map((effect) => effect.toJson()).toList(),
      'images': images,
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  ProductInfo copyWith({
    String? id,
    I18NString? name,
    String? code,
    String? level,
    double? suggestedPrice,
    CardLanguage? cardLanguage,
    ProductType? type,
    List<ProductCategory>? categories,
    CardEffectFields? cardEffectTemplate,
    List<DynamicField>? cardEffects,
    List<String>? images,
    AuditMetadata? auditMetadata,
  }) {
    return ProductInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      level: level ?? this.level,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      cardLanguage: cardLanguage ?? this.cardLanguage,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      cardEffectTemplate: cardEffectTemplate ?? this.cardEffectTemplate,
      cardEffects: cardEffects ?? this.cardEffects,
      images: images ?? this.images,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => name.toString();

  /// 便捷方法：获取类目ID列表
  List<String> get categoryIds =>
      categories.map((category) => category.id).toList();

  /// 便捷方法：判断是否有卡牌效果
  bool get hasCardEffects => cardEffects.isNotEmpty;

  /// 便捷方法：判断是否有图片
  bool get hasImages => images.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductInfo(id: $id, name: ${name.toString()}, code: $code, level: $level, suggestedPrice: $suggestedPrice, cardLanguage: $cardLanguage, type: $type)';
  }
}

// ============================================================================
// API 请求参数类型定义
// ============================================================================

/// 创建商品信息参数
/// 对应 TypeScript: CreateProductInfoParams
class CreateProductInfoParams {
  /// 名称
  final I18NString name;

  /// 编码
  final String code;

  /// 类型
  final ProductType type;

  const CreateProductInfoParams({
    required this.name,
    required this.code,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'code': code,
      'type': type.value,
    };
  }
}

/// 创建商品信息（全参数）参数
/// 对应 TypeScript: CreateProductInfoWithAllFieldsParams
class CreateProductInfoWithAllFieldsParams {
  /// 名称
  final I18NString name;

  /// 编码
  final String code;

  /// 等级
  final String? level;

  /// 建议售价
  final double? suggestedPrice;

  /// 卡片语言
  final CardLanguage? cardLanguage;

  /// 类型
  final ProductType type;

  /// 所属类目
  final List<String>? categories;

  /// 卡牌效果模板
  final String? cardEffectTemplate;

  /// 卡牌效果
  final List<DynamicField>? cardEffects;

  /// 图片
  final List<String>? images;

  const CreateProductInfoWithAllFieldsParams({
    required this.name,
    required this.code,
    this.level,
    this.suggestedPrice,
    this.cardLanguage,
    required this.type,
    this.categories,
    this.cardEffectTemplate,
    this.cardEffects,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'code': code,
      if (level != null) 'level': level,
      if (suggestedPrice != null) 'suggestedPrice': suggestedPrice,
      if (cardLanguage != null) 'cardLanguage': cardLanguage!.value,
      'type': type.value,
      if (categories != null) 'categories': categories,
      if (cardEffectTemplate != null) 'cardEffectTemplate': cardEffectTemplate,
      if (cardEffects != null)
        'cardEffects': cardEffects!.map((effect) => effect.toJson()).toList(),
      if (images != null) 'images': images,
    };
  }
}

/// 修改名称参数
/// 对应 TypeScript: UpdateProductInfoNameParams
class UpdateProductInfoNameParams {
  /// 名称
  final I18NString name;

  const UpdateProductInfoNameParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
    };
  }
}

/// 修改编码参数
/// 对应 TypeScript: UpdateProductInfoCodeParams
class UpdateProductInfoCodeParams {
  /// 编码
  final String code;

  const UpdateProductInfoCodeParams({
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}

/// 修改等级参数
/// 对应 TypeScript: UpdateProductInfoLevelParams
class UpdateProductInfoLevelParams {
  /// 等级
  final String level;

  const UpdateProductInfoLevelParams({
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
    };
  }
}

/// 修改建议售价参数
/// 对应 TypeScript: UpdateProductInfoSuggestedPriceParams
class UpdateProductInfoSuggestedPriceParams {
  /// 建议售价
  final double suggestedPrice;

  const UpdateProductInfoSuggestedPriceParams({
    required this.suggestedPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'suggestedPrice': suggestedPrice,
    };
  }
}

/// 修改卡片语言参数
/// 对应 TypeScript: UpdateProductInfoCardLanguageParams
class UpdateProductInfoCardLanguageParams {
  /// 卡片语言
  final CardLanguage cardLanguage;

  const UpdateProductInfoCardLanguageParams({
    required this.cardLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardLanguage': cardLanguage.value,
    };
  }
}

/// 修改类型参数
/// 对应 TypeScript: UpdateProductInfoTypeParams
class UpdateProductInfoTypeParams {
  /// 类型
  final ProductType type;

  const UpdateProductInfoTypeParams({
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
    };
  }
}

/// 修改卡牌效果模板参数
/// 对应 TypeScript: UpdateProductInfoCardEffectTemplateParams
class UpdateProductInfoCardEffectTemplateParams {
  /// 卡牌效果模板
  final String cardEffectTemplate;

  const UpdateProductInfoCardEffectTemplateParams({
    required this.cardEffectTemplate,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardEffectTemplate': cardEffectTemplate,
    };
  }
}

/// 修改卡牌效果参数
/// 对应 TypeScript: UpdateProductInfoCardEffectsParams
class UpdateProductInfoCardEffectsParams {
  /// 卡牌效果
  final List<DynamicField> cardEffects;

  const UpdateProductInfoCardEffectsParams({
    required this.cardEffects,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardEffects': cardEffects.map((effect) => effect.toJson()).toList(),
    };
  }
}

/// 修改图片参数
/// 对应 TypeScript: UpdateProductInfoImagesParams
class UpdateProductInfoImagesParams {
  /// 图片
  final List<String> images;

  const UpdateProductInfoImagesParams({
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'images': images,
    };
  }
}

/// 添加所属类目参数
/// 对应 TypeScript: AddProductInfoCategoriesParams
class AddProductInfoCategoriesParams {
  /// 所属类目列表
  final List<String> categories;

  const AddProductInfoCategoriesParams({
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
    };
  }
}

/// 移除所属类目参数
/// 对应 TypeScript: RemoveProductInfoCategoriesParams
class RemoveProductInfoCategoriesParams {
  /// 要移除的所属类目列表
  final List<String> categories;

  const RemoveProductInfoCategoriesParams({
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
    };
  }
}

/// 分页查询商品信息参数
/// 对应 TypeScript: ProductInfoPageParams
class ProductInfoPageParams {
  /// 当前页
  final int current;

  /// 分页大小
  final int pageSize;

  /// 名称 - 中文
  final String? nameChinese;

  /// 名称 - 英文
  final String? nameEnglish;

  /// 名称 - 日文
  final String? nameJapanese;

  /// 编码
  final String? code;

  /// 等级
  final String? level;

  /// 建议售价最小值
  final double? minSuggestedPrice;

  /// 建议售价最大值
  final double? maxSuggestedPrice;

  /// 卡片语言
  final CardLanguage? cardLanguage;

  /// 类型
  final ProductType? type;

  /// 所属类目
  final List<String>? categories;

  /// 卡牌效果模板
  final String? cardEffectTemplate;

  /// 字段名（模糊查询）
  final String? fieldName;

  /// 字段类型
  final String? fieldType;

  /// 显示名称（模糊查询）
  final String? displayName;

  /// 字段值（模糊查询）
  final String? fieldValue;

  /// 图片
  final List<String>? images;

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

  const ProductInfoPageParams({
    this.current = 1,
    this.pageSize = 20,
    this.nameChinese,
    this.nameEnglish,
    this.nameJapanese,
    this.code,
    this.level,
    this.minSuggestedPrice,
    this.maxSuggestedPrice,
    this.cardLanguage,
    this.type,
    this.categories,
    this.cardEffectTemplate,
    this.fieldName,
    this.fieldType,
    this.displayName,
    this.fieldValue,
    this.images,
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
      if (nameChinese != null) 'nameChinese': nameChinese,
      if (nameEnglish != null) 'nameEnglish': nameEnglish,
      if (nameJapanese != null) 'nameJapanese': nameJapanese,
      if (code != null) 'code': code,
      if (level != null) 'level': level,
      if (minSuggestedPrice != null) 'minSuggestedPrice': minSuggestedPrice,
      if (maxSuggestedPrice != null) 'maxSuggestedPrice': maxSuggestedPrice,
      if (cardLanguage != null) 'cardLanguage': cardLanguage!.value,
      if (type != null) 'type': type!.value,
      if (categories != null) 'categories': categories,
      if (cardEffectTemplate != null) 'cardEffectTemplate': cardEffectTemplate,
      if (fieldName != null) 'fieldName': fieldName,
      if (fieldType != null) 'fieldType': fieldType,
      if (displayName != null) 'displayName': displayName,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (images != null) 'images': images,
      if (createdAtStart != null) 'createdAtStart': createdAtStart,
      if (createdAtEnd != null) 'createdAtEnd': createdAtEnd,
      if (updatedAtStart != null) 'updatedAtStart': updatedAtStart,
      if (updatedAtEnd != null) 'updatedAtEnd': updatedAtEnd,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}

/// 手动分页查询商品信息参数（合并名称查询）
/// 对应 TypeScript: ProductInfoManualPageParams
class ProductInfoManualPageParams {
  /// 当前页
  final int current;

  /// 分页大小
  final int pageSize;

  /// 名称（合并查询中文名、英文名、日文名）
  final String? name;

  /// 编码
  final String? code;

  /// 等级
  final String? level;

  /// 所属类目
  final List<String>? categories;

  /// 卡牌效果模板
  final String? cardEffectTemplate;

  /// 字段名（模糊查询）
  final String? fieldName;

  /// 字段类型
  final String? fieldType;

  /// 显示名称（模糊查询）
  final String? displayName;

  /// 字段值（模糊查询）
  final String? fieldValue;

  /// 图片
  final List<String>? images;

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

  const ProductInfoManualPageParams({
    this.current = 1,
    this.pageSize = 20,
    this.name,
    this.code,
    this.level,
    this.categories,
    this.cardEffectTemplate,
    this.fieldName,
    this.fieldType,
    this.displayName,
    this.fieldValue,
    this.images,
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
      if (code != null) 'code': code,
      if (level != null) 'level': level,
      if (categories != null) 'categories': categories,
      if (cardEffectTemplate != null) 'cardEffectTemplate': cardEffectTemplate,
      if (fieldName != null) 'fieldName': fieldName,
      if (fieldType != null) 'fieldType': fieldType,
      if (displayName != null) 'displayName': displayName,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (images != null) 'images': images,
      if (createdAtStart != null) 'createdAtStart': createdAtStart,
      if (createdAtEnd != null) 'createdAtEnd': createdAtEnd,
      if (updatedAtStart != null) 'updatedAtStart': updatedAtStart,
      if (updatedAtEnd != null) 'updatedAtEnd': updatedAtEnd,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}