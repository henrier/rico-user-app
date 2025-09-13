import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 批量编辑弹窗组件
class BulkEditDialog extends StatefulWidget {
  final String title;
  final Widget content;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const BulkEditDialog({
    super.key,
    required this.title,
    required this.content,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  });

  @override
  State<BulkEditDialog> createState() => _BulkEditDialogState();
}

class _BulkEditDialogState extends State<BulkEditDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 580.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Padding(
              padding: EdgeInsets.only(top: 50.h, bottom: 30.h),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212222),
                ),
              ),
            ),
            
            // 内容区域
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: widget.content,
            ),
            
            SizedBox(height: 50.h),
            
            // 底部按钮
            Padding(
              padding: EdgeInsets.only(
                left: 40.w,
                right: 40.w,
                bottom: 40.h,
              ),
              child: Row(
                children: [
                  // Cancel 按钮
                  Expanded(
                    child: Container(
                      height: 88.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFf4f4f4),
                        borderRadius: BorderRadius.circular(69.r),
                      ),
                      child: TextButton(
                        onPressed: widget.onCancel ?? () => Navigator.pop(context),
                        child: Text(
                          widget.cancelText,
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
                  
                  // Confirm 按钮
                  Expanded(
                    child: Container(
                      height: 88.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF0dee80),
                        borderRadius: BorderRadius.circular(66.r),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onConfirm?.call();
                        },
                        child: Text(
                          widget.confirmText,
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
          ],
        ),
      ),
    );
  }
}

/// 显示批量编辑弹窗
Future<T?> showBulkEditDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => BulkEditDialog(
      title: title,
      content: content,
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
}
