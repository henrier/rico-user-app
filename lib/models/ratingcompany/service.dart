// 评级公司聚合 - API服务接口
//
// 对应后端 RatingCompany 聚合的服务接口
// 与 TypeScript 版本保持同步: docs/api/ratingcompany/service.ts

import 'package:dio/dio.dart';

import '../../api/base_api.dart';
import '../../common/constants/app_constants.dart';
import '../../common/utils/logger.dart';
import '../api_response.dart';
import '../page_data.dart';
import 'data.dart';

/// 评级公司API服务
/// 对应 TypeScript 中的各个服务函数
class RatingCompanyService extends BaseApi {
  static const String _baseUrl = AppConstants.baseUrl;
  static const String _apiPath = '/api/products/rating-companies';

  final Dio _dio;

  RatingCompanyService({Dio? dio}) : _dio = dio ?? Dio() {
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

  /// 创建评级公司
  /// 对应 TypeScript: createRatingCompany
  Future<String> createRatingCompany(CreateRatingCompanyParams params) async {
    try {
      AppLogger.i('正在创建评级公司: ${params.name}');

      final response = await _dio.post(
        _apiPath,
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建评级公司: ${apiResponse.data}');
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
      AppLogger.e('创建评级公司失败', e);
      rethrow;
    }
  }

  /// 创建评级公司（全参数）
  /// 对应 TypeScript: createRatingCompanyWithAllFields
  Future<String> createRatingCompanyWithAllFields(
      CreateRatingCompanyWithAllFieldsParams params) async {
    try {
      AppLogger.i('正在创建评级公司（全参数）: ${params.name}');

      final response = await _dio.post(
        '$_apiPath/with-all-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建评级公司: ${apiResponse.data}');
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
      AppLogger.e('创建评级公司失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 查询操作
  // ============================================================================

  /// 查询评级公司详情
  /// 对应 TypeScript: getRatingCompanyDetail
  Future<RatingCompany> getRatingCompanyDetail(String ratingCompanyId) async {
    try {
      AppLogger.i('正在查询评级公司详情: $ratingCompanyId');

      final response = await _dio.get('$_apiPath/$ratingCompanyId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => RatingCompany.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取评级公司详情: ${apiResponse.data!.displayName}');
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
      AppLogger.e('查询评级公司详情失败', e);
      rethrow;
    }
  }

  /// 分页查询评级公司
  /// 对应 TypeScript: getRatingCompanyPage
  Future<PageData<RatingCompany>> getRatingCompanyPage(
      RatingCompanyPageParams params) async {
    try {
      AppLogger.i('正在分页查询评级公司');

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
          (item) => RatingCompany.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个评级公司');
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
      AppLogger.e('分页查询评级公司失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 更新操作
  // ============================================================================

  /// 修改名称
  /// 对应 TypeScript: updateRatingCompanyName
  Future<void> updateRatingCompanyName(
      String ratingCompanyId, UpdateRatingCompanyNameParams params) async {
    try {
      AppLogger.i('正在修改评级公司名称: $ratingCompanyId');

      final response = await _dio.put(
        '$_apiPath/$ratingCompanyId/name',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改评级公司名称');
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
      AppLogger.e('修改评级公司名称失败', e);
      rethrow;
    }
  }

  /// 修改官网URL
  /// 对应 TypeScript: updateRatingCompanyOfficialWebsiteUrl
  Future<void> updateRatingCompanyOfficialWebsiteUrl(String ratingCompanyId,
      UpdateRatingCompanyOfficialWebsiteUrlParams params) async {
    try {
      AppLogger.i('正在修改评级公司官网URL: $ratingCompanyId');

      final response = await _dio.put(
        '$_apiPath/$ratingCompanyId/official-website-url',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改评级公司官网URL');
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
      AppLogger.e('修改评级公司官网URL失败', e);
      rethrow;
    }
  }

  /// 修改分值
  /// 对应 TypeScript: updateRatingCompanyScore
  Future<void> updateRatingCompanyScore(
      String ratingCompanyId, UpdateRatingCompanyScoreParams params) async {
    try {
      AppLogger.i('正在修改评级公司分值: $ratingCompanyId');

      final response = await _dio.put(
        '$_apiPath/$ratingCompanyId/score',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改评级公司分值');
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
      AppLogger.e('修改评级公司分值失败', e);
      rethrow;
    }
  }

  /// 修改官网信息字段
  /// 对应 TypeScript: updateRatingCompanyOfficialWebsiteFields
  Future<void> updateRatingCompanyOfficialWebsiteFields(String ratingCompanyId,
      UpdateRatingCompanyOfficialWebsiteFieldsParams params) async {
    try {
      AppLogger.i('正在修改评级公司官网信息字段: $ratingCompanyId');

      final response = await _dio.put(
        '$_apiPath/$ratingCompanyId/official-website-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改评级公司官网信息字段');
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
      AppLogger.e('修改评级公司官网信息字段失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 删除操作
  // ============================================================================

  /// 删除评级公司
  /// 对应 TypeScript: deleteRatingCompany
  Future<void> deleteRatingCompany(String ratingCompanyId) async {
    try {
      AppLogger.i('正在删除评级公司: $ratingCompanyId');

      final response = await _dio.delete('$_apiPath/$ratingCompanyId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功删除评级公司');
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
      AppLogger.e('删除评级公司失败', e);
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
