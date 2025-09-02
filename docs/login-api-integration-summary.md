# 登录API集成总结

## 概述

本次更新将应用的登录系统从演示模式改为真实的后端API集成，实现了一键登录功能，使用指定的账号密码（12312341234 / admin123）进行认证。

## 主要修改

### 1. 用户模型更新 (`lib/models/user_model.dart`)

- **新增模型类**：
  - `UserRole`: 用户角色模型
  - `AuditMetadata`: 审计元数据模型

- **更新User模型字段**：
  - `id`: 用户ID
  - `openId`: 开放ID
  - `name`: 用户姓名
  - `phone`: 手机号码
  - `avatar`: 头像URL
  - `roles`: 用户角色列表
  - `remark`: 备注信息
  - `disabled`: 是否禁用
  - `auditMetadata`: 审计元数据

- **新增方法**：
  - `displayName`: 获取显示名称
  - `primaryRole`: 获取主要角色
  - `hasRole()`: 检查是否有特定角色

### 2. API接口更新 (`lib/api/auth_api.dart`)

- **登录接口** (`POST /api/user/login`):
  - 使用手机号和密码进行登录
  - 返回用户信息和JWT token
  - 自动保存token到本地存储

- **一键登录方法**:
  - 使用默认账号：12312341234
  - 使用默认密码：admin123
  - 调用标准登录接口

- **用户登出** (`POST /api/user/logout`):
  - 携带Authorization头进行登出
  - 清除本地存储的token

- **获取当前用户信息** (`GET /api/user/current`):
  - 携带Authorization头获取用户详细信息
  - 处理token失效情况

- **获取用户权限** (`GET /api/user/current/permissions`):
  - 返回用户权限列表
  - 用于权限控制

### 3. 认证Provider更新 (`lib/providers/auth_provider.dart`)

- **更新登录方法**：
  - 改为使用手机号和密码
  - 更新日志信息

- **新增权限获取方法**：
  - `getCurrentUserPermissions()`: 获取用户权限列表

- **改进状态管理**：
  - 更好的错误处理
  - 更详细的日志记录

### 4. UI界面适配

- **首页** (`lib/screens/home/home_screen.dart`):
  - 使用`displayName`替代`fullName`
  - 显示手机号替代邮箱

- **个人资料页** (`lib/screens/profile/profile_screen.dart`):
  - 适配新的用户模型字段
  - 显示手机号、用户ID、备注等信息
  - 使用`disabled`状态替代`isActive`

### 5. 登录页面 (`lib/screens/auth/login_screen.dart`)

- **简化UI**：
  - 移除用户名密码输入框
  - 只保留一键登录按钮
  - 更新提示文案

## API接口规范

### 请求格式

所有API请求都使用JSON格式，并设置正确的Content-Type头：

```json
{
  "Content-Type": "application/json"
}
```

### 认证头格式

需要认证的接口使用Bearer token：

```
Authorization: Bearer {jwt-token}
```

### 响应格式

所有API响应都遵循统一格式：

```json
{
  "success": true,
  "data": {
    // 具体数据
  }
}
```

## Token管理

- **存储**: 使用SharedPreferences存储JWT token
- **携带**: 所有需要认证的请求自动携带Authorization头
- **失效处理**: 自动检测401状态码并清除无效token
- **安全**: token仅在内存和安全存储中保存

## 错误处理

- **网络错误**: 提供友好的错误提示
- **认证失败**: 显示具体的错误信息
- **Token失效**: 自动清除并要求重新登录
- **服务器错误**: 解析并显示服务器返回的错误信息

## 测试

创建了测试脚本 `test_login.dart` 用于验证：
- 一键登录功能
- 用户信息获取
- 权限列表获取
- 错误处理

## 使用方式

1. **一键登录**：
   - 打开应用
   - 点击"立即登录"按钮
   - 系统自动使用默认账号登录

2. **查看用户信息**：
   - 登录后在首页查看基本信息
   - 进入个人资料页查看详细信息

3. **权限管理**：
   - 通过`getCurrentUserPermissions()`获取权限列表
   - 可用于功能权限控制

## 注意事项

1. **网络依赖**: 应用现在依赖真实的后端API，需要网络连接
2. **Token安全**: JWT token包含敏感信息，需要安全存储
3. **错误处理**: 需要处理各种网络和服务器错误情况
4. **权限控制**: 可以基于用户权限列表实现功能访问控制

## 后续优化建议

1. **离线支持**: 考虑添加离线模式或缓存机制
2. **Token刷新**: 实现token自动刷新机制
3. **生物识别**: 添加指纹或面部识别登录
4. **多账号支持**: 支持多个账号切换
5. **权限UI**: 基于权限动态显示/隐藏功能按钮
