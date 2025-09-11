import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomActionButtons extends StatelessWidget {
  final VoidCallback? onAddProduct;
  final VoidCallback? onBulkAddProduct;
  final VoidCallback? onCreateBundle;

  const BottomActionButtons({
    super.key,
    this.onAddProduct,
    this.onBulkAddProduct,
    this.onCreateBundle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton('Add\nProduct', onAddProduct),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: _buildActionButton('Bulk Add\nProduct', onBulkAddProduct),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: _buildActionButton('Create\nBundle', onCreateBundle),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.h,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEBEBEB), width: 3.w),
          borderRadius: BorderRadius.circular(96.r),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF212222),
            ),
          ),
        ),
      ),
    );
  }
}
