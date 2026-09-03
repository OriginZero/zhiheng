#!/usr/bin/env bash
# 发版前校验脚本（docs/约束性文档.md「9. 版本管理」的可执行版本）。
#
# 用法：
#   bash tool/check_release.sh          # 校验 pubspec 版本 vs 最新 tag
#   bash tool/check_release.sh --dry    # 仅输出判定信息，不失败
#
# 规则：
#   1. pubspec.yaml 的 version 必须 > 最新 tag（major/minor/patch 至少一位更高）
#   2. build number 必须大于最新 tag 的 build number
#   3. tag 名必须与版本一致（v1.8.0 ↔ 1.8.0+9，tag 不含 +build）
#   4. 新版本档位判定提示（major/minor/patch 哪一位变化）

set -euo pipefail

cd "$(dirname "$0")/.."

# 解析 pubspec version（如 1.8.0+9）
VERSION_LINE=$(grep '^version:' pubspec.yaml | awk '{print $2}')
MAJOR_MINOR_PATCH="${VERSION_LINE%%+*}"
BUILD="${VERSION_LINE##*+}"

IFS='.' read -r NEW_MAJOR NEW_MINOR NEW_PATCH <<<"$MAJOR_MINOR_PATCH"

# 最新 tag（v1.7.0）
LATEST_TAG=$(git tag --sort=-version:refname | head -1 || true)
if [[ -z "$LATEST_TAG" ]]; then
  echo "✅ 无历史 tag（首次发布），版本 $VERSION_LINE"
  exit 0
fi

LATEST_TAG_BARE="${LATEST_TAG#v}"   # 去掉 v 前缀
LATEST_VER="${LATEST_TAG_BARE%%+*}"
# git tag 惯例不带 +build（如 v1.7.0）；若带了则解析，否则 build 视为 0。
if [[ "$LATEST_TAG_BARE" == *+* ]]; then
  LATEST_BUILD="${LATEST_TAG_BARE##*+}"
else
  LATEST_BUILD=0
fi

IFS='.' read -r OLD_MAJOR OLD_MINOR OLD_PATCH <<<"$LATEST_VER"

FAIL=0
check() {
  local desc="$1"; local ok="$2"
  if [[ "$ok" == "ok" ]]; then
    echo "✅ $desc"
  else
    echo "❌ $desc"
    FAIL=1
  fi
}

echo "当前版本 : $VERSION_LINE  ($MAJOR_MINOR_PATCH, build $BUILD)"
echo "最新 tag  : $LATEST_TAG  ($LATEST_VER, build $LATEST_BUILD)"
echo ""

# 1. 版本必须高于最新 tag（至少一位）
HIGHER=no
if (( NEW_MAJOR > OLD_MAJOR )); then HIGHER=yes
elif (( NEW_MAJOR == OLD_MAJOR && NEW_MINOR > OLD_MINOR )); then HIGHER=yes
elif (( NEW_MAJOR == OLD_MAJOR && NEW_MINOR == OLD_MINOR && NEW_PATCH > OLD_PATCH )); then HIGHER=yes
fi
check "版本高于最新 tag（major.minor.patch 至少一位更高）" "$([[ $HIGHER == yes ]] && echo ok || echo fail)"

# 2. build number 必须递增（版本升级时 build 可重置为 1 或继续递增，但不得回退）
if [[ "$HIGHER" == yes ]]; then
  check "build number 有效（版本升级，build=$BUILD）" ok
elif (( BUILD > LATEST_BUILD )); then
  check "build number 递增（$LATEST_BUILD → $BUILD）" ok
else
  check "build number 递增（$LATEST_BUILD → $BUILD）" fail
fi

# 3. 档位判定提示
if (( NEW_MAJOR > OLD_MAJOR )); then
  TIER="大功能迭代（major）—— 破坏性架构/schema 不兼容/跨产品线能力"
elif (( NEW_MINOR > OLD_MINOR )); then
  TIER="中等功能迭代（minor）—— 新功能模块/向后兼容 schema 迁移/跨页面功能集"
else
  TIER="小功能迭代（patch）—— 单点增强/bug 修复/UI 微调/文档"
fi
echo ""
echo "档位判定：$TIER"
echo "发版命令：git tag v$MAJOR_MINOR_PATCH && git push origin v$MAJOR_MINOR_PATCH"
# 发布形态（docs/约束性文档.md §9.4）：默认 pre；仅当「最新版本」条目显式标注「正式」才按正式发布。
MODE="pre（默认）"
LATEST_ENTRY=$(awk '''/^## 最新版本/{f=1;next} /^## / && f && !/最新版本/{f=0} f && /^### v/{print;exit}''' docs/更新文档.md)
case "$LATEST_ENTRY" in
  *正式*) MODE="正式（需显式声明）" ;;
esac
echo "发布形态：$MODE（默认 pre；正式化 = 验证通过后取消 GitHub Release 的 prerelease 标记）"


if [[ "${1:-}" == "--dry" ]]; then
  exit 0
fi
exit $FAIL
