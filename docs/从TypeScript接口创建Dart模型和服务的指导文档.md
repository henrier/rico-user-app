# 从 TypeScript 接口创建 Dart 模型和服务的指导文档

## 概述

本文档指导 AI 编程助手如何根据人类工程师提供的 JavaScript/TypeScript 版本的聚合接口服务和数据模型，创建对应的 Dart 版本的接口服务和数据模型。

## 核心原则

### 1. 聚合边界原则
- **不要跨聚合创建类型**：每个聚合应该只定义自己领域内的类型
- **正确处理依赖关系**：如果聚合A依赖聚合B的类型，应该通过import引用，而不是重新定义
- **保持聚合独立性**：每个聚合应该能够独立编译和测试

### 2. 类型映射原则
- **保持接口一致性**：Dart版本的接口应该与TypeScript版本完全对应
- **遵循Dart命名规范**：使用驼峰命名法，类名首字母大写
- **保持字段语义一致**：字段名称、类型、可选性都应该保持一致

## 执行步骤

### 第一步：分析依赖关系

在开始创建之前，必须先分析TypeScript代码中的依赖关系：

```typescript
// 示例：分析 productinfo/data.ts 中的依赖
import { ProductCategoryAPI } from '../productcategory/data';
import { CardEffectFieldsAPI } from '../cardeffectfields/data';
import { DynamicField } from '@/components/DynamicField/types';
```

**关键判断：**
- `ProductCategoryAPI` → 来自 `productcategory` 聚合
- `CardEffectFieldsAPI` → 来自 `cardeffectfields` 聚合  
- `DynamicField` → 前端组件类型，需要在对应的聚合中定义

### 第二步：确定创建顺序

根据依赖关系确定聚合的创建顺序：

1. **基础聚合优先**：没有业务依赖的聚合（如 `cardeffectfields`）
2. **依赖聚合其次**：依赖其他聚合的聚合（如 `productinfo` 依赖 `cardeffectfields` 和 `productcategory`）

### 第三步：创建目录结构

为每个聚合创建标准的目录结构：

```
lib/models/{聚合名}/
├── data.dart     # 数据模型和类型定义
└── service.dart  # API服务接口
```

### 第四步：创建数据模型 (data.dart)

#### 4.1 文件头部模板

```dart
// {聚合名}聚合 - 数据模型和类型定义
//
// 对应后端 {聚合名} 聚合的数据结构
// 与 TypeScript 版本保持同步: docs/api/{聚合名}/data.ts

import '../audit_metadata.dart';
import '../i18n_string.dart';
// 根据需要导入其他聚合的类型
import '../{依赖聚合名}/data.dart';
```

#### 4.2 枚举类型转换

TypeScript 枚举转换为 Dart 枚举：

```typescript
// TypeScript
type CategoryTypesKey = 'IP' | 'LANGUAGE' | 'SERIES1' | 'SERIES2';
```

```dart
// Dart
enum CategoryType {
  ip('IP'),
  language('LANGUAGE'),
  series1('SERIES1'),
  series2('SERIES2');

  const CategoryType(this.value);
  final String value;

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryType.ip,
    );
  }
}
```

#### 4.3 接口类型转换

TypeScript 接口转换为 Dart 类：

```typescript
// TypeScript
export interface ProductCategoryVO {
  id: string;
  name: I18NStringVO;
  images: string[];
  categoryTypes: CategoryTypesKey[];
  auditMetadata: API.AuditMetadata;
}
```

```dart
// Dart
class ProductCategory {
  final String id;
  final I18NString name;
  final List<String> images;
  final List<CategoryType> categoryTypes;
  final AuditMetadata auditMetadata;

  const ProductCategory({
    required this.id,
    required this.name,
    this.images = const [],
    this.categoryTypes = const [],
    required this.auditMetadata,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: I18NString.fromJson(json['name'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      categoryTypes: (json['categoryTypes'] as List<dynamic>?)
          ?.map((type) => CategoryType.fromString(type.toString()))
          .toList() ?? [],
      auditMetadata: AuditMetadata.fromJson(json['auditMetadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'images': images,
      'categoryTypes': categoryTypes.map((type) => type.value).toList(),
      'auditMetadata': auditMetadata.toJson(),
    };
  }

  // copyWith 方法
  ProductCategory copyWith({
    String? id,
    I18NString? name,
    List<String>? images,
    List<CategoryType>? categoryTypes,
    AuditMetadata? auditMetadata,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      categoryTypes: categoryTypes ?? this.categoryTypes,
      auditMetadata: auditMetadata ?? this.auditMetadata,
    );
  }
}
```

