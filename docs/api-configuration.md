# API配置说明

## 当前配置

所有API请求现在都使用本地开发服务器：

```
基础地址: http://localhost:8081
API版本: api
```

## API端点

### 用户认证相关
- 登录: `POST http://localhost:8081/api/user/login`
- 登出: `POST http://localhost:8081/api/user/logout`
- 获取当前用户: `GET http://localhost:8081/api/user/current`
- 获取用户权限: `GET http://localhost:8081/api/user/current/permissions`

### 商品类目相关
- 分页查询: `GET http://localhost:8081/api/products/product-categories`
- 类目详情: `GET http://localhost:8081/api/products/product-categories/{id}`
- 创建类目: `POST http://localhost:8081/api/products/product-categories`
- 更新类目: `PUT http://localhost:8081/api/products/product-categories/{id}/*`
- 删除类目: `DELETE http://localhost:8081/api/products/product-categories/{id}`

### 商品信息相关
- 分页查询: `GET http://localhost:8081/api/products/product-infos`
- 商品详情: `GET http://localhost:8081/api/products/product-infos/{id}`
- 创建商品: `POST http://localhost:8081/api/products/product-infos`
- 更新商品: `PUT http://localhost:8081/api/products/product-infos/{id}/*`
- 删除商品: `DELETE http://localhost:8081/api/products/product-infos/{id}`

## Token认证

所有需要认证的API请求都会自动携带JWT token：

```
Authorization: Bearer {jwt-token}
```

## 配置文件位置

API配置在以下文件中定义：
- `lib/common/constants/app_constants.dart` - 全局API配置
- `lib/models/productcategory/service.dart` - 商品类目服务
- `lib/models/productinfo/service.dart` - 商品信息服务
- `lib/api/auth_api.dart` - 认证服务

## 环境切换

如需切换到其他环境，只需修改 `app_constants.dart` 中的 `baseUrl` 常量：

```dart
// 本地开发
static const String baseUrl = 'http://localhost:8081';

// 测试环境
static const String baseUrl = 'http://test-api.ricoapp.com';

// 生产环境
static const String baseUrl = 'https://api.ricoapp.com';
```

## 注意事项

1. **本地开发**: 确保本地服务器运行在8081端口
2. **网络权限**: 确保应用有网络访问权限
3. **CORS设置**: 本地开发时可能需要配置CORS
4. **Token管理**: Token会自动存储和携带，无需手动处理
