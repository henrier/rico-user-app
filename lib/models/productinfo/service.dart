// 商品信息聚合 - API服务接口
//
// 对应后端 ProductInfo 聚合的服务接口
// 与 TypeScript 版本保持同步: docs/api/productinfo/service.ts

import 'package:dio/dio.dart';

import '../../api/base_api.dart';
import '../../common/constants/app_constants.dart';
import '../../common/utils/logger.dart';
import '../api_response.dart';
import '../cardeffectfields/data.dart';
import '../page_data.dart';
import 'data.dart';

/// 商品信息API服务
/// 对应 TypeScript 中的各个服务函数
class ProductInfoService extends BaseApi {
  static const String _baseUrl = AppConstants.baseUrl;
  static const String _apiPath = '/api/products/product-infos';

  final Dio _dio;

  ProductInfoService({Dio? dio}) : _dio = dio ?? Dio() {
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

  /// 创建商品信息
  /// 对应 TypeScript: createProductInfo
  Future<String> createProductInfo(CreateProductInfoParams params) async {
    try {
      AppLogger.i('正在创建商品信息: ${params.name}');

      final response = await _dio.post(
        _apiPath,
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建商品信息: ${apiResponse.data}');
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
      AppLogger.e('创建商品信息失败', e);
      rethrow;
    }
  }

  /// 创建商品信息（全参数）
  /// 对应 TypeScript: createProductInfoWithAllFields
  Future<String> createProductInfoWithAllFields(
      CreateProductInfoWithAllFieldsParams params) async {
    try {
      AppLogger.i('正在创建商品信息（全参数）: ${params.name}');

      final response = await _dio.post(
        '$_apiPath/with-all-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建商品信息: ${apiResponse.data}');
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
      AppLogger.e('创建商品信息失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 查询操作
  // ============================================================================

  /// 查询商品信息详情
  /// 对应 TypeScript: getProductInfoDetail
  Future<ProductInfo> getProductInfoDetail(String productInfoId) async {
    try {
      AppLogger.i('正在查询商品信息详情: $productInfoId');

      final response = await _dio.get('$_apiPath/$productInfoId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => ProductInfo.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取商品信息详情: ${apiResponse.data!.displayName}');
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
      AppLogger.e('查询商品信息详情失败', e);
      rethrow;
    }
  }

  /// 分页查询商品信息
  /// 对应 TypeScript: getProductInfoPage
  Future<PageData<ProductInfo>> getProductInfoPage(
      ProductInfoPageParams params) async {
    try {
      AppLogger.i('正在分页查询商品信息');

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
          (item) => ProductInfo.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个商品信息');
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
      AppLogger.e('分页查询商品信息失败', e);
      rethrow;
    }
  }

  /// 根据ID列表查询商品信息
  /// 对应 TypeScript: getProductInfoByIds
  Future<List<ProductInfo>> getProductInfoByIds(List<String> ids) async {
    try {
      AppLogger.i('正在根据ID列表查询商品信息: ${ids.length}个');

      final response = await _dio.get(
        '$_apiPath/batch',
        queryParameters: {'ids': ids},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) => ProductInfo.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个商品信息');
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
      AppLogger.e('根据ID列表查询商品信息失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 更新操作
  // ============================================================================

  /// 修改名称
  /// 对应 TypeScript: updateProductInfoName
  Future<void> updateProductInfoName(
      String productInfoId, UpdateProductInfoNameParams params) async {
    try {
      AppLogger.i('正在修改商品信息名称: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/name',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息名称');
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
      AppLogger.e('修改商品信息名称失败', e);
      rethrow;
    }
  }

  /// 修改编码
  /// 对应 TypeScript: updateProductInfoCode
  Future<void> updateProductInfoCode(
      String productInfoId, UpdateProductInfoCodeParams params) async {
    try {
      AppLogger.i('正在修改商品信息编码: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/code',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息编码');
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
      AppLogger.e('修改商品信息编码失败', e);
      rethrow;
    }
  }

  /// 修改等级
  /// 对应 TypeScript: updateProductInfoLevel
  Future<void> updateProductInfoLevel(
      String productInfoId, UpdateProductInfoLevelParams params) async {
    try {
      AppLogger.i('正在修改商品信息等级: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/level',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息等级');
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
      AppLogger.e('修改商品信息等级失败', e);
      rethrow;
    }
  }

  /// 修改建议售价
  /// 对应 TypeScript: updateProductInfoSuggestedPrice
  Future<void> updateProductInfoSuggestedPrice(
      String productInfoId, UpdateProductInfoSuggestedPriceParams params) async {
    try {
      AppLogger.i('正在修改商品信息建议售价: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/suggested-price',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息建议售价');
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
      AppLogger.e('修改商品信息建议售价失败', e);
      rethrow;
    }
  }

  /// 修改卡片语言
  /// 对应 TypeScript: updateProductInfoCardLanguage
  Future<void> updateProductInfoCardLanguage(
      String productInfoId, UpdateProductInfoCardLanguageParams params) async {
    try {
      AppLogger.i('正在修改商品信息卡片语言: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/card-language',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息卡片语言');
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
      AppLogger.e('修改商品信息卡片语言失败', e);
      rethrow;
    }
  }

  /// 修改类型
  /// 对应 TypeScript: updateProductInfoType
  Future<void> updateProductInfoType(
      String productInfoId, UpdateProductInfoTypeParams params) async {
    try {
      AppLogger.i('正在修改商品信息类型: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/type',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息类型');
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
      AppLogger.e('修改商品信息类型失败', e);
      rethrow;
    }
  }

  /// 修改卡牌效果模板
  /// 对应 TypeScript: updateProductInfoCardEffectTemplate
  Future<void> updateProductInfoCardEffectTemplate(String productInfoId,
      UpdateProductInfoCardEffectTemplateParams params) async {
    try {
      AppLogger.i('正在修改商品信息卡牌效果模板: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/card-effect-template',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息卡牌效果模板');
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
      AppLogger.e('修改商品信息卡牌效果模板失败', e);
      rethrow;
    }
  }

  /// 修改卡牌效果
  /// 对应 TypeScript: updateProductInfoCardEffects
  Future<void> updateProductInfoCardEffects(
      String productInfoId, UpdateProductInfoCardEffectsParams params) async {
    try {
      AppLogger.i('正在修改商品信息卡牌效果: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/card-effects',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息卡牌效果');
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
      AppLogger.e('修改商品信息卡牌效果失败', e);
      rethrow;
    }
  }

  /// 修改图片
  /// 对应 TypeScript: updateProductInfoImages
  Future<void> updateProductInfoImages(
      String productInfoId, UpdateProductInfoImagesParams params) async {
    try {
      AppLogger.i('正在修改商品信息图片: $productInfoId');

      final response = await _dio.put(
        '$_apiPath/$productInfoId/images',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品信息图片');
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
      AppLogger.e('修改商品信息图片失败', e);
      rethrow;
    }
  }

  /// 添加所属类目
  /// 对应 TypeScript: addProductInfoCategories
  Future<void> addProductInfoCategories(
      String productInfoId, AddProductInfoCategoriesParams params) async {
    try {
      AppLogger.i('正在添加商品信息所属类目: $productInfoId');

      final response = await _dio.post(
        '$_apiPath/$productInfoId/categories',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功添加商品信息所属类目');
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
      AppLogger.e('添加商品信息所属类目失败', e);
      rethrow;
    }
  }

  /// 移除所属类目
  /// 对应 TypeScript: removeProductInfoCategories
  Future<void> removeProductInfoCategories(
      String productInfoId, RemoveProductInfoCategoriesParams params) async {
    try {
      AppLogger.i('正在移除商品信息所属类目: $productInfoId');

      final response = await _dio.delete(
        '$_apiPath/$productInfoId/categories',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功移除商品信息所属类目');
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
      AppLogger.e('移除商品信息所属类目失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 删除操作
  // ============================================================================

  /// 删除商品信息
  /// 对应 TypeScript: deleteProductInfo
  Future<void> deleteProductInfo(String productInfoId) async {
    try {
      AppLogger.i('正在删除商品信息: $productInfoId');

      final response = await _dio.delete('$_apiPath/$productInfoId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功删除商品信息');
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
      AppLogger.e('删除商品信息失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 特殊查询操作
  // ============================================================================

  /// 获取卡牌效果动态字段模板
  /// 对应 TypeScript: getProductInfoCardEffectsTemplates
  Future<List<DynamicFieldTemplate>> getProductInfoCardEffectsTemplates(
      String cardEffectTemplateId) async {
    try {
      AppLogger.i('正在获取卡牌效果动态字段模板: $cardEffectTemplateId');

      final response = await _dio.get(
        '$_apiPath/card-effects/templates',
        queryParameters: {'cardEffectTemplateId': cardEffectTemplateId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) =>
                DynamicFieldTemplate.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个动态字段模板');
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
      AppLogger.e('获取卡牌效果动态字段模板失败', e);
      rethrow;
    }
  }

  /// 查询所有商品信息的 distinct level 值
  /// 对应 TypeScript: getProductInfoDistinctLevels
  Future<List<String>> getProductInfoDistinctLevels() async {
    try {
      AppLogger.i('正在查询所有商品信息的distinct level值');

      final response = await _dio.get('$_apiPath/levels/distinct');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => List<String>.from(data as List<dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取${apiResponse.data!.length}个不同的等级值');
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
      AppLogger.e('查询distinct level值失败', e);
      rethrow;
    }
  }

  /// 分页查询商品信息（使用合并名称查询）
  /// 对应 TypeScript: getProductInfoPageByName
  Future<PageData<ProductInfo>> getProductInfoPageByName(
      ProductInfoManualPageParams params) async {
    try {
      AppLogger.i('正在分页查询商品信息（使用合并名称查询）');

      final response = await _dio.get(
        '$_apiPath/page-by-name',
        queryParameters: params.toJson(),
      );

      AppLogger.d('响应状态码: ${response.statusCode}');
      AppLogger.d('响应数据: ${response.data}');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageData.fromJson(
          data as Map<String, dynamic>,
          (item) => ProductInfo.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个商品信息（按名称查询）');
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
      AppLogger.e('分页查询商品信息（按名称）失败', e);
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
