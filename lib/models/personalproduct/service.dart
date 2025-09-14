// 个人商品聚合 - API服务接口
//
// 对应后端 PersonalProduct 聚合的服务接口
// 与 TypeScript 版本保持同步: docs/api/personalproduct/service.ts 和 manual-service.ts

import 'package:dio/dio.dart';

import '../../api/base_api.dart';
import '../../common/constants/app_constants.dart';
import '../../common/utils/logger.dart';
import '../api_response.dart';
import '../page_data.dart';
import '../productcategory/data.dart';
import '../ratingcompany/data.dart';
import 'data.dart';

/// 个人商品API服务
/// 对应 TypeScript 中的各个服务函数
class PersonalProductService extends BaseApi {
  static const String _baseUrl = AppConstants.baseUrl;
  static const String _apiPath = '/api/products/personal-products';

  final Dio _dio;

  PersonalProductService({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // 添加token拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 获取token并添加到请求头
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          AppLogger.d('添加Authorization头: Bearer ${token.substring(0, 20)}...');
        } else {
          AppLogger.w('未找到token，请求可能需要认证');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 处理401错误（token失效）
        if (error.response?.statusCode == 401) {
          AppLogger.w('收到401错误，token可能已失效');
          await clearToken();
        }
        handler.next(error);
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => AppLogger.d(obj.toString()),
    ));
  }

  // ============================================================================
  // 创建操作
  // ============================================================================

  /// 创建个人商品
  /// 对应 TypeScript: createPersonalProduct
  Future<String> createPersonalProduct(CreatePersonalProductParams params) async {
    try {
      AppLogger.i('正在创建个人商品');

      final response = await _dio.post(
        _apiPath,
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建个人商品: ${apiResponse.data}');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('创建个人商品失败', e);
      rethrow;
    }
  }

  /// 创建个人商品（全参数）
  /// 对应 TypeScript: createPersonalProductWithAllFields
  Future<String> createPersonalProductWithAllFields(
      CreatePersonalProductWithAllFieldsParams params) async {
    try {
      AppLogger.i('正在创建个人商品（全参数）');

      final response = await _dio.post(
        '$_apiPath/with-all-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建个人商品: ${apiResponse.data}');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('创建个人商品失败', e);
      rethrow;
    }
  }

  /// 创建个人商品（移动端专用）
  /// 对应 TypeScript: createPersonalProductForMobile
  Future<String> createPersonalProductForMobile(
      CreatePersonalProductManualParams params) async {
    try {
      AppLogger.i('正在创建个人商品（移动端专用）');

      final response = await _dio.post(
        '$_apiPath/mobile-create',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建个人商品（移动端）: ${apiResponse.data}');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('创建个人商品（移动端）失败', e);
      rethrow;
    }
  }

  /// 批量创建个人商品（移动端专用）
  /// 对应 TypeScript: batchCreatePersonalProductForMobile
  Future<List<String>> batchCreatePersonalProductForMobile(
      List<BatchCreatePersonalProductManualParams> paramsList) async {
    try {
      AppLogger.i('正在批量创建个人商品（移动端专用）: ${paramsList.length}个');

      final response = await _dio.post(
        '$_apiPath/batch-mobile-create',
        data: paramsList.map((params) => params.toJson()).toList(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => List<String>.from(data as List<dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功批量创建个人商品（移动端）: ${apiResponse.data!.length}个');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('批量创建个人商品（移动端）失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 查询操作
  // ============================================================================

  /// 查询个人商品详情
  /// 对应 TypeScript: getPersonalProductDetail
  Future<PersonalProduct> getPersonalProductDetail(String personalProductId) async {
    try {
      AppLogger.i('正在查询个人商品详情: $personalProductId');

      final response = await _dio.get('$_apiPath/$personalProductId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PersonalProduct.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取个人商品详情: ${apiResponse.data!.displayName}');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('查询个人商品详情失败', e);
      rethrow;
    }
  }

  /// 分页查询个人商品
  /// 对应 TypeScript: getPersonalProductPage
  Future<PageData<PersonalProduct>> getPersonalProductPage(
      PersonalProductPageParams params) async {
    try {
      AppLogger.i('正在分页查询个人商品');

      final response = await _dio.get(
        _apiPath,
        queryParameters: params.toJson(),
      );

      AppLogger.d('响应状态码: ${response.statusCode}');
      AppLogger.d('响应数据: ${response.data}');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageData.fromJson(
          data as Map<String, dynamic>,
          (item) => PersonalProduct.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个个人商品');
        return pageData;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('分页查询个人商品失败', e);
      rethrow;
    }
  }

  /// 根据ID列表查询个人商品
  /// 对应 TypeScript: getPersonalProductByIds
  Future<List<PersonalProduct>> getPersonalProductByIds(List<String> ids) async {
    try {
      AppLogger.i('正在根据ID列表查询个人商品: ${ids.length}个');

      final response = await _dio.get(
        '$_apiPath/batch',
        queryParameters: {'ids': ids},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) => PersonalProduct.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个个人商品');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('根据ID列表查询个人商品失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 更新操作
  // ============================================================================

  /// 整体更新个人商品（移动端专用）
  /// 对应 TypeScript: updatePersonalProductForMobile
  Future<void> updatePersonalProductForMobile(
      String personalProductId, UpdatePersonalProductManualParams params) async {
    try {
      AppLogger.i('正在整体更新个人商品（移动端专用）: $personalProductId');

      final response = await _dio.put(
        '$_apiPath/$personalProductId/mobile-update',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功整体更新个人商品（移动端）');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('整体更新个人商品（移动端）失败', e);
      rethrow;
    }
  }

  /// 批量整体更新个人商品（移动端专用）
  /// 对应 TypeScript: batchUpdatePersonalProductForMobile
  Future<void> batchUpdatePersonalProductForMobile(
      List<UpdatePersonalProductManualParams> paramsList) async {
    try {
      AppLogger.i('正在批量整体更新个人商品（移动端专用）: ${paramsList.length}个');

      final response = await _dio.post(
        '$_apiPath/batch-mobile-update',
        data: paramsList.map((params) => params.toJson()).toList(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功批量整体更新个人商品（移动端）');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('批量整体更新个人商品（移动端）失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 删除操作
  // ============================================================================

  /// 删除个人商品
  /// 对应 TypeScript: deletePersonalProduct
  Future<void> deletePersonalProduct(String personalProductId) async {
    try {
      AppLogger.i('正在删除个人商品: $personalProductId');

      final response = await _dio.delete('$_apiPath/$personalProductId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功删除个人商品');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('删除个人商品失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 手动服务API方法（来自 manual-service.ts）
  // ============================================================================

  /// 根据查询条件统计数量（支持跨聚合查询）
  /// 对应 TypeScript: countPersonalProductsByCondition
  Future<int> countPersonalProductsByCondition(
      PersonalProductManualPageParams params) async {
    try {
      AppLogger.i('正在根据查询条件统计个人商品数量');

      final response = await _dio.get(
        '$_apiPath/count',
        queryParameters: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as int,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功统计个人商品数量: ${apiResponse.data}');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('统计个人商品数量失败', e);
      rethrow;
    }
  }

  /// 分页查询个人商品（支持多字段排序和跨聚合查询）
  /// 对应 TypeScript: getPersonalProductsPageWithSort
  Future<PageData<PersonalProduct>> getPersonalProductsPageWithSort(
      PersonalProductPageWithSortParams params) async {
    try {
      AppLogger.i('正在分页查询个人商品（支持多字段排序）');

      final response = await _dio.get(
        '$_apiPath/page-with-sort',
        queryParameters: params.toJson(),
      );

      AppLogger.d('响应状态码: ${response.statusCode}');
      AppLogger.d('响应数据: ${response.data}');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageData.fromJson(
          data as Map<String, dynamic>,
          (item) => PersonalProduct.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个个人商品（支持排序）');
        return pageData;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('分页查询个人商品（支持排序）失败', e);
      rethrow;
    }
  }

  /// 查询指定用户店铺的所有个人商品的 distinct 的 ratedCard.cardScore 值
  /// 对应 TypeScript: getDistinctCardScoresByOwner
  Future<List<String>> getDistinctCardScoresByOwner(String ownerId) async {
    try {
      AppLogger.i('正在查询指定店铺的distinct卡牌评分: $ownerId');

      final response = await _dio.get(
        '$_apiPath/card-scores/distinct',
        queryParameters: {'ownerId': ownerId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => List<String>.from(data as List<dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个不同的卡牌评分');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('查询distinct卡牌评分失败', e);
      rethrow;
    }
  }

  /// 查询指定店铺的所有个人商品的 distinct 的 productInfo 值，并进一步查询这些 productInfo 的 distinct 的 level 值
  /// 对应 TypeScript: getDistinctLevelsByOwner
  Future<List<String>> getDistinctLevelsByOwner(String ownerId) async {
    try {
      AppLogger.i('正在查询指定店铺的distinct等级: $ownerId');

      final response = await _dio.get(
        '$_apiPath/levels/distinct',
        queryParameters: {'ownerId': ownerId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => List<String>.from(data as List<dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个不同的等级');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('查询distinct等级失败', e);
      rethrow;
    }
  }

  /// 查询指定店铺的所有个人商品的 distinct 的 productInfo 值，并进一步查询这些 productInfo 的 distinct 的 categories 值
  /// 对应 TypeScript: getDistinctCategoriesByOwner
  Future<List<ProductCategory>> getDistinctCategoriesByOwner(String ownerId) async {
    try {
      AppLogger.i('正在查询指定店铺的distinct类目: $ownerId');

      final response = await _dio.get(
        '$_apiPath/categories/distinct',
        queryParameters: {'ownerId': ownerId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个不同的类目');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('查询distinct类目失败', e);
      rethrow;
    }
  }

  /// 查询指定店铺的所有个人商品的 distinct 的 ratedCard.ratingCompany 值
  /// 对应 TypeScript: getDistinctRatingCompaniesByOwner
  Future<List<RatingCompany>> getDistinctRatingCompaniesByOwner(String ownerId) async {
    try {
      AppLogger.i('正在查询指定店铺的distinct评级公司: $ownerId');

      final response = await _dio.get(
        '$_apiPath/rating-companies/distinct',
        queryParameters: {'ownerId': ownerId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) => RatingCompany.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个不同的评级公司');
        return apiResponse.data!;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('查询distinct评级公司失败', e);
      rethrow;
    }
  }

  /// 批量删除个人商品
  /// 对应 TypeScript: batchDeletePersonalProduct
  Future<void> batchDeletePersonalProduct(List<String> ids) async {
    try {
      AppLogger.i('正在批量删除个人商品: ${ids.length}个');

      final response = await _dio.delete(
        '$_apiPath/batch-delete',
        data: ids,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功批量删除个人商品');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'API返回错误: ${apiResponse.errorMessage ?? "未知错误"}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('网络请求失败', e);
      rethrow;
    } catch (e) {
      AppLogger.e('批量删除个人商品失败', e);
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
