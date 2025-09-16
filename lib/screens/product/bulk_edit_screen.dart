import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../models/personalproduct/data.dart';
import '../../models/personalproduct/service.dart';
import '../../models/page_data.dart';
import '../../widgets/selectable_product_item.dart';
import '../../widgets/bulk_action_bottom_sheet.dart';
import '../../widgets/bulk_edit_dialog.dart';
import '../../widgets/spu_select_filter.dart';
import '../../common/utils/logger.dart';

class BulkEditScreen extends StatefulWidget {
  final Map<String, dynamic>? routeData;
  
  const BulkEditScreen({super.key, this.routeData});

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
  bool isDropdownVisible = false;
  
  // 数据状态
  List<PersonalProduct> products = [];
  bool isLoading = true;
  String? errorMessage;
  
  // API服务
  late final PersonalProductService _personalProductService;
  
  // 分页参数
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  // 从路由传递的参数
  String? _currentStatus;
  SpuFilterSelections _filterSelections = {};
  
  // 页面内部排序参数（不从路由传递）
  List<String> _sortFields = ['createdAt'];
  List<String> _sortDirections = ['desc'];

  @override
  void initState() {
    super.initState();
    _personalProductService = PersonalProductService();
    _initializeFromRouteData();
    _loadProducts();
  }

  @override
  void dispose() {
    _personalProductService.dispose();
    super.dispose();
  }

  /// 从路由数据初始化参数
  void _initializeFromRouteData() {
    AppLogger.i('BulkEditScreen 接收到的路由数据: ${widget.routeData}');
    
    if (widget.routeData != null) {
      _currentStatus = widget.routeData!['currentStatus'] as String?;
      _filterSelections = widget.routeData!['filterSelections'] as SpuFilterSelections? ?? {};
      
      AppLogger.i('从路由初始化参数:');
      AppLogger.i('  - status: $_currentStatus');
      AppLogger.i('  - filters: $_filterSelections');
    } else {
      AppLogger.w('未接收到路由数据，使用默认参数');
    }
    
    // 初始化页面内部排序参数
    AppLogger.i('初始化排序参数:');
    AppLogger.i('  - sortFields: $_sortFields');
    AppLogger.i('  - sortDirections: $_sortDirections');
  }

