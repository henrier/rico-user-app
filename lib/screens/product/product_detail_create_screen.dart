import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import '../../models/productinfo/service.dart';
import '../../models/productinfo/data.dart';
import '../../models/i18n_string.dart';

/// 商品详情新增页面
/// 对应Figma设计中的"7 商品详情编辑 - raw 裸卡"页面
class ProductDetailCreateScreen extends ConsumerStatefulWidget {
  final String spuId;
  final String spuName;
  final String spuCode;
  final String spuImageUrl;

  const ProductDetailCreateScreen({
    super.key,
    required this.spuId,
    required this.spuName,
    required this.spuCode,
    required this.spuImageUrl,
  });

  @override
  ConsumerState<ProductDetailCreateScreen> createState() =>
      _ProductDetailCreateScreenState();
}

class _ProductDetailCreateScreenState
    extends ConsumerState<ProductDetailCreateScreen> {
  // 表单控制器
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '1');
  final TextEditingController _notesController = TextEditingController();

  // 选择状态
  String _selectedType = 'Raw';
  String _selectedCondition = '';
  String _selectedGradedBy = '';
  String _selectedGrade = '';
  String _serialNumber = '';
  List<File> _selectedImages = [];
  bool _setCoverPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();
  
  // 序列号输入控制器
  final TextEditingController _serialNumberController = TextEditingController();

  // API服务
  late final ProductInfoService _productInfoService;
  
  // 加载状态
  bool _isLoading = false;
  String? _errorMessage;

  // 设计图中的络色
  static const Color designGreen = Color(0xFF0DEE80);
  static const Color designOrange = Color(0xFFF86700);

  @override
  void initState() {
    super.initState();
    _productInfoService = ProductInfoService();
    // 监听notes输入变化以更新字符计数
    _notesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _notesController.dispose();
    _serialNumberController.dispose();
    _productInfoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 自定义AppBar
          _buildSliverAppBar(),
          // 主要内容
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品信息展示区域
                _buildProductInfoSection(),
                // 分隔条
                _buildSectionDivider(),
                // Type & Condition 区域
                _buildTypeConditionSection(),
                 // 分隔条
                _buildSectionDivider(),
                if (_selectedType == 'Graded') ...[
                // Serial Number区域容器
                _buildSerialNumberInput(),
                // 分隔条
                _buildSectionDivider(),
                // Price区域（仅在Graded类型时显示）
                _buildGradedPriceSection(),
                ],
                // 分隔条
                _buildSectionDivider(),
                // Price & Stock 区域（在Raw和Sealed类型时显示）
                if (_selectedType == 'Raw' || _selectedType == 'Sealed') _buildPriceStockSection(),
                // 分隔条
                if (_selectedType == 'Raw' || _selectedType == 'Sealed') _buildSectionDivider(),
                // Notes to Buyer 区域
                _buildNotesSection(),
                // 分隔条
                _buildSectionDivider(),
                // Upload Item Photo 区域
                _buildPhotoUploadSection(),
                // Done按钮区域
                _buildDoneButtonSection(),
                // 底部安全区域间距
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建SliverAppBar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      toolbarHeight: 88.h, // 设计图中的高度
      leading: Container(
        margin: EdgeInsets.only(left: 26.w, top: 12.h, bottom: 12.h),
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[700],
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: Text(
        'Edit Listing',
        style: TextStyle(
          color: const Color(0xFF212222),
          fontSize: 36.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      // 添加底部边框
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          height: 1.h,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  /// 构建商品信息展示区域
  Widget _buildProductInfoSection() {
    return Container(
      color: Colors.white,
      height: 257.h, // 设计图中的高度
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片 - 按设计图尺寸
          Container(
            width: 136.w,
            height: 188.h,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: widget.spuImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      widget.spuImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    ),
                  )
                : _buildPlaceholderImage(),
          ),
          SizedBox(width: 24.w), // 设计图中的间距
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h), // 顶部对齐调整
                // 商品名称 - 精确字体大小
                Text(
                  widget.spuName,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF212222),
                    height: 1.2,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                // 商品编码和稀有度 - 分开显示
                Row(
                  children: [
                    Text(
                      widget.spuCode,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: const Color(0xFF919191),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Text(
                      'Rainbow',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: const Color(0xFF919191),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h), // 增加间距
                // 标签区域 - 按设计图样式
                Row(
                  children: [
                    _buildInfoTag('Pokémon'),
                    SizedBox(width: 12.w),
                    _buildInfoTag('EN'),
                  ],
                ),
                SizedBox(height: 24.h),
                // Card Info 按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildCardInfoButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: 48.sp,
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoTag(String text) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!, width: 2.w),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xFF919191),
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  /// 构建Card Info按钮
  Widget _buildCardInfoButton() {
    return Container(
      height: 44.h,
      width: 169.w, // 设计图中的宽度
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Card Info',
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(width: 8.w),
          Transform.rotate(
            angle: 0.785398, // 45度旋转，匹配设计图
            child: Icon(
              Icons.add,
              size: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分隔条
  Widget _buildSectionDivider() {
    return Container(
      height: 20.h,
      color: const Color(0xFFF4F4F6),
    );
  }

  /// 构建Type & Condition区域
  Widget _buildTypeConditionSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和指导链接
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Type & Condition',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 24.sp,
                    color: Colors.green[600],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Condition guide',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40.h),
          // Type选择
          _buildTypeSelection(),
          SizedBox(height: 40.h),
          // Condition选择（在Raw和Sealed类型时显示）
          if (_selectedType == 'Raw') _buildConditionSelection(),
          // Graded相关字段（仅在Graded类型时显示）
          if (_selectedType == 'Graded') ..._buildGradedFields(),
          if (_selectedType == 'Raw' || _selectedType == 'Graded') SizedBox(height: 40.h),
          // 注意事项
          _buildNoticeSection(),
          // Serial Number输入（仅在Graded类型时显示）

        ],
      ),
    );
  }

  /// 构建Type选择区域
  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF919191),
          ),
        ),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 20.w,
          runSpacing: 12.h,
          children: [
            _buildTypeChip('Raw', _selectedType == 'Raw'),
            _buildTypeChip('Graded', _selectedType == 'Graded'),
            _buildTypeChip('Sealed', _selectedType == 'Sealed'),
          ],
        ),
      ],
    );
  }

  /// 构建Type选择芯片
  Widget _buildTypeChip(String type, bool isSelected) {
    // 根据设计图设置不同宽度
    double width;
    switch (type) {
      case 'Raw':
        width = 110.w;
        break;
      case 'Graded':
        width = 141.w;
        break;
      case 'Sealed':
        width = 137.w;
        break;
      default:
        width = 110.w;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // 切换类型时清空相关选择
          _selectedCondition = '';
          _selectedGradedBy = '';
          _selectedGrade = '';
          _serialNumber = '';
          _serialNumberController.clear();
        });
      },
      child: Container(
        height: 54.h,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? designGreen : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(47.r),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  /// 构建Condition选择区域
  Widget _buildConditionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF919191),
          ),
        ),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 20.w,
          runSpacing: 12.h,
          children: [
            _buildConditionChip('Mint'),
            _buildConditionChip('Near Mint'),
            _buildConditionChip('Lightly Played'),
            _buildConditionChip('Damaged'),
          ],
        ),
      ],
    );
  }

  /// 构建Graded相关字段
  List<Widget> _buildGradedFields() {
    return [
      // Graded by 选择
      _buildGradedBySelection(),
      SizedBox(height: 40.h),
      // Grades 选择
      _buildGradesSelection(),
    ];
  }

  /// 构建Graded by选择区域
  Widget _buildGradedBySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Graded by',
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF919191),
          ),
        ),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 20.w,
          runSpacing: 12.h,
          children: [
            _buildGradedByChip('PSA'),
            _buildGradedByChip('BGS'),
            _buildGradedByChip('CGC'),
            _buildGradedByChip('PGC'),
          ],
        ),
      ],
    );
  }

  /// 构建Grades选择区域
  Widget _buildGradesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grades',
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF919191),
          ),
        ),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 20.w,
          runSpacing: 12.h,
          children: [
            _buildGradeChip('Black Label'),
          ],
        ),
      ],
    );
  }

  /// 构建Serial Number输入区域
  Widget _buildSerialNumberInput() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Serial Number',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: 显示帮助信息
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 24.sp,
                      color: Colors.green[600],
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Where to find',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(59.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serialNumberController,
                    onChanged: (value) {
                      setState(() {
                        _serialNumber = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter serial number',
                      hintStyle: TextStyle(
                        fontSize: 24.sp,
                        color: const Color(0xFF919191),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 20.h,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                // 相机图标
                GestureDetector(
                  onTap: () {
                    // TODO: 实现相机扫描功能
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    margin: EdgeInsets.only(right: 14.w),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 28.sp,
                      color: Colors.grey[600],
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

  /// 构建Condition选择芯片
  Widget _buildConditionChip(String condition) {
    final isSelected = _selectedCondition == condition;
    
    // 根据设计图设置不同宽度
    double width;
    switch (condition) {
      case 'Mint':
        width = 113.w;
        break;
      case 'Near Mint':
        width = 169.w;
        break;
      case 'Lightly Played':
        width = 212.w;
        break;
      case 'Damaged':
        width = 167.w;
        break;
      default:
        width = 113.w;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCondition = isSelected ? '' : condition;
        });
      },
      child: Container(
        height: 54.h,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? designGreen : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(47.r),
        ),
        child: Center(
          child: Text(
            condition,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  /// 构建Graded by选择芯片
  Widget _buildGradedByChip(String gradedBy) {
    final isSelected = _selectedGradedBy == gradedBy;
    
    // 根据设计图设置不同宽度
    double width;
    switch (gradedBy) {
      case 'PSA':
        width = 110.w;
        break;
      case 'BGS':
        width = 110.w;
        break;
      case 'CGC':
        width = 110.w;
        break;
      case 'PGC':
        width = 110.w;
        break;
      default:
        width = 110.w;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGradedBy = isSelected ? '' : gradedBy;
        });
      },
      child: Container(
        height: 54.h,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? designGreen : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(47.r),
        ),
        child: Center(
          child: Text(
            gradedBy,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  /// 构建Grade选择芯片
  Widget _buildGradeChip(String grade) {
    final isSelected = _selectedGrade == grade;
    
    // 根据设计图设置不同宽度
    double width;
    switch (grade) {
      case 'Black Label':
        width = 208.w; // 根据设计图调整
        break;
      default:
        width = 208.w;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGrade = isSelected ? '' : grade;
        });
      },
      child: Container(
        height: 54.h,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? designGreen : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(47.r),
        ),
        child: Center(
          child: Text(
            grade,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  /// 构建注意事项区域
  Widget _buildNoticeSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 24.sp,
          color: Colors.grey[400],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'Note: Make sure your information is accurate. Sellers will be responsible for any disputes caused by incorrect details.',
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.grey[400],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建Price & Stock区域
  Widget _buildPriceStockSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            'Price & Stock',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40.h),
          // 价格设置
          _buildPriceSection(),
          SizedBox(height: 40.h),
          // 库存设置
          _buildStockSection(),
        ],
      ),
    );
  }

  /// 构建价格设置区域
  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Set Price',
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF919191),
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFFD83333),
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        SizedBox(height: 13.h), // 按设计图调整间距
        Row(
          children: [
            Text(
              'RM',
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(width: 48.w), // 增加RM和输入框的间距
            Container(
              width: 113.w,
              height: 54.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(47.r),
              ),
              child: TextField(
                controller: _priceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 57.h), // 按设计图调整间距
        // 建议价格 - 精确定位
        Padding(
          padding: EdgeInsets.only(left: 222.w), // 按设计图定位
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 22.sp, fontFamily: 'Roboto'),
              children: const [
                TextSpan(
                  text: 'RM 12,123',
                  style: TextStyle(color: designOrange),
                ),
                TextSpan(
                  text: ' Suggested by PriceCharting',
                  style: TextStyle(color: Color(0xFFC1C1C1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建Graded类型的价格区域
  Widget _buildGradedPriceSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Price',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Text(
                'Set Price',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF919191),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          Row(
            children: [
              Text(
                'RM',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(width: 48.w),
              Container(
                width: 113.w,
                height: 54.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(47.r),
                ),
                child: TextField(
                  controller: _priceController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 24.sp,
                      color: const Color(0xFF919191),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建库存设置区域
  Widget _buildStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Stock',
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF919191),
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 13.h), // 按设计图调整间距
        Row(
          children: [
            // 减少按钮 - 按设计图样式
            GestureDetector(
              onTap: () {
                int currentStock = int.tryParse(_stockController.text) ?? 1;
                if (currentStock > 1) {
                  _stockController.text = (currentStock - 1).toString();
                }
              },
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    '−',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.w), // 按设计图调整间距
            // 数量输入框
            Container(
              width: 142.w,
              height: 54.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(47.r),
              ),
              child: TextField(
                controller: _stockController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(width: 20.w), // 按设计图调整间距
            // 增加按钮 - 按设计图样式
            GestureDetector(
              onTap: () {
                int currentStock = int.tryParse(_stockController.text) ?? 1;
                _stockController.text = (currentStock + 1).toString();
              },
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建Notes区域
  Widget _buildNotesSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes to Buyer',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40.h),
          Container(
            height: 183.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              maxLength: 50,
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Up to 50 characters',
                hintStyle: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFF919191),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20.w),
                counterText: '', // 隐藏默认计数器
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_notesController.text.length}/50',
              style: TextStyle(
                fontSize: 24.sp,
                color: const Color(0xFF919191),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建照片上传区域
  Widget _buildPhotoUploadSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和指导链接
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Item Photo (${_selectedImages.length}/2)',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 24.sp,
                    color: Colors.green[600],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Photo Guide',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40.h),
          // 照片上传区域
          _buildPhotoUploadArea(),
          SizedBox(height: 24.h),
          // 设为封面照片选项
          _buildCoverPhotoOption(),
        ],
      ),
    );
  }

  /// 构建照片上传区域
  Widget _buildPhotoUploadArea() {
    return Row(
      children: [
        // 已选择的图片
        ..._selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: _buildImageItem(image, index),
          );
        }).toList(),
        // 添加图片按钮（最多2张）
        if (_selectedImages.length < 2)
          Container(
            width: 136.w,
            height: 188.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFFF6B6B),
                width: 2.w,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: _pickImage,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 48.sp,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建单个图片项
  Widget _buildImageItem(File image, int index) {
    return Container(
      width: 136.w,
      height: 188.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              image,
              width: 136.w,
              height: 188.h,
              fit: BoxFit.cover,
            ),
          ),
          // 删除按钮
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 选择图片
  void _pickImage() async {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('最多只能选择2张图片'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 显示选择对话框
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('选择图片失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 显示图片来源选择对话框
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择图片来源', style: TextStyle(fontSize: 18.sp)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('相机'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('相册'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 移除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 构建设为封面照片选项
  Widget _buildCoverPhotoOption() {
    return Row(
      children: [
        Switch(
          value: _setCoverPhoto,
          onChanged: (value) {
            setState(() {
              _setCoverPhoto = value;
            });
          },
          activeColor: designGreen,
        ),
        SizedBox(width: 12.w),
        Text(
          'set as cover photo',
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF212222),
          ),
        ),
      ],
    );
  }

  /// 构建Done按钮区域
  Widget _buildDoneButtonSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      child: Center(
        child: Container(
          width: 540.w,
          height: 96.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onDonePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: designGreen,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Creating...',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                )
              : Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
          ),
        ),
      ),
    );
  }

  /// Done按钮点击处理
  void _onDonePressed() {
    // 验证必填字段
    if (_priceController.text.isEmpty) {
      _showErrorSnackBar('请设置价格');
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showErrorSnackBar('请输入有效的价格');
      return;
    }

    final stock = int.tryParse(_stockController.text);
    if (stock == null || stock <= 0) {
      _showErrorSnackBar('请输入有效的库存数量');
      return;
    }

    if (_selectedType == 'Raw' && _selectedCondition.isEmpty) {
      _showErrorSnackBar('请选择商品品质');
      return;
    }

    if (_selectedType == 'Graded') {
      if (_selectedGradedBy.isEmpty) {
        _showErrorSnackBar('请选择评级机构');
        return;
      }
      if (_selectedGrade.isEmpty) {
        _showErrorSnackBar('请选择等级');
        return;
      }
      if (_serialNumber.isEmpty) {
        _showErrorSnackBar('请输入序列号');
        return;
      }
    }

    // 构建商品详情数据
    final productDetail = _buildProductDetailData();
    
    // 显示确认对话框
    _showConfirmationDialog(productDetail);
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  /// 构建商品详情数据
  Map<String, dynamic> _buildProductDetailData() {
    return {
      'spuId': widget.spuId,
      'spuName': widget.spuName,
      'spuCode': widget.spuCode,
      'type': _selectedType,
      'condition': _selectedCondition,
      'gradedBy': _selectedGradedBy,
      'grade': _selectedGrade,
      'serialNumber': _serialNumber,
      'price': double.parse(_priceController.text),
      'stock': int.parse(_stockController.text),
      'notes': _notesController.text.trim(),
      'images': _selectedImages.map((file) => file.path).toList(),
      'setCoverPhoto': _setCoverPhoto,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// 显示确认对话框
  void _showConfirmationDialog(Map<String, dynamic> productDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: designGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: designGreen,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '确认创建商品',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmRow('商品名称', productDetail['spuName']),
                const SizedBox(height: 8),
                _buildConfirmRow('类型', productDetail['type']),
                if (productDetail['condition'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildConfirmRow('品质', productDetail['condition']),
                ],
                if (productDetail['gradedBy'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildConfirmRow('评级机构', productDetail['gradedBy']),
                ],
                if (productDetail['grade'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildConfirmRow('等级', productDetail['grade']),
                ],
                if (productDetail['serialNumber'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildConfirmRow('序列号', productDetail['serialNumber']),
                ],
                const SizedBox(height: 8),
                _buildConfirmRow('价格', 'RM ${productDetail['price']}'),
                const SizedBox(height: 8),
                _buildConfirmRow('库存', '${productDetail['stock']}'),
                if (productDetail['images'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildConfirmRow('图片', '${productDetail['images'].length} 张'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveProductDetail(productDetail);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: designGreen,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                '确认创建',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建确认信息行
  Widget _buildConfirmRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }

  /// 保存商品详情
  Future<void> _saveProductDetail(Map<String, dynamic> productDetail) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 构建创建参数 - 使用createProductInfo接口
      final createParams = CreateProductInfoParams(
        name: I18NString(
          chinese: widget.spuName,
          english: widget.spuName,
          japanese: widget.spuName,
        ),
        code: widget.spuCode,
        type: _getProductTypeFromString(_selectedType),
      );

      // 调用API创建商品信息
      final productId = await _productInfoService.createProductInfo(createParams);

      setState(() {
        _isLoading = false;
      });

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('商品创建成功，ID: $productId'),
          backgroundColor: designGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );

      // 返回上一页
      context.pop({'productId': productId, ...productDetail});

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('商品创建失败: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
  }

  /// 将字符串类型转换为ProductType枚举
  ProductType _getProductTypeFromString(String type) {
    switch (type) {
      case 'Raw':
        return ProductType.raw;
      case 'Sealed':
        return ProductType.sealed;
      case 'Graded':
        return ProductType.raw; // Graded类型暂时映射为raw
      default:
        return ProductType.raw;
    }
  }
}
