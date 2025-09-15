# 批量添加商品页面图片上传功能

## 概述

为批量添加商品页面集成了完整的图片上传功能，支持每个商品最多上传2张图片，并集成了阿里云OSS上传服务。

## 功能特性

### ✅ 已实现功能

- **图片显示逻辑**：
  - 无图片时显示加号和"(0/2)"提示，点击可选择图片
  - 有图片时显示单张图片，只能通过Photo按钮继续上传
  - 有2张图片时显示左右切换按钮和"1/2"或"2/2"指示器

- **图片上传方式**：
  - 无图片时：点击加号区域选择图片
  - 有图片时：只能通过Photo按钮选择图片
  - 支持相机拍照和相册选择

- **图片管理**：
  - 每个商品最多2张图片
  - 右上角删除按钮可删除当前显示的图片
  - 左右切换按钮浏览多张图片
  - 图片数量指示器显示当前位置
  - 自动上传到阿里云OSS
  - 图片压缩和格式验证

- **用户反馈**：
  - 上传成功/失败提示
  - 图片数量限制提示
  - 删除确认反馈

## 技术实现

### 核心组件

1. **图片状态管理**
   ```dart
   // 每个商品的图片列表（最多2张）
   List<List<File>> _productImages = [];
   
   // 每个商品当前显示的图片索引
   List<int> _currentImageIndexes = [];
   
   // 图片选择器
   final ImagePicker _imagePicker = ImagePicker();
   ```

2. **图片显示区域**
   ```dart
   Widget _buildImageDisplayArea(int productIndex) {
     // 根据图片数量显示不同UI
     // 0张：显示加号和提示，可点击选择
     // 有图片：显示当前图片，带切换按钮和指示器
   }
   ```

3. **图片切换功能**
   ```dart
   void _switchImage(int productIndex, int direction) {
     // 切换当前显示的图片
     // direction: -1向左，1向右
   }
   ```

### 主要方法

#### 图片选择
```dart
Future<void> _pickImageForProduct(int productIndex) async {
  // 1. 检查图片数量限制
  // 2. 显示图片来源选择对话框
  // 3. 选择图片并添加到列表
  // 4. 自动上传到OSS
}
```

#### 图片删除
```dart
void _removeImageFromProduct(int productIndex, int imageIndex) {
  // 从图片列表中移除指定图片
}
```

#### OSS上传
```dart
Future<void> _uploadImageToOss(File imageFile, int productIndex) async {
  // 1. 验证文件类型
  // 2. 压缩图片
  // 3. 上传到OSS
  // 4. 更新商品图片URL列表
}
```

## 用户交互流程

### 添加图片流程
1. **无图片时**：点击加号区域选择图片
2. **有图片时**：只能通过Photo按钮选择图片
3. 选择图片来源（相机/相册）
4. 选择图片后自动添加到界面
5. 后台自动上传到OSS
6. 显示上传成功提示

### 浏览图片流程
1. 当有2张图片时，显示左右切换按钮
2. 点击左右按钮切换图片
3. 左上角显示当前图片位置"1/2"或"2/2"
4. 第一张图片时隐藏左按钮，最后一张图片时隐藏右按钮

### 删除图片流程
1. 用户点击当前显示图片右上角的删除按钮
2. 删除当前显示的图片
3. 自动调整显示索引到有效范围
4. 显示删除成功提示

## UI设计规范

### 图片显示区域
- **尺寸**：164w × 228h
- **圆角**：8.r
- **边框**：灰色边框，无图片时红色边框

### 删除按钮
- **尺寸**：20w × 20h
- **位置**：右上角，距离边缘4w/4h
- **样式**：红色圆形背景，白色关闭图标

### 添加按钮
- **图标**：加号图标
- **颜色**：灰色 (#b5b5b7)
- **提示文字**：显示当前图片数量 "(0/2)"

### 图片切换按钮
- **尺寸**：33w × 33h
- **样式**：白色圆形背景，带阴影
- **位置**：左右两侧居中
- **图标**：左右箭头图标

### 图片指示器
- **背景**：黑色半透明 (opacity: 0.8)
- **位置**：左上角，距离边缘8w/8h
- **文字**：白色，显示"1/2"或"2/2"

## 错误处理

### 图片数量限制
```dart
if (images.length >= 2) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('每个商品最多只能选择2张图片'),
      backgroundColor: Colors.orange,
    ),
  );
  return;
}
```

### 文件格式验证
```dart
if (!ossApi.validateFileType(imageFile, OssApi.supportedImageTypes)) {
  AppLogger.warning('不支持的图片格式: ${imageFile.path}');
  // 显示错误提示
  return;
}
```

### 上传失败处理
```dart
catch (e) {
  AppLogger.error('图片上传失败: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('图片上传失败: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## 性能优化

### 图片压缩
- **质量**：85%
- **最大尺寸**：1024×1024px
- **自动压缩**：选择图片后自动压缩

### 内存管理
- 使用`File`对象管理本地图片
- 及时释放不需要的图片资源
- 避免内存泄漏

## 集成说明

### 依赖项
```yaml
dependencies:
  image_picker: ^1.0.4  # 图片选择
  # OSS相关依赖已在oss-upload-integration.md中说明
```

### 导入文件
```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../api/oss_api.dart';
import '../../common/utils/logger.dart';
```

## 测试建议

### 功能测试
1. **图片选择测试**
   - 测试相机拍照功能
   - 测试相册选择功能
   - 测试图片数量限制

2. **图片显示测试**
   - 测试无图片状态显示
   - 测试单张图片显示
   - 测试双张图片切换显示

3. **图片切换测试**
   - 测试左右切换按钮功能
   - 测试图片指示器显示
   - 测试边界情况（第一张/最后一张）

4. **图片删除测试**
   - 测试删除当前显示图片
   - 测试删除后索引调整
   - 测试删除后重新添加

5. **OSS上传测试**
   - 测试上传成功场景
   - 测试网络异常场景
   - 测试文件格式验证

### 边界测试
- 测试超过2张图片的限制
- 测试不支持的文件格式
- 测试网络断开情况
- 测试大文件上传

## 后续优化建议

1. **批量上传优化**
   - 支持同时选择多张图片
   - 批量上传进度显示

2. **图片预览功能**
   - 点击图片查看大图
   - 支持图片缩放和旋转

3. **图片编辑功能**
   - 支持图片裁剪
   - 支持图片滤镜

4. **离线支持**
   - 离线时保存图片
   - 网络恢复后自动上传

## 相关文档

- [OSS上传集成指南](./oss-upload-integration.md)
- [图片选择器使用指南](https://pub.dev/packages/image_picker)
- [Flutter ScreenUtil使用指南](./flutter_screenutil_usage.md)
