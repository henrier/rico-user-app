import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/themes/app_theme.dart';
import '../../widgets/stats_section.dart';
import '../../widgets/bottom_action_buttons.dart';
import '../../widgets/spu_select_filter.dart';
import '../../models/personalproduct/service.dart';
import '../../models/personalproduct/data.dart';
import '../../models/page_data.dart';
import '../../common/utils/logger.dart';

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

  @override
  void initState() {
    super.initState();
    _personalProductService = PersonalProductService();
    _loadProducts();
  }
  
  @override
  void dispose() {
    _personalProductService.dispose();
    super.dispose();
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
      
      final params = PersonalProductPageParams(
        current: _currentPage,
        pageSize: _pageSize,
        // 根据选中的状态筛选
        status: _getStatusFromTab(selectedTab),
      );
      
      final pageData = await _personalProductService.getPersonalProductPage(params);
      
      setState(() {
        if (isRefresh) {
          _products = pageData.list;
        } else {
          _products.addAll(pageData.list);
        }
        _hasMoreData = pageData.list.length >= _pageSize;
        _isLoading = false;
      });
      
      AppLogger.i('成功加载${pageData.list.length}个商品');
      
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
  
  /// 显示筛选抽屉
  Future<void> _showFilterDrawer() async {
    final filterSections = _buildFilterSections();
    
    final result = await showSpuSelectFilter(
      context,
      sections: filterSections,
      initialSelections: _filterSelections,
      title: 'Filtering',
      clearText: 'Clear',
      confirmText: 'Confirm',
    );
    
    if (result != null) {
      setState(() {
        _filterSelections = result;
      });
      // 应用筛选条件，重新加载数据
      _loadProducts(isRefresh: true);
    }
  }
  
  /// 构建筛选选项
  List<SpuSelectFilterSection> _buildFilterSections() {
    return [
      // View Graded Cards 开关
      const SpuSelectFilterSection(
        title: 'View Graded Cards',
        options: [
          SpuSelectFilterOption(id: 'graded_cards', label: 'View Graded Cards'),
        ],
      ),
      
      // Graded Slabs 评级公司
      const SpuSelectFilterSection(
        title: 'Graded Slabs',
        options: [
          SpuSelectFilterOption(id: 'psa', label: 'PSA'),
          SpuSelectFilterOption(id: 'bgs', label: 'BGS'),
          SpuSelectFilterOption(id: 'cgc', label: 'CGC'),
          SpuSelectFilterOption(id: 'pgc', label: 'PGC'),
        ],
      ),
      
      // Rarity 稀有度 - 根据Figma设计包含5个选项
      const SpuSelectFilterSection(
        title: 'Rarity',
        options: [
          SpuSelectFilterOption(id: 'amazing', label: 'Amazing'),
          SpuSelectFilterOption(id: 'rainbow', label: 'Rainbow'),
          SpuSelectFilterOption(id: 'radiant_1', label: 'Radiant'),
          SpuSelectFilterOption(id: 'radiant_2', label: 'Radiant'),
          SpuSelectFilterOption(id: 'holo', label: 'Holo'),
        ],
      ),
      
      // Series & Expansion 系列扩展 - 根据Figma设计包含4个Amazing选项
      const SpuSelectFilterSection(
        title: 'Series & Expansion',
        options: [
          SpuSelectFilterOption(id: 'series_amazing_1', label: 'Amazing'),
          SpuSelectFilterOption(id: 'series_amazing_2', label: 'Amazing'),
          SpuSelectFilterOption(id: 'series_amazing_3', label: 'Amazing'),
          SpuSelectFilterOption(id: 'series_amazing_4', label: 'Amazing'),
        ],
      ),
    ];
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
              // 导航到批量编辑页面
              Navigator.pushNamed(context, '/home/bulk-edit');
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
    if (_isLoading && _products.isEmpty) {
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
    
    return Container(
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
    
    return GestureDetector(
      onTap: () {
        setState(() {
          isDropdownVisible = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Column(
          children: [
            // 保持顶部区域不被遮罩
            Container(
              height: 338.h, // 顶部导航栏 + 统计栏 + 操作栏的高度
              color: Colors.transparent,
            ),
            
            // 下拉菜单区域
            Container(
              width: 750.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: sortOptions.map((option) {
                  final isSelected = option == selectedSortOption;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSortOption = option;
                        isDropdownVisible = false;
                      });
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
                            color: isSelected ? const Color(0xFF00D86F) : Colors.black,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // 剩余空间填充
            Expanded(
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
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

}
