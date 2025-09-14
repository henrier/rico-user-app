import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/category/category_selection_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/spu_search_screen.dart';
import '../screens/product/spu_selection_screen.dart';
import '../screens/product/product_detail_create_screen.dart';
import '../screens/product/product_detail_demo_screen.dart';
import '../screens/product/batch_add_product_screen.dart';
import '../screens/product/product_management_screen.dart';
import '../screens/product/bulk_edit_screen.dart';
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
          GoRoute(
            path: 'product-detail-create',
            name: 'product-detail-create',
            builder: (context, state) {
              // 从查询参数获取基本信息（主要用于新增模式）
              final spuId = state.uri.queryParameters['spuId'] ?? '';
              final spuName = Uri.decodeComponent(state.uri.queryParameters['spuName'] ?? '');
              final spuCode = state.uri.queryParameters['spuCode'] ?? '';
              final spuImageUrl = Uri.decodeComponent(state.uri.queryParameters['spuImageUrl'] ?? '');
              
              // 从extra获取扩展参数
              final extra = state.extra as Map<String, dynamic>?;
              final isEditMode = extra?['isEditMode'] ?? false;
              final personalProductId = extra?['personalProductId'];
              
              // 如果extra中有基本信息，优先使用extra中的数据（编辑模式）
              final finalSpuId = extra?['spuId'] ?? spuId;
              final finalSpuName = extra?['spuName'] ?? spuName;
              final finalSpuCode = extra?['spuCode'] ?? spuCode;
              final finalSpuImageUrl = extra?['spuImageUrl'] ?? spuImageUrl;

              // 调试日志
              debugPrint('=== 商品详情页面路由调试 ===');
              debugPrint('查询参数: spuId="$spuId", spuName="$spuName", spuCode="$spuCode"');
              debugPrint('Extra参数: $extra');
              debugPrint('最终参数: finalSpuId="$finalSpuId" (长度: ${finalSpuId.length}), isEditMode=$isEditMode, personalProductId=$personalProductId');
              debugPrint('SPU扩展数据: ${extra?['spuData']}');

              // 参数验证 - 编辑模式下允许spuId为空，因为可以通过personalProductId获取
              if (!isEditMode && finalSpuId.isEmpty) {
                debugPrint('❌ 新增模式下缺少SPU参数');
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('参数错误'),
                    backgroundColor: Colors.red,
                  ),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '缺少必要的SPU参数',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('请从正确的页面进入商品创建流程'),
                      ],
                    ),
                  ),
                );
              }

              // 编辑模式下验证personalProductId
              if (isEditMode && (personalProductId == null || personalProductId.isEmpty)) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('参数错误'),
                    backgroundColor: Colors.red,
                  ),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '编辑模式缺少商品ID',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('无法获取要编辑的商品信息'),
                      ],
                    ),
                  ),
                );
              }

              return ProductDetailCreateScreen(
                spuId: finalSpuId.isNotEmpty ? finalSpuId : (isEditMode ? 'temp_spu_id' : finalSpuId),
                spuName: finalSpuName,
                spuCode: finalSpuCode,
                spuImageUrl: finalSpuImageUrl,
                isEditMode: isEditMode,
                personalProductId: personalProductId,
                existingData: null, // 不再使用existingData，通过API获取
                spuData: extra?['spuData'] as Map<String, dynamic>?, // 传递SPU扩展数据
              );
            },
          ),
          GoRoute(
            path: 'product-detail-demo',
            name: 'product-detail-demo',
            builder: (context, state) => const ProductDetailDemoScreen(),
          ),
          GoRoute(
            path: 'batch-add-product',
            name: 'batch-add-product',
            builder: (context, state) => BatchAddProductScreen(
              routeData: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: 'product-management',
            name: 'product-management',
            builder: (context, state) => const ProductManagementScreen(),
          ),
          GoRoute(
            path: 'bulk-edit',
            name: 'bulk-edit',
            builder: (context, state) {
              debugPrint('路由构建 BulkEditScreen，extra参数: ${state.extra}');
              return BulkEditScreen(
                routeData: state.extra as Map<String, dynamic>?,
              );
            },
          ),
        ],
      ),
    ],
  );
});
