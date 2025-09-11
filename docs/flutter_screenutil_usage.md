# Flutter ScreenUtil 使用指南

## 已完成的配置

### 1. 依赖添加
在 `pubspec.yaml` 中已添加：
```yaml
flutter_screenutil: ^5.9.0
```

### 2. 初始化配置
在 `main.dart` 中已配置：
```dart
ScreenUtilInit(
  // 设计稿的设备尺寸（宽度，高度）
  designSize: const Size(750, 1624), // iPhone X 尺寸作为设计基准
  // 最小文字适配，设置字体大小根据系统的"字体大小"辅助选项来进行缩放
  minTextAdapt: true,
  // 支持分屏尺寸
  splitScreenMode: true,
  builder: (context, child) {
    return MaterialApp.router(
      // ... 其他配置
    );
  },
);
```

### 3. 主题适配
在 `app_theme.dart` 中已更新使用响应式尺寸：
- 按钮内边距：`EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h)`
- 圆角半径：`BorderRadius.circular(8.r)`
- 边框宽度：`width: 2.w`

## 使用方法

### 基本用法
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 宽度适配
Container(
  width: 100.w, // 相对于设计稿宽度的100像素
  height: 200.h, // 相对于设计稿高度的200像素
)

// 字体大小适配
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16.sp, // 相对于设计稿的16像素字体
  ),
)

// 圆角半径适配
BorderRadius.circular(8.r)

// 内边距和外边距适配
EdgeInsets.all(16.w) // 或者 16.h
EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h)
```

### 设备信息获取
```dart
// 屏幕宽度
double screenWidth = 1.sw; // 或 ScreenUtil().screenWidth

// 屏幕高度  
double screenHeight = 1.sh; // 或 ScreenUtil().screenHeight

// 状态栏高度
double statusBarHeight = ScreenUtil().statusBarHeight;

// 底部安全区高度
double bottomBarHeight = ScreenUtil().bottomBarHeight;
```

### 判断设备方向
```dart
// 是否为横屏
bool isLandscape = ScreenUtil().orientation == Orientation.landscape;
```

## 注意事项

1. **设计稿尺寸**：当前设置为 375x812（iPhone X），请根据实际设计稿调整
2. **单位说明**：
   - `.w` - 宽度适配
   - `.h` - 高度适配  
   - `.r` - 圆角半径适配（取宽高中较小值）
   - `.sp` - 字体大小适配
3. **初始化时机**：必须在 MaterialApp 外层包裹 ScreenUtilInit
4. **热重载**：修改设计稿尺寸后需要热重启应用
5. **主题中的使用**：在静态主题方法中，ScreenUtil 扩展方法需要在运行时才能获取屏幕信息，所以采用了私有方法的方式来处理

## 问题修复说明

### 原始问题
在静态 getter 中直接使用 `32.w`、`16.h` 等 ScreenUtil 扩展方法会导致错误，因为这些方法需要在 Widget 构建时才能访问屏幕尺寸信息。

### 解决方案
1. 将静态 getter 改为调用私有静态方法
2. 在私有方法中使用 ScreenUtil 扩展方法
3. 提供备用的 fallback 主题（不使用 ScreenUtil）以防初始化问题

```dart
// 正确的做法
static ThemeData get lightTheme => _buildLightTheme();

static ThemeData _buildLightTheme() {
  return ThemeData(
    // 在这里可以安全使用 ScreenUtil
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      ),
    ),
  );
}
```

## 最佳实践

1. 统一使用 ScreenUtil 进行尺寸适配
2. 在组件中优先使用 `.w`、`.h`、`.sp`、`.r` 等适配单位
3. 对于固定比例的设计，可以使用 `0.5.sw`（屏幕宽度的50%）
4. 重要的间距和尺寸建议在 `app_theme.dart` 中统一定义
