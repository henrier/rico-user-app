class Category {
  final String id;
  final String name;
  final String? parentId;
  final int level; // 3级类目或4级类目
  final List<Category> children;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.level,
    this.children = const [],
  });

  Category copyWith({
    String? id,
    String? name,
    String? parentId,
    int? level,
    List<Category>? children,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, level: $level, parentId: $parentId)';
  }
}

// 类目状态模型
class CategoryState {
  final List<Category> thirdLevelCategories; // 三级类目列表
  final List<Category> fourthLevelCategories; // 当前选中三级类目下的四级类目列表
  final Category? selectedThirdCategory; // 当前选中的三级类目
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.thirdLevelCategories = const [],
    this.fourthLevelCategories = const [],
    this.selectedThirdCategory,
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? thirdLevelCategories,
    List<Category>? fourthLevelCategories,
    Category? selectedThirdCategory,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      thirdLevelCategories: thirdLevelCategories ?? this.thirdLevelCategories,
      fourthLevelCategories:
          fourthLevelCategories ?? this.fourthLevelCategories,
      selectedThirdCategory:
          selectedThirdCategory ?? this.selectedThirdCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
