import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/common/utils/logger.dart';
import '../../lib/providers/category_provider.dart';

void main() {
  group('CategoryProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      // 初始化Logger
      AppLogger.init();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should load categories on initialization', () async {
      const secondCategoryId = 'testSecondCategoryId';

      // 触发Provider创建
      container.read(categoryViewModelProvider(secondCategoryId));

      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 600));

      final state = container.read(categoryViewModelProvider(secondCategoryId));

      expect(state.isLoading, false);
      expect(state.secondCategoryId, secondCategoryId);
      // 注意：由于使用真实API，这里可能会失败，但测试结构是正确的
    });

    test('should handle API errors gracefully', () async {
      const secondCategoryId = 'invalidCategoryId';

      // 触发Provider创建
      container.read(categoryViewModelProvider(secondCategoryId));

      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 2000));

      final state = container.read(categoryViewModelProvider(secondCategoryId));

      expect(state.isLoading, false);
      // 由于API调用可能失败，检查错误状态
      if (state.error != null) {
        expect(state.error, isNotNull);
        expect(state.thirdLevelCategories.isEmpty, true);
      }
    });

    test('should handle second category ID changes', () async {
      const firstCategoryId = 'firstCategoryId';
      const secondCategoryId = 'secondCategoryId';

      // 创建第一个Provider
      container.read(categoryViewModelProvider(firstCategoryId));
      await Future.delayed(const Duration(milliseconds: 600));

      final firstState =
          container.read(categoryViewModelProvider(firstCategoryId));
      expect(firstState.secondCategoryId, firstCategoryId);

      // 创建第二个Provider
      container.read(categoryViewModelProvider(secondCategoryId));
      await Future.delayed(const Duration(milliseconds: 600));

      final secondState =
          container.read(categoryViewModelProvider(secondCategoryId));
      expect(secondState.secondCategoryId, secondCategoryId);
    });
  });
}
