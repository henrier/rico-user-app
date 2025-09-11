import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String code;
  final String type;
  final String price;
  final String condition;
  final String quantity;
  final String? grade;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.code,
    required this.type,
    required this.price,
    required this.condition,
    required this.quantity,
    this.grade,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            // 商品图片
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(
                Icons.image,
                color: Color(0xFF9E9E9E),
                size: 40,
              ),
            ),
            
            SizedBox(width: 20.w),
            
            // 商品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF212222),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: const Color(0xFF919191),
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 19.h,
                        color: const Color(0xFF919191),
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: const Color(0xFF919191),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF919191)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          condition,
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: const Color(0xFF919191),
                          ),
                        ),
                      ),
                      if (grade != null) ...[
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4D5862), Color(0xFF737373)],
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            grade!,
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // 价格和数量
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF86700),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D5862), Color(0xFF737373)],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    quantity,
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
