import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/productinfo/data.dart';
import '../../models/productinfo/service.dart';
import '../../viewmodels/spu_selection_viewmodel.dart';
import '../../widgets/spu_select_filter.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // 分类筛选区域
            _buildCategoryTabs(),
            // SPU列表
            Expanded(
              child: _buildSpuList(state),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[700],
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: Text(
        'SPU选择',
        style: TextStyle(
          color: Colors.grey[900],
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        // 相机图标
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.grey[600],
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('相机功能开发中'),
                  backgroundColor: Colors.grey[800],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            padding: EdgeInsets.zero,
          ),
        ),
        // 搜索图标
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
            onPressed: () => context.pushNamed('spu-search'),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  /// 获取ProductType对应的label
  String _getProductTypeLabel(ProductType type) {
    final option = ProductType.options.firstWhere(
      (option) => option['value'] == type.value,
      orElse: () => {'label': type.value, 'value': type.value},
    );
    return option['label'] ?? type.value;
  }

  /// 构建分类标签区域
  Widget _buildCategoryTabs() {
    final state = ref.watch(spuSelectionViewModelProvider(widget.categoryId));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // 单卡标签 - 使用枚举的label
          _buildCategoryTab(
            ProductType.raw,
            state.selectedType == ProductType.raw,
            _getProductTypeLabel(ProductType.raw),
          ),
          const SizedBox(width: 12),
          // 原盒标签 - 使用枚举的label
          _buildCategoryTab(
            ProductType.sealed,
            state.selectedType == ProductType.sealed,
            _getProductTypeLabel(ProductType.sealed),
          ),
          const Spacer(),
          // 筛选按钮
          _buildFilterButton(state.filter.hasFilters),
        ],
      ),
    );
  }

  /// 构建单个分类标签 - 按照设计图样式
  Widget _buildCategoryTab(ProductType type, bool isSelected, String displayText) {
    // 定义设计图中的绿色
    const Color designGreen = Color(0xFF00D86F);

    return GestureDetector(
      onTap: () {
        final viewModel =
            ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
        viewModel.selectProductType(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? designGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25), // 完全圆角
          border: Border.all(
            color: isSelected ? designGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 16, // 稍大的字体
              color: isSelected ? designGreen : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Roboto', // 使用设计图中的字体
            ),
          ),
        ),
      ),
    );
  }

  /// 构建筛选按钮
  Widget _buildFilterButton(bool hasActiveFilters) {
    return GestureDetector(
      onTap: () => _showFilterDialog(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: hasActiveFilters
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 18,
              color: hasActiveFilters
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hasActiveFilters
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建SPU列表
  Widget _buildSpuList(SpuSelectionViewModelState state) {
    if (state.spuList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final viewModel =
            ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
        await viewModel.refresh();
      },
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.spuList.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 加载更多指示器
          if (index == state.spuList.length) {
            return _buildLoadingIndicator();
          }

          final spu = state.spuList[index];
          return _buildSpuCard(spu, index);
        },
      ),
    );
  }

  /// 构建SPU卡片
  Widget _buildSpuCard(ProductInfo spu, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSpuTap(spu),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SPU图片
                _buildSpuImage(spu),
                const SizedBox(width: 16),
                // SPU信息
                Expanded(
                  child: _buildSpuInfo(spu),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建SPU图片
  Widget _buildSpuImage(ProductInfo spu) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: spu.hasImages
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                spu.images.first,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  /// 构建SPU信息
  Widget _buildSpuInfo(ProductInfo spu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SPU名称
        Text(
          spu.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // SPU编码和等级
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                spu.code,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            if (spu.level.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  spu.level,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // 标签区域
        _buildSpuTags(spu),
      ],
    );
  }

  /// 构建SPU标签
  Widget _buildSpuTags(ProductInfo spu) {
    return Row(
      children: [
        // 类目标签
        if (spu.categories.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              spu.categories.first.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
        const SizedBox(width: 8),
        // 语言标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Text(
            'EN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[100]!,
                  Colors.grey[200]!,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无SPU信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试调整筛选条件或搜索关键词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '加载更多...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// SPU项目点击处理
  void _onSpuTap(ProductInfo spu) {
    final viewModel =
        ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
    viewModel.selectSpu(spu);

    // 显示选择反馈
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择: ${spu.displayName}'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // 跳转到商品详情创建页面 - 使用pushNamed方式传递参数
    context.pushNamed(
      'product-detail-create',
      queryParameters: {
        'spuId': spu.id,
        'spuName': Uri.encodeComponent(spu.displayName),
        'spuCode': spu.code,
        'spuImageUrl': spu.hasImages ? Uri.encodeComponent(spu.images.first) : '',
      },
      extra: {
        'isEditMode': false,
        'categoryId': widget.categoryId,
        'sourceScreen': 'spu-selection',
        // 传递完整的SPU对象信息，便于后续使用
        'spuData': {
          'id': spu.id,
          'displayName': spu.displayName,
          'code': spu.code,
          'level': spu.level,
          'categories': spu.categories.map((cat) => {
            'id': cat.id,
            'displayName': cat.displayName,
          }).toList(),
          'images': spu.images,
          'type': spu.type?.value,
        },
      },
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }

  /// 显示搜索对话框
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '搜索SPU',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 搜索框
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '请输入SPU名称或编码',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 24),
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final keyword = _searchController.text.trim();
                          if (keyword.isNotEmpty) {
                            final viewModel = ref.read(
                                spuSelectionViewModelProvider(widget.categoryId)
                                    .notifier);
                            viewModel.searchSpu(keyword);
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '搜索',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        if (distinctLevels.isNotEmpty)
          SpuSelectFilterSection(
            title: 'Level',
            options: distinctLevels.map((level) => 
              SpuSelectFilterOption(id: level, label: level)
            ).toList(),
          ),
      ];

      // 获取当前状态
      final state = ref.read(spuSelectionViewModelProvider(widget.categoryId));
      
      // 构建当前选择状态
      final currentSelections = <String, Set<String>>{};
      if (distinctLevels.isNotEmpty) {
        currentSelections['Level'] = Set<String>.from(state.filter.levels);
      }

      // 显示筛选对话框
      final result = await showSpuSelectFilter(
        context,
        sections: sections,
        initialSelections: currentSelections,
        title: 'Filtering',
        clearText: 'Clear',
        confirmText: 'Confirm',
      );

      if (result != null) {
        // 处理筛选结果
        final selectedLevels = result['Level']?.toList() ?? <String>[];
        
        // 检查是否有筛选条件
        final hasFilters = selectedLevels.isNotEmpty;
        
        final viewModel = ref.read(
            spuSelectionViewModelProvider(widget.categoryId).notifier);
        
        if (hasFilters) {
          // 创建筛选对象并应用筛选条件
          final filter = SpuSelectionFilter(
            levels: selectedLevels,
            categories: const [],
            languages: const [],
          );
          
          await viewModel.applyFilter(filter);
          
          // 显示筛选结果反馈
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已应用 ${selectedLevels.length} 个筛选条件'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } else {
          // 清除筛选条件
          await viewModel.clearFilter();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已清除所有筛选条件'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
