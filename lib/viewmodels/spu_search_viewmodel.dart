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

  /// 筛选条件
  final Map<String, Set<String>> filterConditions;

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
    this.filterConditions = const {},
    this.errorMessage,
    this.isEmpty = true,
  });

  SpuSearchState copyWith({
    List<ProductInfo>? productList,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? searchKeyword,
    Map<String, Set<String>>? filterConditions,
    String? errorMessage,
    bool? isEmpty,
  }) {
    return SpuSearchState(
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

      final params = _buildSearchParams(
        keyword: keyword.trim(),
        page: 1,
        filterConditions: state.filterConditions,
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
      final params = _buildSearchParams(
        keyword: state.searchKeyword,
        page: nextPage,
        filterConditions: state.filterConditions,
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

  /// 应用筛选条件并重新搜索
  Future<void> applyFilter(Map<String, Set<String>> filterConditions) async {
    if (state.searchKeyword.isEmpty) {
      AppLogger.w('没有搜索关键字，无法应用筛选');
      return;
    }

    try {
      // 更新筛选条件并开始搜索
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 1,
        filterConditions: filterConditions,
      );

      AppLogger.i('应用筛选条件重新搜索: ${state.searchKeyword}');

      final params = _buildSearchParams(
        keyword: state.searchKeyword,
        page: 1,
        filterConditions: filterConditions,
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

      AppLogger.i('筛选搜索完成，找到${pageData.list.length}个商品');
    } catch (e) {
      AppLogger.e('筛选搜索失败', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '筛选搜索失败: ${e.toString()}',
      );
    }
  }

  /// 构建搜索参数
  ProductInfoManualPageParams _buildSearchParams({
    required String keyword,
    required int page,
    Map<String, Set<String>>? filterConditions,
  }) {
    // 获取Level筛选条件
    final levelFilters = filterConditions?['Level'];
    
    // 将Set<String>转换为List<String>以支持多个level值
    final selectedLevels = levelFilters?.isNotEmpty == true 
        ? levelFilters!.toList() 
        : null;
    
    AppLogger.d('构建搜索参数 - 关键字: $keyword, 页码: $page, Level筛选: $selectedLevels');

    return ProductInfoManualPageParams(
      current: page,
      pageSize: 20,
      name: keyword,
      level: selectedLevels, // 使用level字段进行筛选，支持多个值
    );
  }
}

/// SPU搜索ViewModel Provider
final spuSearchViewModelProvider = StateNotifierProvider<SpuSearchViewModel, SpuSearchState>((ref) {
  final productInfoService = ProductInfoService();
  return SpuSearchViewModel(productInfoService);
});
