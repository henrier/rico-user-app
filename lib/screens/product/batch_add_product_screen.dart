import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/themes/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/spu_select_filter.dart';
import '../../widgets/bulk_edit_dialog.dart';
import '../../models/productinfo/service.dart';
import '../../models/productinfo/data.dart';
import '../../models/i18n_string.dart';

class BatchAddProductScreen extends ConsumerStatefulWidget {
  const BatchAddProductScreen({super.key});

  @override
  ConsumerState<BatchAddProductScreen> createState() => _BatchAddProductScreenState();
}

class _BatchAddProductScreenState extends ConsumerState<BatchAddProductScreen> {
  // 商品条件选择
  String _selectedCondition = 'Mint';
  final List<String> _conditions = ['Mint', 'Near Mint', 'Lightly Played', 'Damaged'];
  
  // 发布设置
  bool _isPublishingNow = true;
  
  // 批量编辑模式
  bool _isBulkEditMode = false;
  String _bulkEditType = ''; // Price, Stock, Notes - 默认不选中任何类型
  
  // API服务
  late final ProductInfoService _productInfoService;
  
  // 加载状态
  bool _isLoading = false;
  String? _errorMessage;
  
  // 筛选参数
  SpuFilterSelections _filterSelections = {};
  
  // 商品列表
  final List<ProductItem> _productList = [
    ProductItem(
      id: '1',
      name: 'Galarian Moltres\'s Devotion\'s Page',
      code: 'CEC-251',
      variant: 'Rainbow',
      condition: 'BGS Black Label',
      price: 192.12,
      stock: 1,
      notes: '',
      imageUrl: 'https://via.placeholder.com/164x228',
      type: ProductType.raw,
      cardLanguage: CardLanguage.en,
      categories: [],
      images: ['https://via.placeholder.com/164x228'],
    ),
    ProductItem(
      id: '2',
      name: 'Galarian Moltres\'s Devotion\'s Page',
      code: 'CEC-251',
      variant: 'Rainbow',
      condition: 'BGS Black Label',
      price: 192.12,
      stock: 1,
      notes: '',
      imageUrl: 'https://via.placeholder.com/164x228',
      type: ProductType.raw,
      cardLanguage: CardLanguage.en,
      categories: [],
      images: ['https://via.placeholder.com/164x228'],
    ),
    ProductItem(
      id: '3',
      name: 'Galarian Moltres\'s Devotion\'s Page',
      code: 'CEC-251',
      variant: 'Rainbow',
      condition: 'BGS Black Label',
      price: 192.12,
      stock: 1,
      notes: '',
      imageUrl: 'https://via.placeholder.com/164x228',
      type: ProductType.raw,
      cardLanguage: CardLanguage.en,
      categories: [],
      images: ['https://via.placeholder.com/164x228'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _productInfoService = ProductInfoService();
  }

  @override
  void dispose() {
    _productInfoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部标题区域
          _buildHeader(),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 基本信息区域
                  _buildBasicInfoSection(),
                  
                  // 发布设置区域
                  _buildPublishingSection(),
                  
                  // 批量编辑区域
                  _buildBulkEditSection(),
                  
                  // 商品列表区域
                  _buildProductListSection(),
                ],
              ),
            ),
          ),
          
          // 底部操作区域
          _buildBottomActionSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 88.h,
      color: Colors.white,
      child: Stack(
        children: [
          // 标题
          Center(
            child: Text(
              'Bulk Adjust Listing',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212222),
              ),
            ),
          ),
          
          // 返回按钮
          Positioned(
            left: 26.w,
            top: 22.h,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                size: 24.w,
                color: Color(0xFF212222),
              ),
            ),
          ),
          
          // 筛选按钮
          Positioned(
            right: 26.w,
            top: 22.h,
            child: GestureDetector(
              onTap: () => _showFilterDrawer(),
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1.w,
                  ),
                ),
                child: Icon(
                  Icons.tune,
                  size: 24.w,
                  color: const Color(0xFF212222),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic 标题和条件指南
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Basic',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212222),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 24.w,
                      color: Color(0xFF65c574),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Condition guide',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Color(0xFF65c574),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 条件选择和按钮
          Padding(
            padding: EdgeInsets.only(left: 30.w, bottom: 20.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Condition 标签 - 固定宽度
                Container(
                  width: 120.w,
                  child: Text(
                    'Condition',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Color(0xFF919191),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // 条件按钮区域 - 剩余宽度
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: _conditions.map((condition) {
                      final isSelected = _selectedCondition == condition;
                      return Padding(
                        padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCondition = condition;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFF65c574) : Color(0xFFf4f4f4),
                              borderRadius: BorderRadius.circular(47.r),
                            ),
                            child: Text(
                              condition,
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: isSelected ? Colors.white : Color(0xFF212222),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishingSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Publishing now?',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Color(0xFF919191),
                ),
              ),
              SizedBox(width: 20.w),
              Switch(
                value: _isPublishingNow,
                onChanged: (value) {
                  setState(() {
                    _isPublishingNow = value;
                  });
                },
                activeColor: Color(0xFF65c574),
              ),
              SizedBox(width: 12.w),
              Text(
                _isPublishingNow ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Color(0xFF212222),
                ),
              ),
            ],
          ),
          
          if (_isPublishingNow) ...[
            SizedBox(height: 16.h),
            Text(
              'Your listing will be published immediately\nand visible to buyers',
              style: TextStyle(
                fontSize: 22.sp,
                color: Color(0xFFc1c1c1),
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulkEditSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分割线
          Container(
            height: 20.h,
            color: Color(0xFFf4f4f6),
          ),
          
          // Bulk Edit 内容
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk Edit',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212222),
                  ),
                ),
                SizedBox(height: 20.h),
                
                Row(
                  children: [
                    _buildBulkEditButton('Price'),
                    SizedBox(width: 12.w),
                    _buildBulkEditButton('Stock'),
                    SizedBox(width: 12.w),
                    _buildBulkEditButton('Notes'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkEditButton(String type) {
    final isSelected = _bulkEditType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _bulkEditType = type;
          _isBulkEditMode = true;
        });
        
        // 根据类型显示相应的批量编辑弹窗
        if (type == 'Price') {
          _showBulkPriceEditDialog();
        } else if (type == 'Stock') {
          _showBulkStockEditDialog();
        } else if (type == 'Notes') {
          _showBulkNotesEditDialog();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF65c574) : Color(0xFFf4f4f4),
          borderRadius: BorderRadius.circular(47.r),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 24.sp,
            color: isSelected ? Colors.white : Color(0xFF212222),
          ),
        ),
      ),
    );
  }

  Widget _buildProductListSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分割线
          Container(
            height: 20.h,
            color: Color(0xFFf4f4f6),
          ),
          
          // Bulk List 标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: Text(
              'Bulk List',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212222),
              ),
            ),
          ),
          
          // 商品列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _productList.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_productList[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductItem product, int index) {
    // 判断是否为占位符卡片（第一个卡片显示为占位符）
    final bool isPlaceholder = index == 0;
    
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFf1f1f3),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片区域
          Container(
            width: 164.w,
            child: Column(
              children: [
                // 图片部分
                Container(
                  width: 164.w,
                  height: 228.h, // 图片高度164w*228h
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: isPlaceholder ? Color(0xFFf4f4f6) : Color(0xFFf4f4f4),
                    border: isPlaceholder ? Border.all(
                      color: Color(0xFFb84846),
                      width: 2.w,
                    ) : null,
                  ),
                  child: isPlaceholder 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 32.w,
                            color: Color(0xFFb5b5b7),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '(0/2)',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFb5b5b7),
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Color(0xFFf4f4f4),
                              child: Icon(
                                Icons.image,
                                size: 48.w,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                ),
                
                SizedBox(height: 12.h), // 与上边的距离
                
                // Photo按钮 (始终显示)
                Container(
                  width: 164.w,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFf4f4f4),
                    borderRadius: BorderRadius.circular(47.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 20.w,
                        color: Color(0xFF212222),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Photo',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212222),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  product.name,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212222),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                
                // 商品编码和变体
                Row(
                  children: [
                    Text(
                      product.code,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Color(0xFF919191),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      product.variant,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Color(0xFF919191),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                
                // Price标题和输入框在一行显示
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Color(0xFF212222),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Container(
                      width: 142.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFf4f4f4),
                        borderRadius: BorderRadius.circular(47.r),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'RM ${product.price}',
                          hintStyle: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xFFc1c1c1),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    // 建议价格
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Suggest Price\n',
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Color(0xFFc1c1c1),
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text: 'RM ${product.price}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: index == 0 ? Color(0xFFd83333) : Color(0xFFf86700),
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                
                // Stock标题和控件在一行显示
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Stock',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Color(0xFF212222),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Container(
                      width: 142.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFf4f4f4),
                        borderRadius: BorderRadius.circular(47.r),
                      ),
                      child: Row(
                        children: [
                          // 减号按钮
                          Container(
                            width: 24.w,
                            height: 24.h,
                            margin: EdgeInsets.only(left: 14.w),
                            child: Center(
                              child: Container(
                                width: 17.w,
                                height: 3.h,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(22.r),
                                ),
                              ),
                            ),
                          ),
                          // 数量显示
                          Expanded(
                            child: Text(
                              '${product.stock}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // 加号按钮
                          Container(
                            width: 24.w,
                            height: 24.h,
                            margin: EdgeInsets.only(right: 14.w),
                            child: Center(
                              child: Stack(
                                children: [
                                  // 水平线
                                  Positioned(
                                    left: 3.5.w,
                                    top: 10.5.h,
                                    child: Container(
                                      width: 17.w,
                                      height: 3.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(22.r),
                                      ),
                                    ),
                                  ),
                                  // 垂直线
                                  Positioned(
                                    left: 10.5.w,
                                    top: 3.5.h,
                                    child: Container(
                                      width: 3.w,
                                      height: 17.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(22.r),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                
                // Notes 标题和输入框
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Color(0xFF212222),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    // 备注输入框
                    Expanded(
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: Color(0xFFf4f4f4),
                          borderRadius: BorderRadius.circular(47.r),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Up to 50 characters',
                            hintStyle: TextStyle(
                              fontSize: 22.sp,
                              color: Color(0xFF919191),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                          style: TextStyle(fontSize: 22.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSection() {
    return Container(
      height: 192.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.6.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 操作按钮区域
          Container(
            height: 88.h,
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Row(
              children: [
                // Publish按钮
                Expanded(
                  child: Container(
                    height: 88.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFebebeb), width: 3.w),
                      borderRadius: BorderRadius.circular(96.r),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        // 发布商品
                        _showPublishDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(96.r),
                        ),
                      ),
                      child: _isLoading 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF212222)),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Creating...',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF212222),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Publish',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212222),
                            ),
                          ),
                    ),
                  ),
                ),
                
                SizedBox(width: 30.w),
                
                // Create Bundle按钮
                Expanded(
                  child: Container(
                    height: 88.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFebebeb), width: 3.w),
                      borderRadius: BorderRadius.circular(96.r),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        // 创建捆绑
                        _showCreateBundleDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(96.r),
                        ),
                      ),
                      child: Text(
                        'Create Bundle',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212222),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 底部进度条区域
          Container(
            height: 68.h,
            padding: EdgeInsets.symmetric(horizontal: 30.w),
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

  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '发布商品',
          style: TextStyle(fontSize: 20.sp),
        ),
        content: Text(
          '确定要发布这些商品吗？',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _batchCreateProducts();
            },
            child: Text('确定', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  void _showCreateBundleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '创建捆绑',
          style: TextStyle(fontSize: 20.sp),
        ),
        content: Text(
          '确定要创建商品捆绑吗？',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行创建捆绑逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('捆绑创建成功', style: TextStyle(fontSize: 14.sp)),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: Text('确定', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  /// 批量创建商品信息
  Future<void> _batchCreateProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<String> createdProductIds = [];
      List<String> errors = [];

      // 为每个商品创建ProductInfo
      for (int i = 0; i < _productList.length; i++) {
        final product = _productList[i];
        
        try {
          // 构建创建参数 - 使用createProductInfoWithAllFields接口
          final createParams = CreateProductInfoWithAllFieldsParams(
            name: I18NString(
              chinese: product.name,
              english: product.name,
              japanese: product.name,
            ),
            code: product.code,
            level: product.condition,
            suggestedPrice: product.price,
            cardLanguage: product.cardLanguage ?? CardLanguage.en,
            type: product.type,
            categories: product.categories ?? [],
            images: product.images ?? (product.imageUrl.isNotEmpty ? [product.imageUrl] : []),
          );

          // 调用API创建商品信息
          final productId = await _productInfoService.createProductInfoWithAllFields(createParams);
          createdProductIds.add(productId);
          
        } catch (e) {
          errors.add('商品 ${i + 1}: ${e.toString()}');
        }
      }

      setState(() {
        _isLoading = false;
      });

      // 显示结果
      if (createdProductIds.isNotEmpty) {
        _showBatchCreateResult(createdProductIds, errors);
      } else {
        _showErrorSnackBar('所有商品创建失败');
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showErrorSnackBar('批量创建失败: $e');
    }
  }

  /// 显示批量创建结果
  void _showBatchCreateResult(List<String> createdIds, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              createdIds.isNotEmpty ? Icons.check_circle : Icons.error,
              color: createdIds.isNotEmpty ? Colors.green : Colors.red,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '批量创建结果',
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (createdIds.isNotEmpty) ...[
              Text(
                '成功创建 ${createdIds.length} 个商品:',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ...createdIds.map((id) => Padding(
                padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
                child: Text(
                  '• 商品ID: $id',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )),
            ],
            if (errors.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                '失败 ${errors.length} 个商品:',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              SizedBox(height: 8.h),
              ...errors.map((error) => Padding(
                padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
                child: Text(
                  '• $error',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
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
      // 应用筛选条件，重新筛选商品列表
      _applyFilters();
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
      
      // Rarity 稀有度
      const SpuSelectFilterSection(
        title: 'Rarity',
        options: [
          SpuSelectFilterOption(id: 'amazing', label: 'Amazing'),
          SpuSelectFilterOption(id: 'rainbow', label: 'Rainbow'),
          SpuSelectFilterOption(id: 'radiant', label: 'Radiant'),
          SpuSelectFilterOption(id: 'holo', label: 'Holo'),
        ],
      ),
      
      // Series & Expansion 系列扩展
      const SpuSelectFilterSection(
        title: 'Series & Expansion',
        options: [
          SpuSelectFilterOption(id: 'amazing_1', label: 'Amazing'),
          SpuSelectFilterOption(id: 'amazing_2', label: 'Amazing'),
          SpuSelectFilterOption(id: 'amazing_3', label: 'Amazing'),
          SpuSelectFilterOption(id: 'amazing_4', label: 'Amazing'),
        ],
      ),
    ];
  }
  
  /// 应用筛选条件
  void _applyFilters() {
    // 这里可以根据筛选条件过滤商品列表
    // 例如：根据评级公司、稀有度等筛选商品
    
    // 显示筛选结果提示
    final selectedFilters = <String>[];
    _filterSelections.forEach((section, selections) {
      if (selections.isNotEmpty) {
        selectedFilters.addAll(selections);
      }
    });
    
    if (selectedFilters.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '已应用筛选条件: ${selectedFilters.join(', ')}',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '已清除所有筛选条件',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.grey[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }
  
  /// 显示批量价格编辑弹窗
  void _showBulkPriceEditDialog() {
    String selectedPriceType = 'Same Price'; // 默认选择Same Price
    String customPrice = '455'; // 默认价格
    
    showBulkEditDialog(
      context: context,
      title: 'Bulk Price Edit',
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit all in 标签和选项
            Row(
              children: [
                Text(
                  'Edit all in',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Color(0xFF919191),
                  ),
                ),
                SizedBox(width: 40.w),
                // Same Price 按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPriceType = 'Same Price';
                    });
                  },
                  child: Container(
                    width: 186.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: selectedPriceType == 'Same Price' 
                          ? Color(0xFF0dee80) 
                          : Color(0xFFf4f4f4),
                      borderRadius: BorderRadius.circular(47.r),
                    ),
                    child: Center(
                      child: Text(
                        'Same Price',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Color(0xFF212222),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Suggested Price 按钮
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 220.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPriceType = 'Suggested Price';
                    });
                  },
                  child: Container(
                    width: 236.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: selectedPriceType == 'Suggested Price' 
                          ? Color(0xFF0dee80) 
                          : Color(0xFFf4f4f4),
                      borderRadius: BorderRadius.circular(47.r),
                    ),
                    child: Center(
                      child: Text(
                        'Suggested Price',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Color(0xFF212222),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Set Price 区域
            Row(
              children: [
                Text(
                  'Set Price',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Color(0xFF919191),
                  ),
                ),
                SizedBox(width: 40.w),
                Text(
                  'RM',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 20.w),
                Container(
                  width: 115.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFf4f4f4),
                    borderRadius: BorderRadius.circular(47.r),
                  ),
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: customPrice,
                        hintStyle: TextStyle(
                          fontSize: 28.sp,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        customPrice = value;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onConfirm: () => _applyBulkPriceEdit(selectedPriceType, customPrice),
    );
  }
  
  /// 显示批量库存编辑弹窗
  void _showBulkStockEditDialog() {
    int stockValue = 1; // 默认库存值
    
    showBulkEditDialog(
      context: context,
      title: 'Bulk Stock Edit',
      content: StatefulBuilder(
        builder: (context, setState) => Row(
          children: [
            Text(
              'Stocks',
              style: TextStyle(
                fontSize: 24.sp,
                color: Color(0xFF919191),
              ),
            ),
            SizedBox(width: 40.w),
            Container(
              width: 142.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Color(0xFFf4f4f4),
                borderRadius: BorderRadius.circular(47.r),
              ),
              child: Row(
                children: [
                  // 减号按钮
                  Container(
                    width: 24.w,
                    height: 24.h,
                    margin: EdgeInsets.only(left: 14.w),
                    child: GestureDetector(
                      onTap: () {
                        if (stockValue > 0) {
                          setState(() {
                            stockValue--;
                          });
                        }
                      },
                      child: Center(
                        child: Container(
                          width: 17.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 数量显示
                  Expanded(
                    child: Text(
                      '$stockValue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // 加号按钮
                  Container(
                    width: 24.w,
                    height: 24.h,
                    margin: EdgeInsets.only(right: 14.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          stockValue++;
                        });
                      },
                      child: Center(
                        child: Stack(
                          children: [
                            // 水平线
                            Positioned(
                              left: 3.5.w,
                              top: 10.5.h,
                              child: Container(
                                width: 17.w,
                                height: 3.h,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(22.r),
                                ),
                              ),
                            ),
                            // 垂直线
                            Positioned(
                              left: 10.5.w,
                              top: 3.5.h,
                              child: Container(
                                width: 3.w,
                                height: 17.h,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(22.r),
                                ),
                              ),
                            ),
                          ],
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
      onConfirm: () => _applyBulkStockEdit(stockValue),
    );
  }
  
  /// 显示批量备注编辑弹窗
  void _showBulkNotesEditDialog() {
    String notesText = ''; // 备注文本
    int maxLength = 50; // 最大字符数
    
    showBulkEditDialog(
      context: context,
      title: 'Bulk Notes Edit',
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stocks 标签和输入框在同一行
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stocks 标签
                Text(
                  'Stocks',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Color(0xFF919191),
                  ),
                ),
                SizedBox(width: 40.w),
                
                // 文本输入区域整体容器
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFf4f4f4),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      children: [
                        // 文本输入框
                        Container(
                          height: 188.h,
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            maxLength: maxLength,
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'up to 50 characters',
                              hintStyle: TextStyle(
                                fontSize: 24.sp,
                                color: Color(0xFF919191),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20.w),
                              counterText: '', // 隐藏默认计数器
                            ),
                            onChanged: (value) {
                              setState(() {
                                notesText = value;
                              });
                            },
                          ),
                        ),
                        
                        // 字符计数器
                        Container(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 20.w,
                            bottom: 20.h,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${notesText.length}/$maxLength',
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Color(0xFF919191),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onConfirm: () => _applyBulkNotesEdit(notesText),
    );
  }
  
  /// 应用批量价格编辑
  void _applyBulkPriceEdit(String priceType, String customPrice) {
    // 这里实现批量价格编辑逻辑
    String message = '';
    
    if (priceType == 'Same Price') {
      message = '已将所有商品价格设置为 RM $customPrice';
      // 实际应用：更新所有商品的价格为customPrice
    } else if (priceType == 'Suggested Price') {
      message = '已将所有商品价格设置为建议价格';
      // 实际应用：更新所有商品的价格为各自的建议价格
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
  
  /// 应用批量库存编辑
  void _applyBulkStockEdit(int stockValue) {
    // 这里实现批量库存编辑逻辑
    String message = '已将所有商品库存设置为 $stockValue';
    // 实际应用：更新所有商品的库存为stockValue
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
  
  /// 应用批量备注编辑
  void _applyBulkNotesEdit(String notesText) {
    // 这里实现批量备注编辑逻辑
    String message = notesText.isEmpty 
        ? '已清空所有商品备注' 
        : '已将所有商品备注设置为: $notesText';
    // 实际应用：更新所有商品的备注为notesText
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final String code;
  final String variant;
  final String condition;
  final double price;
  final int stock;
  final String notes;
  final String imageUrl;
  
  // API调用需要的字段
  final ProductType type;
  final CardLanguage? cardLanguage;
  final List<String>? categories;
  final List<String>? images;

  ProductItem({
    required this.id,
    required this.name,
    required this.code,
    required this.variant,
    required this.condition,
    required this.price,
    required this.stock,
    required this.notes,
    required this.imageUrl,
    this.type = ProductType.raw,
    this.cardLanguage,
    this.categories,
    this.images,
  });
}
