import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common/themes/app_theme.dart';
import 'routes/app_router.dart';
import 'common/utils/logger.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  AppLogger.init();
  
  runApp(
    const ProviderScope(
      child: RicoUserApp(),
    ),
  );
}

class RicoUserApp extends ConsumerWidget {
  const RicoUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);
    
    return ScreenUtilInit(
      // 设计稿的设备尺寸（宽度，高度）
      designSize: const Size(750,1624), // iPhone X 尺寸作为设计基准
      // 最小文字适配，设置字体大小根据系统的"字体大小"辅助选项来进行缩放
      minTextAdapt: true,
      // 支持分屏尺寸
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Rico User App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.flutterThemeMode, // 🔥 动态主题模式
          routerConfig: router,
        );
      },
    );
  }
}
