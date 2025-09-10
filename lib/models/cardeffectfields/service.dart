// 卡牌效果字段模板聚合 - API服务接口
//
// 对应后端 CardEffectFields 聚合的服务接口
// 与 TypeScript 版本保持同步: docs/api/cardeffectfields/service.ts

import 'package:dio/dio.dart';

import '../../common/constants/app_constants.dart';
import '../../common/utils/logger.dart';
import '../api_response.dart';
import '../page_data.dart';
import 'data.dart';

/// 卡牌效果字段模板API服务
/// 对应 TypeScript 中的各个服务函数
class CardEffectFieldsService {
  static const String _baseUrl = AppConstants.baseUrl;
  static const String _apiPath = '/api/products/card-effect-fieldses';

  final Dio _dio;

  CardEffectFieldsService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // 添加日志拦截器
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => AppLogger.d(obj.toString()),
    ));

    return dio;
  }

  // ============================================================================
  // 创建操作
  // ============================================================================

  /// 创建卡牌效果模板
  /// 对应 TypeScript: createCardEffectFields
  Future<String> createCardEffectFields(
      CreateCardEffectFieldsParams params) async {
    try {
      AppLogger.i('正在创建卡牌效果模板: ${params.templateName}');

      final response = await _dio.post(
        _apiPath,
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建卡牌效果模板: ${apiResponse.data}');
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
      AppLogger.e('创建卡牌效果模板失败', e);
      rethrow;
    }
  }

  /// 创建卡牌效果模板（全参数）
  /// 对应 TypeScript: createCardEffectFieldsWithAllFields
  Future<String> createCardEffectFieldsWithAllFields(
      CreateCardEffectFieldsWithAllFieldsParams params) async {
    try {
      AppLogger.i('正在创建卡牌效果模板（全参数）: ${params.templateName}');

      final response = await _dio.post(
        '$_apiPath/with-all-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功创建卡牌效果模板: ${apiResponse.data}');
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
      AppLogger.e('创建卡牌效果模板失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 查询操作
  // ============================================================================

  /// 查询卡牌效果模板详情
  /// 对应 TypeScript: getCardEffectFieldsDetail
  Future<CardEffectFields> getCardEffectFieldsDetail(
      String cardEffectFieldsId) async {
    try {
      AppLogger.i('正在查询卡牌效果模板详情: $cardEffectFieldsId');

      final response = await _dio.get('$_apiPath/$cardEffectFieldsId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => CardEffectFields.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取卡牌效果模板详情: ${apiResponse.data!.templateName}');
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
      AppLogger.e('查询卡牌效果模板详情失败', e);
      rethrow;
    }
  }

  /// 分页查询卡牌效果模板
  /// 对应 TypeScript: getCardEffectFieldsPage
  Future<PageData<CardEffectFields>> getCardEffectFieldsPage(
      CardEffectFieldsPageParams params) async {
    try {
      AppLogger.i('正在分页查询卡牌效果模板');

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
          (item) => CardEffectFields.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final pageData = apiResponse.data!;
        AppLogger.i('成功获取${pageData.list.length}个卡牌效果模板');
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
      AppLogger.e('分页查询卡牌效果模板失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 更新操作
  // ============================================================================

  /// 修改模板名
  /// 对应 TypeScript: updateCardEffectFieldsTemplateName
  Future<void> updateCardEffectFieldsTemplateName(String cardEffectFieldsId,
      UpdateCardEffectFieldsTemplateNameParams params) async {
    try {
      AppLogger.i('正在修改卡牌效果模板名: $cardEffectFieldsId');

      final response = await _dio.put(
        '$_apiPath/$cardEffectFieldsId/template-name',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改卡牌效果模板名');
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
      AppLogger.e('修改卡牌效果模板名失败', e);
      rethrow;
    }
  }

  /// 修改效果字段模板
  /// 对应 TypeScript: updateCardEffectFieldsEffectFields
  Future<void> updateCardEffectFieldsEffectFields(String cardEffectFieldsId,
      UpdateCardEffectFieldsEffectFieldsParams params) async {
    try {
      AppLogger.i('正在修改卡牌效果字段模板: $cardEffectFieldsId');

      final response = await _dio.put(
        '$_apiPath/$cardEffectFieldsId/effect-fields',
        data: params.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功修改卡牌效果字段模板');
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
      AppLogger.e('修改卡牌效果字段模板失败', e);
      rethrow;
    }
  }

  // ============================================================================
  // 删除操作
  // ============================================================================

  /// 删除卡牌效果模板
  /// 对应 TypeScript: deleteCardEffectFields
  Future<void> deleteCardEffectFields(String cardEffectFieldsId) async {
    try {
      AppLogger.i('正在删除卡牌效果模板: $cardEffectFieldsId');

      final response = await _dio.delete('$_apiPath/$cardEffectFieldsId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => null,
      );

      if (apiResponse.success) {
        AppLogger.i('成功删除卡牌效果模板');
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
      AppLogger.e('删除卡牌效果模板失败', e);
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
