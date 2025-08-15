# Flutter VS Code/Cursor 插件推荐指南

> 本文档整理了 Flutter 开发中最实用的 VS Code/Cursor 插件，按重要性和功能分类，方便按需安装。

## 🚀 快速安装指南

### 方式1: 通过扩展商店
1. 打开扩展商店 (`Ctrl+Shift+X` / `Cmd+Shift+X`)
2. 搜索插件名称或 ID
3. 点击安装

### 方式2: 通过命令行
```bash
# 基础必装
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code

# 开发增强
code --install-extension alexisvt.flutter-snippets
code --install-extension jeroen-meijer.pubspec-assist
code --install-extension usernamehw.errorlens
```

## 📋 分级安装清单

### 🔥 Level 1: 必装插件 (启动必需)

| 插件名称 | 插件ID | 优先级 | 说明 |
|---------|--------|--------|------|
| **Flutter** | `Dart-Code.flutter` | ⭐⭐⭐⭐⭐ | 官方核心插件，Flutter 开发必需 |
| **Dart** | `Dart-Code.dart-code` | ⭐⭐⭐⭐⭐ | Dart 语言支持，必需 |

**功能**: 语法高亮、代码补全、错误检查、热重载、调试、设备管理

### 🎯 Level 2: 强烈推荐 (效率提升)

| 插件名称 | 插件ID | 优先级 | 说明 |
|---------|--------|--------|------|
| **Flutter Widget Snippets** | `alexisvt.flutter-snippets` | ⭐⭐⭐⭐ | 快速生成 Widget 代码 |
| **Pubspec Assist** | `jeroen-meijer.pubspec-assist` | ⭐⭐⭐⭐ | 依赖包管理神器 |
| **Error Lens** | `usernamehw.errorlens` | ⭐⭐⭐⭐ | 行内错误显示 |

**安装命令**:
```bash
code --install-extension alexisvt.flutter-snippets
code --install-extension jeroen-meijer.pubspec-assist
code --install-extension usernamehw.errorlens
```

**Widget Snippets 常用快捷键**:
```dart
stless → StatelessWidget
stful  → StatefulWidget
scaf   → Scaffold
appb   → AppBar
cont   → Container
```

### 🛠️ Level 3: 开发增强 (功能扩展)

| 插件名称 | 插件ID | 优先级 | 功能说明 |
|---------|--------|--------|----------|
| **Awesome Flutter Snippets** | `Nash.awesome-flutter-snippets` | ⭐⭐⭐ | 更丰富的代码片段 |
| **Flutter Tree** | `marcelovelasquez.flutter-tree` | ⭐⭐⭐ | Widget 树可视化 |
| **Flutter Intl** | `localizely.flutter-intl` | ⭐⭐⭐ | 国际化支持 |
| **Dart Data Class Generator** | `hzgood.dart-data-class-generator` | ⭐⭐⭐ | 自动生成数据类 |

**安装命令**:
```bash
code --install-extension Nash.awesome-flutter-snippets
code --install-extension marcelovelasquez.flutter-tree
code --install-extension localizely.flutter-intl
code --install-extension hzgood.dart-data-class-generator
```

### 🎨 Level 4: UI 优化 (视觉体验)

| 插件名称 | 插件ID | 优先级 | 功能说明 |
|---------|--------|--------|----------|
| **Flutter Color** | `circlecodesolution.ccs-flutter-color` | ⭐⭐⭐ | 颜色预览和选择 |
| **Bracket Pair Colorizer 2** | `CoenraadS.bracket-pair-colorizer-2` | ⭐⭐⭐ | 括号配对着色 |
| **Auto Rename Tag** | `formulahendry.auto-rename-tag` | ⭐⭐ | 自动重命名配对标签 |

**安装命令**:
```bash
code --install-extension circlecodesolution.ccs-flutter-color
code --install-extension CoenraadS.bracket-pair-colorizer-2
code --install-extension formulahendry.auto-rename-tag
```

### 🔍 Level 5: 调试分析 (深度开发)

| 插件名称 | 插件ID | 优先级 | 功能说明 |
|---------|--------|--------|----------|
| **Flutter Coverage** | `Flutterando.flutter-coverage` | ⭐⭐ | 代码覆盖率可视化 |
| **Dart Code Metrics** | `dart-code.dart-code-metrics-action` | ⭐⭐ | 代码质量分析 |
| **GitLens** | `eamodio.gitlens` | ⭐⭐⭐ | Git 增强工具 |

