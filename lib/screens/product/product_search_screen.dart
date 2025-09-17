import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/constants/app_constants.dart';
import '../../viewmodels/product_search_viewmodel.dart';

/// 商品搜索页面
/// 高度还原Figma设计的搜索界面
class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // 更新UI以显示/隐藏清空按钮
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 执行搜索
  void _performSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      final viewModel = ref.read(productSearchViewModelProvider.notifier);
      viewModel.searchProducts(keyword);
      _searchFocusNode.unfocus(); // 隐藏键盘
    }
  }

  /// 清空搜索
  void _clearSearch() {
    _searchController.clear();
    final viewModel = ref.read(productSearchViewModelProvider.notifier);
    viewModel.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productSearchViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopNavigationBar(),
            // 搜索框区域
            _buildSearchArea(),
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
                  // 清空按钮
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: GestureDetector(
                        onTap: _clearSearch,
                        child: Icon(
                          Icons.clear,
                          color: const Color(0xFF212222),
                          size: 24.w,
                        ),
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
  Widget _buildContent(ProductSearchState state) {
    // 加载状态
    if (state.isLoading) {
      return _buildLoadingState();
    }

    // 初始状态（未搜索）
    if (state.isEmpty) {
      return _buildEmptyState();
    }

    // 错误状态
    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    // 搜索结果为空
    if (state.showNoResults) {
      return _buildNoResultsState();
    }

    // 显示搜索结果
    return _buildSearchResults(state);
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: const Color(0xFF00D86F),
            strokeWidth: 3.w,
          ),
          SizedBox(height: 24.h),
          Text(
            'Searching...',
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

  /// 构建空状态（未搜索）- 根据Figma设计
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 搜索图标
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Icon(
              Icons.search,
              size: 80.w,
              color: const Color(0xFFB8B8B8),
            ),
          ),
          SizedBox(height: 48.h),
          Text(
            'Search for Products',
            style: TextStyle(
              fontSize: 36.sp,
              color: const Color(0xFF919191),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.w),
            child: Text(
              'Enter product name, code, or category\nto find what you\'re looking for',
              style: TextStyle(
                fontSize: 28.sp,
                color: const Color(0xFFB8B8B8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
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
          Icon(
            Icons.error_outline,
            size: 100.w,
            color: Colors.red,
          ),
          SizedBox(height: 32.h),
          Text(
            'Search Failed',
            style: TextStyle(
              fontSize: 36.sp,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.w),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 28.sp,
                color: const Color(0xFF919191),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D86F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 20.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: 28.sp),
            ),
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
              fontSize: 36.sp,
              color: const Color(0xFF919191),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Try different keywords or check spelling',
            style: TextStyle(
              fontSize: 28.sp,
              color: const Color(0xFFB8B8B8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果列表 - 根据Figma设计
  Widget _buildSearchResults(ProductSearchState state) {
    return RefreshIndicator(
      onRefresh: () async {
        if (state.searchKeyword.isNotEmpty) {
          final viewModel = ref.read(productSearchViewModelProvider.notifier);
          await viewModel.searchProducts(state.searchKeyword);
        }
      },
      color: const Color(0xFF00D86F),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: state.productList.length,
        separatorBuilder: (context, index) {
          return Container(
            height: 0.5.h,
            color: const Color(0xFFF1F1F3),
          );
        },
        itemBuilder: (context, index) {
          final product = state.productList[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  /// 构建商品卡片 - 根据Figma设计
  Widget _buildProductCard(ProductSearchItem product) {
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
  Widget _buildProductImage(ProductSearchItem product) {
    return Container(
      width: 154.w,
      height: 214.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: product.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                product.imageUrl!,
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
  Widget _buildProductInfo(ProductSearchItem product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 商品名称
        Text(
          product.name,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212222),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 8.h),
        
        // 商品编码和等级信息
        Row(
          children: [
            Text(
              product.code,
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF919191),
              ),
            ),
            if (product.level?.isNotEmpty == true) ...[
              Container(
                width: 2.w,
                height: 19.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                color: const Color(0xFF919191),
              ),
              Text(
                product.level!,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF919191),
                ),
              ),
            ],
          ],
        ),
        
        // 价格信息
        if (product.price != null) ...[
          SizedBox(height: 12.h),
          Text(
            '\$${product.price!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00D86F),
            ),
          ),
        ],
        
        const Spacer(),
        
        // 底部标签区域
        _buildProductTags(product),
      ],
    );
  }

  /// 构建商品标签
  Widget _buildProductTags(ProductSearchItem product) {
    return Row(
      children: [
        // 类目标签
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD3D3D3)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              product.category,
              style: TextStyle(
                fontSize: 22.sp,
                color: const Color(0xFF919191),
              ),
            ),
          ),
        ),
        
        // 语言标签
        if (product.language?.isNotEmpty == true) ...[
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
                product.language!,
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
  void _onProductTap(ProductSearchItem product) {
    // 显示商品详情对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Product Details',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${product.name}',
                style: TextStyle(fontSize: 28.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                'Code: ${product.code}',
                style: TextStyle(fontSize: 28.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                'Category: ${product.category}',
                style: TextStyle(fontSize: 28.sp),
              ),
              if (product.level?.isNotEmpty == true) ...[
                SizedBox(height: 12.h),
                Text(
                  'Level: ${product.level}',
                  style: TextStyle(fontSize: 28.sp),
                ),
              ],
              if (product.price != null) ...[
                SizedBox(height: 12.h),
                Text(
                  'Price: \$${product.price!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: const Color(0xFF00D86F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(fontSize: 28.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Selected: ${product.name}',
                      style: TextStyle(fontSize: 28.sp),
                    ),
                    backgroundColor: const Color(0xFF00D86F),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D86F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Select',
                style: TextStyle(fontSize: 28.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}