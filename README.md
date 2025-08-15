# Rico User App

一个基于 Flutter 开发的用户应用，支持 iOS 和 Android 平台，遵循社区最佳实践。

## 🚀 项目特性

- **跨平台支持**: 支持 iOS 和 Android
- **现代架构**: 使用 Riverpod 进行状态管理
- **路由导航**: 使用 go_router 进行声明式路由
- **主题支持**: 支持浅色和深色主题
- **API 集成**: 完整的网络请求和错误处理
- **本地存储**: 使用 SharedPreferences 和 SQLite
- **代码质量**: 完整的 linting 配置和最佳实践

## 📁 项目结构

```
rico_user_app/
├── android/                 # Android 平台相关文件
│   ├── app/
│   │   ├── build.gradle    # Android 应用构建配置
│   │   └── src/main/       # Android 主要源码目录
│   ├── gradle/             # Gradle 构建工具配置
│   └── build.gradle        # Android 项目构建配置
├── ios/                     # iOS 平台相关文件
│   ├── Runner/             # iOS 应用主要配置
│   │   ├── Info.plist     # iOS 应用信息配置
│   │   └── AppDelegate.swift # iOS 应用委托
│   ├── Runner.xcodeproj/   # Xcode 项目文件
│   └── Podfile            # iOS 依赖管理文件
├── web/                     # Web 平台相关文件
│   ├── index.html          # Web 应用入口 HTML
│   ├── manifest.json       # Web 应用清单文件
│   └── icons/             # Web 应用图标
├── lib/                     # 🔥 Flutter 应用主要源码目录
│   ├── api/                # API 服务层
│   │   ├── auth_api.dart  # 认证相关 API
│   │   └── base_api.dart  # 基础 API 配置
│   ├── common/            # 公共组件和工具
│   │   ├── constants/     # 常量定义
│   │   ├── themes/       # 主题配置
│   │   └── utils/        # 工具类
│   ├── models/           # 数据模型
│   │   └── user_model.dart # 用户数据模型
│   ├── providers/        # 状态管理 (Riverpod)
│   │   └── auth_provider.dart # 认证状态管理
│   ├── routes/           # 路由配置
│   │   └── app_router.dart # 应用路由
│   ├── screens/          # 页面视图
│   │   ├── auth/        # 认证相关页面
│   │   ├── home/        # 主页
│   │   └── profile/     # 个人资料
│   ├── widgets/          # 可复用组件
│   │   ├── custom_button.dart    # 自定义按钮
│   │   └── custom_text_field.dart # 自定义输入框
│   └── main.dart        # 🚀 Flutter 应用入口文件
├── test/                   # 测试文件目录
│   ├── unit/             # 单元测试
│   ├── widget/           # Widget 测试
│   └── integration/      # 集成测试
├── assets/                # 静态资源文件
│   ├── images/           # 图片资源
│   ├── icons/            # 图标资源
│   └── fonts/            # 字体资源
├── .gitignore             # Git 忽略文件配置
├── analysis_options.yaml  # Dart 代码分析配置
├── pubspec.yaml           # 🔥 Flutter 项目配置文件
├── pubspec.lock           # 依赖版本锁定文件
└── README.md              # 项目说明文档
```

## 📖 目录详细说明

### 🤖 平台相关目录

#### `android/` - Android 平台配置
- **用途**: 包含 Android 应用的所有原生配置和代码
- **重要文件**:
  - `app/build.gradle`: Android 应用级别的构建配置，包含应用 ID、版本、签名等
  - `app/src/main/AndroidManifest.xml`: Android 应用清单文件，定义权限、启动配置等
  - `gradle/wrapper/`: Gradle 构建工具的版本管理
- **何时修改**: 添加 Android 权限、配置推送、第三方 SDK 集成时

#### `ios/` - iOS 平台配置  
- **用途**: 包含 iOS 应用的所有原生配置和代码
- **重要文件**:
  - `Runner/Info.plist`: iOS 应用信息配置文件，包含权限、URL Scheme 等
  - `Runner.xcodeproj/`: Xcode 项目文件，用于在 Xcode 中打开项目
  - `Podfile`: iOS 依赖管理文件，类似于 npm 的 package.json
- **何时修改**: 添加 iOS 权限、配置证书、集成原生库时

#### `web/` - Web 平台配置
- **用途**: 包含 Web 应用的配置文件
- **重要文件**:
  - `index.html`: Web 应用的入口 HTML 文件
  - `manifest.json`: PWA (Progressive Web App) 配置文件
  - `icons/`: Web 应用的各种尺寸图标
- **何时修改**: 配置 PWA、修改网页标题、添加 meta 标签时

### 📝 配置文件

#### `pubspec.yaml` - 项目配置核心
- **用途**: Flutter 项目的配置文件，类似于 package.json
- **包含内容**:
  ```yaml
  name: rico_user_app          # 应用名称
  version: 1.0.0+1            # 版本号
  dependencies:               # 生产依赖
  dev_dependencies:           # 开发依赖
  flutter:                    # Flutter 特定配置
    assets:                   # 静态资源路径
  ```

#### `analysis_options.yaml` - 代码质量配置
- **用途**: 配置 Dart 代码分析器的规则
- **作用**: 
  - 代码风格检查
  - 潜在错误检测
  - 最佳实践建议

