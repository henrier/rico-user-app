// Flutter 核心包 - 提供所有 UI 组件和 Material Design 风格
import 'package:flutter/material.dart';
// Riverpod 状态管理包 - 类似于 React 的 Context API 或 Redux
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 路由管理包 - 用于页面导航，类似于 React Router
import 'package:go_router/go_router.dart';

// 导入应用常量配置
import '../../common/constants/app_constants.dart';
// 导入自定义的认证状态管理 Provider
import '../../providers/auth_provider.dart';
// 导入自定义按钮组件
import '../../widgets/custom_button.dart';

// LoginScreen 继承自 ConsumerStatefulWidget
// 这类似于 React 的 Class Component，但有状态管理集成
// ConsumerStatefulWidget 允许我们使用 Riverpod 的状态管理功能
class LoginScreen extends ConsumerStatefulWidget {
  // const 构造函数 - Dart 的编译时常量声明
  // super.key 相当于传递 key 给父类，类似 React 的 key prop
  const LoginScreen({super.key});

  // 必须重写的方法，返回 State 实例
  // 这类似于 React 类组件的 state 初始化
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// State 类 - 包含组件的状态和生命周期方法
// 下划线开头的类名表示私有类（Dart 约定）
class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 处理一键登录逻辑的异步方法
  // async/await 语法与 JavaScript 相同
  void _handleQuickLogin() async {
    // 直接调用登录方法，使用默认的演示账号
    // 使用 Riverpod 的 ref.read 来调用 provider 的方法
    await ref.read(authProvider.notifier).quickLogin();
  }

  // build 方法 - 构建 UI 的方法，类似于 React 的 render 方法
  // 返回 Widget 树来描述界面结构
  @override
  Widget build(BuildContext context) {
    // 监听认证状态 - 类似于 React 的 useSelector 或 useContext
    final authState = ref.watch(authProvider);

    // 监听状态变化并执行副作用 - 类似于 React 的 useEffect
    // 当认证状态改变时会触发这个回调
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        // 登录成功后导航到主页 - 类似于 React Router 的 navigate
        context.go('/home');
      } else if (next.error != null) {
        // 显示错误信息 - 类似于显示 Toast 通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    // 返回 Widget 树 - 这是 Flutter 的 UI 描述方式
    return Scaffold(
      // Scaffold - Flutter 的基础页面结构，类似于 HTML 的 body
      body: SafeArea(
        // SafeArea - 确保内容不被状态栏等系统 UI 遮挡
        child: Padding(
          // Padding - 添加内边距，类似于 CSS 的 padding
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            // Center - 水平和垂直居中，类似于 CSS 的 display: flex + justify-content: center + align-items: center
            child: SingleChildScrollView(
              // SingleChildScrollView - 可滚动容器，防止键盘弹出时溢出
              child: Column(
                // Column - 垂直布局容器，类似于 CSS 的 flex-direction: column
                mainAxisAlignment: MainAxisAlignment.center, // 主轴居中对齐
                crossAxisAlignment: CrossAxisAlignment.stretch, // 交叉轴拉伸填满
                children: [
                  // 应用图标或标题
                  Icon(
                    Icons.account_circle, // Material Design 图标
                    size: 120,
                    color: Theme.of(context).primaryColor, // 获取主题色
                  ),
                  const SizedBox(height: AppConstants.largePadding), // 垂直间距

                  // 欢迎标题
                  Text(
                    'Welcome to Rico!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          // copyWith - 复制样式并修改部分属性，类似于 JavaScript 的 spread operator
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center, // 文本居中对齐
                  ),
                  const SizedBox(height: AppConstants.smallPadding), // 小间距

                  // 副标题
                  Text(
                    '点击下方按钮即可开始使用',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600], // 设置灰色，[] 表示色彩深度
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largePadding * 2),

                  // 🎯 一键登录提示卡片
                  Container(
                    // Container - 类似于 HTML 的 div，可以设置样式和布局
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      // BoxDecoration - 装饰容器，类似于 CSS 的各种样式属性
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.1), // 半透明背景
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius), // 圆角边框
                      border: Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.3), // 边框颜色
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          // Row - 水平布局容器，类似于 CSS 的 flex-direction: row
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flash_on, // 闪电图标表示快速登录
                              size: 24,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8), // 水平间距
                            Text(
                              '一键登录',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '无需输入用户名密码\n直接体验应用功能',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding * 2),

                  // 一键登录按钮
                  CustomButton(
                    text: '立即登录',
                    // 条件渲染 - 加载时禁用按钮，类似于 React 的条件渲染
                    onPressed: authState.isLoading ? null : _handleQuickLogin,
                    isLoading: authState.isLoading, // 显示加载状态
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // 说明文字
                  Text(
                    '点击登录即表示您同意我们的服务条款',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 总结：
// 1. Flutter 使用 Widget 树来构建 UI，类似于 React 的 Virtual DOM
// 2. StatefulWidget 类似于 React 的 Class Component，有生命周期方法
// 3. setState() 用于更新状态，类似于 React 的 setState()
// 4. Dart 的语法与 TypeScript 相似，但有一些特殊的语法（如 const、final、?、!）
// 5. Flutter 的布局系统基于 Flexbox，Column 和 Row 类似于 CSS 的 flex 布局
// 6. Riverpod 是状态管理方案，类似于 Redux 或 React Context
