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
lib/
├── api/                    # API 服务层
│   ├── auth_api.dart      # 认证相关 API
│   └── base_api.dart      # 基础 API 配置
├── common/                # 公共组件和工具
│   ├── constants/         # 常量定义
│   ├── themes/           # 主题配置
│   └── utils/            # 工具类
├── models/               # 数据模型
│   └── user_model.dart   # 用户数据模型
├── providers/            # 状态管理 (Riverpod)
│   └── auth_provider.dart # 认证状态管理
├── routes/               # 路由配置
│   └── app_router.dart   # 应用路由
├── screens/              # 页面视图
│   ├── auth/            # 认证相关页面
│   ├── home/            # 主页
│   └── profile/         # 个人资料
├── widgets/              # 可复用组件
│   ├── custom_button.dart    # 自定义按钮
│   └── custom_text_field.dart # 自定义输入框
└── main.dart            # 应用入口
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
