import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/utils/logger.dart';

/// 商品搜索状态
class ProductSearchState {
  /// 商品列表
  final List<ProductSearchItem> productList;

  /// 是否正在加载
  final bool isLoading;

  /// 搜索关键字
  final String searchKeyword;

  /// 错误信息
  final String? errorMessage;

  /// 是否为空状态（首次进入，未搜索）
  final bool isEmpty;

  /// 是否显示无结果状态
  final bool showNoResults;

  const ProductSearchState({
    this.productList = const [],
    this.isLoading = false,
    this.searchKeyword = '',
    this.errorMessage,
    this.isEmpty = true,
    this.showNoResults = false,
  });

  ProductSearchState copyWith({
    List<ProductSearchItem>? productList,
    bool? isLoading,
    String? searchKeyword,
    String? errorMessage,
    bool? isEmpty,
    bool? showNoResults,
  }) {
    return ProductSearchState(
      productList: productList ?? this.productList,
      isLoading: isLoading ?? this.isLoading,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      errorMessage: errorMessage,
      isEmpty: isEmpty ?? this.isEmpty,
      showNoResults: showNoResults ?? this.showNoResults,
    );
  }
}

/// 商品搜索项数据模型
class ProductSearchItem {
  final String id;
  final String name;
  final String code;
  final String? imageUrl;
  final String category;
  final String? language;
  final String? level;
  final double? price;

  const ProductSearchItem({
    required this.id,
    required this.name,
    required this.code,
    this.imageUrl,
    required this.category,
    this.language,
    this.level,
    this.price,
  });
}

/// 商品搜索ViewModel
class ProductSearchViewModel extends StateNotifier<ProductSearchState> {
  ProductSearchViewModel() : super(const ProductSearchState());

  /// 模拟商品数据
  static final List<ProductSearchItem> _mockProducts = [
    ProductSearchItem(
      id: '1',
      name: 'Pokémon Trading Card Game Classic',
      code: 'PKM-TCG-001',
      imageUrl: 'https://images.pokemontcg.io/base1/4_hires.png',
      category: 'Pokémon',
      language: 'EN',
      level: 'Base Set',
      price: 29.99,
    ),
    ProductSearchItem(
      id: '2',
      name: 'Charizard VMAX Rainbow Rare',
      code: 'PKM-TCG-002',
      imageUrl: 'https://images.pokemontcg.io/swsh4/74_hires.png',
      category: 'Pokémon',
      language: 'EN',
      level: 'VMAX',
      price: 199.99,
    ),
    ProductSearchItem(
      id: '3',
      name: 'Pikachu Promo Card',
      code: 'PKM-PROMO-025',
      imageUrl: 'https://images.pokemontcg.io/base1/58_hires.png',
      category: 'Pokémon',
      language: 'JP',
      level: 'Promo',
      price: 15.99,
    ),
    ProductSearchItem(
      id: '4',
      name: 'Blue-Eyes White Dragon',
      code: 'YGO-LOB-001',
      imageUrl: 'https://ms.yugipedia.com//thumb/c/c8/BlueEyesWhiteDragon-SDK-EN-UR-1E.png/300px-BlueEyesWhiteDragon-SDK-EN-UR-1E.png',
      category: 'Yu-Gi-Oh!',
      language: 'EN',
      level: 'Ultra Rare',
      price: 89.99,
    ),
    ProductSearchItem(
      id: '5',
      name: 'Dark Magician Girl',
      code: 'YGO-MFC-000',
      imageUrl: 'https://ms.yugipedia.com//thumb/d/d5/DarkMagicianGirl-YGLD-EN-C-1E.png/300px-DarkMagicianGirl-YGLD-EN-C-1E.png',
      category: 'Yu-Gi-Oh!',
      language: 'EN',
      level: 'Secret Rare',
      price: 45.99,
    ),
    ProductSearchItem(
      id: '6',
      name: 'Magic: The Gathering Starter Deck',
      code: 'MTG-STD-001',
      category: 'Magic',
      language: 'EN',
      level: 'Standard',
      price: 12.99,
    ),
    ProductSearchItem(
      id: '7',
      name: 'Black Lotus Alpha',
      code: 'MTG-ALP-232',
      category: 'Magic',
      language: 'EN',
      level: 'Alpha',
      price: 25000.00,
    ),
    ProductSearchItem(
      id: '8',
      name: 'Lightning Bolt',
      code: 'MTG-LEA-161',
      category: 'Magic',
      language: 'EN',
      level: 'Beta',
      price: 299.99,
    ),
  ];

  /// 搜索商品
  Future<void> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      AppLogger.w('搜索关键字为空');
      return;
    }

    try {
      // 设置加载状态
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        searchKeyword: keyword.trim(),
        isEmpty: false,
        showNoResults: false,
      );

      AppLogger.i('开始搜索商品: $keyword');

      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 在模拟数据中搜索
      final results = _mockProducts.where((product) {
        final searchTerm = keyword.toLowerCase();
        return product.name.toLowerCase().contains(searchTerm) ||
               product.code.toLowerCase().contains(searchTerm) ||
               product.category.toLowerCase().contains(searchTerm);
      }).toList();

      // 更新状态
      state = state.copyWith(
        productList: results,
        isLoading: false,
        showNoResults: results.isEmpty,
      );

      AppLogger.i('搜索完成，找到${results.length}个商品');
    } catch (e) {
      AppLogger.e('搜索商品失败', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '搜索失败: ${e.toString()}',
      );
    }
  }

  /// 清空搜索结果
  void clearSearch() {
    state = const ProductSearchState();
  }

  /// 获取搜索建议（基于已有的商品名称）
  List<String> getSearchSuggestions(String keyword) {
    if (keyword.trim().isEmpty) return [];
    
    final suggestions = <String>{};
    final searchTerm = keyword.toLowerCase();
    
    for (final product in _mockProducts) {
      if (product.name.toLowerCase().contains(searchTerm)) {
        suggestions.add(product.name);
      }
      if (product.category.toLowerCase().contains(searchTerm)) {
        suggestions.add(product.category);
      }
    }
    
    return suggestions.take(5).toList();
  }
}

/// 商品搜索ViewModel Provider
final productSearchViewModelProvider = StateNotifierProvider<ProductSearchViewModel, ProductSearchState>((ref) {
  return ProductSearchViewModel();
});