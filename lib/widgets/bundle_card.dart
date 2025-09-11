import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BundleCard extends StatelessWidget {
  final String title;
  final String price;
  final String originalPrice;
  final String days;
  final String hours;
  final String minutes;
  final String seconds;
  final VoidCallback? onTap;

  const BundleCard({
    super.key,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 281.h,
        width: 432.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片区域
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildProductImage()),
                    Expanded(child: _buildProductImage()),
                    Expanded(child: _buildProductImage()),
                    Expanded(child: _buildProductImage()),
                  ],
                ),
              ),
            ),
            
            // 商品信息
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF212222),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF86700),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: const Color(0xFFC1C1C1),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // 时间信息
                    Row(
                      children: [
                        _buildTimeItem(days, 'D'),
                        SizedBox(width: 8.w),
                        _buildTimeItem(hours, 'H'),
                        SizedBox(width: 8.w),
                        _buildTimeItem(minutes, 'M'),
                        SizedBox(width: 8.w),
                        _buildTimeItem(seconds, 'S'),
                      ],
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

  Widget _buildProductImage() {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Icon(
        Icons.image,
        color: Color(0xFF9E9E9E),
      ),
    );
  }

  Widget _buildTimeItem(String value, String label) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              color: const Color(0xFF212222),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 22.sp,
              color: const Color(0xFF919191),
            ),
          ),
        ],
      ),
    );
  }
}
