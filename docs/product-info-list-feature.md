# 商品信息列表页面功能文档

## 概述

商品信息列表页面是一个基于Figma设计实现的商品浏览和选择界面，采用MVVM架构模式，提供了完整的商品信息展示、筛选、搜索和分页功能。

## 页面结构

### 1. 顶部导航栏
- **返回按钮**: 左上角箭头图标，返回上一页
- **页面标题**: 居中显示"Item List"
- **功能按钮**: 
  - 相机图标（占位功能）
  - 搜索图标，点击弹出搜索对话框

### 2. 分类筛选区域
- **Singles标签**: 单卡商品分类
- **Sealed Products标签**: 密封商品分类
- **筛选按钮**: 右侧Filter按钮，支持高级筛选

### 3. 商品列表区域
- **商品项目**: 每个商品包含图片、名称、编码、等级和标签
- **分页加载**: 支持下拉刷新和滚动加载更多
- **空状态**: 当无商品时显示友好的空状态界面

## 技术架构

### MVVM架构组件

#### 1. ViewModel (`ProductInfoViewModel`)
- **状态管理**: 管理商品列表、分页、筛选等状态
- **业务逻辑**: 处理商品加载、搜索、筛选等业务操作
- **数据流控制**: 协调View和Model之间的数据流

#### 2. Provider (`ProductInfoProvider`)
- **数据获取**: 封装API调用和数据获取逻辑
- **缓存管理**: 提供商品数据的缓存机制
- **状态提供**: 为UI组件提供响应式数据状态

#### 3. View (`ProductInfoListScreen`)
- **UI渲染**: 负责页面UI的渲染和用户交互
- **事件处理**: 处理用户点击、滚动等交互事件
- **状态响应**: 响应ViewModel状态变化更新UI

### 核心组件

#### 1. `ProductInfoItem` - 商品项目组件
```dart
ProductInfoItem(
  productInfo: productInfo,
  showDivider: true,
  onTap: () => _onProductInfoTap(productInfo),
)
```

#### 2. `ProductInfoViewModel` - 状态管理
```dart
// 切换商品类型
viewModel.selectProductType(ProductType.singles);

// 搜索商品
viewModel.searchProducts(keyword);

// 应用筛选
viewModel.applyFilter(filter);
```

#### 3. `ProductInfoService` - API服务
```dart
// 分页查询商品
final pageData = await service.getProductInfoPage(params);

// 获取商品详情
final productInfo = await service.getProductInfoDetail(id);
```

## 主要功能

### 1. 商品分类切换
- 支持Singles和Sealed Products两种商品类型
- 切换时自动重新加载对应类型的商品数据
- 选中状态有明显的视觉反馈

### 2. 商品搜索
- 支持按商品名称和编码搜索
- 实时搜索结果展示
- 搜索历史和建议（待实现）

### 3. 高级筛选
- 支持按等级、类目、语言等条件筛选
- 筛选条件持久化
- 清除筛选功能

### 4. 分页加载
- 下拉刷新重新加载数据
- 滚动到底部自动加载更多
- 加载状态指示器

### 5. 商品选择
- 点击商品项目显示详情对话框
- 支持商品选择确认
- 选择结果回调处理

## 使用方法

### 1. 导航到商品列表页面
```dart
// 从其他页面导航
context.go('/home/products');

// 带类目ID参数导航
context.go('/home/products?categoryId=your_category_id');
```

### 2. 在代码中使用ViewModel
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productInfoViewModelProvider('categoryId'));
    final viewModel = ref.read(productInfoViewModelProvider('categoryId').notifier);
    
    return Column(
      children: [
        // 显示商品数量
        Text('共${state.total}个商品'),
        
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

### 3. 自定义商品项目组件
```dart
ProductInfoItem(
  productInfo: productInfo,
  showDivider: false,
  onTap: () {
    // 自定义点击处理
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ProductDetailScreen(productInfo: productInfo),
    ));
  },
)
```

## 配置说明

### 1. API配置
在`ProductInfoService`中配置后端API地址：
```dart
static const String _baseUrl = 'http://localhost:8081';
static const String _apiPath = '/api/products/product-infos';
```

### 2. 分页配置
在`ProductInfoViewModelState`中配置分页参数：
```dart
final int pageSize; // 每页大小，默认20
final int currentPage; // 当前页码
```

### 3. 缓存配置
在`ProductInfoCacheNotifier`中配置缓存策略：
```dart
bool isCacheExpired({Duration maxAge = const Duration(minutes: 5)})
```

## 扩展功能

### 1. 添加新的筛选条件
1. 在`ProductInfoFilter`中添加新的筛选字段
2. 在`ProductInfoViewModel`中添加对应的处理逻辑
3. 在UI中添加筛选控件

### 2. 自定义商品项目布局
1. 继承`ProductInfoItem`创建自定义组件
2. 重写`build`方法实现自定义布局
3. 在列表中使用自定义组件

### 3. 添加商品操作功能
1. 在`ProductInfoItem`中添加操作按钮
2. 在ViewModel中添加操作方法
3. 在Service中添加对应的API调用

## 注意事项

1. **内存管理**: 大量商品数据可能导致内存问题，建议实现虚拟化列表
2. **网络优化**: 图片加载应该使用缓存和占位符
3. **错误处理**: 网络错误和数据错误需要友好的用户提示
4. **性能优化**: 列表滚动性能需要优化，避免频繁重建Widget
5. **用户体验**: 加载状态、空状态、错误状态都需要良好的视觉反馈

## 相关文件

- `lib/screens/product/product_info_list_screen.dart` - 主页面
- `lib/viewmodels/product_info_viewmodel.dart` - ViewModel
- `lib/providers/product_info_provider.dart` - Provider
- `lib/widgets/product_info_item.dart` - 商品项目组件
- `lib/models/productinfo/data.dart` - 数据模型
- `lib/models/productinfo/service.dart` - API服务
- `lib/routes/app_router.dart` - 路由配置
