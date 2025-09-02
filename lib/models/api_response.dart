/// 通用API响应格式
///
/// 统一的后端API响应结构
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

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'showType': showType,
      'traceId': traceId,
      'host': host,
    };
  }
}
