# Git Commit Message 规范指南

> 本文档定义了 Rico User App 项目的 Git 提交信息规范，旨在提高代码提交的可读性和项目历史的可追溯性。

## 📋 规范概述

本项目采用基于 [Conventional Commits](https://www.conventionalcommits.org/) 的提交信息规范，结合项目实际情况进行适配。

### 基本格式

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 示例

```
feat(auth): 添加用户登录功能

- 实现用户名/密码登录
- 添加表单验证
- 集成 JWT token 管理

Closes #123
```

## 🎯 Type 类型说明

### 主要类型 (必须使用)

| Type | 说明 | 示例 |
|------|------|------|
| **feat** | 新功能 | `feat(auth): 添加 OAuth 登录支持` |
| **fix** | Bug 修复 | `fix(login): 修复密码验证错误` |
| **docs** | 文档更改 | `docs(readme): 更新安装说明` |
| **style** | 代码格式调整 | `style(auth): 统一代码缩进格式` |
| **refactor** | 代码重构 | `refactor(api): 重构网络请求层` |
| **test** | 测试相关 | `test(auth): 添加登录单元测试` |
| **chore** | 构建/工具相关 | `chore(deps): 更新 Flutter 依赖` |

### 扩展类型 (按需使用)

| Type | 说明 | 示例 |
|------|------|------|
| **perf** | 性能优化 | `perf(ui): 优化列表渲染性能` |
| **build** | 构建系统 | `build(android): 更新 Gradle 配置` |
| **ci** | CI/CD 配置 | `ci(github): 添加自动化测试` |
| **revert** | 回滚提交 | `revert: 回滚登录功能更改` |
| **merge** | 合并分支 | `merge: 合并 feature/auth 分支` |

## 🎯 Scope 作用域说明

### Flutter 项目相关作用域

| Scope | 说明 | 示例 |
|-------|------|------|
| **auth** | 认证相关 | `feat(auth): 添加 Google 登录` |
| **ui** | UI 组件 | `feat(ui): 添加自定义按钮组件` |
| **api** | API 接口 | `fix(api): 修复网络超时问题` |
| **theme** | 主题样式 | `feat(theme): 添加深色主题支持` |
| **routing** | 路由导航 | `fix(routing): 修复页面跳转逻辑` |
| **storage** | 本地存储 | `feat(storage): 添加用户偏好设置` |
| **models** | 数据模型 | `refactor(models): 重构用户数据模型` |
| **widgets** | 自定义组件 | `feat(widgets): 添加加载指示器` |
| **providers** | 状态管理 | `feat(providers): 添加主题状态管理` |
| **utils** | 工具类 | `feat(utils): 添加日期格式化工具` |

### 平台相关作用域

| Scope | 说明 | 示例 |
|-------|------|------|
| **android** | Android 平台 | `fix(android): 修复权限请求问题` |
| **ios** | iOS 平台 | `feat(ios): 添加推送通知支持` |
| **web** | Web 平台 | `fix(web): 修复浏览器兼容性问题` |

### 开发相关作用域

| Scope | 说明 | 示例 |
|-------|------|------|
| **deps** | 依赖管理 | `chore(deps): 升级 Riverpod 到 2.5.0` |
| **config** | 配置文件 | `chore(config): 更新 linting 规则` |
| **docs** | 文档 | `docs(api): 添加 API 使用说明` |
| **test** | 测试 | `test(auth): 添加登录流程测试` |

## ✍️ Description 描述规范

### 基本原则

1. **使用中文**: 项目主要使用中文，提交信息也使用中文
2. **动词开头**: 使用动词开始描述，如"添加"、"修复"、"更新"
3. **简洁明了**: 控制在 50 字符以内
4. **现在时态**: 使用现在时描述，如"添加"而不是"已添加"
5. **小写开头**: 英文部分使用小写开头

### 动词使用建议

| 中文动词 | 使用场景 | 示例 |
|---------|---------|------|
| **添加** | 新增功能、文件 | `添加用户注册功能` |
| **修复** | Bug 修复 | `修复登录失败的问题` |
| **更新** | 内容更改 | `更新用户协议内容` |
| **删除** | 移除功能、文件 | `删除过期的API接口` |
| **重构** | 代码重构 | `重构认证模块架构` |
| **优化** | 性能优化 | `优化列表滚动性能` |
| **调整** | 样式、配置调整 | `调整按钮样式` |
| **统一** | 格式统一 | `统一代码格式` |
| **完善** | 功能完善 | `完善错误处理逻辑` |

## 📝 Body 正文规范

### 使用场景

- 解释**为什么**做这个更改
- 详细说明**做了什么**
- 提及**影响范围**

### 格式要求

1. **空行分隔**: Body 与 subject 之间空一行
2. **列表格式**: 使用 `-` 或 `*` 列出要点
3. **换行控制**: 每行不超过 72 字符
4. **详细说明**: 提供足够的上下文信息

### 示例

```
feat(auth): 添加多种登录方式支持

- 实现邮箱/密码登录
- 添加 Google OAuth 登录
- 集成第三方登录 SDK
- 统一登录状态管理
- 添加登录错误处理

这个更改为用户提供了更多登录选择，提升了用户体验。
同时为后续添加更多第三方登录奠定了基础。
```

## 🏷️ Footer 页脚规范

### Breaking Changes

```
BREAKING CHANGE: 
- 移除了旧的登录 API
- 需要更新所有登录相关的调用代码
```

### 关联 Issue

```
Closes #123
Fixes #456
Refs #789
```

### 共同作者

```
Co-authored-by: 张三 <zhangsan@example.com>
```

## 📚 完整示例

### 功能开发示例

```
feat(theme): 添加动态主题切换功能

- 实现浅色/深色/跟随系统三种主题模式
- 添加主题持久化存储
- 创建主题切换动画效果
- 更新所有页面的主题适配
- 在设置页面添加主题选择器

这个功能让用户可以根据个人喜好和环境光线
选择合适的应用主题，提升了用户体验。

Closes #45
```

### Bug 修复示例

```
fix(auth): 修复登录状态丢失问题

修复了应用重启后用户需要重新登录的问题。
问题原因是 token 过期检查逻辑错误。

- 更正 token 过期时间判断
- 添加 token 自动刷新机制
- 完善登录状态检查逻辑

Fixes #67
```

### 文档更新示例

```
docs(readme): 完善项目安装和运行说明

- 添加 Flutter 环境配置步骤
- 更新依赖安装说明
- 补充常见问题解决方案
- 添加项目目录结构说明
```

### 重构示例

```
refactor(api): 重构网络请求架构

- 统一 API 请求接口设计
- 抽取公共错误处理逻辑
- 实现请求拦截器
- 优化网络请求性能
- 添加请求缓存机制

这次重构提高了代码的可维护性和网络请求的稳定性。

BREAKING CHANGE: 
- 所有 API 调用方式发生变化
- 需要更新现有的网络请求代码
```

## 🚫 不良示例

### ❌ 避免的写法

```bash
# 太简略，没有说明具体做了什么
fix: bug

# 使用英文但不规范
Fix Bug in login

# 没有类型标识
修复登录问题

# 描述不清楚
update stuff

# 混用中英文
feat: 添加 new feature

# 全大写
FIX: LOGIN BUG

# 太啰嗦
feat(auth): 今天我添加了一个非常重要的用户登录功能，这个功能可以让用户通过邮箱和密码进行登录
```

### ✅ 正确的写法

```bash
fix(auth): 修复登录状态检查逻辑错误

feat(ui): 添加自定义加载组件

docs(readme): 更新项目安装说明

refactor(api): 统一网络请求错误处理

chore(deps): 升级 Flutter 到 3.35.1
```

## 🛠️ 工具推荐

### VS Code 插件

- **Conventional Commits**: 自动生成符合规范的提交信息
- **GitLens**: Git 增强工具，查看提交历史

### 命令行工具

```bash
# 安装 commitizen (可选)
npm install -g commitizen cz-conventional-changelog

# 使用 commitizen 提交
git cz
```

### Git Hooks

在 `.git/hooks/commit-msg` 中添加提交信息检查：

```bash
#!/bin/sh
# 检查提交信息格式
commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf|build|ci|revert|merge)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "提交信息格式不符合规范！"
    echo "正确格式: type(scope): description"
    echo "示例: feat(auth): 添加用户登录功能"
    exit 1
fi
```

## 📊 提交统计和分析

### 查看提交统计

```bash
# 按类型统计提交
git log --oneline | grep -E '^[a-f0-9]+\s+(feat|fix|docs)' | wc -l

# 查看最近的功能提交
git log --oneline --grep="feat"

# 查看特定作用域的提交
git log --oneline --grep="auth"
```

### 生成变更日志

```bash
# 根据提交信息自动生成 CHANGELOG
npm install -g conventional-changelog-cli
conventional-changelog -p angular -i CHANGELOG.md -s
```

## 🎯 团队协作建议

### Code Review 要点

1. **检查提交信息规范**: 确保符合本文档规范
2. **验证作用域准确性**: 确保 scope 选择合适
3. **确认描述清晰度**: 确保描述准确且易懂

### 分支命名规范

配合提交信息规范，建议的分支命名：

```bash
feature/auth-login       # 新功能分支
fix/login-validation     # Bug 修复分支
docs/api-documentation   # 文档更新分支
refactor/api-structure   # 重构分支
```

### PR/MR 标题规范

Pull Request 标题应当遵循同样的规范：

```
feat(auth): 添加多因素认证支持
fix(ui): 修复在小屏幕设备上的布局问题
docs(guide): 完善开发环境配置说明
```

## 📝 检查清单

在提交前，请确认：

- [ ] 提交信息包含正确的 type
- [ ] scope 选择准确（如果适用）
- [ ] 描述简洁明了（50字符以内）
- [ ] 使用中文描述
- [ ] 动词开头，现在时态
- [ ] 如有必要，包含详细的 body 说明
- [ ] 关联相关的 Issue（如果适用）
- [ ] 标注 Breaking Changes（如果适用）

## 🔄 版本更新

当本规范发生重要更新时，会在此记录：

- **v1.0** (2024-12): 初始版本，建立基础规范
- 未来版本将根据团队反馈和项目需求进行调整

---

**文档维护**: Rico User App 项目组  
**最后更新**: 2024年12月  
**参考标准**: [Conventional Commits 1.0.0](https://www.conventionalcommits.org/)

> 💡 **提示**: 良好的提交信息是团队协作的基础，请认真对待每一次提交！