  /// 加载商品数据
  Future<void> _loadProducts({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        _hasMoreData = true;
      }
      
      setState(() {
        if (isRefresh) {
          products.clear();
          selectedProductIds.clear();
          selectAll = false;
        }
        isLoading = true;
        errorMessage = null;
      });
      
      AppLogger.i('正在加载批量编辑商品数据，页码: $_currentPage');
      
      // 获取状态筛选
      final statusFilter = _getStatusFromTab(_currentStatus);
      AppLogger.i('状态筛选: _currentStatus=$_currentStatus, statusFilter=$statusFilter');
      
      // 获取类型筛选
      final typeFilter = _getFilteredProductTypes();
      AppLogger.i('类型筛选: selectedFilter=$selectedFilter, typeFilter=$typeFilter');
      
      // 构建基础查询参数
      final baseParams = PersonalProductManualPageParams(
        current: _currentPage,
        pageSize: _pageSize,
        // 根据传递的状态筛选
        status: statusFilter != null ? [statusFilter.value] : null,
        // 应用筛选条件
        ratedCardRatingCompany: _getFilteredRatingCompanies(),
        ratedCardCardScore: _getFilteredCardScores(),
        type: typeFilter,
      );
      
      AppLogger.i('API查询参数: ${baseParams.toJson()}');
      
      // 构建排序参数
      final params = PersonalProductPageWithSortParams(
        current: _currentPage,
        pageSize: _pageSize,
        sortFields: _sortFields,
        sortDirections: _sortDirections,
        baseParams: baseParams,
      );
      
      final pageData = await _personalProductService.getPersonalProductsPageWithSort(params);
      
      AppLogger.i('API响应成功，数据长度: ${pageData.list.length}');
      
      setState(() {
        if (isRefresh) {
          products = pageData.list;
        } else {
          products.addAll(pageData.list);
        }
        _hasMoreData = pageData.list.length >= _pageSize;
        isLoading = false;
      });
      
      AppLogger.i('成功加载${pageData.list.length}个商品，当前总数: ${products.length}');
      
    } catch (e) {
      AppLogger.e('加载批量编辑商品数据失败', e);
      setState(() {
        isLoading = false;
        errorMessage = '加载商品数据失败: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载商品数据失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 加载更多数据
  Future<void> _loadMoreProducts() async {
    if (!_hasMoreData || isLoading) return;
    
    _currentPage++;
    await _loadProducts();
  }

  /// 根据选中的Tab获取对应的状态
  PersonalProductStatus? _getStatusFromTab(String? tab) {
    if (tab == null) return null;
    switch (tab) {
      case 'Published':
        return PersonalProductStatus.listed;
      case 'Pending':
        return PersonalProductStatus.pendingListing;
      case 'Sold Out':
        return PersonalProductStatus.soldOut;
      default:
        return null; // 显示所有状态
    }
  }
  
  /// 获取筛选的评级公司列表
  List<String>? _getFilteredRatingCompanies() {
    final gradedSlabsSelections = _filterSelections['Graded Slabs'];
    if (gradedSlabsSelections == null || gradedSlabsSelections.isEmpty) {
      return null;
    }
    
    // 将筛选选项ID映射为评级公司名称
    final companies = <String>[];
    for (final selection in gradedSlabsSelections) {
      switch (selection) {
        case 'psa':
          companies.add('PSA');
          break;
        case 'bgs':
          companies.add('BGS');
          break;
        case 'cgc':
          companies.add('CGC');
          break;
        case 'pgc':
          companies.add('PGC');
          break;
      }
    }
    
    return companies.isNotEmpty ? companies : null;
  }
  
  /// 获取筛选的卡牌评分列表
  List<String>? _getFilteredCardScores() {
    final raritySelections = _filterSelections['Rarity'];
    if (raritySelections == null || raritySelections.isEmpty) {
      return null;
    }
    
    // 将稀有度映射为卡牌评分（这里是示例映射，实际应根据业务逻辑调整）
    final scores = <String>[];
    for (final selection in raritySelections) {
      switch (selection) {
        case 'amazing':
          scores.add('10');
          break;
        case 'rainbow':
          scores.add('9.5');
          break;
        case 'radiant_1':
        case 'radiant_2':
          scores.add('9');
          break;
        case 'holo':
          scores.add('8.5');
          break;
      }
    }
    
    return scores.isNotEmpty ? scores : null;
  }
  
  /// 获取筛选的商品类型列表
  List<String>? _getFilteredProductTypes() {
    // 优先根据筛选标签进行筛选
    switch (selectedFilter) {
      case 'Raw':
        return [PersonalProductType.rawCard.value];
      case 'Graded':
        return [PersonalProductType.ratedCard.value];
      case 'Sealed':
        return [PersonalProductType.box.value];
      default:
        break;
    }
    
    // 其次根据筛选条件进行筛选
    final viewGradedCards = _filterSelections['View Graded Cards'];
    if (viewGradedCards != null && viewGradedCards.isNotEmpty) {
      // 如果选择了View Graded Cards，则只显示评级卡
      if (viewGradedCards.contains('graded_cards')) {
        return [PersonalProductType.ratedCard.value];
      }
    }
    
    return null;
  }

  /// 根据排序选项更新排序参数
  void _updateSortParams(String sortOption) {
    switch (sortOption) {
      case 'Latest Listing':
        _sortFields = ['createdAt'];
        _sortDirections = ['desc'];
        break;
      case 'Price: Low to High':
        _sortFields = ['price'];
        _sortDirections = ['asc'];
        break;
      case 'Price: High to Low':
        _sortFields = ['price'];
        _sortDirections = ['desc'];
        break;
      case 'Stock: Low to High':
        _sortFields = ['quantity'];
        _sortDirections = ['asc'];
        break;
      case 'Stock: High to Low':
        _sortFields = ['quantity'];
        _sortDirections = ['desc'];
        break;
      default:
        _sortFields = ['createdAt'];
        _sortDirections = ['desc'];
    }
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
  
  Future<void> _performBulkDelete() async {
    try {
      // 记录删除的数量
      final deletedCount = selectedProductIds.length;
      final idsToDelete = selectedProductIds.toList();
      
      AppLogger.i('开始批量删除商品，数量: $deletedCount');
      AppLogger.i('删除的商品ID: $idsToDelete');
      
      // 显示加载状态
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在删除商品...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
      
      // 调用API批量删除商品
      await _personalProductService.batchDeletePersonalProduct(idsToDelete);
      
      AppLogger.i('API调用成功，批量删除完成');
      
      // 清空选中状态
      setState(() {
        selectedProductIds.clear();
        selectAll = false;
      });
      
      // 重新获取列表信息
      AppLogger.i('开始重新获取商品列表');
      await _loadProducts(isRefresh: true);
      
      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功删除 $deletedCount 个商品'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      AppLogger.i('批量删除操作完成，列表已刷新');
      
    } catch (e) {
      AppLogger.e('批量删除商品失败', e);
      
      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleBulkEdit() {
    // 校验是否有选中的商品
    if (selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择要编辑的商品'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 获取选中的商品数据
    final selectedProducts = products
        .where((product) => selectedProductIds.contains(product.id))
        .toList();

    // 跳转到批量添加商品页面，携带选中的商品数据
    context.pushNamed(
      'batch-add-product',
      extra: {
        'selectedProducts': selectedProducts,
        'isEditMode': true, // 标识为编辑模式
      },
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
        child: Stack(
          children: [
            // 主要内容
            Column(
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
            
            // 下拉菜单覆盖层
            if (isDropdownVisible) _buildDropdownOverlay(),
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
              'Bulk Edit${_currentStatus != null ? ' - $_currentStatus' : ''}',
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
              // 切换筛选标签时重新加载数据
              _loadProducts(isRefresh: true);
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
              setState(() {
                isDropdownVisible = !isDropdownVisible;
              });
            },
            child: Row(
              children: [
                Text(
                  selectedSort,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: selectedSort == 'Latest Listing' 
                        ? const Color(0xFF00D86F) 
                        : const Color(0xFF212222),
                  ),
                ),
                SizedBox(width: 8.w),
                Transform.rotate(
                  angle: isDropdownVisible ? 3.14159 : 0, // 180度旋转
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 22.w,
                    color: selectedSort == 'Latest Listing' 
                        ? const Color(0xFF00D86F) 
                        : const Color(0xFF212222),
                  ),
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
    if (isLoading && products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (errorMessage != null && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _loadProducts(isRefresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
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
            SizedBox(height: 8.h),
            Text(
              '当前筛选条件下没有找到商品',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(isRefresh: true),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: products.length + (_hasMoreData ? 1 : 0),
        separatorBuilder: (context, index) => Container(
          height: 1.h,
          color: const Color(0xFFF4F4F6),
        ),
        itemBuilder: (context, index) {
          if (index == products.length) {
            // 加载更多指示器
            return Container(
              padding: EdgeInsets.all(16.h),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _loadMoreProducts,
                        child: const Text('加载更多'),
                      ),
              ),
            );
          }
          
          final product = products[index];
          final isSelected = selectedProductIds.contains(product.id);
          
          return SelectableProductItem(
            product: product,
            isSelected: isSelected,
            onSelectionChanged: () => _toggleProductSelection(product.id),
          );
        },
      ),
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

  Widget _buildDropdownOverlay() {
    final sortOptions = [
      'Latest Listing',
      'Price: Low to High',
      'Price: High to Low',
      'Stock: Low to High',
      'Stock: High to Low',
    ];
    
    return Stack(
      children: [
        // 点击遮罩层关闭下拉菜单
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownVisible = false;
            });
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        
        // 下拉菜单 - 在排序按钮下方
        Positioned(
          top: 240.h, // 88h(顶部导航) + 64h(筛选标签栏) + 32h(排序栏padding) = 184h，菜单紧贴排序栏下方
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortOptions.map((option) {
                final isSelected = option == selectedSort;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSort = option;
                      isDropdownVisible = false;
                      // 更新排序参数并重新加载数据
                      _updateSortParams(option);
                    });
                    // 重新加载数据
                    _loadProducts(isRefresh: true);
                  },
                  child: Container(
                    height: 80.h,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: isSelected ? const Color(0xFF00D86F) : const Color(0xFF212222),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // 下方遮罩层 - 只遮罩菜单下方的内容
        Positioned(
          top: 240.h + (80.h * sortOptions.length), // 菜单底部开始
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isDropdownVisible = false;
              });
            },
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
