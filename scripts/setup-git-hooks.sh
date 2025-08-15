#!/bin/bash

# Git Hooks 安装脚本
# 用于设置提交信息格式检查

echo "🔧 正在设置 Git Hooks..."

# 创建 hooks 目录（如果不存在）
mkdir -p .git/hooks

# 创建 commit-msg hook
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/sh

# 提交信息格式检查脚本
# 检查是否符合 Conventional Commits 规范

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 读取提交信息
commit_msg=$(cat "$1")

# 忽略合并提交和revert提交
if echo "$commit_msg" | grep -qE "^(Merge|Revert)"; then
    exit 0
fi

# 定义提交信息格式正则表达式
commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf|build|ci|revert|merge)(\(.+\))?: .{1,50}'

# 检查格式
if ! echo "$commit_msg" | grep -qE "$commit_regex"; then
    echo ""
    echo -e "${RED}❌ 提交信息格式不符合规范！${NC}"
    echo ""
    echo -e "${YELLOW}正确格式:${NC} <type>(<scope>): <description>"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  feat(auth): 添加用户登录功能"
    echo "  fix(ui): 修复按钮样式问题"  
    echo "  docs(readme): 更新安装说明"
    echo ""
    echo -e "${YELLOW}支持的类型:${NC}"
    echo "  feat, fix, docs, style, refactor, test, chore, perf, build, ci"
    echo ""
    echo -e "${YELLOW}常用作用域:${NC}"
    echo "  auth, ui, api, theme, routing, storage, models, widgets, providers"
    echo ""
    echo -e "${YELLOW}详细规范请查看:${NC} docs/commit-message-guide.md"
    echo ""
    exit 1
fi

# 检查描述长度
description=$(echo "$commit_msg" | head -n1 | sed 's/^[^:]*: //')
if [ ${#description} -gt 50 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  警告: 提交描述过长 (${#description} > 50 字符)${NC}"
    echo "建议简化描述内容"
    echo ""
fi

echo -e "${GREEN}✅ 提交信息格式检查通过${NC}"
exit 0
EOF

# 给 hook 文件添加执行权限
chmod +x .git/hooks/commit-msg

# 设置提交模板
git config commit.template .gitmessage

echo ""
echo "✅ Git Hooks 设置完成！"
echo ""
echo "📋 已启用的功能："
echo "  • 提交信息格式自动检查"
echo "  • 提交模板自动加载"
echo ""
echo "💡 使用提示："
echo "  • 提交时会自动检查格式"
echo "  • 格式不符合会阻止提交"
echo "  • 查看规范: docs/commit-message-guide.md"
echo ""
