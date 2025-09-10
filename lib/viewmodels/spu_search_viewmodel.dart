import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/utils/logger.dart';
import '../models/page_data.dart';
import '../models/productinfo/data.dart';
import '../models/productinfo/service.dart';

/// SPU搜索状态
class SpuSearchState {
  /// 商品列表
  final List<ProductInfo> productList;

  /// 是否正在加载
  final bool isLoading;

  /// 是否还有更多数据
  final bool hasMore;

  /// 当前页码
  final int currentPage;

  /// 搜索关键字
  final String searchKeyword;

  /// 错误信息
  final String? errorMessage;

  /// 是否为空状态（首次进入，未搜索）
  final bool isEmpty;

  const SpuSearchState({
    this.productList = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchKeyword = '',
    this.errorMessage,
    this.isEmpty = true,
  });

  SpuSearchState copyWith({
    List<ProductInfo>? productList,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? searchKeyword,
    String? errorMessage,
    bool? isEmpty,
  }) {
    return SpuSearchState(
      productList: productList ?? this.productList,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      errorMessage: errorMessage,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }
}

/// SPU搜索ViewModel
class SpuSearchViewModel extends StateNotifier<SpuSearchState> {
  final ProductInfoService _productInfoService;

  SpuSearchViewModel(this._productInfoService) : super(const SpuSearchState());

  /// 搜索商品
  Future<void> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      AppLogger.w('搜索关键字为空');
      return;
    }

    try {
      // 重置状态，开始新搜索
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 1,
        searchKeyword: keyword.trim(),
        isEmpty: false,
      );

      AppLogger.i('开始搜索商品: $keyword');

      final params = ProductInfoManualPageParams(
        current: 1,
        pageSize: 20,
        name: keyword.trim(), // 使用name字段进行合并名称搜索
      );

      final pageData = await _productInfoService.getProductInfoPageByName(params);

      // 计算是否还有更多数据
      final hasMore = pageData.current * pageData.pageSize < pageData.total;

      state = state.copyWith(
        productList: pageData.list,
        isLoading: false,
        hasMore: hasMore,
        currentPage: 1,
      );

      AppLogger.i('搜索完成，找到${pageData.list.length}个商品');
    } catch (e) {
      AppLogger.e('搜索商品失败', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '搜索失败: ${e.toString()}',
      );
    }
  }

  /// 加载更多商品
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.searchKeyword.isEmpty) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      final nextPage = state.currentPage + 1;
      final params = ProductInfoManualPageParams(
        current: nextPage,
        pageSize: 20,
        name: state.searchKeyword,
      );

      final pageData = await _productInfoService.getProductInfoPageByName(params);

      final updatedList = [...state.productList, ...pageData.list];
      
      // 计算是否还有更多数据
      final hasMore = pageData.current * pageData.pageSize < pageData.total;

      state = state.copyWith(
        productList: updatedList,
        isLoading: false,
        hasMore: hasMore,
        currentPage: nextPage,
      );

      AppLogger.i('加载更多完成，当前共${updatedList.length}个商品');
    } catch (e) {
      AppLogger.e('加载更多失败', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载更多失败: ${e.toString()}',
      );
    }
  }

  /// 清空搜索结果
  void clearSearch() {
    state = const SpuSearchState();
  }

  /// 刷新搜索结果
  Future<void> refresh() async {
    if (state.searchKeyword.isNotEmpty) {
      await searchProducts(state.searchKeyword);
    }
  }
}

/// SPU搜索ViewModel Provider
final spuSearchViewModelProvider = StateNotifierProvider<SpuSearchViewModel, SpuSearchState>((ref) {
  final productInfoService = ProductInfoService();
  return SpuSearchViewModel(productInfoService);
});
