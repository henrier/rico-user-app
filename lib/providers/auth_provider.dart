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

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _authApi.login(email, password);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      AppLogger.i('User logged in successfully: ${user.email}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );

      AppLogger.e('Login failed', e);
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _authApi.register(email, password, username);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      AppLogger.i('User registered successfully: ${user.email}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );

      AppLogger.e('Registration failed', e);
    }
  }

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
      }
    } catch (e) {
      AppLogger.e('Auth status check failed', e);
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
