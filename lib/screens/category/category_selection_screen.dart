import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../common/constants/app_constants.dart';
import '../../models/productcategory/data.dart';
import '../../providers/category_provider.dart';
import '../../viewmodels/category_viewmodel.dart';

class CategorySelectionScreen extends ConsumerWidget {
  final String secondCategoryId;

  const CategorySelectionScreen({
    super.key,
    required this.secondCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState =
        ref.watch(categoryViewModelProvider(secondCategoryId));
    final isLoading = ref.watch(isLoadingCategoriesProvider(secondCategoryId));
    final error = ref.watch(categoryErrorProvider(secondCategoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 32.w),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Series & Expansion',
          style: TextStyle(
            color: const Color(0xFF212222),
            fontSize: 36.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.black, size: 32.w),
            onPressed: () {
              // 相机功能
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black, size: 32.w),
            onPressed: () {
              // 跳转到SPU搜索页面
              context.push('/home/spu-search');
            },
          ),
        ],
      ),
      body: _buildContent(context, ref, categoryState, isLoading, error),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CategoryViewModelState categoryState,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: () => ref
                  .read(categoryViewModelProvider(secondCategoryId).notifier)
                  .refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // 左侧三级类目列表 - 根据设计调整比例
        SizedBox(
          width: 280.w,
          child: _buildThirdLevelList(context, ref, categoryState),
        ),
        // 右侧四级类目列表 - 占据剩余空间
        Expanded(
          child: _buildFourthLevelList(context, ref, categoryState),
        ),
      ],
    );
  }

  Widget _buildThirdLevelList(
    BuildContext context,
    WidgetRef ref,
    CategoryViewModelState categoryState,
  ) {
    final thirdLevelCategories = categoryState.thirdLevelCategories;
    final selectedCategory = categoryState.selectedThirdCategory;

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: thirdLevelCategories.length,
        itemBuilder: (context, index) {
          final category = thirdLevelCategories[index];
          final isSelected = selectedCategory?.id == category.id;

          return GestureDetector(
            onTap: () {
              ref
                  .read(categoryViewModelProvider(secondCategoryId).notifier)
                  .selectThirdCategory(category);
            },
            child: Container(
              height: 88.h,
              color: Colors.white,
              child: Center(
                child: Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF00D86F) : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFourthLevelList(
    BuildContext context,
    WidgetRef ref,
    CategoryViewModelState categoryState,
  ) {
    final fourthLevelCategories = categoryState.fourthLevelCategories;

    if (fourthLevelCategories.isEmpty) {
      return Container(
        color: const Color(0xFFF4F4F6),
        child: Center(
          child: Text(
            '请选择左侧类目',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 28.sp,
            ),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF4F4F6),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: fourthLevelCategories.length,
        itemBuilder: (context, index) {
          final category = fourthLevelCategories[index];

          // 根据设计交替背景色
          final isEvenIndex = index % 2 == 0;
          final backgroundColor = isEvenIndex ? Colors.white : const Color(0xFFE8E8EB);

          return GestureDetector(
            onTap: () {
              _navigateToSpuSelection(context, category);
            },
            child: Container(
              height: 88.h,
              color: backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 60.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF212222),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 导航到SPU选择页面
  void _navigateToSpuSelection(BuildContext context, ProductCategory category) {
    // 跳转到SPU选择页面，传递类目ID
    context.go('/home/spu-selection?categoryId=${category.id}');
  }
}
