import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audit_metadata.dart';
import '../models/i18n_string.dart';
import '../models/productcategory/data.dart';
import '../models/productinfo/data.dart';

class ProductSearchMockState {
  final List<ProductInfo> productList;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String searchKeyword;
  final Map<String, Set<String>> filterConditions;
  final String? errorMessage;
  final bool isEmpty;

  const ProductSearchMockState({
    this.productList = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.searchKeyword = '',
    this.filterConditions = const {},
    this.errorMessage,
    this.isEmpty = true,
  });

  ProductSearchMockState copyWith({
    List<ProductInfo>? productList,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? searchKeyword,
    Map<String, Set<String>>? filterConditions,
    String? errorMessage,
    bool? isEmpty,
  }) {
    return ProductSearchMockState(
      productList: productList ?? this.productList,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      filterConditions: filterConditions ?? this.filterConditions,
      errorMessage: errorMessage,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }
}

class ProductSearchMockViewModel extends StateNotifier<ProductSearchMockState> {
  ProductSearchMockViewModel() : super(const ProductSearchMockState());

  /// 触发搜索（使用模拟数据）
  Future<void> search(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isEmpty: false,
      searchKeyword: trimmed,
      currentPage: 1,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    final all = _mockProducts();
    final filteredByKeyword = all.where((p) {
      final text = '${p.displayName}|${p.code}'.toLowerCase();
      return text.contains(trimmed.toLowerCase());
    }).toList();

    // 应用筛选条件（Level）
    final selectedLevels = state.filterConditions['Level'];
    final applied = (selectedLevels != null && selectedLevels.isNotEmpty)
        ? filteredByKeyword
            .where((p) => selectedLevels.contains(p.level))
            .toList()
        : filteredByKeyword;

    state = state.copyWith(
      productList: applied,
      isLoading: false,
      hasMore: false,
      currentPage: 1,
    );
  }

  Future<void> applyFilter(Map<String, Set<String>> conditions) async {
    state = state.copyWith(filterConditions: conditions);
    if (state.searchKeyword.isNotEmpty) {
      await search(state.searchKeyword);
    }
  }

  void clear() {
    state = const ProductSearchMockState();
  }

  List<ProductInfo> _mockProducts() {
    final now = DateTime.now();
    ProductInfo make({
      required String id,
      required String zh,
      required String en,
      required String code,
      required String level,
      required String categoryName,
      List<String> images = const [],
    }) {
      return ProductInfo(
        id: id,
        name: I18NString(chinese: zh, english: en, japanese: ''),
        code: code,
        level: level,
        suggestedPrice: 0,
        cardLanguage: CardLanguage.en,
        type: ProductType.raw,
        categories: [
          ProductCategory(
            id: 'cat_$categoryName',
            name: categoryName,
            displayName: categoryName,
            parentId: '',
            level: 1,
            children: const [],
          ),
        ],
        cardEffectTemplate: null,
        cardEffects: const [],
        images: images,
        auditMetadata: AuditMetadata(createdAt: now, updatedAt: now),
      );
    }

    return [
      make(
        id: '1',
        zh: '皮卡丘 VSTAR',
        en: 'Pikachu VSTAR',
        code: 'PIKA-001',
        level: 'SSR',
        categoryName: 'Pokémon',
      ),
      make(
        id: '2',
        zh: '喷火龙 GX',
        en: 'Charizard GX',
        code: 'CHAR-002',
        level: 'SR',
        categoryName: 'Pokémon',
      ),
      make(
        id: '3',
        zh: '妙蛙种子',
        en: 'Bulbasaur',
        code: 'BULB-003',
        level: 'R',
        categoryName: 'Pokémon',
      ),
    ];
  }
}

final productSearchMockProvider =
    StateNotifierProvider<ProductSearchMockViewModel, ProductSearchMockState>((ref) {
  return ProductSearchMockViewModel();
});

