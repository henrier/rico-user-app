import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/personalproduct/data.dart';

class SelectableProductItem extends StatelessWidget {
  final PersonalProduct product;
  final bool isSelected;
  final VoidCallback onSelectionChanged;

  const SelectableProductItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 274.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      child: Row(
        children: [
          // 选择按钮
          GestureDetector(
            onTap: onSelectionChanged,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF00D86F) : const Color(0xFFD3D3D3),
                  width: 2.w,
                ),
                color: isSelected ? const Color(0xFF00D86F) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20.w,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          
          SizedBox(width: 24.w),
          
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
                        return _buildPlaceholderImage();
                      },
                    ),
                  )
                : _buildPlaceholderImage(),
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
                      product.productInfo.code ?? 'DRI-031/182',
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
                      'Holo',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: const Color(0xFF919191),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // 价格
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
                        text: ' ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF86700),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // 底部信息：品质和数量
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
                    
                    // 数量标签
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Stack(
      children: [
        // 背景
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        
        // 卡片图案 - 模拟Figma中的Pokémon卡片
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.3),
                  Colors.green.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 模拟卡片中心的图案
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow.withOpacity(0.8),
                      border: Border.all(
                        color: Colors.orange,
                        width: 2.w,
                      ),
                    ),
                    child: Icon(
                      Icons.star,
                      size: 40.w,
                      color: Colors.orange,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // 模拟卡片名称区域
                  Container(
                    width: 120.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // 模拟卡片信息区域
                  Container(
                    width: 100.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 获取品相显示名称
  String _getConditionDisplayName(PersonalProductCondition condition) {
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
