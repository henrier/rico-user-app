import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../common/constants/app_constants.dart';
import '../common/utils/logger.dart';

/// 阿里云OSS上传服务
/// 简化版本，用于演示和开发阶段
class OssApi {
  static final OssApi _instance = OssApi._internal();
  factory OssApi() => _instance;
  OssApi._internal();

  late Dio _dio;
  bool _isInitialized = false;

  /// 初始化HTTP客户端
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _dio = Dio();
      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 30);
      _isInitialized = true;
      
      AppLogger.info('OSS HTTP客户端初始化成功');
    } catch (e) {
      AppLogger.error('OSS HTTP客户端初始化失败: $e');
      rethrow;
    }
  }

  /// 上传单个文件
  /// 
  /// 注意：这是一个简化的实现，用于开发阶段
  /// 在生产环境中，建议使用后端API来处理文件上传
  /// 
  /// [file] 要上传的文件
  /// [folder] 存储文件夹路径，默认为产品图片文件夹
  /// [fileName] 自定义文件名，如果不提供则使用时间戳生成
  /// 
  /// 返回上传成功后的文件URL（模拟）
  Future<String> uploadFile(
    File file, {
    String? folder,
    String? fileName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Web环境下的特殊处理
      if (kIsWeb) {
        AppLogger.info('Web环境：跳过文件大小检查');
        // 在Web环境下，我们无法直接获取文件大小，所以跳过检查
      } else {
        // 检查文件大小（仅在非Web环境）
        final fileSize = await file.length();
        if (fileSize > AppConstants.ossMaxFileSize) {
          throw Exception('文件大小超过限制 (${AppConstants.ossMaxFileSize / 1024 / 1024}MB)');
        }
      }

      // 生成文件名
      final String finalFileName = fileName ?? _generateFileName(file.path);
      final String folderPath = folder ?? AppConstants.ossImageFolder;
      final String objectKey = '$folderPath$finalFileName';

      AppLogger.info('开始模拟上传文件: $objectKey');

      // 模拟上传延迟
      await Future.delayed(const Duration(milliseconds: 1500));

      // 生成模拟的OSS URL
      final String fileUrl = '${AppConstants.ossEndpoint.replaceAll('https://', 'https://${AppConstants.ossBucketName}.')}/$objectKey';
      
      AppLogger.info('文件模拟上传成功: $fileUrl');
      return fileUrl;

    } catch (e) {
      AppLogger.error('文件上传失败: $e');
      
      // 提供更详细的错误信息
      if (e.toString().contains('_Namespace')) {
        AppLogger.error('检测到Web环境文件操作错误，这通常发生在Web环境下使用File对象时');
        throw Exception('Web环境不支持此文件操作，请检查平台兼容性');
      }
      
      rethrow;
    }
  }

  /// Web兼容的文件上传方法
  /// 
  /// [fileBytes] 文件的字节数据
  /// [fileName] 文件名
  /// [folder] 存储文件夹路径
  /// 
  /// 返回上传成功后的文件URL（模拟）
  Future<String> uploadFileBytes(
    Uint8List fileBytes, {
    required String fileName,
    String? folder,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // 检查文件大小
      if (fileBytes.length > AppConstants.ossMaxFileSize) {
        throw Exception('文件大小超过限制 (${AppConstants.ossMaxFileSize / 1024 / 1024}MB)');
      }

      // 生成文件名
      final String finalFileName = fileName;
      final String folderPath = folder ?? AppConstants.ossImageFolder;
      final String objectKey = '$folderPath$finalFileName';

      AppLogger.info('开始模拟上传文件字节: $objectKey');

      // 模拟上传延迟
      await Future.delayed(const Duration(milliseconds: 1500));

      // 生成模拟的OSS URL
      final String fileUrl = '${AppConstants.ossEndpoint.replaceAll('https://', 'https://${AppConstants.ossBucketName}.')}/$objectKey';
      
      AppLogger.info('文件字节模拟上传成功: $fileUrl');
      return fileUrl;

    } catch (e) {
      AppLogger.error('文件字节上传失败: $e');
      rethrow;
    }
  }

  /// 批量上传文件
  /// 
  /// [files] 要上传的文件列表
  /// [folder] 存储文件夹路径
  /// [onProgress] 上传进度回调，参数为 (当前索引, 总数, 当前文件URL)
  /// 
  /// 返回所有上传成功的文件URL列表
  Future<List<String>> uploadFiles(
    List<File> files, {
    String? folder,
    Function(int current, int total, String? currentUrl)? onProgress,
  }) async {
    if (files.isEmpty) return [];

    final List<String> uploadedUrls = [];
    
    for (int i = 0; i < files.length; i++) {
      try {
        onProgress?.call(i, files.length, null);
        
        final String url = await uploadFile(
          files[i],
          folder: folder,
        );
        
        uploadedUrls.add(url);
        onProgress?.call(i + 1, files.length, url);
        
        AppLogger.info('批量上传进度: ${i + 1}/${files.length}');
      } catch (e) {
        AppLogger.error('批量上传第${i + 1}个文件失败: $e');
        // 继续上传其他文件，不中断整个过程
        onProgress?.call(i + 1, files.length, null);
      }
    }

    return uploadedUrls;
  }

  /// 删除文件（模拟）
  /// 
  /// [objectKey] OSS中的文件键名
  Future<bool> deleteFile(String objectKey) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      AppLogger.info('模拟删除文件: $objectKey');
      // 模拟删除延迟
      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.info('文件模拟删除成功: $objectKey');
      return true;
    } catch (e) {
      AppLogger.error('文件删除失败: $e');
      return false;
    }
  }

  /// 从URL中提取OSS对象键名
  /// 
  /// [url] 完整的OSS文件URL
  /// 返回对象键名，用于删除文件
  String extractObjectKeyFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // 移除开头的 '/' 
      return uri.path.substring(1);
    } catch (e) {
      AppLogger.error('解析URL失败: $e');
      return '';
    }
  }

  /// 生成唯一文件名
  /// 
  /// [originalPath] 原始文件路径
  /// 返回格式: timestamp_randomString.extension
  String _generateFileName(String originalPath) {
    try {
      if (kIsWeb) {
        // Web环境下，可能无法获取文件路径，使用默认扩展名
        final int timestamp = DateTime.now().millisecondsSinceEpoch;
        final String randomString = _generateRandomString(8);
        return '${timestamp}_$randomString.jpg'; // 默认使用jpg扩展名
      } else {
        final String extension = originalPath.split('.').last.toLowerCase();
        final int timestamp = DateTime.now().millisecondsSinceEpoch;
        final String randomString = _generateRandomString(8);
        return '${timestamp}_$randomString.$extension';
      }
    } catch (e) {
      // 如果解析路径失败，使用默认文件名
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String randomString = _generateRandomString(8);
      return '${timestamp}_$randomString.jpg';
    }
  }

  /// 生成随机字符串
  String _generateRandomString(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// 压缩图片文件（模拟）
  /// 
  /// [file] 原始图片文件
  /// [quality] 压缩质量 (0-100)
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// 
  /// 返回压缩后的文件（当前返回原文件）
  Future<File> compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    // Web环境下的特殊处理
    if (kIsWeb) {
      AppLogger.info('Web环境：跳过图片压缩');
      // 在Web环境下，直接返回原文件
      return file;
    } else {
      // 这里可以集成图片压缩库，如 flutter_image_compress
      // 目前先返回原文件，后续可以根据需要添加压缩逻辑
      AppLogger.info('模拟图片压缩: ${file.path}');
      return file;
    }
  }

  /// 验证文件类型
  /// 
  /// [file] 要验证的文件
  /// [allowedTypes] 允许的MIME类型列表
  bool validateFileType(File file, List<String> allowedTypes) {
    // Web环境下的特殊处理
    if (kIsWeb) {
      AppLogger.info('Web环境：跳过文件类型验证');
      // 在Web环境下，我们暂时跳过文件类型验证
      // 实际应用中可以通过其他方式验证
      return true;
    } else {
      final String? mimeType = lookupMimeType(file.path);
      if (mimeType == null) return false;
      
      return allowedTypes.contains(mimeType);
    }
  }

  /// 获取支持的图片类型
  static List<String> get supportedImageTypes => [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/webp',
  ];
}

/// OSS上传结果
class OssUploadResult {
  final bool success;
  final String? url;
  final String? error;
  final String? objectKey;

  const OssUploadResult({
    required this.success,
    this.url,
    this.error,
    this.objectKey,
  });

  factory OssUploadResult.success(String url, String objectKey) {
    return OssUploadResult(
      success: true,
      url: url,
      objectKey: objectKey,
    );
  }

  factory OssUploadResult.failure(String error) {
    return OssUploadResult(
      success: false,
      error: error,
    );
  }
}

/// OSS上传进度信息
class OssUploadProgress {
  final int current;
  final int total;
  final String? currentFileName;
  final String? currentUrl;
  final double progress;

  const OssUploadProgress({
    required this.current,
    required this.total,
    this.currentFileName,
    this.currentUrl,
    required this.progress,
  });

  factory OssUploadProgress.create(
    int current,
    int total, {
    String? currentFileName,
    String? currentUrl,
  }) {
    return OssUploadProgress(
      current: current,
      total: total,
      currentFileName: currentFileName,
      currentUrl: currentUrl,
      progress: total > 0 ? current / total : 0.0,
    );
  }
}