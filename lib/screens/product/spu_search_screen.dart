import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 搜索框区域
          _buildSearchArea(),
          // 筛选栏（始终显示）
          _buildFilterBar(),
          // 分隔线
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          // 内容区域
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Search Products',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 构建筛选栏（右侧Filter图标+文字）
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _showFilterDialog(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.filter_alt_outlined,
              size: 18,
              color: Colors.black,
            ),
            SizedBox(width: 6),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索区域
  Widget _buildSearchArea() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  // 搜索图标
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search for products...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      onSubmitted: (_) => _performSearch(),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  // 清空按钮
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16, left: 8),
                        child: Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 搜索按钮
          GestureDetector(
            onTap: _performSearch,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 取消按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
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

  /// 构建无结果状态
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 空盒子图标 - 模拟Figma设计中的图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 盒子主体
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFFB8B8B8),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // 盒子盖子
                Positioned(
                  top: 25,
                  child: Container(
                    width: 86,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFFB8B8B8),
                        width: 3,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                // 盒子把手
                Positioned(
                  top: 15,
                  child: Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFFB8B8B8),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                // 装饰星星
                Positioned(
                  top: 10,
                  right: 10,
                  child: Text(
                    '✦',
                    style: TextStyle(
                      color: const Color(0xFFB8B8B8),
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 5,
                  child: Text(
                    '✦',
                    style: TextStyle(
                      color: const Color(0xFFB8B8B8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // "No matching items" 文本
          const Text(
            'No matching items',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF919191),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults(SpuSearchState state) {
    return RefreshIndicator(
      onRefresh: () async {
        final viewModel = ref.read(spuSearchViewModelProvider.notifier);
        await viewModel.refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: state.productList.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 加载更多指示器
          if (index == state.productList.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = state.productList[index];
          return ProductInfoItem(
            productInfo: product,
            showDivider: index < state.productList.length - 1,
            onTap: () => _onProductTap(product),
          );
        },
      ),
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

      // 显示筛选对话框
      final result = await showSpuSelectFilter(
        context,
        sections: sections,
        title: 'Filtering',
        clearText: 'Clear',
        confirmText: 'Confirm',
      );

      if (result != null) {
        // 处理筛选结果
        final selectedLevels = result['Level'] ?? <String>{};
        
        // 检查是否是清空操作
        final isClearing = selectedLevels.isEmpty;
        
        // 显示筛选结果反馈
        final selectedCount = result.values.fold<int>(0, (sum, set) => sum + set.length);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(selectedCount > 0 
                ? '已应用 $selectedCount 个筛选条件'
                : '已清除所有筛选条件'),
              duration: const Duration(seconds: 2),
              backgroundColor: selectedCount > 0 ? Colors.green : Colors.orange,
            ),
          );
        }

        // TODO: 这里可以根据筛选结果重新搜索
        // 例如：将筛选条件传递给搜索ViewModel进行筛选搜索
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
