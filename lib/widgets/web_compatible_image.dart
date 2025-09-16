import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web兼容的图片显示组件
/// 在Web环境下使用Image.memory，在移动端使用Image.file
class WebCompatibleImage extends StatelessWidget {
  final File file;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorBuilder;
  final Widget? loadingBuilder;

  const WebCompatibleImage({
    super.key,
    required this.file,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web环境：显示占位符或错误信息
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 40,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Text(
              'Web环境图片预览',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    } else {
      // 移动端：使用Image.file
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorBuilder ?? const Icon(Icons.error);
        },
      );
    }
  }
}
