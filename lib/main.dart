import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    
    return MaterialApp.router(
      title: 'Rico User App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.flutterThemeMode, // 🔥 动态主题模式
      routerConfig: router,
    );
  }
}
