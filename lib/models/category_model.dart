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
