// 个人商品聚合 - 数据模型和类型定义
//
// 对应后端 PersonalProduct 聚合的数据结构
// 与 TypeScript 版本保持同步: docs/api/personalproduct/data.ts

import '../audit_metadata.dart';
import '../packagedproduct/data.dart';
import '../productinfo/data.dart';
import '../ratingcompany/data.dart';
import '../usershop/data.dart';

// ============================================================================
// 枚举类型定义
// ============================================================================

/// 商品类型枚举
/// 对应 TypeScript: TypeKey
enum PersonalProductType {
  rawCard('RAWCARD'),
  box('BOX'),
  ratedCard('RATEDCARD');

  const PersonalProductType(this.value);
  final String value;

  /// 类型枚举选项（用于UI显示）
  static const List<Map<String, String>> options = [
    {'label': '普通卡', 'value': 'RAWCARD'},
    {'label': '原盒', 'value': 'BOX'},
    {'label': '评级卡', 'value': 'RATEDCARD'},
  ];

  static PersonalProductType fromString(String value) {
    return PersonalProductType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PersonalProductType.rawCard,
    );
  }

  @override
  String toString() => value;
}

/// 商品状态枚举
/// 对应 TypeScript: StatusKey
enum PersonalProductStatus {
  pendingListing('PENDINGLISTING'),
  listed('LISTED'),
  soldOut('SOLDOUT');

  const PersonalProductStatus(this.value);
  final String value;

  /// 状态枚举选项（用于UI显示）
  static const List<Map<String, String>> options = [
    {'label': '待上架', 'value': 'PENDINGLISTING'},
    {'label': '已上架', 'value': 'LISTED'},
    {'label': '已售罄', 'value': 'SOLDOUT'},
  ];

  static PersonalProductStatus fromString(String value) {
    return PersonalProductStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PersonalProductStatus.pendingListing,
    );
  }

  @override
  String toString() => value;
}

/// 商品品相枚举
/// 对应 TypeScript: ConditionKey
enum PersonalProductCondition {
  mint('MINT'),
  nearMint('NEARMINT'),
  lightlyPlayed('LIGHTLYPLAYED'),
  damaged('DAMAGED');

  const PersonalProductCondition(this.value);
  final String value;

  /// 品相枚举选项（用于UI显示）
  static const List<Map<String, String>> options = [
    {'label': '完美品相', 'value': 'MINT'},
    {'label': '近完美品相', 'value': 'NEARMINT'},
    {'label': '轻微磨损', 'value': 'LIGHTLYPLAYED'},
    {'label': '有损伤', 'value': 'DAMAGED'},
  ];

  static PersonalProductCondition fromString(String value) {
    return PersonalProductCondition.values.firstWhere(
      (condition) => condition.value == value,
      orElse: () => PersonalProductCondition.mint,
    );
  }

  @override
  String toString() => value;
}

// ============================================================================
// 数据模型定义
// ============================================================================

/// 评级信息
/// 对应 TypeScript: RatingInfoVO
class RatingInfo {
  /// 名称
  final String name;

  /// 值
  final String value;

  const RatingInfo({
    required this.name,
    required this.value,
  });

