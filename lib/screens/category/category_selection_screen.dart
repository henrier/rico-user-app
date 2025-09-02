import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants/app_constants.dart';
import '../../models/category_model.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Series & Expansion',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: 实现搜索功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能开发中')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分隔线
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          // 主体内容
          Expanded(
            child: _buildContent(context, ref, categoryState, isLoading, error),
          ),
        ],
      ),
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
        // 左侧三级类目列表
        Expanded(
          flex: 2,
          child: _buildThirdLevelList(context, ref, categoryState),
        ),
        // 垂直分隔线
        Container(
          width: 1,
          color: Colors.grey[300],
        ),
        // 右侧四级类目列表
        Expanded(
          flex: 3,
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

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: thirdLevelCategories.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.grey[300],
      ),
      itemBuilder: (context, index) {
        final category = thirdLevelCategories[index];
        final isSelected = selectedCategory?.id == category.id;

        return Container(
          color: isSelected ? Colors.grey[400] : Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 8,
            ),
            title: Text(
              category.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {
              ref
                  .read(categoryViewModelProvider(secondCategoryId).notifier)
                  .selectThirdCategory(category);
            },
          ),
        );
      },
    );
  }

  Widget _buildFourthLevelList(
    BuildContext context,
    WidgetRef ref,
    CategoryViewModelState categoryState,
  ) {
    final fourthLevelCategories = categoryState.fourthLevelCategories;

    if (fourthLevelCategories.isEmpty) {
      return const Center(
        child: Text(
          '请选择左侧类目',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: fourthLevelCategories.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        color: Colors.grey[300],
      ),
      itemBuilder: (context, index) {
        final category = fourthLevelCategories[index];

        // 特殊处理高亮项目（模拟Figma设计中的高亮效果）
        final isHighlighted = category.displayName == 'Twilight Masquerade';

        return Container(
          color: isHighlighted ? Colors.grey[200] : Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 8,
            ),
            title: Container(
              padding: isHighlighted
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  : EdgeInsets.zero,
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            onTap: () {
              _showCategoryClickedDialog(context, category);
            },
          ),
        );
      },
    );
  }

  void _showCategoryClickedDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('类目选择'),
          content: Text(
              '${category.displayName} 类目被点击\n类目ID: ${category.id}\n二级类目ID: $secondCategoryId'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
