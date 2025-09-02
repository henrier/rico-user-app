// 商品类目聚合 - API服务接口
//
// 对应后端 ProductCategory 聚合的服务接口
// 与 TypeScript 版本保持同步: docs/api/productcategory/service.ts

import 'package:dio/dio.dart';

import '../../api/base_api.dart';
import '../../common/utils/logger.dart';
import '../api_response.dart';
import '../page_data.dart';
import 'data.dart';

/// 商品类目API服务
/// 对应 TypeScript 中的各个服务函数
class ProductCategoryService extends BaseApi {
  static const String _baseUrl = 'http://localhost:8081'; // 本地开发服务器
  static const String _apiPath = '/api/products/product-categories';

  final Dio _dio;

  ProductCategoryService({Dio? dio}) : _dio = dio ?? Dio() {
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

  /// 创建商品类目
  /// 对应 TypeScript: createProductCategory
  Future<String> createProductCategory(
      CreateProductCategoryParams params) async {
    try {
      AppLogger.i('正在创建商品类目: ${params.name}');

      final response = await _dio.post(
        _apiPath,
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建商品类目: ${apiResponse.data}');
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
      AppLogger.e('创建商品类目失败', e);
      rethrow;
    }
  }

  /// 创建商品类目（全参数）
  /// 对应 TypeScript: createProductCategoryWithAllFields
  Future<String> createProductCategoryWithAllFields(
      CreateProductCategoryWithAllFieldsParams params) async {
    try {
      AppLogger.i('正在创建商品类目（全参数）: ${params.name}');

      final response = await _dio.post(
        '$_apiPath/with-all-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建商品类目: ${apiResponse.data}');
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
      AppLogger.e('创建商品类目失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 查询操作
  // ============================================================================

  /// 查询商品类目详情
  /// 对应 TypeScript: getProductCategoryDetail
  Future<ProductCategory> getProductCategoryDetail(
      String productCategoryId) async {
    try {
      AppLogger.i('正在查询商品类目详情: $productCategoryId');

      final response = await _dio.get('$_apiPath/$productCategoryId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => ProductCategory.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取商品类目详情: ${apiResponse.data!.displayName}');
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
      AppLogger.e('查询商品类目详情失败', e);
      rethrow;
    }
  }

  /// 分页查询商品类目
  /// 对应 TypeScript: getProductCategoryPage
  Future<PageData<ProductCategory>> getProductCategoryPage(
      ProductCategoryPageParams params) async {
    try {
      AppLogger.i('正在分页查询商品类目');

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
          (item) => ProductCategory.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个商品类目');
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
      AppLogger.e('分页查询商品类目失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 更新操作
  // ============================================================================

  /// 修改名称
  /// 对应 TypeScript: updateProductCategoryName
  Future<void> updateProductCategoryName(
      String productCategoryId, UpdateProductCategoryNameParams params) async {
    try {
      AppLogger.i('正在修改商品类目名称: $productCategoryId');

      final response = await _dio.put(
        '$_apiPath/$productCategoryId/name',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品类目名称');
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
      AppLogger.e('修改商品类目名称失败', e);
      rethrow;
    }
  }

  /// 修改图片
  /// 对应 TypeScript: updateProductCategoryImages
  Future<void> updateProductCategoryImages(String productCategoryId,
      UpdateProductCategoryImagesParams params) async {
    try {
      AppLogger.i('正在修改商品类目图片: $productCategoryId');

      final response = await _dio.put(
        '$_apiPath/$productCategoryId/images',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改商品类目图片');
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
      AppLogger.e('修改商品类目图片失败', e);
      rethrow;
    }
  }

  /// 添加类目类型
  /// 对应 TypeScript: addProductCategoryCategoryTypes
  Future<void> addProductCategoryCategoryTypes(String productCategoryId,
      AddProductCategoryCategoryTypesParams params) async {
    try {
      AppLogger.i('正在添加商品类目类型: $productCategoryId');

      final response = await _dio.post(
        '$_apiPath/$productCategoryId/category-types',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功添加商品类目类型');
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
      AppLogger.e('添加商品类目类型失败', e);
      rethrow;
    }
  }

  /// 移除类目类型
  /// 对应 TypeScript: removeProductCategoryCategoryTypes
  Future<void> removeProductCategoryCategoryTypes(String productCategoryId,
      RemoveProductCategoryCategoryTypesParams params) async {
    try {
      AppLogger.i('正在移除商品类目类型: $productCategoryId');

      final response = await _dio.delete(
        '$_apiPath/$productCategoryId/category-types',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功移除商品类目类型');
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
      AppLogger.e('移除商品类目类型失败', e);
      rethrow;
    }
  }

  /// 添加父类目
  /// 对应 TypeScript: addProductCategoryParentCategories
  Future<void> addProductCategoryParentCategories(String productCategoryId,
      AddProductCategoryParentCategoriesParams params) async {
    try {
      AppLogger.i('正在添加商品类目父类目: $productCategoryId');

      final response = await _dio.post(
        '$_apiPath/$productCategoryId/parent-categories',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功添加商品类目父类目');
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
      AppLogger.e('添加商品类目父类目失败', e);
      rethrow;
    }
  }

  /// 移除父类目
  /// 对应 TypeScript: removeProductCategoryParentCategories
  Future<void> removeProductCategoryParentCategories(String productCategoryId,
      RemoveProductCategoryParentCategoriesParams params) async {
    try {
      AppLogger.i('正在移除商品类目父类目: $productCategoryId');

      final response = await _dio.delete(
        '$_apiPath/$productCategoryId/parent-categories',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功移除商品类目父类目');
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
      AppLogger.e('移除商品类目父类目失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 删除操作
  // ============================================================================

  /// 删除商品类目
  /// 对应 TypeScript: deleteProductCategory
  Future<void> deleteProductCategory(String productCategoryId) async {
    try {
      AppLogger.i('正在删除商品类目: $productCategoryId');

      final response = await _dio.delete('$_apiPath/$productCategoryId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功删除商品类目');
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
      AppLogger.e('删除商品类目失败', e);
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
