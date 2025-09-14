import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../common/themes/app_theme.dart';
import '../../widgets/stats_section.dart';
import '../../widgets/bottom_action_buttons.dart';
import '../../models/personalproduct/service.dart';
import '../../models/personalproduct/data.dart';
import '../../models/page_data.dart';
import '../../common/utils/logger.dart';

// 筛选选择类型定义
typedef SpuFilterSelections = Map<String, Set<String>>; // sectionTitle -> set of option ids

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String selectedLanguage = 'Pokemon EN';
  String selectedTab = 'Published';
  String selectedSortOption = 'Latest Listing';
  bool isDropdownVisible = false;
  
  // API服务
  late final PersonalProductService _personalProductService;
  
  // 数据状态
  List<PersonalProduct> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // 分页参数
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  // 筛选参数
  SpuFilterSelections _filterSelections = {};
  
  // 排序参数
  List<String> _sortFields = ['createdAt']; // 默认按创建时间排序
  List<String> _sortDirections = ['desc']; // 默认降序
  
  // Tab数量统计
  int _publishedCount = 0;
  int _pendingCount = 0;
  int _soldOutCount = 0;
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _personalProductService = PersonalProductService();
    _loadTabCounts();
    _loadProducts();
  }
  
  @override
  void dispose() {
    _personalProductService.dispose();
    super.dispose();
  }
  
  /// 加载Tab数量统计
  Future<void> _loadTabCounts() async {
    try {
      setState(() {
        _isLoadingCounts = true;
      });
      
      AppLogger.i('正在加载Tab数量统计');
      
      // 并行获取各状态的数量
      final futures = await Future.wait([
        // Published数量
        _personalProductService.countPersonalProductsByCondition(
          PersonalProductManualPageParams(
            status: [PersonalProductStatus.listed.value],
          ),
        ),
        // Pending数量  
        _personalProductService.countPersonalProductsByCondition(
          PersonalProductManualPageParams(
            status: [PersonalProductStatus.pendingListing.value],
          ),
        ),
        // Sold Out数量
        _personalProductService.countPersonalProductsByCondition(
          PersonalProductManualPageParams(
            status: [PersonalProductStatus.soldOut.value],
          ),
        ),
      ]);
      
      setState(() {
        _publishedCount = futures[0];
        _pendingCount = futures[1];
        _soldOutCount = futures[2];
        _isLoadingCounts = false;
      });
      
      AppLogger.i('Tab数量统计加载完成: Published=$_publishedCount, Pending=$_pendingCount, SoldOut=$_soldOutCount');
      
    } catch (e) {
      AppLogger.e('加载Tab数量统计失败', e);
      setState(() {
        _isLoadingCounts = false;
        // 保持默认值0
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载统计数据失败: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
          _products.clear();
        }
        _isLoading = true;
        _errorMessage = null;
      });
      
      AppLogger.i('正在加载商品数据，页码: $_currentPage');
      
      // 构建基础查询参数
      final baseParams = PersonalProductManualPageParams(
        current: _currentPage,
        pageSize: _pageSize,
        // 根据选中的状态筛选
        status: _getStatusFromTab(selectedTab) != null 
            ? [_getStatusFromTab(selectedTab)!.value] 
            : null,
        // 应用筛选条件
        ratedCardRatingCompany: _getFilteredRatingCompanies(),
        ratedCardCardScore: _getFilteredCardScores(),
        type: _getFilteredProductTypes(),
      );
      
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
      AppLogger.d('第一个商品数据: ${pageData.list.isNotEmpty ? pageData.list.first.toString() : "无数据"}');
      
      setState(() {
        if (isRefresh) {
          _products = pageData.list;
        } else {
          _products.addAll(pageData.list);
        }
        _hasMoreData = pageData.list.length >= _pageSize;
        _isLoading = false;
      });
      
      AppLogger.i('成功加载${pageData.list.length}个商品，当前总数: ${_products.length}');
      
    } catch (e) {
      AppLogger.e('加载商品数据失败', e);
      setState(() {
        _isLoading = false;
        _errorMessage = '加载商品数据失败: ${e.toString()}';
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
    if (!_hasMoreData || _isLoading) return;
    
    _currentPage++;
    await _loadProducts();
  }
  
  /// 根据选中的Tab获取对应的状态
  PersonalProductStatus? _getStatusFromTab(String tab) {
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
    final viewGradedCards = _filterSelections['View Graded Cards'];
    if (viewGradedCards == null || viewGradedCards.isEmpty) {
      return null;
    }
    
    // 如果选择了View Graded Cards，则只显示评级卡
    if (viewGradedCards.contains('view_graded_cards')) {
      return [PersonalProductType.ratedCard.value];
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
  
  /// 显示筛选抽屉
  Future<void> _showFilterDrawer() async {
    final result = await _showCustomFilterDrawer();
    
    if (result != null) {
      // 处理开关逻辑：如果View Graded Cards关闭，清除Graded Slabs选择
      final processedResult = _processFilterResult(result);
      
      setState(() {
        _filterSelections = processedResult;
      });
      // 应用筛选条件，重新加载数据
      _loadProducts(isRefresh: true);
      // 筛选条件变化时也需要重新加载Tab数量
      _loadTabCounts();
    }
  }
  
  /// 显示自定义筛选抽屉（带开关控件）
  Future<SpuFilterSelections?> _showCustomFilterDrawer() async {
    return showGeneralDialog<SpuFilterSelections>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: _CustomFilterDrawer(
            initialSelections: _filterSelections,
            onResult: (result) => Navigator.of(context).pop(result),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(curved),
          child: child,
        );
      },
    );
  }
  
  /// 处理筛选结果，确保开关逻辑正确
  SpuFilterSelections _processFilterResult(SpuFilterSelections result) {
    final processedResult = Map<String, Set<String>>.from(result);
    
    // 检查View Graded Cards开关状态
    final isViewGradedCardsEnabled = processedResult['View Graded Cards']?.contains('view_graded_cards') ?? false;
    
    // 如果开关关闭，清除Graded Slabs的所有选择
    if (!isViewGradedCardsEnabled) {
      processedResult.remove('Graded Slabs');
    }
    
    return processedResult;
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
                
                // 统计信息
              StatsSection(
                selectedTab: selectedTab,
                publishedCount: _publishedCount,
                pendingCount: _pendingCount,
                soldOutCount: _soldOutCount,
                isLoadingCounts: _isLoadingCounts,
                onTabChanged: (tab) {
                  setState(() {
                    selectedTab = tab;
                  });
                  // 切换Tab时重新加载数据
                  _loadProducts(isRefresh: true);
                },
              ),
                
                // 分割线
                Container(
                  height: 1.h,
                  color: const Color(0xFFF4F4F6),
                ),
                
                // 操作按钮区域
                _buildActionSection(),
                
                // Bundle Sales 部分
                _buildBundleSalesSection(),
                
                // 商品列表
                Expanded(
                  child: _buildProductList(),
                ),
                
                // 底部操作按钮
                BottomActionButtons(
                  onAddProduct: () {
                    // 导航到添加商品页面
                    Navigator.pushNamed(context, '/home/categories');
                  },
                  onBulkAddProduct: () {
                    // 导航到批量添加商品页面
                    Navigator.pushNamed(context, '/home/batch-add-product');
                  },
                  onCreateBundle: () {
                    // 导航到创建Bundle页面
                    Navigator.pushNamed(context, '/home/categories');
                  },
                ),
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
      color: const Color(0xFFF4F4F6),
      child: Stack(
        children: [
          // 返回按钮
          Positioned(
            left: 30.w,
            top: 24.h,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF212222),
                  size: 20,
                ),
              ),
            ),
          ),
          
          // 搜索按钮
          Positioned(
            left: 105.w,
            top: 24.h,
            child: GestureDetector(
              onTap: () {
                // 导航到搜索页面
                Navigator.pushNamed(context, '/home/spu-search');
              },
              child: Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF212222),
                  size: 24,
                ),
              ),
            ),
          ),
          
          // 标题
          Center(
            child: Text(
              'Manage Listing',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212222),
              ),
            ),
          ),
          
          // 语言选择器
          Positioned(
            right: 30.w,
            top: 24.h,
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF000000).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(33.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguage,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
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
          ),
        ],
      ),
    );
  }


  Widget _buildActionSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Row(
        children: [
          // 批量编辑按钮
          GestureDetector(
            onTap: () {
              // 导航到批量编辑页面，携带当前状态
              final routeData = {
                'currentStatus': selectedTab,
                'filterSelections': _filterSelections,
              };
              
              // 添加调试日志
              AppLogger.i('跳转到批量编辑页面，携带参数: $routeData');
              AppLogger.i('当前状态Tab: $selectedTab');
              
              context.pushNamed('bulk-edit', extra: routeData);
            },
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F6),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: 22.w,
                    color: const Color(0xFF212222),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Bulk Edit',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: const Color(0xFF212222),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // 最新列表下拉
          GestureDetector(
            onTap: () {
              setState(() {
                isDropdownVisible = !isDropdownVisible;
              });
            },
            child: Row(
              children: [
                Text(
                  selectedSortOption,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: selectedSortOption == 'Latest Listing' 
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
                    color: selectedSortOption == 'Latest Listing' 
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
              _showFilterDrawer();
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

  Widget _buildBundleSalesSection() {
    return Column(
      children: [
        // 上分割线
        Container(
          height: 0.5.h,
          color: const Color(0xFFF1F1F3),
        ),
        
        // Bundle Sales 区域（带背景色）
        Container(
          color: const Color(0xFFF4F4F6),
          child: Column(
            children: [
              // Bundle Sales 标题栏
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bundle Sales',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF212222),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // 显示更多Bundle选项
                      },
                      child: Row(
                        children: [
                          Text(
                            'More',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF212222),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.keyboard_arrow_right,
                            size: 22.w,
                            color: const Color(0xFF212222),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bundle 卡片横向滚动列表
              Container(
                height: 281.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 30.w),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 24.w),
                      child: _buildBundleCard(index + 1),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // 下分割线
        Container(
          height: 0.5.h,
          color: const Color(0xFFF1F1F3),
        ),
      ],
    );
  }
  
  Widget _buildBundleCard(int bundleNumber) {
    return Container(
      width: 432.w,
      height: 281.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 第一行：标题（左）和价格（右）
          Positioned(
            left: 30.w,
            right: 30.w,
            top: 20.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bundle标题（左边）
                Text(
                  'Bundle $bundleNumber',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF212222),
                  ),
                ),
                // 当前价格（右边）
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'RM',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF86700),
                        ),
                      ),
                      TextSpan(
                        text: ' 2,500',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF86700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 第二行：倒计时（左）和删除价格（右）
          Positioned(
            left: 30.w,
            right: 30.w,
            top: 60.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 倒计时（左边）
                Row(
                  children: [
                    _buildTimeBox('12', 'D'),
                    SizedBox(width: 14.w),
                    _buildTimeBox('12', 'H'),
                    SizedBox(width: 14.w),
                    _buildTimeBox('12', 'M'),
                    SizedBox(width: 14.w),
                    _buildTimeBox('12', 'S'),
                  ],
                ),
                // 原价删除线（右边）
                Text(
                  'RM 2,500',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: const Color(0xFFC1C1C1),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: const Color(0xFFC1C1C1),
                  ),
                ),
              ],
            ),
          ),
          
          // 背景卡片图片（在底部）
          Positioned(
            left: 20.w,
            top: 120.h,
            child: Row(
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
                  width: 98.w,
                  height: 137.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[400],
                    size: 40.w,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeBox(String time, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF212222),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          unit,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF919191),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    AppLogger.d('构建商品列表: isLoading=$_isLoading, products.length=${_products.length}, errorMessage=$_errorMessage');
    
    if (_isLoading && _products.isEmpty) {
      AppLogger.d('显示加载指示器');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null && _products.isEmpty) {
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
              _errorMessage!,
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
    
    if (_products.isEmpty) {
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
              '您还没有添加任何商品',
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
        itemCount: _products.length + (_hasMoreData ? 1 : 0),
        separatorBuilder: (context, index) => Container(
          height: 2.h,
          color: const Color(0xFFF1F1F3),
        ),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            // 加载更多指示器
            return Container(
              padding: EdgeInsets.all(16.h),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _loadMoreProducts,
                        child: const Text('加载更多'),
                      ),
              ),
            );
          }
          return _buildProductItem(_products[index]);
        },
      ),
    );
  }
  
  Widget _buildProductItem(PersonalProduct product) {
    AppLogger.d('构建商品项: id=${product.id}, name=${product.displayName}');
    
    return GestureDetector(
      onTap: () => _navigateToProductEdit(product),
      child: Container(
        height: 274.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Row(
          children: [
            // 商品图片
            Container(
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
                          return Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 60.w,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 60.w,
                    ),
            ),
            
            SizedBox(width: 24.w),
            
            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  Text(
                    product.displayName,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF212222),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // 商品代码和类型
                  Row(
                    children: [
                      Text(
                        product.productInfo.code ?? 'N/A',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: const Color(0xFF919191),
                        ),
                      ),
                      Container(
                        width: 2.w,
                        height: 19.h,
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        color: const Color(0xFF919191),
                      ),
                      Text(
                        _getProductTypeDisplayName(product.type),
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: const Color(0xFF919191),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // 价格
                  Text(
                    'RM ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF86700),
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // 底部信息：品质、评级、数量
                  Row(
                    children: [
                      // 品质标签
                      Container(
                        height: 36.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD3D3D3)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            _getConditionDisplayName(product.condition),
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: const Color(0xFF919191),
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // 评级标签（如果有）
                      if (product.hasRatedCard) ...[
                        Container(
                          height: 34.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            gradient: _getGradeGradient(product.ratedCard!.cardScore),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '${product.ratedCard!.ratingCompany.name} ${product.ratedCard!.cardScore}',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ] else ...[
                        // 数量标签（无评级时）
                        Container(
                          height: 34.h,
                          width: 44.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4D5862), Color(0xFF737373)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              'x${product.quantity}',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        
        // 下拉菜单 - 直接从操作区域底部开始，不包含Bundle Sales
        Positioned(
          top: 257.h, // 88h(顶部导航) + 1h(分割线) + 90h(统计区域) + 1h(分割线) + 64h(操作区域总高度) + 13h(到操作区域底部) = 257h
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
                final isSelected = option == selectedSortOption;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSortOption = option;
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
          top: 257.h + (80.h * sortOptions.length), // 菜单底部开始
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
  
  /// 获取商品类型显示名称
  String _getProductTypeDisplayName(PersonalProductType type) {
    switch (type) {
      case PersonalProductType.rawCard:
        return '普通卡';
      case PersonalProductType.box:
        return '原盒';
      case PersonalProductType.ratedCard:
        return '评级卡';
    }
  }
  
  /// 获取品相显示名称
  String _getConditionDisplayName(PersonalProductCondition condition) {
    switch (condition) {
      case PersonalProductCondition.mint:
        return '完美品相';
      case PersonalProductCondition.nearMint:
        return '近完美品相';
      case PersonalProductCondition.lightlyPlayed:
        return '轻微磨损';
      case PersonalProductCondition.damaged:
        return '有损伤';
    }
  }
  
  /// 获取评级渐变色
  LinearGradient _getGradeGradient(String grade) {
    if (grade.contains('10') || grade.toUpperCase().contains('BLACK LABEL')) {
      return const LinearGradient(
        colors: [Color(0xFFF86700), Color(0xFFF89900)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF4D5862), Color(0xFF737373)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// 导航到商品编辑页面
  Future<void> _navigateToProductEdit(PersonalProduct product) async {
    try {
      AppLogger.i('点击商品卡片，准备跳转到编辑页面: ${product.id}');
      
      // 调试日志：检查关键参数
      AppLogger.i('商品信息调试:');
      AppLogger.i('  - personalProductId: ${product.id}');
      AppLogger.i('  - spuId: "${product.productInfo.id}" (长度: ${product.productInfo.id.length})');
      AppLogger.i('  - spuName: ${product.displayName}');
      AppLogger.i('  - spuCode: ${product.productInfo.code ?? ""}');
      AppLogger.i('  - productInfo完整对象: ${product.productInfo.toString()}');
      
      // 跳转到商品详情编辑页面，让目标页面自己获取详细数据
      final result = await context.pushNamed(
        'product-detail-create',
        extra: {
          'isEditMode': true,
          'personalProductId': product.id,
          'spuId': product.productInfo.id,
          'spuName': product.displayName,
          'spuCode': product.productInfo.code ?? '',
          'spuImageUrl': product.hasImages ? product.images.first : '',
          // 不再传递existingData，让目标页面通过API获取
        },
      );
      
      // 处理编辑结果
      if (result != null && result is Map<String, dynamic>) {
        AppLogger.i('商品编辑页面返回结果: $result');
        
        if (result['success'] == true) {
          // 编辑成功，刷新商品列表
          _loadProducts(isRefresh: true);
          
          // 显示成功提示
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? '操作成功'),
                backgroundColor: const Color(0xFF0DEE80),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
        } else if (result['deleted'] == true) {
          // 商品被删除，刷新列表和统计
          _loadProducts(isRefresh: true);
          _loadTabCounts();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('商品删除成功'),
                backgroundColor: const Color(0xFF0DEE80),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
        }
      }
      
    } catch (e) {
      AppLogger.e('跳转到商品编辑页面失败', e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开编辑页面失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  /// 从PersonalProduct构建编辑模式的现有数据
  Map<String, dynamic> _buildExistingDataFromProduct(PersonalProduct product) {
    return {
      'type': _getTypeStringFromPersonalProductType(product.type),
      'condition': _getConditionStringFromPersonalProductCondition(product.condition),
      'gradedBy': product.hasRatedCard ? product.ratedCard!.ratingCompany.name : '',
      'grade': product.hasRatedCard ? product.ratedCard!.cardScore : '',
      'serialNumber': product.hasRatedCard ? (product.ratedCard!.gradedCardNumber ?? '') : '',
      'price': product.price,
      'stock': product.quantity,
      'notes': product.notes,
      'setCoverPhoto': false, // 默认值，实际应根据图片信息判断
      'listingStatus': product.status == PersonalProductStatus.listed,
      // TODO: 添加图片URL列表，需要从PersonalProduct获取
      'imageUrls': product.images,
    };
  }

  /// 将PersonalProductType转换为字符串
  String _getTypeStringFromPersonalProductType(PersonalProductType type) {
    switch (type) {
      case PersonalProductType.rawCard:
        return 'Raw';
      case PersonalProductType.box:
        return 'Sealed';
      case PersonalProductType.ratedCard:
        return 'Graded';
    }
  }

  /// 将PersonalProductCondition转换为字符串
  String _getConditionStringFromPersonalProductCondition(PersonalProductCondition condition) {
    switch (condition) {
      case PersonalProductCondition.mint:
        return 'Mint';
      case PersonalProductCondition.nearMint:
        return 'Near Mint';
      case PersonalProductCondition.lightlyPlayed:
        return 'Lightly Played';
      case PersonalProductCondition.damaged:
        return 'Damaged';
    }
  }

}

/// 筛选选项数据类
class _FilterOption {
  final String id;
  final String label;

  const _FilterOption({required this.id, required this.label});
}

/// 筛选分组数据类
class _FilterSection {
  final String title;
  final List<_FilterOption>? options;
  final bool isToggleSection;
  final bool isInlineToggle; // 标题和开关是否在同一行
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const _FilterSection({
    required this.title,
    this.options,
    this.isToggleSection = false,
    this.isInlineToggle = false,
    this.toggleValue,
    this.onToggleChanged,
  });
}

/// 自定义筛选抽屉组件
class _CustomFilterDrawer extends StatefulWidget {
  final SpuFilterSelections initialSelections;
  final Function(SpuFilterSelections) onResult;

  const _CustomFilterDrawer({
    required this.initialSelections,
    required this.onResult,
  });

  @override
  State<_CustomFilterDrawer> createState() => _CustomFilterDrawerState();
}

class _CustomFilterDrawerState extends State<_CustomFilterDrawer> {
  late SpuFilterSelections _selections;
  late bool _viewGradedCardsEnabled;

  @override
  void initState() {
    super.initState();
    _selections = Map<String, Set<String>>.from(widget.initialSelections);
    _viewGradedCardsEnabled = _selections['View Graded Cards']?.contains('view_graded_cards') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawerWidth = 479.w; // 根据Figma设计稿宽度

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            Container(
              width: drawerWidth,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1A000000), // rgba(0,0,0,0.1)
                    blurRadius: 12.r,
                    offset: Offset(-4.w, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 30.h,
                    ),
                    child: Text(
                      'Filtering',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF212222),
                        fontWeight: FontWeight.w500,
                        fontSize: 36.sp, // 根据Figma设计稿调整
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 20.h,
                      ),
                      itemCount: _getFilterSections().length,
                      separatorBuilder: (_, __) => SizedBox(height: 40.h),
                      itemBuilder: (context, index) {
                        final section = _getFilterSections()[index];
                        return _buildFilterSection(section);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 88.h, // 根据Figma设计稿高度
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(44.r), // 完全圆角
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(44.r),
                                onTap: () {
                                  // 清空所有选择并立即返回空结果
                                  final emptySelections = <String, Set<String>>{};
                                  for (final key in _selections.keys) {
                                    emptySelections[key] = <String>{};
                                  }
                                  Navigator.of(context).pop(emptySelections);
                                },
                                child: Center(
                                  child: Text(
                                    'Clear',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF090909),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32.sp, // 根据Figma设计稿调整
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 25.w), // 根据Figma设计稿间距
                        Expanded(
                          child: Container(
                            height: 88.h, // 根据Figma设计稿高度
                            decoration: BoxDecoration(
                              color: const Color(0xFF0DEE80),
                              borderRadius: BorderRadius.circular(44.r), // 完全圆角
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(44.r),
                                onTap: () {
                                  Navigator.of(context).pop(_selections);
                                },
                                child: Center(
                                  child: Text(
                                    'Confirm',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF090909),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32.sp, // 根据Figma设计稿调整
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取筛选分组列表
  List<_FilterSection> _getFilterSections() {
    final sections = <_FilterSection>[];
    
    // View Graded Cards 开关分组
    sections.add(_FilterSection(
      title: 'View Graded Cards',
      isToggleSection: true,
      isInlineToggle: true, // 标题和开关在同一行
      toggleValue: _viewGradedCardsEnabled,
      onToggleChanged: (value) {
        setState(() {
          _viewGradedCardsEnabled = value;
          if (_viewGradedCardsEnabled) {
            _selections['View Graded Cards'] = {'view_graded_cards'};
          } else {
            _selections.remove('View Graded Cards');
            _selections.remove('Graded Slabs'); // 清除相关选择
          }
        });
      },
    ));
    
    // Graded Slabs 分组（条件显示）
    if (_viewGradedCardsEnabled) {
      sections.add(_FilterSection(
        title: 'Graded Slabs',
        options: [
          _FilterOption(id: 'psa', label: 'PSA'),
          _FilterOption(id: 'bgs', label: 'BGS'),
          _FilterOption(id: 'cgc', label: 'CGC'),
          _FilterOption(id: 'pgc', label: 'PGC'),
        ],
      ));
    }
    
    // Rarity 分组
    sections.add(_FilterSection(
      title: 'Rarity',
      options: [
        _FilterOption(id: 'amazing', label: 'Amazing'),
        _FilterOption(id: 'rainbow', label: 'Rainbow'),
        _FilterOption(id: 'radiant_1', label: 'Radiant'),
        _FilterOption(id: 'radiant_2', label: 'Radiant'),
        _FilterOption(id: 'holo', label: 'Holo'),
      ],
    ));
    
    // Series & Expansion 分组
    sections.add(_FilterSection(
      title: 'Series & Expansion',
      options: [
        _FilterOption(id: 'series_amazing_1', label: 'Amazing'),
        _FilterOption(id: 'series_amazing_2', label: 'Amazing'),
        _FilterOption(id: 'series_amazing_3', label: 'Amazing'),
        _FilterOption(id: 'series_amazing_4', label: 'Amazing'),
      ],
    ));
    
    return sections;
  }
  
  /// 构建筛选分组
  Widget _buildFilterSection(_FilterSection section) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 如果是内联开关分组（标题和开关在同一行）
        if (section.isToggleSection && section.isInlineToggle)
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.title, 
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF212222),
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp, // 根据Figma设计稿调整
                  ),
                ),
                _buildToggleSwitch(section.toggleValue!, section.onToggleChanged!),
              ],
            ),
          )
        else ...[
          // 普通标题
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(
              section.title, 
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF212222),
                fontWeight: FontWeight.w500,
                fontSize: 24.sp, // 根据Figma设计稿调整
              ),
            ),
          ),
          SizedBox(height: 20.h),
          
          // 如果是非内联开关分组
          if (section.isToggleSection) 
            _buildToggleSwitch(section.toggleValue!, section.onToggleChanged!)
          else if (section.title == 'Series & Expansion')
            // Series & Expansion 模块：每个选项单独一行显示
            Column(
              children: [
                for (int i = 0; i < section.options!.length; i++) ...[
                  if (i > 0) SizedBox(height: 20.h), // 选项间距
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildSelectableChip(
                      label: section.options![i].label,
                      selected: (_selections[section.title] ?? <String>{}).contains(section.options![i].id),
                      onTap: () => _toggleOption(section.title, section.options![i].id),
                    ),
                  ),
                ],
              ],
            )
          else
            // 其他模块：使用网格布局来更好地控制间距和对齐
            Wrap(
              spacing: 20.w, // 根据Figma设计调整间距
              runSpacing: 20.h, // 垂直间距
              alignment: WrapAlignment.start,
              children: [
                for (final opt in section.options!)
                  _buildSelectableChip(
                    label: opt.label,
                    selected: (_selections[section.title] ?? <String>{}).contains(opt.id),
                    onTap: () => _toggleOption(section.title, opt.id),
                  ),
              ],
            ),
        ],
      ],
    );
  }
  
  /// 构建开关控件
  Widget _buildToggleSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 60.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: value 
              ? const Color(0xFF0DEE80) 
              : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: value 
                ? const Color(0xFF0DEE80) 
                : const Color(0xFFCCCCCC),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 30.w : 2.w,
              top: 2.h,
              child: Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建可选择的芯片
  Widget _buildSelectableChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      height: 54.h, // 根据Figma设计的高度
      constraints: BoxConstraints(
        minWidth: 99.w, // 最小宽度，根据Figma中最小的chip
        maxWidth: 143.w, // 最大宽度，根据Figma中最大的chip
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0DEE80) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(27.r), // 完全圆角
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(27.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 13.h),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF212222),
                  fontWeight: FontWeight.w400,
                  fontSize: 24.sp, // 根据Figma设计稿调整
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 切换选项状态
  void _toggleOption(String sectionTitle, String optionId) {
    setState(() {
      final currentSelections = _selections[sectionTitle] ?? <String>{};
      if (currentSelections.contains(optionId)) {
        currentSelections.remove(optionId);
        if (currentSelections.isEmpty) {
          _selections.remove(sectionTitle);
        }
      } else {
        _selections[sectionTitle] = currentSelections..add(optionId);
      }
    });
  }

}
