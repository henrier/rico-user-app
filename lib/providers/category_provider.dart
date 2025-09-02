import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';

// ============================================================================
// Provider 声明和依赖注入
// ============================================================================

/// 主要的类目ViewModel提供者
/// 提供CategoryViewModel实例和CategoryViewModelState状态
final categoryViewModelProvider =
    StateNotifierProvider<CategoryViewModel, CategoryViewModelState>((ref) {
  return CategoryViewModel();
});

// ============================================================================
// 计算属性Providers - 提供细粒度的状态访问
// ============================================================================

/// 获取当前选中的三级类目
/// 用于需要监听选中类目变化的组件
final selectedThirdCategoryProvider = Provider<Category?>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.selectedThirdCategory;
});

/// 获取当前四级类目列表
/// 用于右侧四级类目列表的渲染
final fourthLevelCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.fourthLevelCategories;
});

/// 获取三级类目列表
/// 用于左侧三级类目列表的渲染
final thirdLevelCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.thirdLevelCategories;
});

/// 检查是否正在加载
/// 用于显示加载指示器
final isLoadingCategoriesProvider = Provider<bool>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.isLoading;
});

/// 获取错误信息
/// 用于错误处理和显示错误消息
final categoryErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.error;
});

// ============================================================================
// 兼容性Providers - 保持向后兼容
// ============================================================================

/// @deprecated 使用 categoryViewModelProvider 替代
/// 为了保持向后兼容而保留的别名
final categoryProvider = categoryViewModelProvider;
