import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  List<File> _selectedImages = [];
  bool _setCoverPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();

  // 设计图中的络色
  static const Color designGreen = Color(0xFF0DEE80);
  static const Color designOrange = Color(0xFFF86700);

  @override
  void initState() {
    super.initState();
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
                // Price & Stock 区域
                _buildPriceStockSection(),
                // 分隔条
                _buildSectionDivider(),
                // Notes to Buyer 区域
                _buildNotesSection(),
                // 分隔条
                _buildSectionDivider(),
                // Upload Item Photo 区域
                _buildPhotoUploadSection(),
                // 底部间距
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      // 固定底部按钮
      floatingActionButton: _buildDoneButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 构建SliverAppBar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      toolbarHeight: 88, // 设计图中的高度
      leading: Container(
        margin: const EdgeInsets.only(left: 26, top: 12, bottom: 12),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[700],
            size: 20,
          ),
          onPressed: () => context.pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: const Text(
        'Edit Listing',
        style: TextStyle(
          color: Color(0xFF212222),
          fontSize: 36,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      // 添加底部边框
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  /// 构建商品信息展示区域
  Widget _buildProductInfoSection() {
    return Container(
      color: Colors.white,
      height: 257, // 设计图中的高度
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片 - 按设计图尺寸
          Container(
            width: 136,
            height: 188,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: widget.spuImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.spuImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    ),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 24), // 设计图中的间距
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12), // 顶部对齐调整
                // 商品名称 - 精确字体大小
                Text(
                  widget.spuName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212222),
                    height: 1.2,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 商品编码和稀有度 - 分开显示
                Row(
                  children: [
                    Text(
                      widget.spuCode,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF919191),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Text(
                      'Rainbow',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF919191),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32), // 增加间距
                // 标签区域 - 按设计图样式
                Row(
                  children: [
                    _buildInfoTag('Pokémon'),
                    const SizedBox(width: 12),
                    _buildInfoTag('EN'),
                  ],
                ),
                const SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: 48,
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoTag(String text) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF919191),
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  /// 构建Card Info按钮
  Widget _buildCardInfoButton() {
    return Container(
      height: 44,
      width: 169, // 设计图中的宽度
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Card Info',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(width: 8),
          Transform.rotate(
            angle: 0.785398, // 45度旋转，匹配设计图
            child: Icon(
              Icons.add,
              size: 16,
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
      height: 20,
      color: const Color(0xFFF4F4F6),
    );
  }

  /// 构建Type & Condition区域
  Widget _buildTypeConditionSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和指导链接
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Type & Condition',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 24,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Condition guide',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Type选择
          _buildTypeSelection(),
          const SizedBox(height: 40),
          // Condition选择（仅在Raw类型时显示）
          if (_selectedType == 'Raw') _buildConditionSelection(),
          const SizedBox(height: 40),
          // 注意事项
          _buildNoticeSection(),
        ],
      ),
    );
  }

  /// 构建Type选择区域
  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF919191),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _buildTypeChip('Raw', true),
            _buildTypeChip('Graded', false),
            _buildTypeChip('Sealed', false),
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
        width = 110;
        break;
      case 'Graded':
        width = 141;
        break;
      case 'Sealed':
        width = 137;
        break;
      default:
        width = 110;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // 切换类型时清空条件选择
          _selectedCondition = '';
          _selectedGradedBy = '';
        });
      },
      child: Container(
        height: 54,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? designGreen : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(47),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 24,
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
        const Text(
          'Graded by',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF919191),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 12,
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

  /// 构建Condition选择芯片
  Widget _buildConditionChip(String condition) {
    final isSelected = _selectedCondition == condition;
    
    // 根据设计图设置不同宽度
    double width;
    switch (condition) {
      case 'Mint':
        width = 113;
        break;
      case 'Near Mint':
        width = 169;
        break;
      case 'Lightly Played':
        width = 212;
        break;
      case 'Damaged':
        width = 167;
        break;
      default:
        width = 113;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCondition = isSelected ? '' : condition;
        });
      },
      child: Container(
        height: 54,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? designGreen : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(47),
        ),
        child: Center(
          child: Text(
            condition,
            style: TextStyle(
              fontSize: 24,
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
          size: 24,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Note: Make sure your information is accurate. Sellers will be responsible for any disputes caused by incorrect details.',
            style: TextStyle(
              fontSize: 24,
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
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Text(
            'Price & Stock',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          // 价格设置
          _buildPriceSection(),
          const SizedBox(height: 40),
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
        const Row(
          children: [
            Text(
              'Set Price',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF919191),
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFFD83333),
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        const SizedBox(height: 13), // 按设计图调整间距
        Row(
          children: [
            const Text(
              'RM',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(width: 48), // 增加RM和输入框的间距
            Container(
              width: 113,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(47),
              ),
              child: TextField(
                controller: _priceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
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
        const SizedBox(height: 57), // 按设计图调整间距
        // 建议价格 - 精确定位
        Padding(
          padding: const EdgeInsets.only(left: 222), // 按设计图定位
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 22, fontFamily: 'Roboto'),
              children: [
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

  /// 构建库存设置区域
  Widget _buildStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Stock',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF919191),
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 13), // 按设计图调整间距
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
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: const Center(
                  child: Text(
                    '−',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20), // 按设计图调整间距
            // 数量输入框
            Container(
              width: 142,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(47),
              ),
              child: TextField(
                controller: _stockController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 20), // 按设计图调整间距
            // 增加按钮 - 按设计图样式
            GestureDetector(
              onTap: () {
                int currentStock = int.tryParse(_stockController.text) ?? 1;
                _stockController.text = (currentStock + 1).toString();
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 24,
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
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes to Buyer',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            height: 183,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              maxLength: 50,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Up to 50 characters',
                hintStyle: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF919191),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
                counterText: '', // 隐藏默认计数器
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_notesController.text.length}/50',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF919191),
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
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和指导链接
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Item Photo (${_selectedImages.length}/2)',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 24,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Photo Guide',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          // 照片上传区域
          _buildPhotoUploadArea(),
          const SizedBox(height: 24),
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
            margin: const EdgeInsets.only(right: 12),
            child: _buildImageItem(image, index),
          );
        }).toList(),
        // 添加图片按钮（最多2张）
        if (_selectedImages.length < 2)
          Container(
            width: 136,
            height: 188,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFFF6B6B),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickImage,
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 48,
                    color: Color(0xFFFF6B6B),
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
      width: 136,
      height: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: 136,
              height: 188,
              fit: BoxFit.cover,
            ),
          ),
          // 删除按钮
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
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
          title: const Text('选择图片来源'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
        const SizedBox(width: 12),
        const Text(
          'set as cover photo',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF212222),
          ),
        ),
      ],
    );
  }

  /// 构建Done按钮
  Widget _buildDoneButton() {
    return Container(
      width: 540,
      height: 96,
      margin: const EdgeInsets.only(bottom: 68), // 按设计图底部间距
      child: ElevatedButton(
        onPressed: _onDonePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: designGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
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
          borderRadius: BorderRadius.circular(10),
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
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: designGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: designGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '确认创建商品',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveProductDetail(productDetail);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: designGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '确认创建',
                style: TextStyle(
                  fontSize: 16,
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

  /// 保存商品详情
  void _saveProductDetail(Map<String, dynamic> productDetail) {
    // TODO: 实现实际的保存逻辑，可能需要调用API或保存到本地数据库
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('商品详情创建成功'),
        backgroundColor: designGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );

    // 返回上一页
    context.pop(productDetail);
  }
}