#### 4.4 API参数类型转换

每个 TypeScript 参数接口都需要对应的 Dart 类：

```typescript
// TypeScript
export interface CreateProductCategoryParams {
  name: I18NStringVO;
}
```

```dart
// Dart
class CreateProductCategoryParams {
  final I18NString name;

  const CreateProductCategoryParams({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
    };
  }
}
```

### 第五步：创建API服务 (service.dart)

#### 5.1 文件头部模板

```dart
// {聚合名}聚合 - API服务接口
//
// 对应后端 {聚合名} 聚合的服务接口
// 与 TypeScript 版本保持同步: docs/api/{聚合名}/service.ts

import 'package:dio/dio.dart';

import '../../common/utils/logger.dart';
import '../api_response.dart';
import '../page_data.dart';
import 'data.dart';
// 根据需要导入依赖聚合的类型
import '../{依赖聚合名}/data.dart';
```

#### 5.2 服务类结构

```dart
class {聚合名}Service {
  static const String _baseUrl = 'http://localhost:8081';
  static const String _apiPath = '/api/{路径}';

  final Dio _dio;

  {聚合名}Service({Dio? dio}) : _dio = dio ?? _createDio();

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

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => AppLogger.d(obj.toString()),
    ));

    return dio;
  }

  // API 方法...

  void dispose() {
    _dio.close();
  }
}
```

#### 5.3 API方法转换模式

每个 TypeScript 服务函数都需要对应的 Dart 方法：

```typescript
// TypeScript
export async function createProductCategory(params: CreateProductCategoryParams) {
  return request<API.ApiResponse<string>>('/api/products/product-categories', {
    method: 'POST',
    data: params,
  });
}
```

```dart
// Dart
Future<String> createProductCategory(CreateProductCategoryParams params) async {
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
```

## 常见错误和解决方案

### 错误1：跨聚合重复定义类型

**错误示例：**
```dart
// 在 productinfo/data.dart 中错误地定义了属于 cardeffectfields 聚合的类型
class DynamicField { ... }
class CardEffectFields { ... }
```

**正确做法：**
```dart
// 在 productinfo/data.dart 中正确引用
import '../cardeffectfields/data.dart';

// 然后直接使用 DynamicField 和 CardEffectFields
```

### 错误2：依赖导入顺序错误

**错误示例：**
```dart
import '../page_data.dart';
import '../cardeffectfields/data.dart';
import 'data.dart';
```

**正确做法：**
```dart
import '../api_response.dart';
import '../page_data.dart';
import '../cardeffectfields/data.dart';  // 依赖聚合的导入
import 'data.dart';                      // 本聚合的导入放最后
```

### 错误3：缺少必要的便捷方法

每个主要的数据类都应该包含：
- `fromJson()` 工厂构造函数
- `toJson()` 方法
- `copyWith()` 方法
- 必要的便捷属性（如 `displayName`、`hasXxx` 等）
- `toString()`、`operator ==`、`hashCode` 重写

## 验证清单

完成创建后，使用以下清单进行验证：

### 代码质量检查
- [ ] 运行 `flutter analyze` 无错误
- [ ] 所有导入语句正确
- [ ] 没有重复定义跨聚合的类型

### 功能完整性检查
- [ ] 所有 TypeScript 接口都有对应的 Dart 类
- [ ] 所有 TypeScript 服务函数都有对应的 Dart 方法
- [ ] API 路径和参数与 TypeScript 版本一致

### 架构一致性检查
- [ ] 聚合边界清晰，没有跨聚合的类型定义
- [ ] 依赖关系正确，通过 import 引用外部类型
- [ ] 错误处理和日志记录与现有代码风格一致

## 示例：完整的执行过程

以创建商品信息聚合为例：

1. **分析依赖**：发现依赖 `productcategory` 和 `cardeffectfields` 聚合
2. **确保依赖存在**：先创建 `cardeffectfields` 聚合（如果不存在）
3. **创建目录**：`lib/models/productinfo/`
4. **创建数据模型**：`productinfo/data.dart`，正确导入依赖聚合
5. **创建服务**：`productinfo/service.dart`，实现所有API方法
6. **验证**：运行语法检查，确保无错误

## 总结

遵循本指导文档，AI 编程助手可以：
- 正确理解聚合边界和依赖关系
- 系统性地将 TypeScript 接口转换为 Dart 模型
- 创建完整、一致、可维护的 Dart 代码
- 避免常见的跨聚合类型定义错误

关键是要始终记住：**每个聚合只定义自己领域内的类型，通过导入来使用其他聚合的类型**。
