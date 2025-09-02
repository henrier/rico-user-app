import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/utils/logger.dart';
import '../models/productcategory/product_category.dart';
import '../services/category_service.dart';

/// 类目页面的ViewModel状态
/// 包含UI需要的所有状态数据
class CategoryViewModelState {
  final List<Category> thirdLevelCategories; // 三级类目列表
  final List<Category> fourthLevelCategories; // 当前选中三级类目下的四级类目列表
  final Category? selectedThirdCategory; // 当前选中的三级类目
  final String secondCategoryId; // 二级类目ID
  final bool isLoading; // 加载状态
  final String? error; // 错误信息

  const CategoryViewModelState({
    this.thirdLevelCategories = const [],
    this.fourthLevelCategories = const [],
    this.selectedThirdCategory,
    required this.secondCategoryId,
    this.isLoading = false,
    this.error,
  });

  /// 创建状态副本，用于不可变状态更新
  CategoryViewModelState copyWith({
    List<Category>? thirdLevelCategories,
    List<Category>? fourthLevelCategories,
    Category? selectedThirdCategory,
    String? secondCategoryId,
    bool? isLoading,
    String? error,
  }) {
    return CategoryViewModelState(
      thirdLevelCategories: thirdLevelCategories ?? this.thirdLevelCategories,
      fourthLevelCategories:
          fourthLevelCategories ?? this.fourthLevelCategories,
      selectedThirdCategory:
          selectedThirdCategory ?? this.selectedThirdCategory,
      secondCategoryId: secondCategoryId ?? this.secondCategoryId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'CategoryViewModelState(thirdLevelCount: ${thirdLevelCategories.length}, '
        'fourthLevelCount: ${fourthLevelCategories.length}, '
        'selectedThird: ${selectedThirdCategory?.displayName}, '
        'secondCategoryId: $secondCategoryId, '
        'isLoading: $isLoading, error: $error)';
  }
}

/// 类目页面的ViewModel
/// 负责业务逻辑处理和状态管理
class CategoryViewModel extends StateNotifier<CategoryViewModelState> {
  final CategoryService _categoryService;

  CategoryViewModel({
    CategoryService? categoryService,
    required String secondCategoryId,
  })  : _categoryService = categoryService ?? CategoryService(),
        super(CategoryViewModelState(
          secondCategoryId: secondCategoryId,
        )) {
    _loadCategories();
  }

  /// 加载类目数据
  /// 使用真实API加载数据
  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.i('加载类目数据，二级类目ID: ${state.secondCategoryId}');

      // 使用真实API加载三级类目
      final thirdLevelCategories =
          await _categoryService.getThirdLevelCategories(
        state.secondCategoryId,
      );

      // 默认选中第一个三级类目
      Category? firstCategory;
      List<Category> fourthLevelCategories = [];

      if (thirdLevelCategories.isNotEmpty) {
        firstCategory = thirdLevelCategories.first;
        fourthLevelCategories = await _categoryService.getFourthLevelCategories(
          firstCategory.id,
        );
      }

      // 更新状态
      state = state.copyWith(
        thirdLevelCategories: thirdLevelCategories,
        fourthLevelCategories: fourthLevelCategories,
        selectedThirdCategory: firstCategory,
        isLoading: false,
      );

      AppLogger.i(
          '类目加载完成: ${thirdLevelCategories.length}个三级类目, ${fourthLevelCategories.length}个四级类目');
    } catch (e) {
      AppLogger.e('加载类目失败', e);

      // 处理错误情况
      state = state.copyWith(
        isLoading: false,
        error: '加载类目失败: $e',
      );
    }
  }

  /// 选择三级类目
  /// 更新选中状态并加载对应的四级类目
  Future<void> selectThirdCategory(Category category) async {
    // 避免重复选择
    if (state.selectedThirdCategory?.id == category.id) {
      return;
    }

    AppLogger.i('选择三级类目: ${category.displayName}');

    try {
      // 先更新选中状态，显示加载中
      state = state.copyWith(
        selectedThirdCategory: category,
        fourthLevelCategories: [], // 清空四级类目
      );

      // 获取选中类目下的四级类目
      final fourthLevelCategories =
          await _categoryService.getFourthLevelCategories(
        category.id,
      );

      // 更新状态
      state = state.copyWith(
        fourthLevelCategories: fourthLevelCategories,
      );

      AppLogger.i('四级类目加载完成: ${fourthLevelCategories.length}个');
    } catch (e) {
      AppLogger.e('选择三级类目失败', e);
      state = state.copyWith(
        error: '加载四级类目失败: $e',
      );
    }
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

  /// 设置二级类目ID并重新加载
  Future<void> setSecondCategoryId(String secondCategoryId) async {
    if (state.secondCategoryId == secondCategoryId) {
      return;
    }

    AppLogger.i('设置二级类目ID: $secondCategoryId');
    state = state.copyWith(secondCategoryId: secondCategoryId);
    await _loadCategories();
  }

  /// 搜索类目（预留接口）
  Future<void> searchCategories(String keyword) async {
    // TODO: 实现搜索功能
    // 可以调用搜索API或本地过滤
    AppLogger.i('搜索类目: $keyword');
  }

  /// 释放资源
  @override
  void dispose() {
    _categoryService.dispose();
    super.dispose();
  }

  /// 获取类目路径（面包屑导航用）
  List<Category> getCategoryPath(Category category) {
    final path = <Category>[];

    // 如果是四级类目，添加其父类目
    if (category.isFourthLevel && category.parentCategories.isNotEmpty) {
      final parentCategory = category.parentCategories.first;
      path.add(parentCategory);
    }

    path.add(category);
    return path;
  }
}

/// Dart 3.0+ 扩展方法，用于安全的firstOrNull操作
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
