import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../common/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // 主题设置部分
          _buildSectionHeader(context, '外观设置'),
          Card(
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  AppThemeMode.system,
                  themeState.themeMode,
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context,
                  ref,
                  AppThemeMode.light,
                  themeState.themeMode,
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context,
                  ref,
                  AppThemeMode.dark,
                  themeState.themeMode,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // 主题预览
          _buildSectionHeader(context, '主题预览'),
          _buildThemePreview(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppConstants.defaultPadding,
        top: AppConstants.smallPadding,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode themeMode,
    AppThemeMode currentMode,
  ) {
    final themeState = ThemeState(themeMode: themeMode);
    final isSelected = themeMode == currentMode;

    return ListTile(
      leading: Icon(
        themeState.icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(themeState.displayName),
      subtitle: Text(_getThemeDescription(themeMode)),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(themeMode);
      },
    );
  }

  String _getThemeDescription(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.system:
        return '跟随系统设置自动切换';
      case AppThemeMode.light:
        return '始终使用浅色主题';
      case AppThemeMode.dark:
        return '始终使用深色主题';
    }
  }

  Widget _buildThemePreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前主题效果',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 颜色样本
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorSample('主色调', colorScheme.primary),
                _buildColorSample('次要色', colorScheme.secondary),
                _buildColorSample('背景色', colorScheme.background),
                _buildColorSample('表面色', colorScheme.surface),
                _buildColorSample('错误色', colorScheme.error),
              ],
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 组件样本
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('示例按钮'),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('轮廓按钮'),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                TextButton(
                  onPressed: () {},
                  child: const Text('文本按钮'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSample(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
