import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/auth_api.dart';
import '../common/utils/logger.dart';
import '../models/user_model.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// 🎯 AuthNotifier 继承自 StateNotifier
// StateNotifier 是一个独立的 Dart 包，不是 Flutter 或 Riverpod 的一部分
// 它是一个通用的状态管理基类
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;

  // 构造函数：调用 super() 设置初始状态
  AuthNotifier(this._authApi) : super(const AuthState());

  Future<void> login(String phone, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _authApi.login(phone, password);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      AppLogger.i('User logged in successfully: ${user.phone}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );

      AppLogger.e('Login failed', e);
    }
  }

  // 一键登录方法 - 使用默认的演示账号
  Future<void> quickLogin() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 使用默认的演示账号进行登录
      final user = await _authApi.quickLogin();

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      AppLogger.i('Quick login successful: ${user.phone}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );

      AppLogger.e('Quick login failed', e);
    }
  }

  // 注册功能暂时不需要，因为我们使用的是现有的后端用户系统
  // Future<void> register(String email, String password, String username) async {
  //   // 注册逻辑可以在需要时实现
  // }

  Future<void> logout() async {
    try {
      await _authApi.logout();

      state = const AuthState(
        user: null,
        isLoading: false,
        isAuthenticated: false,
      );

      AppLogger.i('User logged out successfully');
    } catch (e) {
      AppLogger.e('Logout failed', e);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authApi.getCurrentUser();

      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
        AppLogger.i('Auth status check successful: user is authenticated');
      } else {
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
        );
        AppLogger.i('Auth status check: user is not authenticated');
      }
    } catch (e) {
      AppLogger.e('Auth status check failed', e);
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
      );
    }
  }

  // 获取当前用户权限
  Future<List<String>> getCurrentUserPermissions() async {
    try {
      return await _authApi.getCurrentUserPermissions();
    } catch (e) {
      AppLogger.e('Get user permissions failed', e);
      return [];
    }
  }
}

// 🔧 创建 AuthApi 的 Provider - 依赖注入容器
final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

// 🎯 创建 AuthProvider - 这是一个全局变量！
// StateNotifierProvider 是 Riverpod 的工厂函数，返回一个 Provider 实例
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // 获取 AuthApi 依赖
  final authApi = ref.watch(authApiProvider);
  // 创建并返回 AuthNotifier 实例
  return AuthNotifier(authApi);
});
