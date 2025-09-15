import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopNavigationBar(),
            
            // 分类筛选区域
            _buildCategoryTabs(),
            
            // 分割线
            Container(
              height: 20.h,
              color: const Color(0xFFF1F1F3),
            ),
            
            // SPU列表
            Expanded(
              child: Container(
                color: const Color(0xFFF4F4F6),
                child: _buildSpuList(state),
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
          
          // 标题
          Center(
            child: Text(
              'Item List',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212222),
              ),
            ),
          ),
          
          // 右侧按钮组
          Positioned(
            right: 26.w,
            top: 24.h,
            child: Row(
              children: [
                // 相机按钮
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('相机功能开发中'),
                        backgroundColor: Colors.grey[800],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                  },
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
                      Icons.camera_alt_outlined,
                      color: Color(0xFF212222),
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // 搜索按钮
                GestureDetector(
                  onTap: () => context.pushNamed('spu-search'),
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
                      Icons.search,
                      color: Color(0xFF212222),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  /// 构建分类标签区域 - 根据Figma设计
  Widget _buildCategoryTabs() {
    final state = ref.watch(spuSelectionViewModelProvider(widget.categoryId));

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        children: [
          // Cards标签 - 使用原来的逻辑
          _buildCategoryTab(
            ProductType.raw,
            state.selectedType == ProductType.raw,
            _getProductTypeLabel(ProductType.raw),
          ),
          SizedBox(width: 20.w),
          // Sealed Products标签 - 使用原来的逻辑
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

  /// 构建单个分类标签 - 根据Figma设计
  Widget _buildCategoryTab(ProductType type, bool isSelected, String displayText) {
    const Color designGreen = Color(0xFF00D86F);
    const Color unselectedBorderColor = Color(0xFFEBEBEB);

    return GestureDetector(
      onTap: () {
        final viewModel =
            ref.read(spuSelectionViewModelProvider(widget.categoryId).notifier);
        viewModel.selectProductType(type);
      },
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(
          horizontal: displayText == 'Cards' ? 30.w : 40.w,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? designGreen : unselectedBorderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 24.sp,
              color: isSelected ? designGreen : const Color(0xFF212222),
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  /// 构建筛选按钮 - 根据Figma设计
  Widget _buildFilterButton(bool hasActiveFilters) {
    return GestureDetector(
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
              fontWeight: FontWeight.w400,
              color: const Color(0xFF212222),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建SPU列表 - 根据Figma设计
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
      color: const Color(0xFF00D86F),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: state.spuList.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => Container(
          height: 2.h,
          color: const Color(0xFFF1F1F3),
        ),
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

  /// 构建SPU卡片 - 根据Figma设计
  Widget _buildSpuCard(ProductInfo spu, int index) {
    return GestureDetector(
      onTap: () => _onSpuTap(spu),
      child: Container(
        height: 274.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Row(
          children: [
            // SPU图片
            _buildSpuImage(spu),
            SizedBox(width: 24.w),
            // SPU信息
            Expanded(
              child: _buildSpuInfo(spu),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建SPU图片 - 根据Figma设计
  Widget _buildSpuImage(ProductInfo spu) {
    return Container(
      width: 154.w,
      height: 214.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: spu.hasImages
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
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

  /// 构建占位图片 - 根据Figma设计
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

  /// 构建SPU信息 - 根据Figma设计
  Widget _buildSpuInfo(ProductInfo spu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SPU名称
        Text(
          spu.displayName,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF212222),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 8.h),
        
        // SPU编码和类型信息 - 根据商品类型显示不同内容
        _buildProductDetails(spu),
        
        const Spacer(),
        
        // 底部标签区域
        Row(
          children: [
            Expanded(
              child: _buildSpuTags(spu),
            ),
            // Info按钮 - 根据商品类型显示
            if (_shouldShowInfoButton(spu)) _buildInfoButton(),
          ],
        ),
      ],
    );
  }

  /// 构建商品详情信息 - 根据商品类型显示不同内容
  Widget _buildProductDetails(ProductInfo spu) {
    // 根据商品类型显示不同的信息
    if (spu.type == ProductType.sealed) {
      // Sealed Products 类型显示多行信息
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spu.code,
            style: TextStyle(
              fontSize: 24.sp,
              color: const Color(0xFF919191),
            ),
          ),
          if (spu.level.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              spu.level, // 显示实际的等级信息
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF919191),
              ),
            ),
          ],
          if (spu.categories.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              spu.categories.first.displayName ?? spu.categories.first.name.toString(), // 显示类目名称
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF919191),
              ),
            ),
          ],
        ],
      );
    } else {
      // Cards 类型显示单行信息
      return Row(
        children: [
          Text(
            spu.code,
            style: TextStyle(
              fontSize: 24.sp,
              color: const Color(0xFF919191),
            ),
          ),
          if (spu.level.isNotEmpty || spu.cardLanguage.value.isNotEmpty) ...[
            Container(
              width: 2.w,
              height: 19.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              color: const Color(0xFF919191),
            ),
            if (spu.level.isNotEmpty)
              Text(
                spu.level,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF919191),
                ),
              )
            else if (spu.cardLanguage.value.isNotEmpty)
              Text(
                spu.cardLanguage.value,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF919191),
                ),
              ),
          ],
        ],
      );
    }
  }

  /// 判断是否显示Info按钮
  bool _shouldShowInfoButton(ProductInfo spu) {
    // 根据商品类型决定是否显示Info按钮
    return spu.type == ProductType.sealed;
  }

  /// 构建Info按钮
  Widget _buildInfoButton() {
    return Container(
      height: 44.h,
      width: 110.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Info',
            style: TextStyle(
              fontSize: 24.sp,
              color: const Color(0xFF212222),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16.w,
            color: const Color(0xFF212222),
          ),
        ],
      ),
    );
  }

  /// 构建SPU标签 - 根据Figma设计
  Widget _buildSpuTags(ProductInfo spu) {
    return Row(
      children: [
        // 类目标签 - 显示第一个类目名称，如果没有则显示默认值
        if (spu.categories.isNotEmpty || true) // 总是显示至少一个标签
          Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD3D3D3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                spu.categories.isNotEmpty 
                  ? (spu.categories.first.displayName ?? spu.categories.first.name.toString())
                  : 'Pokémon', // 默认值
                style: TextStyle(
                  fontSize: 22.sp,
                  color: const Color(0xFF919191),
                ),
              ),
            ),
          ),
        
        // 语言标签 - 仅在有卡片语言时显示
        if (spu.cardLanguage.value.isNotEmpty) ...[
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
                spu.cardLanguage.value,
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
          'cardLanguage': spu.cardLanguage.value, // 添加卡片语言信息
          'categories': spu.categories.map((cat) => {
            'id': cat.id,
            'displayName': cat.displayName,
          }).toList(),
          'images': spu.images,
          'type': spu.type?.value,
          'suggestedPrice': spu.suggestedPrice, // 从SPU数据获取建议价格
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
