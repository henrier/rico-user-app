# 商品类目选择功能

## 功能概述

这是一个商品类目选择页面，实现了三级和四级类目的层级选择功能。页面采用左右分栏布局，左侧显示三级类目，右侧显示选中三级类目下的四级类目。

## 技术架构

### MVVM 架构
- **Model**: `Category` 数据模型和 `CategoryState` 状态模型
- **View**: `CategorySelectionScreen` UI界面
- **ViewModel**: `CategoryNotifier` 状态管理器

### 状态管理
- 使用 **Riverpod + StateNotifier** 进行状态管理
- 响应式数据流，自动更新UI

## 文件结构

```
lib/
├── models/
│   └── category_model.dart          # 类目数据模型
├── common/data/
│   └── mock_categories.dart         # 模拟数据
├── providers/
│   └── category_provider.dart       # 状态管理
├── screens/category/
│   └── category_selection_screen.dart # 类目选择页面
└── routes/
    └── app_router.dart              # 路由配置
```

## 主要功能

### 1. 类目数据模型 (`Category`)
- `id`: 类目唯一标识
- `name`: 类目名称
- `parentId`: 父类目ID（四级类目使用）
- `level`: 类目层级（3或4）
- `children`: 子类目列表

### 2. 状态管理 (`CategoryNotifier`)
- `_loadCategories()`: 加载类目数据
- `selectThirdCategory()`: 选择三级类目
- `refresh()`: 刷新数据
- `clearError()`: 清除错误状态

### 3. UI界面特性
- 左右分栏布局，比例为2:3
- 左侧三级类目列表，支持选中高亮
- 右侧四级类目列表，动态更新
- 点击四级类目显示确认弹窗
- 加载状态和错误处理
- 符合Material Design规范

## 数据流

1. 页面初始化 → 加载三级类目数据
2. 默认选中第一个三级类目 → 加载对应四级类目
3. 用户点击三级类目 → 更新选中状态 → 加载新的四级类目
4. 用户点击四级类目 → 显示确认弹窗（包含类目ID）

## 使用方式

### 1. 从首页进入
在首页的 Quick Actions 中点击 "Category Selection" 卡片

### 2. 路由访问
```dart
context.go('/home/categories');
```

### 3. 状态监听
```dart
// 监听类目状态
final categoryState = ref.watch(categoryProvider);

// 监听选中的三级类目
final selectedCategory = ref.watch(selectedThirdCategoryProvider);

// 监听四级类目列表
final fourthLevelCategories = ref.watch(fourthLevelCategoriesProvider);
```

## 测试

运行单元测试：
```bash
flutter test test/unit/category_provider_test.dart
```

## 扩展功能

### 待实现功能
1. 搜索功能
2. 类目图标显示
3. 类目数量统计
4. 收藏类目功能
5. 最近浏览记录

### 数据源扩展
当前使用模拟数据，可以轻松替换为：
- REST API 数据源
- GraphQL 数据源
- 本地数据库
- 缓存机制

## 设计参考

页面设计参考了Figma原型图，实现了：
- 简洁的分栏布局
- 清晰的视觉层次
- 合适的间距和分隔线
- 高亮选中状态
- 响应式交互效果
