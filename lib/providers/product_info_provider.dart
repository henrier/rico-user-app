import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/utils/logger.dart';
import '../models/page_data.dart';
import '../models/productinfo/data.dart';
import '../models/productinfo/service.dart';

/// 商品信息服务Provider
final productInfoServiceProvider = Provider<ProductInfoService>((ref) {
  return ProductInfoService();
});

/// 商品信息分页数据Provider
final productInfoPageProvider = FutureProvider.family<PageData<ProductInfo>, ProductInfoPageParams>(
  (ref, params) async {
    final service = ref.read(productInfoServiceProvider);
    try {
      AppLogger.i('获取商品信息分页数据: 页码=${params.current}');
      final result = await service.getProductInfoPage(params);
      AppLogger.i('成功获取${result.list.length}个商品信息');
      return result;
    } catch (e) {
      AppLogger.e('获取商品信息分页数据失败', e);
      rethrow;
    }
  },
);

/// 商品信息详情Provider
final productInfoDetailProvider = FutureProvider.family<ProductInfo, String>(
  (ref, productInfoId) async {
    final service = ref.read(productInfoServiceProvider);
    try {
      AppLogger.i('获取商品信息详情: $productInfoId');
      final result = await service.getProductInfoDetail(productInfoId);
      AppLogger.i('成功获取商品信息详情: ${result.displayName}');
      return result;
    } catch (e) {
      AppLogger.e('获取商品信息详情失败', e);
      rethrow;
    }
  },
);

/// 商品信息等级列表Provider
final productInfoLevelsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(productInfoServiceProvider);
  try {
    AppLogger.i('获取商品信息等级列表');
    final result = await service.getProductInfoDistinctLevels();
    AppLogger.i('成功获取${result.length}个等级');
    return result;
  } catch (e) {
    AppLogger.e('获取商品信息等级列表失败', e);
    rethrow;
  }
});

/// 商品信息缓存状态
class ProductInfoCacheState {
  /// 缓存的商品信息列表
  final Map<String, List<ProductInfo>> cachedLists;
  
  /// 缓存的商品信息详情
  final Map<String, ProductInfo> cachedDetails;
  
  /// 最后更新时间
  final DateTime lastUpdated;

  const ProductInfoCacheState({
    this.cachedLists = const {},
    this.cachedDetails = const {},
    required this.lastUpdated,
  });

  ProductInfoCacheState copyWith({
    Map<String, List<ProductInfo>>? cachedLists,
    Map<String, ProductInfo>? cachedDetails,
    DateTime? lastUpdated,
  }) {
    return ProductInfoCacheState(
      cachedLists: cachedLists ?? this.cachedLists,
      cachedDetails: cachedDetails ?? this.cachedDetails,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 商品信息缓存Provider
class ProductInfoCacheNotifier extends StateNotifier<ProductInfoCacheState> {
  ProductInfoCacheNotifier() : super(ProductInfoCacheState(lastUpdated: DateTime.now()));

  /// 缓存商品信息列表
  void cacheProductInfoList(String key, List<ProductInfo> productInfos) {
    final newCachedLists = Map<String, List<ProductInfo>>.from(state.cachedLists);
    newCachedLists[key] = productInfos;
    
    state = state.copyWith(
      cachedLists: newCachedLists,
      lastUpdated: DateTime.now(),
    );
    
    AppLogger.d('缓存商品信息列表: $key, 数量: ${productInfos.length}');
  }

  /// 获取缓存的商品信息列表
  List<ProductInfo>? getCachedProductInfoList(String key) {
    final cached = state.cachedLists[key];
    if (cached != null) {
      AppLogger.d('从缓存获取商品信息列表: $key, 数量: ${cached.length}');
    }
    return cached;
  }

  /// 缓存商品信息详情
  void cacheProductInfoDetail(String id, ProductInfo productInfo) {
    final newCachedDetails = Map<String, ProductInfo>.from(state.cachedDetails);
    newCachedDetails[id] = productInfo;
    
    state = state.copyWith(
      cachedDetails: newCachedDetails,
      lastUpdated: DateTime.now(),
    );
    
    AppLogger.d('缓存商品信息详情: ${productInfo.displayName}');
  }

  /// 获取缓存的商品信息详情
  ProductInfo? getCachedProductInfoDetail(String id) {
    final cached = state.cachedDetails[id];
    if (cached != null) {
      AppLogger.d('从缓存获取商品信息详情: ${cached.displayName}');
    }
    return cached;
  }

  /// 清除缓存
  void clearCache() {
    state = ProductInfoCacheState(lastUpdated: DateTime.now());
    AppLogger.i('清除商品信息缓存');
  }

  /// 清除特定列表缓存
  void clearListCache(String key) {
    final newCachedLists = Map<String, List<ProductInfo>>.from(state.cachedLists);
    newCachedLists.remove(key);
    
    state = state.copyWith(
      cachedLists: newCachedLists,
      lastUpdated: DateTime.now(),
    );
    
    AppLogger.d('清除商品信息列表缓存: $key');
  }

  /// 检查缓存是否过期
  bool isCacheExpired({Duration maxAge = const Duration(minutes: 5)}) {
    final now = DateTime.now();
    final isExpired = now.difference(state.lastUpdated) > maxAge;
    if (isExpired) {
      AppLogger.d('商品信息缓存已过期');
    }
    return isExpired;
  }
}

/// 商品信息缓存Provider
final productInfoCacheProvider = StateNotifierProvider<ProductInfoCacheNotifier, ProductInfoCacheState>(
  (ref) => ProductInfoCacheNotifier(),
);

/// 商品信息搜索Provider
final productInfoSearchProvider = FutureProvider.family<List<ProductInfo>, String>(
  (ref, keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    final service = ref.read(productInfoServiceProvider);
    try {
      AppLogger.i('搜索商品信息: $keyword');
      
      final params = ProductInfoPageParams(
        current: 1,
        pageSize: 50, // 搜索时返回更多结果
        nameEnglish: keyword,
        nameChinese: keyword,
        code: keyword,
      );
      
      final result = await service.getProductInfoPage(params);
      AppLogger.i('搜索到${result.list.length}个商品信息');
      return result.list;
    } catch (e) {
      AppLogger.e('搜索商品信息失败', e);
      rethrow;
    }
  },
);

/// 商品信息统计Provider
final productInfoStatsProvider = FutureProvider<ProductInfoStats>((ref) async {
  final service = ref.read(productInfoServiceProvider);
  try {
    AppLogger.i('获取商品信息统计');
    
    // 获取总数统计
    const totalParams = ProductInfoPageParams(current: 1, pageSize: 1);
    final totalResult = await service.getProductInfoPage(totalParams);
    
    // 获取等级统计
    final levels = await service.getProductInfoDistinctLevels();
    
    final stats = ProductInfoStats(
      totalCount: totalResult.total,
      levelCount: levels.length,
      levels: levels,
    );
    
    AppLogger.i('商品信息统计: 总数=${stats.totalCount}, 等级数=${stats.levelCount}');
    return stats;
  } catch (e) {
    AppLogger.e('获取商品信息统计失败', e);
    rethrow;
  }
});

/// 商品信息统计数据
class ProductInfoStats {
  /// 商品总数
  final int totalCount;
  
  /// 等级数量
  final int levelCount;
  
  /// 等级列表
  final List<String> levels;

  const ProductInfoStats({
    required this.totalCount,
    required this.levelCount,
    required this.levels,
  });
}
