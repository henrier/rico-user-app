import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/data/mock_categories.dart';
import '../models/category_model.dart';

/// 类目状态管理器
class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(const CategoryState()) {
    _loadCategories();
  }

  /// 加载类目数据
  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      final thirdLevelCategories = MockCategoryData.getThirdLevelCategories();
      
      // 默认选中第一个三级类目
      Category? firstCategory;
      List<Category> fourthLevelCategories = [];
      
      if (thirdLevelCategories.isNotEmpty) {
        firstCategory = thirdLevelCategories.first;
        fourthLevelCategories = MockCategoryData.getFourthLevelCategories(firstCategory.id);
      }
      
      state = state.copyWith(
        thirdLevelCategories: thirdLevelCategories,
        fourthLevelCategories: fourthLevelCategories,
        selectedThirdCategory: firstCategory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载类目失败: $e',
      );
    }
  }

  /// 选择三级类目
  void selectThirdCategory(Category category) {
    if (state.selectedThirdCategory?.id == category.id) {
      return; // 如果已经选中，不需要重复操作
    }
    
    final fourthLevelCategories = MockCategoryData.getFourthLevelCategories(category.id);
    
    state = state.copyWith(
      selectedThirdCategory: category,
      fourthLevelCategories: fourthLevelCategories,
    );
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadCategories();
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 类目状态提供者
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier();
});

/// 获取当前选中的三级类目
final selectedThirdCategoryProvider = Provider<Category?>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.selectedThirdCategory;
});

/// 获取当前四级类目列表
final fourthLevelCategoriesProvider = Provider<List<Category>>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.fourthLevelCategories;
});

/// 获取三级类目列表
final thirdLevelCategoriesProvider = Provider<List<Category>>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.thirdLevelCategories;
});

/// 检查是否正在加载
final isLoadingCategoriesProvider = Provider<bool>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.isLoading;
});

/// 获取错误信息
final categoryErrorProvider = Provider<String?>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.error;
});
