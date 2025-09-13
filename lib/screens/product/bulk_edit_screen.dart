import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../models/personalproduct/data.dart';
import '../../models/personalproduct/service.dart';
import '../../widgets/selectable_product_item.dart';
import '../../widgets/bulk_action_bottom_sheet.dart';
import '../../widgets/bulk_edit_dialog.dart';
import '../../common/data/mock_bulk_edit_data.dart';

class BulkEditScreen extends StatefulWidget {
  const BulkEditScreen({super.key});

  @override
  State<BulkEditScreen> createState() => _BulkEditScreenState();
}

class _BulkEditScreenState extends State<BulkEditScreen> {
  // 选中状态管理
  Set<String> selectedProductIds = {};
  bool selectAll = false;
  
  // 筛选状态
  String selectedFilter = 'Raw';
  String selectedSort = 'Latest Listing';
  
  // 数据状态
  List<PersonalProduct> products = [];
  bool isLoading = true;
  
  // API服务
  late final PersonalProductService _personalProductService;

  @override
  void initState() {
    super.initState();
    _personalProductService = PersonalProductService();
    _loadMockProducts();
  }

  @override
  void dispose() {
    _personalProductService.dispose();
    super.dispose();
  }

  void _loadMockProducts() {
    setState(() {
      isLoading = true;
    });

    // 模拟加载延迟
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          products = MockBulkEditData.getMockProducts();
          selectedProductIds = MockBulkEditData.getInitialSelectedIds();
          selectAll = false; // 根据Figma设计，不是全选状态
          isLoading = false;
        });
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      if (selectAll) {
        selectedProductIds = products.map((p) => p.id).toSet();
      } else {
        selectedProductIds.clear();
      }
    });
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (selectedProductIds.contains(productId)) {
        selectedProductIds.remove(productId);
      } else {
        selectedProductIds.add(productId);
      }
      
      // 更新全选状态
      selectAll = selectedProductIds.length == products.length;
    });
  }

  void _showBulkActions() {
    if (selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择要操作的商品'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BulkActionBottomSheet(
        selectedCount: selectedProductIds.length,
        onBulkUnpublish: _handleBulkUnpublish,
        onBulkDelete: _handleBulkDelete,
        onBulkEdit: _handleBulkEdit,
        onCreateBundle: _handleCreateBundle,
      ),
    );
  }

  void _handleBulkUnpublish() {
    // 显示下架确认弹窗
    showBulkEditDialog(
      context: context,
      title: 'Unpublish Items',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Do you want to unpublish these items?',
            style: TextStyle(
              fontSize: 32.sp,
              color: const Color(0xFF212222),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirmText: 'Unpublish',
      cancelText: 'Cancel',
      onConfirm: () {
        // 执行下架操作
        _performBulkUnpublish();
      },
    );
  }
  
  void _performBulkUnpublish() {
    final unpublishedCount = selectedProductIds.length;
    
    // 更新选中商品的状态为待上架
    setState(() {
      for (var product in products) {
        if (selectedProductIds.contains(product.id)) {
          // 这里应该更新商品状态，但由于PersonalProduct是不可变的，
          // 在实际应用中需要通过API更新状态
        }
      }
      selectedProductIds.clear();
      selectAll = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('成功下架 $unpublishedCount 个商品'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleBulkDelete() {
    // 显示删除确认弹窗
    showBulkEditDialog(
      context: context,
      title: 'Delete Items',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Deleted items can’t be restored. Are you sure?',
            style: TextStyle(
              fontSize: 28.sp,
              color: const Color(0xFF212222),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () {
        // 执行删除操作
        _performBulkDelete();
      },
    );
  }
  
  void _performBulkDelete() {
    // 记录删除的数量
    final deletedCount = selectedProductIds.length;
    
    // 从列表中移除选中的商品
    setState(() {
      products.removeWhere((product) => selectedProductIds.contains(product.id));
      selectedProductIds.clear();
      selectAll = false;
    });
    
    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('成功删除 $deletedCount 个商品'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleBulkEdit() {
    // TODO: 实现批量编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('批量编辑 ${selectedProductIds.length} 个商品'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleCreateBundle() {
    // TODO: 实现创建套装功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('使用 ${selectedProductIds.length} 个商品创建套装'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopBar(),
            
            // 筛选标签栏
            _buildFilterTabs(),
            
            // 排序和筛选栏
            _buildSortAndFilterBar(),
            
            // 分割线
            Container(
              height: 20.h,
              color: const Color(0xFFF4F4F6),
            ),
            
            // 全选栏
            _buildSelectAllBar(),
            
            // 商品列表
            Expanded(
              child: _buildProductList(),
            ),
            
            // 底部操作按钮
            if (selectedProductIds.isNotEmpty) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 88.h,
      color: Colors.white,
      child: Stack(
        children: [
          // 取消按钮
          Positioned(
            left: 30.w,
            top: 24.h,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 30.sp,
                  color: const Color(0xFF212222),
                ),
              ),
            ),
          ),
          
          // 标题
          Center(
            child: Text(
              'Bulk Edit',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['Raw', 'Graded', 'Sealed'];
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? const Color(0xFF00D86F) : const Color(0xFFEBEBEB),
                  width: 2.w,
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: isSelected ? const Color(0xFF00D86F) : const Color(0xFF212222),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortAndFilterBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
      child: Row(
        children: [
          const Spacer(),
          
          // 排序选项
          GestureDetector(
            onTap: () {
              // TODO: 显示排序选项
            },
            child: Row(
              children: [
                Text(
                  selectedSort,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: const Color(0xFF212222),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 22.w,
                  color: const Color(0xFF212222),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 20.w),
          
          // 筛选按钮
          GestureDetector(
            onTap: () {
              // TODO: 显示筛选选项
            },
            child: Row(
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleSelectAll,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectAll ? const Color(0xFF00D86F) : const Color(0xFFD3D3D3),
                  width: 2.w,
                ),
                color: selectAll ? const Color(0xFF00D86F) : Colors.transparent,
              ),
              child: selectAll
                  ? Icon(
                      Icons.check,
                      size: 20.w,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Select all',
            style: TextStyle(
              fontSize: 24.sp,
              color: const Color(0xFF919191),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64.w,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              '暂无商品',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: products.length,
      separatorBuilder: (context, index) => Container(
        height: 1.h,
        color: const Color(0xFFF4F4F6),
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final isSelected = selectedProductIds.contains(product.id);
        
        return SelectableProductItem(
          product: product,
          isSelected: isSelected,
          onSelectionChanged: () => _toggleProductSelection(product.id),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      height: 192.h,
      color: Colors.white,
      child: Column(
        children: [
          // 阴影分割线
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.6,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
          ),
          
          // 操作按钮
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Bulk\nUnpublish',
                    () => _handleBulkUnpublish(),
                  ),
                  _buildActionButton(
                    'Bulk\nDelete',
                    () => _handleBulkDelete(),
                  ),
                  _buildActionButton(
                    'Bulk\nEdit',
                    () => _handleBulkEdit(),
                  ),
                  _buildActionButton(
                    'Create\nBundle',
                    () => _handleCreateBundle(),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部指示器
          Container(
            height: 68.h,
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 268.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 156.w,
        height: 88.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFEBEBEB),
            width: 3.w,
          ),
          borderRadius: BorderRadius.circular(96.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF212222),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
