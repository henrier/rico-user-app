# SPU选择页面功能文档

## 概述

SPU选择页面是一个基于Figma设计实现的商品浏览和选择界面，采用MVVM架构模式。用户从类目选择页面点击四级类目后，会携带类目ID跳转到此页面，根据类目ID查询并展示对应的SPU列表。

## 页面结构

### 1. 顶部导航栏
- **返回按钮**: 左上角箭头图标，返回类目选择页面
- **页面标题**: 居中显示"Item List"
- **功能按钮**: 
  - 相机图标（占位功能）
  - 搜索图标，点击弹出SPU搜索对话框

### 2. 分类筛选区域
- **Singles标签**: 单卡商品分类
- **Sealed Products标签**: 密封商品分类
- **筛选按钮**: 右侧Filter按钮，支持高级筛选

### 3. SPU列表区域
- **SPU项目**: 每个SPU包含图片、名称、编码、等级和标签
- **分页加载**: 支持下拉刷新和滚动加载更多
- **空状态**: 当无SPU时显示友好的空状态界面

## 技术架构

### MVVM架构组件

#### 1. ViewModel (`SpuSelectionViewModel`)
- **状态管理**: 管理SPU列表、分页、筛选等状态
- **业务逻辑**: 处理SPU加载、搜索、筛选等业务操作
- **类目筛选**: 根据传入的类目ID筛选SPU数据
- **数据流控制**: 协调View和Model之间的数据流

#### 2. Provider (`ProductInfoProvider`)
- **数据获取**: 封装API调用和数据获取逻辑
- **缓存管理**: 提供SPU数据的缓存机制
- **状态提供**: 为UI组件提供响应式数据状态

#### 3. View (`SpuSelectionScreen`)
- **UI渲染**: 负责页面UI的渲染和用户交互
- **事件处理**: 处理用户点击、滚动等交互事件
- **状态响应**: 响应ViewModel状态变化更新UI

### 核心组件

#### 1. `SpuSelectionViewModel` - 状态管理
```dart
// 初始化时传入类目ID
SpuSelectionViewModel(productInfoService, categoryId);

// 根据类目ID加载SPU
await viewModel.loadSpuList(refresh: true);

// 搜索SPU
viewModel.searchSpu(keyword);
```

#### 2. `SpuSelectionScreen` - 页面组件
```dart
SpuSelectionScreen(
  categoryId: categoryId, // 必需的类目ID
)
```

#### 3. `ProductInfoService` - API服务
```dart
// 根据类目ID分页查询SPU
final params = ProductInfoPageParams(
  categories: [categoryId], // 类目筛选
);
final pageData = await service.getProductInfoPage(params);
```

## 导航流程

### 1. 从类目选择页面跳转
```dart
// 在CategorySelectionScreen中
void _navigateToSpuSelection(BuildContext context, ProductCategory category) {
  context.go('/home/spu-selection?categoryId=${category.id}');
}
```

### 2. 路由配置
```dart
GoRoute(
  path: 'spu-selection',
  name: 'spu-selection',
  builder: (context, state) {
    final categoryId = state.uri.queryParameters['categoryId'];
    return SpuSelectionScreenWrapper(categoryId: categoryId);
  },
),
```

### 3. 参数验证
- 路由会验证categoryId参数是否存在
- 如果缺少categoryId，显示错误提示页面
- 确保SPU选择页面始终有有效的类目上下文

## 主要功能

### 1. 基于类目的SPU筛选
- 页面初始化时根据类目ID自动筛选SPU
- 只显示属于指定类目的SPU商品
- 支持类目层级的精确筛选

### 2. SPU分类切换
- 支持Singles和Sealed Products两种商品类型
- 切换时在类目筛选基础上进一步过滤
- 选中状态有明显的视觉反馈

### 3. SPU搜索
- 支持按SPU名称和编码搜索
- 搜索范围限定在当前类目内
- 实时搜索结果展示

### 4. 高级筛选
- 支持按等级、语言等条件筛选
- 筛选条件与类目筛选叠加
- 筛选条件持久化和清除功能

### 5. 分页加载
- 下拉刷新重新加载数据
- 滚动到底部自动加载更多
- 加载状态指示器

### 6. SPU选择
- 点击SPU项目显示详情对话框
- 支持SPU选择确认
- 选择结果回调处理

## 使用方法

