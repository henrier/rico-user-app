import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../models/productinfo/data.dart';
import '../../viewmodels/spu_selection_viewmodel.dart';
import '../../widgets/product_info_item.dart';

/// SPU选择页面
/// 对应Figma设计中的"商品目录 - 按步骤点击 - 展示 Singles"页面
class SpuSelectionScreen extends ConsumerStatefulWidget {
  /// 类目ID，用于筛选特定类目的SPU
  final String categoryId;

  const SpuSelectionScreen({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<SpuSelectionScreen> createState() => _SpuSelectionScreenState();
}

class _SpuSelectionScreenState extends ConsumerState<SpuSelectionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 滚动监听，实现分页加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final viewModel =
          ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spuSelectionViewModelProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 分类筛选区域
          _buildCategoryTabs(),
          // 分隔线
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          // SPU列表
          Expanded(
            child: _buildSpuList(state),
          ),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Item List',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // 相机图标（占位）
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('相机功能开发中')),
            );
          },
        ),
        // 搜索图标
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () => context.push('/home/spu-search'),
        ),
      ],
    );
  }

  /// 构建分类标签区域
  Widget _buildCategoryTabs() {
    final state = ref.watch(spuSelectionViewModelProvider(widget.categoryId));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Singles标签
          _buildCategoryTab(
            ProductType.singles,
            state.selectedType == ProductType.singles,
          ),
          const SizedBox(width: 16),
          // Sealed Products标签
          _buildCategoryTab(
            ProductType.sealedProducts,
            state.selectedType == ProductType.sealedProducts,
          ),
          const Spacer(),
          // 筛选按钮
          _buildFilterButton(state.filter.hasFilters),
        ],
      ),
    );
  }

  /// 构建单个分类标签
  Widget _buildCategoryTab(ProductType type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final viewModel =
            ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
        viewModel.selectProductType(type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[400] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          type.displayName,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建筛选按钮
  Widget _buildFilterButton(bool hasActiveFilters) {
    return GestureDetector(
      onTap: () => _showFilterDialog(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tune,
            size: 17,
            color: hasActiveFilters ? Colors.blue : Colors.black,
          ),
          const SizedBox(width: 4),
          Text(
            'Filter',
            style: TextStyle(
              fontSize: 14,
              color: hasActiveFilters ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建SPU列表
  Widget _buildSpuList(SpuSelectionViewModelState state) {
    if (state.spuList.isEmpty) {
      return const ProductInfoEmptyState(
        message: '暂无SPU信息',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final viewModel =
            ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
        await viewModel.refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: state.spuList.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 加载更多指示器
          if (index == state.spuList.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final spu = state.spuList[index];
          return ProductInfoItem(
            productInfo: spu,
            showDivider: index < state.spuList.length - 1,
            onTap: () => _onSpuTap(spu),
          );
        },
      ),
    );
  }

  /// SPU项目点击处理
  void _onSpuTap(ProductInfo spu) {
    final viewModel =
        ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
    viewModel.selectSpu(spu);

    // 显示选择确认对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('SPU选择'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SPU名称: ${spu.displayName}'),
              const SizedBox(height: 8),
              Text('SPU编码: ${spu.code}'),
              if (spu.level.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('SPU等级: ${spu.level}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 这里可以添加选择SPU后的逻辑
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已选择: ${spu.displayName}')),
                );
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }


  /// 显示筛选对话框
  void _showFilterDialog() {
    final state = ref.read(spuSelectionViewModelProvider(widget.categoryId));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('筛选条件'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('筛选功能开发中...'),
              const SizedBox(height: 16),
              if (state.filter.hasFilters)
                ElevatedButton(
                  onPressed: () {
                    final viewModel = ref.read(
                        spuSelectionViewModelProvider(widget.categoryId)
                            .notifier);
                    viewModel.clearFilter();
                    Navigator.of(context).pop();
                  },
                  child: const Text('清除筛选'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}

/// SPU选择页面错误处理包装器
class SpuSelectionScreenWrapper extends ConsumerWidget {
  final String categoryId;

  const SpuSelectionScreenWrapper({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpuSelectionScreen(categoryId: categoryId);
  }
}
