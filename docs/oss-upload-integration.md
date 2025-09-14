# 阿里云OSS上传功能集成指南

## 概述

本文档介绍如何在Rico User App中使用阿里云OSS（Object Storage Service）进行文件上传功能。

**当前状态：** 开发阶段 - 使用模拟上传功能，便于开发和测试。

## 功能特性

- ✅ 支持单文件和批量文件上传
- ✅ 自动图片压缩和格式验证
- ✅ 上传进度显示
- ✅ 错误处理和重试机制
- ✅ 文件大小限制检查
- ✅ 支持文件删除
- ✅ 唯一文件名生成

## 配置步骤

### 1. 添加依赖

在 `pubspec.yaml` 中已添加以下依赖：

```yaml
dependencies:
  # Network & Data
  dio: ^5.4.0
  http: ^1.1.0
  
  # File Upload & Storage
  crypto: ^3.0.3
  mime: ^1.0.4
  path_provider: ^2.1.1
```

### 2. 配置OSS参数

在 `lib/common/constants/app_constants.dart` 中配置OSS相关参数：

```dart
// 阿里云OSS配置
static const String ossEndpoint = 'https://oss-cn-hangzhou.aliyuncs.com';
static const String ossBucketName = 'rico-user-app';
static const String ossAccessKeyId = 'YOUR_ACCESS_KEY_ID'; // 需要替换为实际的AccessKeyId
static const String ossAccessKeySecret = 'YOUR_ACCESS_KEY_SECRET'; // 需要替换为实际的AccessKeySecret
static const String ossImageFolder = 'images/products/';
static const int ossMaxFileSize = 10 * 1024 * 1024; // 10MB
```

**重要：** 请将 `YOUR_ACCESS_KEY_ID` 和 `YOUR_ACCESS_KEY_SECRET` 替换为你的阿里云OSS实际凭证。

## 当前实现说明

**开发阶段模拟功能：**

当前的OSS上传功能使用模拟实现，主要用于：
- 开发阶段的功能测试
- UI交互流程验证
- 避免在开发过程中产生实际的OSS费用

模拟功能包括：
- ✅ 文件选择和验证
- ✅ 上传进度显示
- ✅ 成功/失败状态反馈
- ✅ 生成模拟的OSS URL格式

**生产环境建议：**

在生产环境中，建议：
1. 使用后端API处理文件上传，避免在客户端暴露OSS凭证
2. 实现STS临时凭证机制
3. 添加文件安全扫描
4. 配置CDN加速访问

### 3. 安全建议

为了安全起见，建议：

1. **不要将AccessKey直接写在代码中**，可以考虑：
   - 使用环境变量
   - 使用STS临时凭证
   - 通过后端API获取上传凭证

2. **配置OSS Bucket权限**：
   - 设置合适的CORS规则
   - 配置访问权限策略
   - 启用防盗链保护

## 使用方法

### 基本用法

```dart
import '../../api/oss_api.dart';

// 初始化OSS客户端
final ossApi = OssApi();

// 上传单个文件
try {
  final String url = await ossApi.uploadFile(
    file,
    folder: 'images/products/',
  );
  print('上传成功: $url');
} catch (e) {
  print('上传失败: $e');
}

// 批量上传文件
try {
  final List<String> urls = await ossApi.uploadFiles(
    files,
    folder: 'images/products/',
    onProgress: (current, total, currentUrl) {
      print('上传进度: $current/$total');
    },
  );
  print('批量上传完成: $urls');
} catch (e) {
  print('批量上传失败: $e');
}
```

### 在产品详情页面中的集成

在 `product_detail_create_screen.dart` 中，`_processImages` 方法已经集成了OSS上传功能：

```dart
Future<List<String>> _processImages(List<File> imageFiles) async {
  // 自动处理图片上传到OSS
  // 包含进度显示、错误处理等完整流程
}
```

## API 参考

### OssApi 类

#### 主要方法

- `initialize()`: 初始化OSS客户端
- `uploadFile(File file, {String? folder, String? fileName})`: 上传单个文件
- `uploadFiles(List<File> files, {String? folder, Function? onProgress})`: 批量上传文件
- `deleteFile(String objectKey)`: 删除文件
- `compressImage(File file, {int quality, int maxWidth, int maxHeight})`: 压缩图片
- `validateFileType(File file, List<String> allowedTypes)`: 验证文件类型

#### 支持的图片格式

```dart
static List<String> get supportedImageTypes => [
  'image/jpeg',
  'image/jpg', 
  'image/png',
  'image/gif',
  'image/webp',
];
```

### 配置参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `ossEndpoint` | OSS服务端点 | `https://oss-cn-hangzhou.aliyuncs.com` |
| `ossBucketName` | OSS存储桶名称 | `rico-user-app` |
| `ossImageFolder` | 图片存储文件夹 | `images/products/` |
| `ossMaxFileSize` | 最大文件大小 | `10MB` |

## 错误处理

### 常见错误及解决方案

1. **AccessKey配置错误**
   ```
   错误: 403 Forbidden
   解决: 检查AccessKeyId和AccessKeySecret是否正确
   ```

2. **文件大小超限**
   ```
   错误: 文件大小超过限制
   解决: 检查文件大小是否超过10MB限制
   ```

3. **网络连接问题**
   ```
   错误: Network connection error
   解决: 检查网络连接，重试上传
   ```

4. **文件格式不支持**
   ```
   错误: 不支持的图片格式
   解决: 确保文件格式为 JPEG、PNG、GIF 或 WebP
   ```

## 性能优化

### 图片压缩

系统会自动对上传的图片进行压缩：

- 质量：85%
- 最大宽度：1024px
- 最大高度：1024px

### 文件命名策略

上传的文件会自动生成唯一文件名：

```
格式: {timestamp}_{randomString}.{extension}
示例: 1703123456789_abc12345.jpg
```

## 监控和日志

### 日志记录

所有上传操作都会记录详细日志：

```dart
AppLogger.info('文件上传成功: $url');
AppLogger.error('文件上传失败: $error');
AppLogger.warning('不支持的图片格式: $path');
```

### 上传进度追踪

批量上传时可以监控进度：

```dart
onProgress: (current, total, currentUrl) {
  double progress = current / total;
  print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
}
```

## 测试

### 单元测试

可以为OSS上传功能编写单元测试：

```dart
// test/unit/oss_api_test.dart
void main() {
  group('OssApi Tests', () {
    test('should validate image file types', () {
      final ossApi = OssApi();
      final file = File('test.jpg');
      
      expect(
        ossApi.validateFileType(file, OssApi.supportedImageTypes),
        isTrue,
      );
    });
  });
}
```

## 故障排除

### 调试步骤

1. **检查网络连接**
2. **验证OSS配置参数**
3. **查看应用日志**
4. **测试文件权限**
5. **检查OSS控制台**

### 常用调试命令

```bash
# 检查依赖是否正确安装
flutter pub deps

# 清理并重新获取依赖
flutter clean && flutter pub get

# 查看详细错误日志
flutter logs
```

## 更新日志

### v1.0.0 (2024-01-01)
- ✅ 初始版本发布
- ✅ 支持基本的文件上传功能
- ✅ 集成图片压缩和验证
- ✅ 添加批量上传支持
- ✅ 实现错误处理和进度显示

## 相关文档

- [阿里云OSS官方文档](https://help.aliyun.com/product/31815.html)
- [Flutter OSS SDK文档](https://pub.dev/packages/oss_flutter_sdk)
- [项目API集成文档](./api-integration-summary.md)
