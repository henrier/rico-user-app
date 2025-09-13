import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulkActionBottomSheet extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onBulkUnpublish;
  final VoidCallback onBulkDelete;
  final VoidCallback onBulkEdit;
  final VoidCallback onCreateBundle;

  const BulkActionBottomSheet({
    super.key,
    required this.selectedCount,
    required this.onBulkUnpublish,
    required this.onBulkDelete,
    required this.onBulkEdit,
    required this.onCreateBundle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部指示器
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // 选中数量提示
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              '已选择 $selectedCount 个商品',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF919191),
              ),
            ),
          ),
          
          // 操作按钮
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Bulk\nUnpublish',
                    onBulkUnpublish,
                  ),
                  _buildActionButton(
                    'Bulk\nDelete',
                    onBulkDelete,
                  ),
                  _buildActionButton(
                    'Bulk\nEdit',
                    onBulkEdit,
                  ),
                  _buildActionButton(
                    'Create\nBundle',
                    onCreateBundle,
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
