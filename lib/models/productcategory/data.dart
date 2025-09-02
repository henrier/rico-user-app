// 商品类目聚合 - 数据模型和类型定义
//
// 对应后端 ProductCategory 聚合的数据结构
// 与 TypeScript 版本保持同步: docs/api/productcategory/data.ts

import '../audit_metadata.dart';
import '../i18n_string.dart';

/// 类目类型枚举
/// 对应 TypeScript: CategoryTypesKey
enum CategoryType {
  /// IP（一级）
  ip('IP'),

  /// 语种（二级）
  language('LANGUAGE'),

  /// 系列1（三级）
  series1('SERIES1'),

  /// 系列2（四级）
  series2('SERIES2'),

  /// 近期更新（标签）
  recentUpdate('RECENTUPDATE');

  const CategoryType(this.value);
  final String value;

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryType.ip,
    );
  }
}

/// 商品类目详情视图对象
/// 对应 TypeScript: ProductCategoryVO
class ProductCategory {
  /// 主键
  final String id;

  /// 名称
  final I18NString name;

  /// 图片
  final List<String> images;

  /// 类目类型
  final List<CategoryType> categoryTypes;

  /// 父类目
  final List<ProductCategory> parentCategories;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const ProductCategory({
    required this.id,
    required this.name,
    this.images = const [],
    this.categoryTypes = const [],
    this.parentCategories = const [],
    required this.auditMetadata,
  });

  /// 从JSON创建ProductCategory对象
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: I18NString.fromJson(json['name'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      categoryTypes: (json['categoryTypes'] as List<dynamic>?)
              ?.map((type) => CategoryType.fromString(type.toString()))
              .toList() ??
          [],
      parentCategories: (json['parentCategories'] as List<dynamic>?)
              ?.map((parent) =>
                  ProductCategory.fromJson(parent as Map<String, dynamic>))
              .toList() ??
          [],
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'images': images,
      'categoryTypes': categoryTypes.map((type) => type.value).toList(),
      'parentCategories':
          parentCategories.map((parent) => parent.toJson()).toList(),
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  ProductCategory copyWith({
    String? id,
    I18NString? name,
    List<String>? images,
    List<CategoryType>? categoryTypes,
    List<ProductCategory>? parentCategories,
    AuditMetadata? auditMetadata,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      categoryTypes: categoryTypes ?? this.categoryTypes,
      parentCategories: parentCategories ?? this.parentCategories,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => name.toString();

  /// 便捷方法：判断是否为三级类目
  bool get isThirdLevel => categoryTypes.contains(CategoryType.series1);

  /// 便捷方法：判断是否为四级类目
  bool get isFourthLevel => categoryTypes.contains(CategoryType.series2);

  /// 便捷方法：获取层级
  int get level {
    if (isFourthLevel) return 4;
    if (isThirdLevel) return 3;
    if (categoryTypes.contains(CategoryType.language)) return 2;
    if (categoryTypes.contains(CategoryType.ip)) return 1;
    return 0;
  }

  /// 便捷方法：获取父类目ID列表
  List<String> get parentIds =>
      parentCategories.map((parent) => parent.id).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductCategory(id: $id, name: ${name.toString()}, level: $level, types: $categoryTypes)';
  }
}

// ============================================================================
// API 请求参数类型定义
// ============================================================================

/// 创建商品类目参数
/// 对应 TypeScript: CreateProductCategoryParams
class CreateProductCategoryParams {
  /// 名称
  final I18NString name;

  const CreateProductCategoryParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
    };
  }
}

/// 创建商品类目（全参数）参数
/// 对应 TypeScript: CreateProductCategoryWithAllFieldsParams
class CreateProductCategoryWithAllFieldsParams {
  /// 名称
  final I18NString name;

  /// 图片
  final List<String>? images;

  /// 类目类型
  final List<CategoryType>? categoryTypes;

  /// 父类目
  final List<String>? parentCategories;

  const CreateProductCategoryWithAllFieldsParams({
    required this.name,
    this.images,
    this.categoryTypes,
    this.parentCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      if (images != null) 'images': images,
      if (categoryTypes != null)
        'categoryTypes': categoryTypes!.map((type) => type.value).toList(),
      if (parentCategories != null) 'parentCategories': parentCategories,
    };
  }
}

/// 修改名称参数
/// 对应 TypeScript: UpdateProductCategoryNameParams
class UpdateProductCategoryNameParams {
  /// 名称
  final I18NString name;

  const UpdateProductCategoryNameParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
    };
  }
}

/// 修改图片参数
/// 对应 TypeScript: UpdateProductCategoryImagesParams
class UpdateProductCategoryImagesParams {
  /// 图片
  final List<String> images;

  const UpdateProductCategoryImagesParams({
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'images': images,
    };
  }
}

/// 添加类目类型参数
/// 对应 TypeScript: AddProductCategoryCategoryTypesParams
class AddProductCategoryCategoryTypesParams {
  /// 类目类型列表
  final List<CategoryType> categoryTypes;

  const AddProductCategoryCategoryTypesParams({
    required this.categoryTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryTypes': categoryTypes.map((type) => type.value).toList(),
    };
  }
}

/// 移除类目类型参数
/// 对应 TypeScript: RemoveProductCategoryCategoryTypesParams
class RemoveProductCategoryCategoryTypesParams {
  /// 要移除的类目类型列表
  final List<CategoryType> categoryTypes;

  const RemoveProductCategoryCategoryTypesParams({
    required this.categoryTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryTypes': categoryTypes.map((type) => type.value).toList(),
    };
  }
}

/// 添加父类目参数
/// 对应 TypeScript: AddProductCategoryParentCategoriesParams
class AddProductCategoryParentCategoriesParams {
  /// 父类目列表
  final List<String> parentCategories;

  const AddProductCategoryParentCategoriesParams({
    required this.parentCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'parentCategories': parentCategories,
    };
  }
}

/// 移除父类目参数
/// 对应 TypeScript: RemoveProductCategoryParentCategoriesParams
class RemoveProductCategoryParentCategoriesParams {
  /// 要移除的父类目列表
  final List<String> parentCategories;

  const RemoveProductCategoryParentCategoriesParams({
    required this.parentCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'parentCategories': parentCategories,
    };
  }
}

/// 分页查询商品类目参数
/// 对应 TypeScript: ProductCategoryPageParams
class ProductCategoryPageParams {
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

  /// 图片
  final List<String>? images;

  /// 类目类型
  final List<CategoryType>? categoryTypes;

  /// 父类目
  final List<String>? parentCategories;

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

  const ProductCategoryPageParams({
    this.current = 1,
    this.pageSize = 20,
    this.nameChinese,
    this.nameEnglish,
    this.nameJapanese,
    this.images,
    this.categoryTypes,
    this.parentCategories,
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
      if (images != null) 'images': images,
      if (categoryTypes != null)
        'categoryTypes': categoryTypes!.map((type) => type.value).toList(),
      if (parentCategories != null) 'parentCategories': parentCategories,
      if (createdAtStart != null) 'createdAtStart': createdAtStart,
      if (createdAtEnd != null) 'createdAtEnd': createdAtEnd,
      if (updatedAtStart != null) 'updatedAtStart': updatedAtStart,
      if (updatedAtEnd != null) 'updatedAtEnd': updatedAtEnd,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}
