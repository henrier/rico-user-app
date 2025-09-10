import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/category/category_selection_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/spu_search_screen.dart';
import '../screens/product/spu_selection_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'categories',
            name: 'categories',
            builder: (context, state) {
              // 从查询参数获取二级类目ID
              final secondCategoryId =
                  state.uri.queryParameters['secondCategoryId'] ??
                      'tempSecondCategoryId';

              return CategorySelectionScreen(
                secondCategoryId: secondCategoryId,
              );
            },
          ),
          GoRoute(
            path: 'spu-selection',
            name: 'spu-selection',
            builder: (context, state) {
              // 从查询参数获取类目ID（必需）
              final categoryId = state.uri.queryParameters['categoryId'];

              if (categoryId == null || categoryId.isEmpty) {
                // 如果没有类目ID，返回错误页面或重定向
                return const Scaffold(
                  body: Center(
                    child: Text('缺少类目ID参数'),
                  ),
                );
              }

              return SpuSelectionScreenWrapper(
                categoryId: categoryId,
              );
            },
          ),
          GoRoute(
            path: 'spu-search',
            name: 'spu-search',
            builder: (context, state) => const SpuSearchScreen(),
          ),
        ],
      ),
    ],
  );
});
