import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/constants/app_constants.dart';
import '../../models/productinfo/data.dart';
import '../../models/productinfo/service.dart';
import '../../viewmodels/spu_search_viewmodel.dart';
import '../../widgets/product_info_item.dart';
import '../../widgets/spu_select_filter.dart';

/// SPU搜索页面
/// 对应Figma设计中的搜索界面
class SpuSearchScreen extends ConsumerStatefulWidget {
  const SpuSearchScreen({super.key});

  @override
  ConsumerState<SpuSearchScreen> createState() => _SpuSearchScreenState();
}

class _SpuSearchScreenState extends ConsumerState<SpuSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {}); // 更新UI以显示/隐藏清空按钮
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 滚动监听，实现分页加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final viewModel = ref.read(spuSearchViewModelProvider.notifier);
      viewModel.loadMore();
    }
  }

  /// 执行搜索
  void _performSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      final viewModel = ref.read(spuSearchViewModelProvider.notifier);
      viewModel.searchProducts(keyword);
      _searchFocusNode.unfocus(); // 隐藏键盘
    }
  }

  /// 清空搜索
  void _clearSearch() {
    _searchController.clear();
    final viewModel = ref.read(spuSearchViewModelProvider.notifier);
    viewModel.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spuSearchViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopNavigationBar(),
            // 搜索框区域
            _buildSearchArea(),
            // 筛选栏（仅在有查询时显示）
            if (!state.isEmpty) _buildFilterBar(),
            // 分隔线
            Container(
              height: 20.h,
              color: const Color(0xFFF1F1F3),
            ),
            // 内容区域
            Expanded(
              child: Container(
                color: const Color(0xFFF4F4F6),
                child: _buildContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏 - 根据Figma设计
  Widget _buildTopNavigationBar() {
    return Container(
      height: 88.h,
      color: Colors.white,
      child: Stack(
        children: [
          // 返回按钮
          Positioned(
            left: 26.w,
            top: 24.h,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF212222),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选栏 - 根据Figma设计
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      height: 88.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _showFilterDialog(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 30.w,
              color: const Color(0xFF212222),
            ),
            SizedBox(width: 8.w),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF212222),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索区域 - 根据Figma设计
  Widget _buildSearchArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 72.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(59.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 搜索图标
                  Padding(
                    padding: EdgeInsets.only(left: 24.w, right: 12.w),
                    child: Icon(
                      Icons.search,
                      color: const Color(0xFF212222),
                      size: 30.w,
                    ),
                  ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search for products...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF212222),
                          fontSize: 28.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20.h),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: const Color(0xFF212222),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                      onSubmitted: (_) => _performSearch(),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Search按钮
          GestureDetector(
            onTap: _performSearch,
            child: Container(
              height: 72.h,
              width: 142.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(59.r),
              ),
              child: Center(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: const Color(0xFF212222),
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(SpuSearchState state) {
    // 初始状态（未搜索）
    if (state.isEmpty) {
      return _buildEmptyState();
    }

    // 错误状态
    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    // 搜索结果为空
    if (!state.isLoading && state.productList.isEmpty) {
      return _buildNoResultsState();
    }

    // 显示搜索结果
    return _buildSearchResults(state);
  }

  /// 构建空状态（未搜索）
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 搜索图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search,
              size: 48,
              color: Color(0xFFB8B8B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Search for Products',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF919191),
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter product name or code to search',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB8B8B8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Search Failed',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final viewModel = ref.read(spuSearchViewModelProvider.notifier);
              viewModel.refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// 构建无结果状态 - 根据Figma设计
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 空盒子图标 - 根据Figma设计
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 盒子主体
                Container(
                  width: 140.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFF919191),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                // 盒子盖子
                Positioned(
                  top: 40.h,
                  child: Container(
                    width: 150.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF919191),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                // 盒子把手
                Positioned(
                  top: 25.h,
                  child: Container(
                    width: 30.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF919191),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                // 装饰星星
                Positioned(
                  top: 15.h,
                  right: 15.w,
                  child: Text(
                    '✦',
                    style: TextStyle(
                      color: const Color(0xFF919191),
                      fontSize: 24.sp,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.h,
                  left: 10.w,
                  child: Text(
                    '✦',
                    style: TextStyle(
                      color: const Color(0xFF919191),
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          // "No matching items" 文本
          Text(
            'No matching items',
            style: TextStyle(
              fontSize: 28.sp,
              color: const Color(0xFF919191),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果列表 - 根据Figma设计，保持与现有功能兼容
  Widget _buildSearchResults(SpuSearchState state) {
    return RefreshIndicator(
      onRefresh: () async {
        final viewModel = ref.read(spuSearchViewModelProvider.notifier);
        await viewModel.refresh();
      },
      color: const Color(0xFF00D86F),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: state.productList.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) {
          // 确保分隔线不会在加载更多指示器前显示
          if (index >= state.productList.length - 1) {
            return const SizedBox.shrink();
          }
          return Container(
            height: 0.5.h,
            color: const Color(0xFFF1F1F3),
          );
        },
        itemBuilder: (context, index) {
          // 加载更多指示器
          if (index == state.productList.length) {
            return Container(
              padding: EdgeInsets.all(16.h),
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF00D86F),
                ),
              ),
            );
          }

          final product = state.productList[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  /// 构建商品卡片 - 根据Figma设计
  Widget _buildProductCard(ProductInfo product) {
    return GestureDetector(
      onTap: () => _onProductTap(product),
      child: Container(
        height: 274.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Row(
          children: [
            // 商品图片
            _buildProductImage(product),
            SizedBox(width: 24.w),
            // 商品信息
            Expanded(
              child: _buildProductInfo(product),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建商品图片
  Widget _buildProductImage(ProductInfo product) {
    return Container(
      width: 154.w,
      height: 214.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: product.hasImages
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholderImage();
                },
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: 60.w,
        ),
      ),
    );
  }

  /// 构建商品信息
  Widget _buildProductInfo(ProductInfo product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 商品名称
        Text(
          product.displayName,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212222),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 8.h),
        
        // 商品编码和类型信息
        Row(
          children: [
            Text(
              product.code,
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF919191),
              ),
            ),
            if (product.level.isNotEmpty || product.cardLanguage.value.isNotEmpty) ...[
              Container(
                width: 2.w,
                height: 19.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                color: const Color(0xFF919191),
              ),
              if (product.level.isNotEmpty)
                Text(
                  product.level,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: const Color(0xFF919191),
                  ),
                )
              else if (product.cardLanguage.value.isNotEmpty)
                Text(
                  product.cardLanguage.value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: const Color(0xFF919191),
                  ),
                ),
            ],
          ],
        ),
        
        const Spacer(),
        
        // 底部标签区域
        _buildProductTags(product),
      ],
    );
  }

  /// 构建商品标签
  Widget _buildProductTags(ProductInfo product) {
    return Row(
      children: [
        // 类目标签 - 显示第一个类目名称，如果没有则显示默认值
        if (product.categories.isNotEmpty || true) // 总是显示至少一个标签
          Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD3D3D3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                product.categories.isNotEmpty 
                  ? (product.categories.first.displayName ?? product.categories.first.name.toString())
                  : 'Pokémon', // 默认值
                style: TextStyle(
                  fontSize: 22.sp,
                  color: const Color(0xFF919191),
                ),
              ),
            ),
          ),
        
        // 语言标签 - 仅在有卡片语言时显示
        if (product.cardLanguage.value.isNotEmpty) ...[
          SizedBox(width: 12.w),
          Container(
            height: 36.h,
            width: 44.w,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD3D3D3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                product.cardLanguage.value,
                style: TextStyle(
                  fontSize: 22.sp,
                  color: const Color(0xFF919191),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 商品项点击处理
  void _onProductTap(ProductInfo product) {
    // 显示商品详情对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${product.displayName}'),
              const SizedBox(height: 8),
              Text('Code: ${product.code}'),
              if (product.level.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Level: ${product.level}'),
              ],
              if (product.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Categories: ${product.categories.map((c) => c.name).join(', ')}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 这里可以添加选择商品后的逻辑
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: ${product.displayName}')),
                );
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  /// 显示筛选对话框
  void _showFilterDialog() async {
    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 调用服务获取动态数据
      final productInfoService = ProductInfoService();
      final distinctLevels = await productInfoService.getProductInfoDistinctLevels();
      
      // 关闭加载指示器
      if (mounted) Navigator.of(context).pop();

      // 构建筛选选项
      final sections = [
        // 等级筛选（动态数据）
        SpuSelectFilterSection(
          title: 'Level',
          options: distinctLevels.map((level) => 
            SpuSelectFilterOption(id: level, label: level)
          ).toList(),
        ),
      ];

      // 获取当前的筛选状态
      final currentState = ref.read(spuSearchViewModelProvider);
      final currentFilterConditions = currentState.filterConditions;

      // 显示筛选对话框，传入当前筛选状态
      final result = await showSpuSelectFilter(
        context,
        sections: sections,
        initialSelections: currentFilterConditions,
        title: 'Filtering',
        clearText: 'Clear',
        confirmText: 'Confirm',
      );

      if (result != null) {
        // 处理筛选结果
        final selectedLevels = result['Level'] ?? <String>{};
        
        // 显示筛选结果反馈
        final selectedCount = result.values.fold<int>(0, (sum, set) => sum + set.length);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(selectedCount > 0 
                ? '正在应用 $selectedCount 个筛选条件...'
                : '已清除所有筛选条件，重新搜索...'),
              duration: const Duration(seconds: 1),
              backgroundColor: selectedCount > 0 ? Colors.blue : Colors.orange,
            ),
          );
        }

        // 应用筛选条件并重新搜索
        final viewModel = ref.read(spuSearchViewModelProvider.notifier);
        await viewModel.applyFilter(result);
        
        // 显示完成反馈
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(selectedCount > 0 
                ? '筛选完成！找到符合条件的商品'
                : '已重新搜索所有结果'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // 关闭加载指示器
      if (mounted) Navigator.of(context).pop();
      
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载筛选选项失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
