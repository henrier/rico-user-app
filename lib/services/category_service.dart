import 'package:dio/dio.dart';

import '../common/utils/logger.dart';
import '../models/productcategory/product_category.dart';

/// API响应格式
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorCode;
  final String? errorMessage;
  final int? showType;
  final String? traceId;
  final String? host;

  const ApiResponse({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
    this.showType,
    this.traceId,
    this.host,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      showType: json['showType'],
      traceId: json['traceId'],
      host: json['host'],
    );
  }
}

/// 分页数据格式
class PageData<T> {
  final List<T> list;
  final int current;
  final int pageSize;
  final int total;

  const PageData({
    required this.list,
    required this.current,
    required this.pageSize,
    required this.total,
  });

  factory PageData.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return PageData<T>(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      current: json['current'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}

/// 商品类目API服务
class CategoryService {
  static const String _baseUrl = 'http://localhost:8081'; // 本地开发服务器
  static const String _apiPath = '/api/products/product-categories';

  final Dio _dio;

  CategoryService({Dio? dio}) : _dio = dio ?? _createDio();

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

  /// 分页查询商品类目
  ///
  /// [parentCategoryId] 父类目ID，用于查询子类目
  /// [categoryTypes] 类目类型过滤
  /// [pageSize] 分页大小，设置为大数值避免分页
  Future<List<Category>> getCategories({
    String? parentCategoryId,
    List<CategoryType>? categoryTypes,
    int pageSize = 1000,
  }) async {
    try {
      AppLogger.i('正在查询类目: parentId=$parentCategoryId, types=$categoryTypes');

      // 构建查询参数
      final queryParams = <String, dynamic>{
        'current': 1,
        'pageSize': pageSize,
      };

      // 添加父类目过滤 - 使用单个值
      if (parentCategoryId != null) {
        queryParams['parentCategories'] = parentCategoryId;
      }

      // 添加类目类型过滤 - 使用单个值
      if (categoryTypes != null && categoryTypes.isNotEmpty) {
        queryParams['categoryTypes'] = categoryTypes.first.value;
      }

      AppLogger.d('请求参数: $queryParams');

      // 发送请求
      final response = await _dio.get(
        _apiPath,
        queryParameters: queryParams,
      );

      AppLogger.d('响应状态码: ${response.statusCode}');
      AppLogger.d('响应数据: ${response.data}');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageData.fromJson(
          data as Map<String, dynamic>,
          (item) => Category.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final categories = apiResponse.data!.list;
        AppLogger.i('成功获取${categories.length}个类目');
        return categories;
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
      AppLogger.e('查询类目失败', e);
      rethrow;
    }
  }

  /// 根据二级类目ID查询三级类目
  Future<List<Category>> getThirdLevelCategories(
      String secondCategoryId) async {
    return getCategories(
      parentCategoryId: secondCategoryId,
      categoryTypes: [CategoryType.series1],
    );
  }

  /// 根据三级类目ID查询四级类目
  Future<List<Category>> getFourthLevelCategories(
      String thirdCategoryId) async {
    return getCategories(
      parentCategoryId: thirdCategoryId,
      categoryTypes: [CategoryType.series2],
    );
  }

  /// 获取类目详情
  Future<Category> getCategoryDetail(String categoryId) async {
    try {
      AppLogger.i('正在查询类目详情: $categoryId');

      final response = await _dio.get('$_apiPath/$categoryId');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Category.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        AppLogger.i('成功获取类目详情: ${apiResponse.data!.displayName}');
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
      AppLogger.e('查询类目详情失败', e);
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
