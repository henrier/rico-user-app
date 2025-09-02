import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';

// ============================================================================
// Provider 声明和依赖注入
// ============================================================================

/// 主要的类目ViewModel提供者
/// 提供CategoryViewModel实例和CategoryViewModelState状态
final categoryViewModelProvider = StateNotifierProvider.family<
    CategoryViewModel, CategoryViewModelState, String>((ref, secondCategoryId) {
  return CategoryViewModel(
    secondCategoryId: secondCategoryId,
  );
});

// ============================================================================
// 计算属性Providers - 提供细粒度的状态访问
// ============================================================================

/// 默认的二级类目ID
const String _defaultSecondCategoryId = 'tempSecondCategoryId';

/// 获取当前选中的三级类目
/// 用于需要监听选中类目变化的组件
final selectedThirdCategoryProvider =
    Provider.family<Category?, String>((ref, secondCategoryId) {
  final state = ref.watch(categoryViewModelProvider(secondCategoryId));
  return state.selectedThirdCategory;
});

/// 获取当前四级类目列表
/// 用于右侧四级类目列表的渲染
final fourthLevelCategoriesProvider =
    Provider.family<List<Category>, String>((ref, secondCategoryId) {
  final state = ref.watch(categoryViewModelProvider(secondCategoryId));
  return state.fourthLevelCategories;
});

/// 获取三级类目列表
/// 用于左侧三级类目列表的渲染
final thirdLevelCategoriesProvider =
    Provider.family<List<Category>, String>((ref, secondCategoryId) {
  final state = ref.watch(categoryViewModelProvider(secondCategoryId));
  return state.thirdLevelCategories;
});

/// 检查是否正在加载
/// 用于显示加载指示器
final isLoadingCategoriesProvider =
    Provider.family<bool, String>((ref, secondCategoryId) {
  final state = ref.watch(categoryViewModelProvider(secondCategoryId));
  return state.isLoading;
});

/// 获取错误信息
/// 用于错误处理和显示错误消息
final categoryErrorProvider =
    Provider.family<String?, String>((ref, secondCategoryId) {
  final state = ref.watch(categoryViewModelProvider(secondCategoryId));
  return state.error;
});

// ============================================================================
// 兼容性Providers - 保持向后兼容
// ============================================================================

/// 默认参数的便捷Providers（向后兼容）
final selectedThirdCategoryProviderCompat = Provider<Category?>((ref) {
  return ref.watch(selectedThirdCategoryProvider(_defaultSecondCategoryId));
});

final fourthLevelCategoriesProviderCompat = Provider<List<Category>>((ref) {
  return ref.watch(fourthLevelCategoriesProvider(_defaultSecondCategoryId));
});

final thirdLevelCategoriesProviderCompat = Provider<List<Category>>((ref) {
  return ref.watch(thirdLevelCategoriesProvider(_defaultSecondCategoryId));
});

final isLoadingCategoriesProviderCompat = Provider<bool>((ref) {
  return ref.watch(isLoadingCategoriesProvider(_defaultSecondCategoryId));
});

final categoryErrorProviderCompat = Provider<String?>((ref) {
  return ref.watch(categoryErrorProvider(_defaultSecondCategoryId));
});
