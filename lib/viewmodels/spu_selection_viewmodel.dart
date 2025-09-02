import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/utils/logger.dart';
import '../models/productinfo/data.dart';
import '../models/productinfo/service.dart';

/// SPU选择页面状态
class SpuSelectionViewModelState {
  /// SPU列表
  final List<ProductInfo> spuList;

  /// 当前选中的分类类型
  final ProductType selectedType;

  /// 当前页码
  final int currentPage;

  /// 每页大小
  final int pageSize;

  /// 是否还有更多数据
  final bool hasMore;

  /// 总数量
  final int total;

  /// 搜索关键词
  final String searchKeyword;

  /// 筛选参数
  final SpuSelectionFilter filter;

  /// 类目ID
  final String? categoryId;

  const SpuSelectionViewModelState({
    this.spuList = const [],
    this.selectedType = ProductType.singles,
    this.currentPage = 1,
    this.pageSize = 20,
    this.hasMore = true,
    this.total = 0,
    this.searchKeyword = '',
    this.filter = const SpuSelectionFilter(),
    this.categoryId,
  });

  SpuSelectionViewModelState copyWith({
    List<ProductInfo>? spuList,
    ProductType? selectedType,
    int? currentPage,
    int? pageSize,
    bool? hasMore,
    int? total,
    String? searchKeyword,
    SpuSelectionFilter? filter,
    String? categoryId,
  }) {
    return SpuSelectionViewModelState(
      spuList: spuList ?? this.spuList,
      selectedType: selectedType ?? this.selectedType,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      filter: filter ?? this.filter,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

/// 商品类型枚举
enum ProductType {
  singles('Singles', 'singles'),
  sealedProducts('Sealed Products', 'sealed');

  const ProductType(this.displayName, this.value);

  final String displayName;
  final String value;
}

/// SPU选择筛选参数
class SpuSelectionFilter {
  /// 等级筛选
  final List<String> levels;

  /// 类目筛选
  final List<String> categories;

  /// 语言筛选
  final List<String> languages;

  const SpuSelectionFilter({
    this.levels = const [],
    this.categories = const [],
    this.languages = const [],
  });

  SpuSelectionFilter copyWith({
    List<String>? levels,
    List<String>? categories,
    List<String>? languages,
  }) {
    return SpuSelectionFilter(
      levels: levels ?? this.levels,
      categories: categories ?? this.categories,
      languages: languages ?? this.languages,
    );
  }

  /// 是否有筛选条件
  bool get hasFilters =>
      levels.isNotEmpty || categories.isNotEmpty || languages.isNotEmpty;
}

/// SPU选择ViewModel
class SpuSelectionViewModel extends StateNotifier<SpuSelectionViewModelState> {
  final ProductInfoService _productInfoService;

  SpuSelectionViewModel(this._productInfoService, String? categoryId)
      : super(SpuSelectionViewModelState(categoryId: categoryId)) {
    _loadInitialData();
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    await loadSpuList(refresh: true);
  }

  /// 加载SPU列表
  Future<void> loadSpuList({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          currentPage: 1,
          spuList: [],
          hasMore: true,
        );
      }

      if (!state.hasMore && !refresh) {
        AppLogger.d('没有更多数据了');
        return;
      }

      final params = _buildPageParams();
      AppLogger.i('正在加载SPU列表: 页码=${params.current}, 类目ID=${state.categoryId}');

      final pageData = await _productInfoService.getProductInfoPage(params);

      final newSpuList =
          refresh ? pageData.list : [...state.spuList, ...pageData.list];

      // 计算总页数
      final totalPages = (pageData.total / pageData.pageSize).ceil();

      state = state.copyWith(
        spuList: newSpuList,
        currentPage: pageData.current,
        hasMore: pageData.current < totalPages,
        total: pageData.total,
      );

      AppLogger.i('成功加载${pageData.list.length}个SPU，总计${newSpuList.length}个');
    } catch (e) {
      AppLogger.e('加载SPU列表失败', e);
      rethrow;
    }
  }

  /// 构建分页查询参数
  ProductInfoPageParams _buildPageParams() {
    // 构建类目筛选列表
    List<String> categoryFilter = [];

    // 如果有指定的类目ID，优先使用
    if (state.categoryId != null) {
      categoryFilter.add(state.categoryId!);
    }

    // 添加筛选条件中的类目
    if (state.filter.categories.isNotEmpty) {
      categoryFilter.addAll(state.filter.categories);
    }

    return ProductInfoPageParams(
      current: state.currentPage,
      pageSize: state.pageSize,
      // 根据类目ID筛选SPU
      categories: categoryFilter.isNotEmpty ? categoryFilter : null,
      // 搜索关键词
      nameEnglish: state.searchKeyword.isNotEmpty ? state.searchKeyword : null,
      nameChinese: state.searchKeyword.isNotEmpty ? state.searchKeyword : null,
      // 筛选条件
      level: state.filter.levels.isNotEmpty ? state.filter.levels.first : null,
    );
  }

  /// 切换商品类型
  Future<void> selectProductType(ProductType type) async {
    if (state.selectedType == type) return;

    AppLogger.i('切换商品类型: ${type.displayName}');
    state = state.copyWith(selectedType: type);
    await loadSpuList(refresh: true);
  }

  /// 搜索SPU
  Future<void> searchSpu(String keyword) async {
    AppLogger.i('搜索SPU: $keyword');
    state = state.copyWith(searchKeyword: keyword);
    await loadSpuList(refresh: true);
  }

  /// 应用筛选条件
  Future<void> applyFilter(SpuSelectionFilter filter) async {
    AppLogger.i('应用筛选条件: ${filter.hasFilters}');
    state = state.copyWith(filter: filter);
    await loadSpuList(refresh: true);
  }

  /// 清除筛选条件
  Future<void> clearFilter() async {
    AppLogger.i('清除筛选条件');
    state = state.copyWith(filter: const SpuSelectionFilter());
    await loadSpuList(refresh: true);
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    if (!state.hasMore) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadSpuList();
  }

  /// 刷新数据
  Future<void> refresh() async {
    AppLogger.i('刷新SPU列表');
    await loadSpuList(refresh: true);
  }

  /// 选择SPU项目
  void selectSpu(ProductInfo spu) {
    AppLogger.i('选择SPU: ${spu.displayName} (${spu.code})');
    // 这里可以添加选择SPU后的逻辑，比如导航到详情页面
  }
}

/// SPU选择ViewModel Provider
final spuSelectionViewModelProvider = StateNotifierProvider.family<
    SpuSelectionViewModel, SpuSelectionViewModelState, String?>(
  (ref, categoryId) {
    final productInfoService = ProductInfoService();
    return SpuSelectionViewModel(productInfoService, categoryId);
  },
);

/// 加载状态Provider
final isLoadingSpuProvider = Provider.family<bool, String?>((ref, categoryId) {
  // 这里可以根据需要添加加载状态的逻辑
  return false;
});

/// 错误状态Provider
final spuSelectionErrorProvider =
    Provider.family<String?, String?>((ref, categoryId) {
  // 这里可以根据需要添加错误状态的逻辑
  return null;
});