#### `.gitignore` - 版本控制配置
- **用途**: 告诉 Git 哪些文件不需要版本控制
- **排除内容**: 
  - 构建产物 (`build/`, `.dart_tool/`)
  - 依赖缓存 (`.pub-cache/`)
  - 平台特定文件 (`.DS_Store`, `Thumbs.db`)

### 🧪 测试目录结构

#### `test/` - 测试文件组织
```
test/
├── unit/          # 单元测试 - 测试单个函数/类
├── widget/        # Widget 测试 - 测试 UI 组件
└── integration/   # 集成测试 - 测试完整流程
```

### 🎨 静态资源管理

#### `assets/` - 资源文件组织
```
assets/
├── images/        # 图片文件 (.png, .jpg, .svg)
├── icons/         # 图标文件
└── fonts/         # 字体文件 (.ttf, .otf)
```

**使用方式**:
```dart
// 在代码中引用资源
Image.asset('assets/images/logo.png')
Icon(Icons.custom, package: 'assets/icons/custom_icon.svg')
```

## 🛠️ 环境配置

### 前置要求

1. **Flutter SDK**: 版本 3.2.0 或更高
2. **Dart SDK**: 版本 3.2.0 或更高
3. **Android Studio** / **Xcode** (用于移动端开发)
4. **Git**: 用于版本控制

### Flutter 安装

#### macOS 安装 Flutter

1. 下载 Flutter SDK:
```bash
# 使用 Homebrew
brew install flutter

# 或手动下载
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
```

2. 配置环境变量:
```bash
# 添加到 ~/.zshrc 或 ~/.bash_profile
export PATH="$PATH:$HOME/development/flutter/bin"
```

3. 验证安装:
```bash
flutter doctor
```

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone git@github.com:henrier/rico-user-app.git
cd rico-user-app
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行项目

```bash
# 在 iOS 模拟器运行
flutter run -d ios

# 在 Android 模拟器运行
flutter run -d android

# 在 Web 浏览器运行
flutter run -d web
```

## 📦 主要依赖包

### 核心依赖
- **flutter_riverpod**: 状态管理
- **go_router**: 路由导航
- **http/dio**: 网络请求
- **shared_preferences**: 本地存储

### UI 组件
- **cupertino_icons**: iOS 风格图标

### 开发工具
- **flutter_lints**: 代码规范检查
- **mockito**: 单元测试

## 🏗️ 项目架构

### 状态管理 (Riverpod)

项目使用 Riverpod 进行状态管理，提供：
- 类型安全的依赖注入
- 自动生命周期管理
- 强大的缓存和组合能力

### 路由管理 (GoRouter)

使用声明式路由，支持：
- 嵌套路由
- 路由守卫
- 深度链接

### API 架构

- **BaseApi**: 提供通用的 HTTP 配置和认证处理
- **具体 API 类**: 继承 BaseApi，实现具体业务逻辑

## 🎨 主题系统

项目支持浅色和深色主题，主题配置在 `lib/common/themes/app_theme.dart`。

## 🧪 测试

```bash
# 运行所有测试
flutter test

# 运行单元测试
flutter test test/unit/

# 运行 Widget 测试
flutter test test/widget/

# 运行集成测试
flutter test integration_test/
```

## 🔌 VS Code/Cursor 插件推荐

为了获得最佳的 Flutter 开发体验，我们整理了详细的插件推荐清单：

📖 **[Flutter VS Code 插件推荐指南](docs/flutter-vscode-plugins.md)**

包含内容：
- 🚀 分级安装策略（必装 → 推荐 → 可选）
- 🛠️ 详细功能说明和使用技巧  
- ⚙️ 推荐配置和快捷键设置
- 🎯 按开发阶段的安装建议
- 🔧 故障排除和常见问题解决

**快速开始**：
```bash
# 安装核心插件
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension alexisvt.flutter-snippets
```

## 📱 构建发布版本

### Android

```bash
# 构建 APK
flutter build apk --release

# 构建 App Bundle (推荐)
flutter build appbundle --release
```

### iOS

```bash
# 构建 iOS 应用
flutter build ios --release
```

## 📝 开发规范

### 代码风格

项目使用 `flutter_lints` 进行代码规范检查，主要规则：
- 使用单引号
- 优先使用 const 构造函数
- 避免不必要的容器
- 保持 Widget 构造函数的 key 参数

### 文件命名

- 文件名使用小写下划线格式 (`snake_case`)
- 类名使用大驼峰格式 (`PascalCase`)
- 变量和方法使用小驼峰格式 (`camelCase`)

### Git 提交规范

```
<type>(<scope>): <description>

feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建或工具相关
```

## 🔧 故障排除

### 常见问题

1. **Flutter doctor 检查失败**
   ```bash
   flutter doctor --android-licenses
   ```

2. **依赖冲突**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **iOS 构建失败**
   ```bash
   cd ios
   pod install
   cd ..
   flutter clean
   flutter build ios
   ```

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 📞 联系方式

- 邮箱: sy.zhangchuang@gmail.com
- GitHub: [@henrier](https://github.com/henrier)

---

**注意**: 这是一个模板项目，请根据实际需求调整配置和功能。
