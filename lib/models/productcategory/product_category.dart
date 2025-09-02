import '../audit_metadata.dart';
import '../i18n_string.dart';

/// 类目类型枚举
enum CategoryType {
  ip('IP'),
  language('LANGUAGE'),
  series1('SERIES1'),
  series2('SERIES2'),
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

/// 商品类目模型（匹配后端API结构）
class Category {
  final String id;
  final I18NString name;
  final List<String> images;
  final List<CategoryType> categoryTypes;
  final List<Category> parentCategories;
  final AuditMetadata auditMetadata;

  const Category({
    required this.id,
    required this.name,
    this.images = const [],
    this.categoryTypes = const [],
    this.parentCategories = const [],
    required this.auditMetadata,
  });

  /// 从JSON创建Category对象
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: I18NString.fromJson(json['name'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      categoryTypes: (json['categoryTypes'] as List<dynamic>?)
              ?.map((type) => CategoryType.fromString(type.toString()))
              .toList() ??
          [],
      parentCategories: (json['parentCategories'] as List<dynamic>?)
              ?.map(
                  (parent) => Category.fromJson(parent as Map<String, dynamic>))
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

  Category copyWith({
    String? id,
    I18NString? name,
    List<String>? images,
    List<CategoryType>? categoryTypes,
    List<Category>? parentCategories,
    AuditMetadata? auditMetadata,
  }) {
    return Category(
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
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: ${name.toString()}, level: $level, types: $categoryTypes)';
  }
}