**安装命令**:
```bash
code --install-extension Flutterando.flutter-coverage
code --install-extension dart-code.dart-code-metrics-action
code --install-extension eamodio.gitlens
```

### 📱 Level 6: 平台特定 (按需安装)

| 插件名称 | 插件ID | 优先级 | 使用场景 |
|---------|--------|--------|----------|
| **Android iOS Emulator** | `DiemasMichiels.emulate` | ⭐⭐ | 需要频繁切换模拟器 |

## 📖 详细功能说明

### 🔥 Flutter Widget Snippets 使用指南

**常用代码片段**:
```dart
// 输入 stless + Tab
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 输入 stful + Tab  
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 其他常用片段
scaf    → Scaffold
col     → Column
row     → Row
cont    → Container
sbox    → SizedBox
```

### 🛠️ Pubspec Assist 使用技巧

1. **快速添加依赖**:
   - `Ctrl+Shift+P` → "Pubspec Assist: Add/Update Dependencies"
   - 搜索并选择需要的包

2. **自动版本管理**:
   - 自动获取最新版本
   - 智能更新依赖

### 🎨 Flutter Color 功能

- **颜色预览**: 直接在代码中显示颜色
- **颜色选择器**: 可视化选择颜色
- **格式转换**: 支持 HEX、RGB、HSL 等格式

```dart
// 插件会直接显示颜色预览
Color primaryColor = Color(0xFF2196F3); // 显示蓝色方块
Color customColor = Colors.red;          // 显示红色方块
```

## ⚙️ 推荐配置

### VS Code/Cursor 设置

创建或更新 `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 120,
  "dart.insertArgumentPlaceholders": false,
  "dart.updateImportsOnRename": true,
  "dart.completeFunctionCalls": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "flutter.copyProfilerUrl": true,
  "flutter.hotReloadOnSave": "manual",
  "errorLens.enabledDiagnosticLevels": [
    "error",
    "warning",
    "info"
  ],
  "bracketPairColorizer.showBracketsInGutter": true,
  "bracketPairColorizer.showHorizontalScopeLine": false
}
```

### 快捷键配置

创建或更新 `.vscode/keybindings.json`:

```json
[
  {
    "key": "ctrl+f5",
    "command": "flutter.hotRestart",
    "when": "dart-code:anyProjectLoaded"
  },
  {
    "key": "f5", 
    "command": "flutter.hotReload",
    "when": "dart-code:anyProjectLoaded"
  },
  {
    "key": "ctrl+shift+p",
    "command": "pubspec-assist.addDependency",
    "when": "editorTextFocus && resourceExtname == '.yaml'"
  }
]
```

## 🎯 安装策略建议

### 新手入门 (第一周)
```bash
# 只安装核心插件
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension alexisvt.flutter-snippets
```

### 进阶开发 (第二周)
```bash
# 添加效率工具
code --install-extension jeroen-meijer.pubspec-assist
code --install-extension usernamehw.errorlens
code --install-extension Nash.awesome-flutter-snippets
```

### 专业开发 (第三周及以后)
```bash
# 完整开发环境
code --install-extension marcelovelasquez.flutter-tree
code --install-extension circlecodesolution.ccs-flutter-color
code --install-extension eamodio.gitlens
```

## 🚨 注意事项

1. **性能考虑**: 不要一次性安装所有插件，按需安装
2. **插件冲突**: 某些插件可能有功能重叠，选择最适合的
3. **定期更新**: 保持插件为最新版本
4. **项目特定**: 某些插件只在特定项目类型中有用

## 🔧 故障排除

### 常见问题

1. **Flutter 插件不生效**
   - 检查 Flutter SDK 路径设置
   - 重启 VS Code/Cursor
   - 运行 `flutter doctor` 检查环境

2. **代码补全不工作**
   - 确保 Dart 插件已安装
   - 检查项目是否正确识别为 Flutter 项目

3. **热重载失败**
   - 检查快捷键配置
   - 确保应用正在运行状态

### 重置插件
```bash
# 禁用所有插件后重新启用
code --list-extensions | xargs -L 1 echo code --uninstall-extension
```

## 📚 扩展阅读

- [Flutter 官方 VS Code 扩展文档](https://docs.flutter.dev/development/tools/vs-code)
- [Dart VS Code 扩展文档](https://dartcode.org/)
- [VS Code Flutter 开发指南](https://code.visualstudio.com/docs/languages/dart)

---

**最后更新**: 2024年12月

**维护者**: Rico User App 项目组

**建议**: 有新的实用插件推荐请在项目中提 Issue 💡
