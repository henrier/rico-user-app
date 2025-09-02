import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/data/mock_categories.dart';
import '../models/category_model.dart';

/// 类目页面的ViewModel状态
/// 包含UI需要的所有状态数据
class CategoryViewModelState {
  final List<Category> thirdLevelCategories; // 三级类目列表
  final List<Category> fourthLevelCategories; // 当前选中三级类目下的四级类目列表
  final Category? selectedThirdCategory; // 当前选中的三级类目
  final bool isLoading; // 加载状态
  final String? error; // 错误信息

  const CategoryViewModelState({
    this.thirdLevelCategories = const [],
    this.fourthLevelCategories = const [],
    this.selectedThirdCategory,
    this.isLoading = false,
    this.error,
  });

  /// 创建状态副本，用于不可变状态更新
  CategoryViewModelState copyWith({
    List<Category>? thirdLevelCategories,
    List<Category>? fourthLevelCategories,
    Category? selectedThirdCategory,
    bool? isLoading,
    String? error,
  }) {
    return CategoryViewModelState(
      thirdLevelCategories: thirdLevelCategories ?? this.thirdLevelCategories,
      fourthLevelCategories:
          fourthLevelCategories ?? this.fourthLevelCategories,
      selectedThirdCategory:
          selectedThirdCategory ?? this.selectedThirdCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'CategoryViewModelState(thirdLevelCount: ${thirdLevelCategories.length}, '
        'fourthLevelCount: ${fourthLevelCategories.length}, '
        'selectedThird: ${selectedThirdCategory?.name}, '
        'isLoading: $isLoading, error: $error)';
  }
}

/// 类目页面的ViewModel
/// 负责业务逻辑处理和状态管理
class CategoryViewModel extends StateNotifier<CategoryViewModelState> {
  CategoryViewModel() : super(const CategoryViewModelState()) {
    _loadCategories();
  }

  /// 加载类目数据
  /// 模拟从服务器获取数据的过程
  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 500));

      // 获取三级类目数据
      final thirdLevelCategories = MockCategoryData.getThirdLevelCategories();

      // 默认选中第一个三级类目
      Category? firstCategory;
      List<Category> fourthLevelCategories = [];

      if (thirdLevelCategories.isNotEmpty) {
        firstCategory = thirdLevelCategories.first;
        fourthLevelCategories =
            MockCategoryData.getFourthLevelCategories(firstCategory.id);
      }

      // 更新状态
      state = state.copyWith(
        thirdLevelCategories: thirdLevelCategories,
        fourthLevelCategories: fourthLevelCategories,
        selectedThirdCategory: firstCategory,
        isLoading: false,
      );
    } catch (e) {
      // 处理错误情况
      state = state.copyWith(
        isLoading: false,
        error: '加载类目失败: $e',
      );
    }
  }

  /// 选择三级类目
  /// 更新选中状态并加载对应的四级类目
  void selectThirdCategory(Category category) {
    // 避免重复选择
    if (state.selectedThirdCategory?.id == category.id) {
      return;
    }

    // 获取选中类目下的四级类目
    final fourthLevelCategories =
        MockCategoryData.getFourthLevelCategories(category.id);

    // 更新状态
    state = state.copyWith(
      selectedThirdCategory: category,
      fourthLevelCategories: fourthLevelCategories,
    );
  }

  /// 刷新数据
  /// 重新加载所有类目数据
  Future<void> refresh() async {
    await _loadCategories();
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 搜索类目（预留接口）
  Future<void> searchCategories(String keyword) async {
    // TODO: 实现搜索功能
    // 这里可以调用搜索API或本地过滤
  }

  /// 获取类目路径（面包屑导航用）
  List<Category> getCategoryPath(Category category) {
    final path = <Category>[];

    // 如果是四级类目，添加其父类目
    if (category.level == 4 && category.parentId != null) {
      final parentCategory = state.thirdLevelCategories
          .where((cat) => cat.id == category.parentId)
          .firstOrNull;
      if (parentCategory != null) {
        path.add(parentCategory);
      }
    }

    path.add(category);
    return path;
  }
}

/// Dart 3.0+ 扩展方法，用于安全的firstOrNull操作
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