  /// 从JSON创建RatingInfo对象
  factory RatingInfo.fromJson(Map<String, dynamic> json) {
    return RatingInfo(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  RatingInfo copyWith({
    String? name,
    String? value,
  }) {
    return RatingInfo(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingInfo && other.name == name && other.value == value;
  }

  @override
  int get hashCode => Object.hash(name, value);

  @override
  String toString() {
    return 'RatingInfo(name: $name, value: $value)';
  }
}

/// 评级卡
/// 对应 TypeScript: RatedCardVO
class RatedCard {
  /// 评级公司
  final RatingCompany ratingCompany;

  /// 卡牌评分
  final String cardScore;

  /// 评级卡编号
  final String gradedCardNumber;

  /// 评级信息
  final List<RatingInfo> ratingInfos;

  const RatedCard({
    required this.ratingCompany,
    required this.cardScore,
    required this.gradedCardNumber,
    this.ratingInfos = const [],
  });

  /// 从JSON创建RatedCard对象
  factory RatedCard.fromJson(Map<String, dynamic> json) {
    return RatedCard(
      ratingCompany: RatingCompany.fromJson(json['ratingCompany'] ?? {}),
      cardScore: json['cardScore'] ?? '',
      gradedCardNumber: json['gradedCardNumber'] ?? '',
      ratingInfos: (json['ratingInfos'] as List<dynamic>?)
              ?.map((info) => RatingInfo.fromJson(info as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'ratingCompany': ratingCompany.toJson(),
      'cardScore': cardScore,
      'gradedCardNumber': gradedCardNumber,
      'ratingInfos': ratingInfos.map((info) => info.toJson()).toList(),
    };
  }

  RatedCard copyWith({
    RatingCompany? ratingCompany,
    String? cardScore,
    String? gradedCardNumber,
    List<RatingInfo>? ratingInfos,
  }) {
    return RatedCard(
      ratingCompany: ratingCompany ?? this.ratingCompany,
      cardScore: cardScore ?? this.cardScore,
      gradedCardNumber: gradedCardNumber ?? this.gradedCardNumber,
      ratingInfos: ratingInfos ?? this.ratingInfos,
    );
  }

  /// 便捷方法：判断是否有评级信息
  bool get hasRatingInfos => ratingInfos.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatedCard && other.gradedCardNumber == gradedCardNumber;
  }

  @override
  int get hashCode => gradedCardNumber.hashCode;

  @override
  String toString() {
    return 'RatedCard(ratingCompany: ${ratingCompany.name}, cardScore: $cardScore, gradedCardNumber: $gradedCardNumber)';
  }
}

/// 打包信息
/// 对应 TypeScript: BundleInfoVO
class BundleInfo {
  /// 允许拆包销售
  final bool allowUnbundleSale;

  /// 已售罄
  final bool isSoldOut;

  /// 打包数量
  final int bundleQuantity;

  const BundleInfo({
    this.allowUnbundleSale = false,
    this.isSoldOut = false,
    this.bundleQuantity = 0,
  });

  /// 从JSON创建BundleInfo对象
  factory BundleInfo.fromJson(Map<String, dynamic> json) {
    return BundleInfo(
      allowUnbundleSale: json['allowUnbundleSale'] ?? false,
      isSoldOut: json['isSoldOut'] ?? false,
      bundleQuantity: json['bundleQuantity'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'allowUnbundleSale': allowUnbundleSale,
      'isSoldOut': isSoldOut,
      'bundleQuantity': bundleQuantity,
    };
  }

  BundleInfo copyWith({
    bool? allowUnbundleSale,
    bool? isSoldOut,
    int? bundleQuantity,
  }) {
    return BundleInfo(
      allowUnbundleSale: allowUnbundleSale ?? this.allowUnbundleSale,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      bundleQuantity: bundleQuantity ?? this.bundleQuantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BundleInfo &&
        other.allowUnbundleSale == allowUnbundleSale &&
        other.isSoldOut == isSoldOut &&
        other.bundleQuantity == bundleQuantity;
  }

  @override
  int get hashCode => Object.hash(allowUnbundleSale, isSoldOut, bundleQuantity);

  @override
  String toString() {
    return 'BundleInfo(allowUnbundleSale: $allowUnbundleSale, isSoldOut: $isSoldOut, bundleQuantity: $bundleQuantity)';
  }
}

/// 个人商品详情视图对象
/// 对应 TypeScript: PersonalProductVO
class PersonalProduct {
  /// 主键
  final String id;

  /// 商品信息
  final ProductInfo productInfo;

  /// 价格
  final double price;

  /// 备注
  final String notes;

  /// 图片
  final List<String> images;

  /// 是否主图
  final bool isMainImage;

  /// 主人
  final UserShop owner;

  /// 类型
  final PersonalProductType type;

  /// 状态
  final PersonalProductStatus status;

  /// 评级卡
  final RatedCard? ratedCard;

  /// 数量
  final int quantity;

  /// 品相
  final PersonalProductCondition condition;

  /// 限时价格
  final double limitedTimePrice;

  /// 截止时间
  final String deadline;

  /// 打包商品
  final PackagedProduct? bundleProduct;

  /// 打包信息
  final BundleInfo bundleInfo;

  /// 审计信息
  final AuditMetadata auditMetadata;

  const PersonalProduct({
    required this.id,
    required this.productInfo,
    this.price = 0.0,
    this.notes = '',
    this.images = const [],
    this.isMainImage = false,
    required this.owner,
    this.type = PersonalProductType.rawCard,
    this.status = PersonalProductStatus.pendingListing,
    this.ratedCard,
    this.quantity = 1,
    this.condition = PersonalProductCondition.mint,
    this.limitedTimePrice = 0.0,
    this.deadline = '',
    this.bundleProduct,
    required this.bundleInfo,
    required this.auditMetadata,
  });

  /// 从JSON创建PersonalProduct对象
  factory PersonalProduct.fromJson(Map<String, dynamic> json) {
    return PersonalProduct(
      id: json['id'] ?? '',
      productInfo: ProductInfo.fromJson(json['productInfo'] ?? {}),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isMainImage: json['isMainImage'] ?? false,
      owner: UserShop.fromJson(json['owner'] ?? {}),
      type: json['type'] != null
          ? PersonalProductType.fromString(json['type'] as String)
          : PersonalProductType.rawCard,
      status: json['status'] != null
          ? PersonalProductStatus.fromString(json['status'] as String)
          : PersonalProductStatus.pendingListing,
      ratedCard: json['ratedCard'] != null
          ? RatedCard.fromJson(json['ratedCard'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] ?? 1,
      condition: json['condition'] != null
          ? PersonalProductCondition.fromString(json['condition'] as String)
          : PersonalProductCondition.mint,
      limitedTimePrice: (json['limitedTimePrice'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] ?? '',
      bundleProduct: json['bundleProduct'] != null
          ? PackagedProduct.fromJson(
              json['bundleProduct'] as Map<String, dynamic>)
          : null,
      bundleInfo: BundleInfo.fromJson(json['bundleInfo'] ?? {}),
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productInfo': productInfo.toJson(),
      'price': price,
      'notes': notes,
      'images': images,
      'isMainImage': isMainImage,
      'owner': owner.toJson(),
      'type': type.value,
      'status': status.value,
      if (ratedCard != null) 'ratedCard': ratedCard!.toJson(),
      'quantity': quantity,
      'condition': condition.value,
      'limitedTimePrice': limitedTimePrice,
      'deadline': deadline,
      if (bundleProduct != null) 'bundleProduct': bundleProduct!.toJson(),
      'bundleInfo': bundleInfo.toJson(),
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  PersonalProduct copyWith({
    String? id,
    ProductInfo? productInfo,
    double? price,
    String? notes,
    List<String>? images,
    bool? isMainImage,
    UserShop? owner,
    PersonalProductType? type,
    PersonalProductStatus? status,
    RatedCard? ratedCard,
    int? quantity,
    PersonalProductCondition? condition,
    double? limitedTimePrice,
    String? deadline,
    PackagedProduct? bundleProduct,
    BundleInfo? bundleInfo,
    AuditMetadata? auditMetadata,
  }) {
    return PersonalProduct(
      id: id ?? this.id,
      productInfo: productInfo ?? this.productInfo,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      isMainImage: isMainImage ?? this.isMainImage,
      owner: owner ?? this.owner,
      type: type ?? this.type,
      status: status ?? this.status,
      ratedCard: ratedCard ?? this.ratedCard,
      quantity: quantity ?? this.quantity,
      condition: condition ?? this.condition,
      limitedTimePrice: limitedTimePrice ?? this.limitedTimePrice,
      deadline: deadline ?? this.deadline,
      bundleProduct: bundleProduct ?? this.bundleProduct,
      bundleInfo: bundleInfo ?? this.bundleInfo,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }

  /// 便捷方法：获取显示名称
  String get displayName => productInfo.displayName;

  /// 便捷方法：判断是否有评级卡
  bool get hasRatedCard => ratedCard != null;

  /// 便捷方法：判断是否有图片
  bool get hasImages => images.isNotEmpty;

  /// 便捷方法：判断是否有打包商品
  bool get hasBundleProduct => bundleProduct != null;

  /// 便捷方法：判断是否有限时价格
  bool get hasLimitedTimePrice => limitedTimePrice > 0;

  /// 便捷方法：判断是否已售罄
  bool get isSoldOut => status == PersonalProductStatus.soldOut;

  /// 便捷方法：判断是否已上架
  bool get isListed => status == PersonalProductStatus.listed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PersonalProduct(id: $id, productInfo: ${productInfo.displayName}, price: $price, type: $type, status: $status)';
  }
}

// ============================================================================
// API 请求参数类型定义
// ============================================================================

/// 创建个人商品参数
/// 对应 TypeScript: CreatePersonalProductParams
class CreatePersonalProductParams {
  /// 商品信息
  final String productInfo;

  /// 主人
  final String owner;

  /// 类型
  final PersonalProductType type;

  /// 状态
  final PersonalProductStatus status;

  /// 数量
  final int quantity;

  const CreatePersonalProductParams({
    required this.productInfo,
    required this.owner,
    required this.type,
    required this.status,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productInfo': productInfo,
      'owner': owner,
      'type': type.value,
      'status': status.value,
      'quantity': quantity,
    };
  }
}

/// 创建个人商品（全参数）参数
/// 对应 TypeScript: CreatePersonalProductWithAllFieldsParams
class CreatePersonalProductWithAllFieldsParams {
  /// 商品信息
  final String productInfo;

  /// 价格
  final double? price;

  /// 备注
  final String? notes;

  /// 图片
  final List<String>? images;

  /// 是否主图
  final bool? isMainImage;

  /// 主人
  final String owner;

  /// 类型
  final PersonalProductType type;

  /// 状态
  final PersonalProductStatus status;

  /// 评级卡
  final RatedCard? ratedCard;

  /// 数量
  final int quantity;

  /// 品相
  final PersonalProductCondition? condition;

  /// 限时价格
  final double? limitedTimePrice;

  /// 截止时间
  final String? deadline;

  /// 打包商品
  final String? bundleProduct;

  const CreatePersonalProductWithAllFieldsParams({
    required this.productInfo,
    this.price,
    this.notes,
    this.images,
    this.isMainImage,
    required this.owner,
    required this.type,
    required this.status,
    this.ratedCard,
    required this.quantity,
    this.condition,
    this.limitedTimePrice,
    this.deadline,
    this.bundleProduct,
  });

  Map<String, dynamic> toJson() {
    return {
      'productInfo': productInfo,
      if (price != null) 'price': price,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
      if (isMainImage != null) 'isMainImage': isMainImage,
      'owner': owner,
      'type': type.value,
      'status': status.value,
      if (ratedCard != null) 'ratedCard': ratedCard!.toJson(),
      'quantity': quantity,
      if (condition != null) 'condition': condition!.value,
      if (limitedTimePrice != null) 'limitedTimePrice': limitedTimePrice,
      if (deadline != null) 'deadline': deadline,
      if (bundleProduct != null) 'bundleProduct': bundleProduct,
    };
  }
}

/// 个人商品手动创建参数（移动端专用）
/// 对应 TypeScript: CreatePersonalProductManualParams
class CreatePersonalProductManualParams {
  /// 商品类型（必填）
  final PersonalProductType type;

  /// 主人ID（必填）
  final String owner;

  /// 商品信息ID（必填）
  final String productInfoId;

  /// 品相
  final PersonalProductCondition? condition;

  /// 评级卡
  final RatedCard? ratedCard;

  /// 价格
  final double? price;

  /// 库存
  final int? quantity;

  /// 备注
  final String? notes;

  /// 图片
  final List<String>? images;

  /// 是否主图
  final bool? isMainImage;

  const CreatePersonalProductManualParams({
    required this.type,
    required this.owner,
    required this.productInfoId,
    this.condition,
    this.ratedCard,
    this.price,
    this.quantity,
    this.notes,
    this.images,
    this.isMainImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'owner': owner,
      'productInfoId': productInfoId,
      if (condition != null) 'condition': condition!.value,
      if (ratedCard != null) 'ratedCard': ratedCard!.toJson(),
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
      if (isMainImage != null) 'isMainImage': isMainImage,
    };
  }
}

/// 个人商品手动批量创建参数（移动端专用）
/// 对应 TypeScript: BatchCreatePersonalProductManualParams
class BatchCreatePersonalProductManualParams {
  /// 商品类型（必填）
  final PersonalProductType type;

  /// 主人ID（必填）
  final String owner;

  /// 商品信息ID（必填）
  final String productInfoId;

  /// 品相
  final PersonalProductCondition? condition;

  /// 评级卡
  final RatedCard? ratedCard;

  /// 价格
  final double? price;

  /// 库存
  final int? quantity;

  /// 备注
  final String? notes;

  /// 图片
  final List<String>? images;

  /// 是否主图
  final bool? isMainImage;

  /// 商品状态（批量创建时可指定，默认为已上架）
  final PersonalProductStatus? status;

  const BatchCreatePersonalProductManualParams({
    required this.type,
    required this.owner,
    required this.productInfoId,
    this.condition,
    this.ratedCard,
    this.price,
    this.quantity,
    this.notes,
    this.images,
    this.isMainImage,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'owner': owner,
      'productInfoId': productInfoId,
      if (condition != null) 'condition': condition!.value,
      if (ratedCard != null) 'ratedCard': ratedCard!.toJson(),
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
      if (isMainImage != null) 'isMainImage': isMainImage,
      if (status != null) 'status': status!.value,
    };
  }
}

/// 个人商品手动整体更新参数（移动端专用）
/// 对应 TypeScript: UpdatePersonalProductManualParams
class UpdatePersonalProductManualParams {
  /// 品相
  final PersonalProductCondition? condition;

  /// 评级卡
  final RatedCard? ratedCard;

  /// 价格
  final double? price;

  /// 库存
  final int? quantity;

  /// 备注
  final String? notes;

  /// 图片
  final List<String>? images;

  /// 状态
  final PersonalProductStatus? status;

  /// 是否主图
  final bool? isMainImage;

  const UpdatePersonalProductManualParams({
    this.condition,
    this.ratedCard,
    this.price,
    this.quantity,
    this.notes,
    this.images,
    this.status,
    this.isMainImage,
  });

  Map<String, dynamic> toJson() {
    return {
      if (condition != null) 'condition': condition!.value,
      if (ratedCard != null) 'ratedCard': ratedCard!.toJson(),
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
      if (status != null) 'status': status!.value,
      if (isMainImage != null) 'isMainImage': isMainImage,
    };
  }
}

// 其他更新参数类型（省略具体实现，与TypeScript版本对应）...

/// 分页查询个人商品参数
/// 对应 TypeScript: PersonalProductPageParams
class PersonalProductPageParams {
  /// 当前页
  final int current;

  /// 分页大小
  final int pageSize;

  /// 商品信息
  final String? productInfo;

  /// 价格最小值
  final double? minPrice;

  /// 价格最大值
  final double? maxPrice;

  /// 备注
  final String? notes;

  /// 图片
  final List<String>? images;

  /// 是否主图
  final bool? isMainImage;

  /// 主人
  final String? owner;

  /// 类型
  final PersonalProductType? type;

  /// 状态
  final PersonalProductStatus? status;

  /// 评级卡 - 评级公司
  final String? ratedCardRatingCompany;

  /// 评级卡 - 卡牌评分
  final String? ratedCardCardScore;

  /// 评级卡 - 评级卡编号
  final String? ratedCardGradedCardNumber;

  /// 评级卡 - 评级信息 - 名称
  final String? ratedCardRatingInfosName;

  /// 评级卡 - 评级信息 - 值
  final String? ratedCardRatingInfosValue;

  /// 数量最小值
  final int? minQuantity;

  /// 数量最大值
  final int? maxQuantity;

  /// 品相
  final PersonalProductCondition? condition;

  /// 限时价格最小值
  final double? minLimitedTimePrice;

  /// 限时价格最大值
  final double? maxLimitedTimePrice;

  /// 截止时间开始时间
  final String? deadlineStart;

  /// 截止时间结束时间
  final String? deadlineEnd;

  /// 打包商品
  final String? bundleProduct;

  /// 创建时间范围开始
  final String? createdAtStart;

  /// 创建时间范围结束
  final String? createdAtEnd;

  /// 更新时间范围开始
  final String? updatedAtStart;

  /// 更新时间范围结束
  final String? updatedAtEnd;

  /// 创建者（模糊查询）
  final String? createdBy;

  /// 更新者（模糊查询）
  final String? updatedBy;

  const PersonalProductPageParams({
    this.current = 1,
    this.pageSize = 20,
    this.productInfo,
    this.minPrice,
    this.maxPrice,
    this.notes,
    this.images,
    this.isMainImage,
    this.owner,
    this.type,
    this.status,
    this.ratedCardRatingCompany,
    this.ratedCardCardScore,
    this.ratedCardGradedCardNumber,
    this.ratedCardRatingInfosName,
    this.ratedCardRatingInfosValue,
    this.minQuantity,
    this.maxQuantity,
    this.condition,
    this.minLimitedTimePrice,
    this.maxLimitedTimePrice,
    this.deadlineStart,
    this.deadlineEnd,
    this.bundleProduct,
    this.createdAtStart,
    this.createdAtEnd,
    this.updatedAtStart,
    this.updatedAtEnd,
    this.createdBy,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'pageSize': pageSize,
      if (productInfo != null) 'productInfo': productInfo,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
      if (isMainImage != null) 'isMainImage': isMainImage,
      if (owner != null) 'owner': owner,
      if (type != null) 'type': type!.value,
      if (status != null) 'status': status!.value,
      if (ratedCardRatingCompany != null)
        'ratedCardRatingCompany': ratedCardRatingCompany,
      if (ratedCardCardScore != null) 'ratedCardCardScore': ratedCardCardScore,
      if (ratedCardGradedCardNumber != null)
        'ratedCardGradedCardNumber': ratedCardGradedCardNumber,
      if (ratedCardRatingInfosName != null)
        'ratedCardRatingInfosName': ratedCardRatingInfosName,
      if (ratedCardRatingInfosValue != null)
        'ratedCardRatingInfosValue': ratedCardRatingInfosValue,
      if (minQuantity != null) 'minQuantity': minQuantity,
      if (maxQuantity != null) 'maxQuantity': maxQuantity,
      if (condition != null) 'condition': condition!.value,
      if (minLimitedTimePrice != null)
        'minLimitedTimePrice': minLimitedTimePrice,
      if (maxLimitedTimePrice != null)
        'maxLimitedTimePrice': maxLimitedTimePrice,
      if (deadlineStart != null) 'deadlineStart': deadlineStart,
      if (deadlineEnd != null) 'deadlineEnd': deadlineEnd,
      if (bundleProduct != null) 'bundleProduct': bundleProduct,
      if (createdAtStart != null) 'createdAtStart': createdAtStart,
      if (createdAtEnd != null) 'createdAtEnd': createdAtEnd,
      if (updatedAtStart != null) 'updatedAtStart': updatedAtStart,
      if (updatedAtEnd != null) 'updatedAtEnd': updatedAtEnd,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }
}