### 1. 从类目选择页面导航
```dart
// 用户点击四级类目时自动跳转
onTap: () {
  _navigateToSpuSelection(context, category);
}
```

### 2. 直接导航（需要类目ID）
```dart
// 直接导航到SPU选择页面
context.go('/home/spu-selection?categoryId=your_category_id');
```

### 3. 在代码中使用ViewModel
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spuSelectionViewModelProvider(categoryId));
    final viewModel = ref.read(spuSelectionViewModelProvider(categoryId).notifier);
    
    return Column(
      children: [
        // 显示SPU数量
        Text('共${state.total}个SPU'),
        
        // 刷新按钮
        ElevatedButton(
          onPressed: () => viewModel.refresh(),
          child: Text('刷新'),
        ),
      ],
    );
  }
}
```

## 数据筛选逻辑

### 1. 类目筛选（主要）
```dart
ProductInfoPageParams(
  categories: [categoryId], // 根据传入的类目ID筛选
)
```

### 2. 商品类型筛选（次要）
- Singles类型：在类目基础上进一步筛选单卡商品
- Sealed Products类型：在类目基础上进一步筛选密封商品

### 3. 搜索筛选（可选）
```dart
ProductInfoPageParams(
  categories: [categoryId],
  nameEnglish: searchKeyword,
  nameChinese: searchKeyword,
)
```

### 4. 高级筛选（可选）
```dart
ProductInfoPageParams(
  categories: [categoryId],
  level: selectedLevel,
  // 其他筛选条件...
)
```

## 状态管理

### 1. SpuSelectionViewModelState
```dart
class SpuSelectionViewModelState {
  final List<ProductInfo> spuList;      // SPU列表
  final String? categoryId;             // 类目ID
  final ProductType selectedType;       // 选中的商品类型
  final String searchKeyword;           // 搜索关键词
  final SpuSelectionFilter filter;      // 筛选条件
  // ...其他状态
}
```

### 2. 状态更新流程
1. 页面初始化 → 根据categoryId加载SPU
2. 用户切换类型 → 在类目基础上重新筛选
3. 用户搜索 → 在类目基础上搜索SPU
4. 用户筛选 → 应用多重筛选条件

## 配置说明

### 1. API配置
```dart
// 在ProductInfoService中配置
static const String _baseUrl = 'http://localhost:8081';
static const String _apiPath = '/api/products/product-infos';
```

### 2. 分页配置
```dart
const SpuSelectionViewModelState({
  this.pageSize = 20,        // 每页大小
  this.currentPage = 1,      // 当前页码
});
```

### 3. 路由配置
```dart
// 在app_router.dart中
GoRoute(
  path: 'spu-selection',
  name: 'spu-selection',
  // ...
)
```

## 扩展功能

### 1. 添加新的筛选条件
1. 在`SpuSelectionFilter`中添加新的筛选字段
2. 在`SpuSelectionViewModel`中添加对应的处理逻辑
3. 在UI中添加筛选控件

### 2. 自定义SPU项目布局
1. 继承`ProductInfoItem`创建自定义组件
2. 重写`build`方法实现自定义布局
3. 在列表中使用自定义组件

### 3. 添加SPU操作功能
1. 在`ProductInfoItem`中添加操作按钮
2. 在ViewModel中添加操作方法
3. 在Service中添加对应的API调用

## 注意事项

1. **类目依赖**: SPU选择页面必须有有效的类目ID才能正常工作
2. **内存管理**: 大量SPU数据可能导致内存问题，建议实现虚拟化列表
3. **网络优化**: 图片加载应该使用缓存和占位符
4. **错误处理**: 网络错误和数据错误需要友好的用户提示
5. **性能优化**: 列表滚动性能需要优化，避免频繁重建Widget
6. **用户体验**: 加载状态、空状态、错误状态都需要良好的视觉反馈

## 相关文件

- `lib/screens/product/spu_selection_screen.dart` - 主页面
- `lib/viewmodels/spu_selection_viewmodel.dart` - ViewModel
- `lib/providers/product_info_provider.dart` - Provider
- `lib/widgets/product_info_item.dart` - SPU项目组件
- `lib/models/productinfo/data.dart` - 数据模型
- `lib/models/productinfo/service.dart` - API服务
- `lib/routes/app_router.dart` - 路由配置
- `lib/screens/category/category_selection_screen.dart` - 类目选择页面（入口）
