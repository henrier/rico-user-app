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
// 导入自定义输入框组件
import '../../widgets/custom_text_field.dart';

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
  // 表单验证的全局键 - 用于表单验证，类似于 React 的 ref
  final _formKey = GlobalKey<FormState>();

  // 文本输入控制器 - 管理输入框的内容，类似于 React 的 useState + useRef 组合
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 布尔状态 - 控制密码是否可见，类似于 React 的 useState
  bool _obscurePassword = true;

  // 生命周期方法 - 组件销毁时调用，类似于 React 的 useEffect cleanup
  @override
  void dispose() {
    // 释放控制器资源，防止内存泄漏 - Flutter 需要手动管理资源
    _emailController.dispose();
    _passwordController.dispose();
    // 调用父类的 dispose 方法
    super.dispose();
  }

  // 处理登录逻辑的异步方法
  // async/await 语法与 JavaScript 相同
  void _handleLogin() async {
    // 验证表单 - ! 操作符表示非空断言（确信不会为 null）
    if (_formKey.currentState!.validate()) {
      // 使用 Riverpod 的 ref.read 来调用 provider 的方法
      // 这类似于调用 Redux 的 dispatch 或 React Context 的方法
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(), // trim() 去除首尾空格
            _passwordController.text,
          );
    }
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
              child: Form(
                // Form - 表单容器，用于统一管理表单验证
                key: _formKey, // 绑定表单键，用于验证
                child: Column(
                  // Column - 垂直布局容器，类似于 CSS 的 flex-direction: column
                  mainAxisAlignment: MainAxisAlignment.center, // 主轴居中对齐
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 交叉轴拉伸填满
                  children: [
                    // 应用图标或标题
                    Icon(
                      Icons.account_circle, // Material Design 图标
                      size: 100,
                      color: Theme.of(context).primaryColor, // 获取主题色
                    ),
                    const SizedBox(height: AppConstants.largePadding), // 垂直间距

                    // 欢迎标题
                    Text(
                      'Welcome Back!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                // copyWith - 复制样式并修改部分属性，类似于 JavaScript 的 spread operator
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center, // 文本居中对齐
                    ),
                    const SizedBox(height: AppConstants.smallPadding), // 小间距

                    // 副标题
                    Text(
                      'Please sign in to your account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600], // 设置灰色，[] 表示色彩深度
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // 🎯 演示账号提示卡片
                    Container(
                      // Container - 类似于 HTML 的 div，可以设置样式和布局
                      padding:
                          const EdgeInsets.all(AppConstants.defaultPadding),
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
                            children: [
                              Icon(
                                Icons.info_outline, // 信息图标
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8), // 水平间距
                              Text(
                                '演示账号',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '邮箱: demo@rico.com\n密码: password123', // \n 换行符
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace', // 等宽字体
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // 邮箱输入框 - 使用自定义组件
                    CustomTextField(
                      controller: _emailController, // 绑定文本控制器
                      labelText: 'Email', // 标签文本
                      hintText: 'Enter your email', // 占位符文本
                      keyboardType: TextInputType.emailAddress, // 键盘类型 - 邮箱键盘
                      prefixIcon: Icons.email, // 前缀图标
                      validator: (value) {
                        // 表单验证函数 - 类似于 HTML5 的表单验证
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email'; // 返回错误信息
                        }
                        // 正则表达式验证邮箱格式 - 与 JavaScript 的 RegExp 相同
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null; // 验证通过返回 null
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // 密码输入框
                    CustomTextField(
                      controller: _passwordController, // 绑定密码控制器
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword, // 是否隐藏文本（密码模式）
                      prefixIcon: Icons.lock, // 锁图标
                      suffixIcon: IconButton(
                        // 后缀按钮 - 用于切换密码可见性
                        icon: Icon(
                          // 三元运算符 - 根据状态显示不同图标
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // setState - 更新状态并重新构建 UI，类似于 React 的 setState
                          setState(() {
                            _obscurePassword = !_obscurePassword; // 切换密码可见性
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < AppConstants.minPasswordLength) {
                          // 字符串插值 - ${} 语法类似于 JavaScript 的模板字符串
                          return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // 登录按钮
                    CustomButton(
                      text: 'Sign In',
                      // 条件渲染 - 加载时禁用按钮，类似于 React 的条件渲染
                      onPressed: authState.isLoading ? null : _handleLogin,
                      isLoading: authState.isLoading, // 显示加载状态
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // 忘记密码按钮
                    TextButton(
                      // TextButton - 文本按钮，类似于 HTML 的 button with text style
                      onPressed: () {
                        // TODO: 实现忘记密码功能
                        ScaffoldMessenger.of(context).showSnackBar(
                          // SnackBar - 底部提示条，类似于 Toast 通知
                          const SnackBar(
                              content:
                                  Text('Forgot password feature coming soon')),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // 注册链接区域
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 水平居中
                      children: [
                        const Text("Don't have an account? "), // 静态文本
                        TextButton(
                          onPressed: () {
                            // TODO: 导航到注册页面
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Registration screen coming soon')),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
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
