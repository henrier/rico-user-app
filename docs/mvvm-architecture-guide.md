# Flutter MVVM 架构设计指南

## 📋 概述

本文档总结了在Flutter项目中实施MVVM（Model-View-ViewModel）架构模式的最佳实践，基于Riverpod状态管理和商品类目选择页面的实际案例。

## 🏗️ MVVM架构核心概念

### 架构层次图

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│    View     │◄──►│  ViewModel   │◄──►│    Model    │
│             │    │              │    │             │
│   UI层      │    │   业务逻辑层   │    │   数据层     │
│   用户交互   │    │   状态管理    │    │   数据模型   │
└─────────────┘    └──────────────┘    └─────────────┘
       ▲                   ▲
       │                   │
       └───── Provider ────┘
       (数据绑定层)
```

### 职责分离

| 层次 | 职责 | 包含内容 |
|------|------|----------|
| **Model** | 数据模型 | 纯数据结构、业务实体、数据转换 |
| **ViewModel** | 业务逻辑 | 状态管理、业务逻辑、数据处理 |
| **View** | 用户界面 | UI渲染、用户交互、事件处理 |
| **Provider** | 数据绑定 | 依赖注入、状态订阅、计算属性 |

## 📁 文件组织结构

### 推荐的目录结构

```
lib/
├── models/                    # 数据模型层
│   ├── category_model.dart    # 类目数据模型
│   └── user_model.dart        # 用户数据模型
├── viewmodels/                # ViewModel层
│   ├── category_viewmodel.dart # 类目业务逻辑
│   └── auth_viewmodel.dart     # 认证业务逻辑
├── providers/                 # Provider声明层
│   ├── category_provider.dart  # 类目Provider
│   └── auth_provider.dart      # 认证Provider
├── screens/                   # View层
│   └── category/
│       └── category_selection_screen.dart
├── services/                  # 数据服务层
│   ├── category_service.dart   # 类目数据服务
│   └── auth_service.dart       # 认证服务
└── common/
    └── data/
        └── mock_categories.dart # 模拟数据
```

## 🎯 实现细节

### 1. Model 层实现

```dart
// lib/models/category_model.dart
class Category {
  final String id;
  final String name;
  final String? parentId;
  final int level;
  final List<Category> children;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.level,
    this.children = const [],
  });

  // 只包含数据相关的方法
  Category copyWith({...}) { ... }
  Map<String, dynamic> toJson() { ... }
  factory Category.fromJson(Map<String, dynamic> json) { ... }
}
```

**Model层特点**：
- ✅ 纯数据结构，无业务逻辑
- ✅ 包含数据转换方法（toJson/fromJson）
- ✅ 不依赖Flutter框架
- ✅ 可以在不同平台复用

### 2. ViewModel 层实现

```dart
// lib/viewmodels/category_viewmodel.dart

/// ViewModel状态 - UI需要的所有状态数据
class CategoryViewModelState {
  final List<Category> thirdLevelCategories;
  final List<Category> fourthLevelCategories;
  final Category? selectedThirdCategory;
  final bool isLoading;
  final String? error;

  const CategoryViewModelState({...});
  CategoryViewModelState copyWith({...}) { ... }
}

/// ViewModel行为 - 业务逻辑处理器
class CategoryViewModel extends StateNotifier<CategoryViewModelState> {
  CategoryViewModel() : super(const CategoryViewModelState()) {
    _loadCategories();
  }

  // 业务逻辑方法
  Future<void> _loadCategories() async { ... }
  void selectThirdCategory(Category category) { ... }
  Future<void> refresh() async { ... }
  void clearError() { ... }
}
```

**ViewModel层特点**：
- ✅ 包含UI状态（isLoading, error等）
- ✅ 处理业务逻辑
- ✅ 调用Model层数据操作
- ✅ 状态不可变更新（copyWith）

### 3. Provider 层实现

```dart
// lib/providers/category_provider.dart

/// 主要的ViewModel提供者
final categoryViewModelProvider = StateNotifierProvider<CategoryViewModel, CategoryViewModelState>((ref) {
  return CategoryViewModel();
});

/// 计算属性Providers - 细粒度状态访问
final selectedThirdCategoryProvider = Provider<Category?>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.selectedThirdCategory;
});

final fourthLevelCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.fourthLevelCategories;
});

final isLoadingCategoriesProvider = Provider<bool>((ref) {
  final state = ref.watch(categoryViewModelProvider);
  return state.isLoading;
});
```

**Provider层特点**：
- ✅ 依赖注入容器
- ✅ 计算属性（类似Vue的computed）
- ✅ 细粒度状态订阅
- ✅ 性能优化（只更新相关组件）

### 4. View 层实现

```dart
// lib/screens/category/category_selection_screen.dart
class CategorySelectionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状态订阅
    final categoryState = ref.watch(categoryViewModelProvider);
    final isLoading = ref.watch(isLoadingCategoriesProvider);
    
    return Scaffold(
      body: _buildContent(context, ref, categoryState, isLoading),
    );
  }

  void _onCategoryTap(WidgetRef ref, Category category) {
    // 调用ViewModel行为
    ref.read(categoryViewModelProvider.notifier).selectThirdCategory(category);
  }
}
```

**View层特点**：
- ✅ 只负责UI渲染和用户交互
- ✅ 通过Provider订阅状态
- ✅ 通过Provider.notifier调用行为
- ✅ 无业务逻辑

## 🔄 数据流向

### 单向数据流

```
User Action → ViewModel.method() → State Change → View Update
     ↑                                              ↓
     └──────────────── UI Feedback ←───────────────┘
