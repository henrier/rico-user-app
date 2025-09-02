/// 通用分页数据格式
///
/// 统一的后端分页响应结构
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

  Map<String, dynamic> toJson() {
    return {
      'list': list,
      'current': current,
      'pageSize': pageSize,
      'total': total,
    };
  }
}
