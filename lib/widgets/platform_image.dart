import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 跨平台图片显示组件
/// 在Web环境下使用Image.memory，在移动端使用Image.file
class PlatformImage extends StatelessWidget {
  final File file;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorBuilder;
  final Widget? loadingBuilder;

  const PlatformImage({
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
      // Web环境：使用Image.memory
      return FutureBuilder<Uint8List>(
        future: _fileToBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingBuilder ?? const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return errorBuilder ?? const Icon(Icons.error);
          }
          
          final bytes = snapshot.data;
          if (bytes == null) {
            return errorBuilder ?? const Icon(Icons.error);
          }
          
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorBuilder ?? const Icon(Icons.error);
            },
          );
        },
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

  /// 将File转换为Uint8List（用于Web环境）
  Future<Uint8List> _fileToBytes() async {
    try {
      if (kIsWeb) {
        // Web环境下，File对象可能不支持readAsBytes
        // 这里我们需要一个替代方案
        throw Exception('Web环境下File.readAsBytes()不支持，请使用其他方式获取图片数据');
      } else {
        return await file.readAsBytes();
      }
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }
}