```

### 具体示例：选择类目

1. **用户操作**：点击左侧三级类目
2. **事件处理**：`onTap: () => ref.read(categoryViewModelProvider.notifier).selectThirdCategory(category)`
3. **业务逻辑**：`CategoryViewModel.selectThirdCategory()` 执行
4. **状态更新**：`state = state.copyWith(selectedThirdCategory: category, ...)`
5. **UI更新**：所有订阅该状态的Widget自动重建

## 🎨 设计模式应用

### 1. 观察者模式（Observer Pattern）
- **实现**：Riverpod的Provider系统
- **作用**：View自动响应ViewModel状态变化

### 2. 命令模式（Command Pattern）
- **实现**：ViewModel的方法调用
- **作用**：封装用户操作为可执行命令

### 3. 工厂模式（Factory Pattern）
- **实现**：Provider的创建函数
- **作用**：统一管理对象创建

### 4. 计算属性模式（Computed Property Pattern）
- **实现**：派生Providers
- **作用**：提供细粒度的状态访问

## 📊 不同场景的文件组织策略

### 场景一：简单页面
**适用**：设置页面、关于页面等
```
lib/
├── models/simple_model.dart
└── providers/simple_provider.dart  # State + Notifier 同文件
```

### 场景二：中等复杂度（推荐）
**适用**：用户认证、商品列表等
```
lib/
├── models/user_model.dart
├── viewmodels/auth_viewmodel.dart  # State + Notifier 同文件
└── providers/auth_provider.dart    # 只有Provider声明
```

### 场景三：复杂业务模块
**适用**：电商系统、内容管理等
```
lib/
├── models/
│   ├── product.dart
│   └── category.dart
├── viewmodels/
│   ├── product_list_viewmodel.dart
│   ├── product_detail_viewmodel.dart
│   └── category_viewmodel.dart
├── providers/
│   ├── product_providers.dart
│   └── category_providers.dart
└── services/
    ├── product_service.dart
    └── category_service.dart
```

## 🧪 测试策略

### 1. Model 测试
```dart
test('Category model should serialize correctly', () {
  final category = Category(id: '1', name: 'Test', level: 3);
  final json = category.toJson();
  final restored = Category.fromJson(json);
  expect(restored, equals(category));
});
```

### 2. ViewModel 测试
```dart
test('should load categories on initialization', () async {
  final container = ProviderContainer();
  await Future.delayed(const Duration(milliseconds: 600));
  
  final state = container.read(categoryViewModelProvider);
  expect(state.isLoading, false);
  expect(state.thirdLevelCategories.isNotEmpty, true);
});
```

### 3. Provider 测试
```dart
test('selectedThirdCategoryProvider should return correct category', () {
  final container = ProviderContainer();
  final selectedCategory = container.read(selectedThirdCategoryProvider);
  expect(selectedCategory, isNotNull);
});
```

## 🚀 性能优化

### 1. 细粒度状态订阅
```dart
// ❌ 不好：订阅整个状态
final state = ref.watch(categoryViewModelProvider);

// ✅ 好：只订阅需要的部分
final isLoading = ref.watch(isLoadingCategoriesProvider);
```

### 2. 计算属性缓存
```dart
final filteredCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(thirdLevelCategoriesProvider);
  final searchTerm = ref.watch(searchTermProvider);
  
  // Riverpod会自动缓存计算结果
  return categories.where((cat) => 
    cat.name.toLowerCase().contains(searchTerm.toLowerCase())
  ).toList();
});
```

### 3. 避免不必要的重建
```dart
// 使用Consumer包装需要更新的部分
Consumer(
  builder: (context, ref, child) {
    final isLoading = ref.watch(isLoadingCategoriesProvider);
    return isLoading ? CircularProgressIndicator() : child!;
  },
  child: ExpensiveWidget(), // 不会重建
)
```

## 📝 最佳实践总结

### ✅ 推荐做法

1. **职责分离**：严格按照MVVM分层
2. **命名规范**：使用清晰的命名约定
3. **状态不可变**：使用copyWith模式
4. **细粒度订阅**：创建计算属性Providers
5. **错误处理**：在ViewModel层统一处理
6. **测试覆盖**：为每一层编写测试

### ❌ 避免做法

1. **在View中写业务逻辑**
2. **在Model中包含UI状态**
3. **直接修改状态对象**
4. **过度订阅（订阅不需要的状态）**
5. **在Provider中写业务逻辑**
6. **忽略错误处理**

## 🔧 迁移指南

### 从现有代码迁移到MVVM

1. **提取Model**：将数据结构移到models目录
2. **创建ViewModel**：将业务逻辑移到viewmodels目录
3. **重构Provider**：只保留Provider声明
4. **更新View**：使用新的Provider结构
5. **添加测试**：为每一层添加测试

### 向后兼容

```dart
// 保持向后兼容的别名
/// @deprecated 使用 categoryViewModelProvider 替代
final categoryProvider = categoryViewModelProvider;
```

## 📚 相关资源

- [Riverpod官方文档](https://riverpod.dev/)
- [Flutter架构指南](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [MVVM设计模式](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

---

**最后更新**：2024年12月
**适用版本**：Flutter 3.x, Riverpod 2.x
