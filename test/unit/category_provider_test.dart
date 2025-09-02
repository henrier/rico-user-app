import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/providers/category_provider.dart';

void main() {
  group('CategoryProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should load categories on initialization', () async {
      // 触发Provider创建
      container.read(categoryViewModelProvider);

      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 600));

      final state = container.read(categoryViewModelProvider);

      expect(state.isLoading, false);
      expect(state.thirdLevelCategories.isNotEmpty, true);
      expect(state.selectedThirdCategory, isNotNull);
      expect(state.fourthLevelCategories.isNotEmpty, true);
    });

    test('should select third category and update fourth level categories',
        () async {
      // 触发Provider创建
      final notifier = container.read(categoryViewModelProvider.notifier);

      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 600));

      final initialState = container.read(categoryViewModelProvider);
      final megaCategory = initialState.thirdLevelCategories
          .firstWhere((cat) => cat.name == 'MEGA');

      // 选择MEGA类目
      notifier.selectThirdCategory(megaCategory);

      final updatedState = container.read(categoryViewModelProvider);

      expect(updatedState.selectedThirdCategory?.name, 'MEGA');
      expect(updatedState.fourthLevelCategories.isNotEmpty, true);
      expect(
        updatedState.fourthLevelCategories
            .any((cat) => cat.name == 'Journey Together'),
        true,
      );
    });

    test('should not change selection if same category is selected', () async {
      // 触发Provider创建
      final notifier = container.read(categoryViewModelProvider.notifier);

      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 600));

      final initialState = container.read(categoryViewModelProvider);
      final firstCategory = initialState.selectedThirdCategory!;
      final initialFourthLevel = initialState.fourthLevelCategories;

      // 重复选择同一个类目
      notifier.selectThirdCategory(firstCategory);

      final updatedState = container.read(categoryViewModelProvider);

      expect(updatedState.selectedThirdCategory?.id, firstCategory.id);
      expect(
          updatedState.fourthLevelCategories.length, initialFourthLevel.length);
    });
  });
}
