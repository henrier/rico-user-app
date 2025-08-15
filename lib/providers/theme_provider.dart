import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constants/app_constants.dart';
import '../common/utils/logger.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeState {
  final AppThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isLoading = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // 转换为 Flutter 的 ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get displayName {
    switch (themeMode) {
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
      case AppThemeMode.system:
        return '跟随系统';
    }
  }

  IconData get icon {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadThemeFromStorage();
  }

  // 从本地存储加载主题设置
  Future<void> _loadThemeFromStorage() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(AppConstants.themeKey);
      
      if (themeString != null) {
        final themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == themeString,
          orElse: () => AppThemeMode.system,
        );
        
        state = state.copyWith(
          themeMode: themeMode,
          isLoading: false,
        );
        
        AppLogger.i('Theme loaded from storage: ${themeMode.name}');
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      AppLogger.e('Failed to load theme from storage', e);
      state = state.copyWith(isLoading: false);
    }
  }

  // 设置主题模式
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      state = state.copyWith(themeMode: themeMode);
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeKey, themeMode.name);
      
      AppLogger.i('Theme changed to: ${themeMode.name}');
    } catch (e) {
      AppLogger.e('Failed to save theme to storage', e);
    }
  }

  // 切换到下一个主题模式
  Future<void> toggleTheme() async {
    final currentIndex = AppThemeMode.values.indexOf(state.themeMode);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    final nextTheme = AppThemeMode.values[nextIndex];
    
    await setThemeMode(nextTheme);
  }

  // 检查当前是否为深色模式
  bool isDarkMode(BuildContext context) {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

// Provider 定义
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
