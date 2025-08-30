#!/bin/bash

# Colima HEAD 版本更新腳本
# 這個腳本會獲取最新的 Colima GitHub commit 並更新模組配置

set -e

echo "🔄 更新 Colima HEAD 版本..."

# 檢查必要的工具
if ! command -v nix-prefetch-github >/dev/null 2>&1; then
    echo "❌ 需要 nix-prefetch-github 工具"
    echo "   安裝: nix-shell -p nix-prefetch-github"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "❌ 需要 jq 工具"
    echo "   安裝: nix-shell -p jq"
    exit 1
fi

# 獲取最新的 commit 資訊
echo "📡 獲取最新的 GitHub commit..."
PREFETCH_OUTPUT=$(nix-shell -p nix-prefetch-github --run "nix-prefetch-github abiosoft colima --rev main")

# 解析輸出
REV=$(echo "$PREFETCH_OUTPUT" | jq -r '.rev')
SHA256=$(echo "$PREFETCH_OUTPUT" | jq -r '.sha256')
DATE=$(date +%Y-%m-%d)

echo "✅ 最新 commit: $REV"
echo "✅ SHA256: $SHA256"

# 更新模組檔案
MODULE_FILE="modules/home/programs/cloud/colima/default.nix"

if [ ! -f "$MODULE_FILE" ]; then
    echo "❌ 找不到模組檔案: $MODULE_FILE"
    exit 1
fi

echo "📝 更新模組檔案..."

# 備份原檔案
cp "$MODULE_FILE" "$MODULE_FILE.backup"

# 更新版本資訊
sed -i '' "s/version = \"unstable-[0-9-]*\";/version = \"unstable-$DATE\";/" "$MODULE_FILE"

# 更新 rev
sed -i '' "s/rev = \"[a-f0-9]*\";/rev = \"$REV\";/" "$MODULE_FILE"

# 更新 sha256
sed -i '' "s/sha256 = \"sha256-[A-Za-z0-9+\/=]*\";/sha256 = \"$SHA256\";/" "$MODULE_FILE"

# 更新 .git-revision
sed -i '' "s/echo \"[a-f0-9]*\" > source\/.git-revision/echo \"$REV\" > source\/.git-revision/" "$MODULE_FILE"

# 更新 ldflags 中的 revision
sed -i '' "s/-X github.com\/abiosoft\/colima\/config.revision=[a-f0-9]*\"/-X github.com\/abiosoft\/colima\/config.revision=$REV\"/" "$MODULE_FILE"

echo "✅ 模組檔案已更新"

# 檢查語法
echo "🔍 檢查語法..."
if nix-instantiate --parse "$MODULE_FILE" >/dev/null 2>&1; then
    echo "✅ 語法檢查通過"
else
    echo "❌ 語法檢查失敗，恢復備份"
    mv "$MODULE_FILE.backup" "$MODULE_FILE"
    exit 1
fi

# 清理備份
rm "$MODULE_FILE.backup"

echo ""
echo "🎉 Colima HEAD 版本更新完成！"
echo ""
echo "📋 更新資訊："
echo "   版本: unstable-$DATE"
echo "   Commit: $REV"
echo "   SHA256: $SHA256"
echo ""
echo "🚀 下一步："
echo "   1. 檢查更改: git diff $MODULE_FILE"
echo "   2. 測試構建: sudo nix run nix-darwin -- switch --flake ~/.config/nix"
echo "   3. 提交更改: git add $MODULE_FILE && git commit -m \"chore: update colima HEAD to $REV\""
echo ""
echo "💡 注意："
echo "   - 新版本可能需要更新 vendorHash"
echo "   - 如果構建失敗，請檢查 Go 依賴項是否有變化"
echo "   - 建議在測試環境中先驗證新版本"
