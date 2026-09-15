#!/bin/bash
#
# fan-shop - 发布脚本（触发 GitHub Actions 自动构建）
# 不在本地编译任何产物：仅更新版本号、推送代码并打 v 开头 tag。
# 推送 tag 后由 GitHub Actions 自动完成发布：
#   release.yml -> 自包含源码包 fan-shop-<version>.tar.gz + SHA256SUMS 并创建 GitHub Release
#   build.yml   -> multi-arch Docker 镜像（latest + 版本标签）
#
# Usage:
#   TAG(必填) 形如 v2.1.7; --yes 免交互
#     bash scripts/build-and-push.sh v2.1.7 --yes
set -euo pipefail

info() { echo -e "\033[32m>>> $*\033[0m"; }
warn() { echo -e "\033[33m!!! $*\033[0m"; }
error() { echo -e "\033[31mERROR: $*\033[0m"; exit 1; }

YES_MODE=0
TAG=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes) YES_MODE=1; shift ;;
        *) TAG="$1"; shift ;;
    esac
done

[[ -z "${TAG}" ]] && error "缺少TAG参数，示例: $0 v2.1.7 --yes"

cd "$(dirname "$0")/.."
TARGET_VER="${TAG#v}"
[[ "${TARGET_VER}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || error "TAG 格式错误，示例: v2.1.7"

# ===================== 重复Tag/Release自动清理 =====================
info "检查远端是否存在 Release ${TAG}"
if command -v gh >/dev/null 2>&1 && gh release view "${TAG}" >/dev/null 2>&1; then
    warn "发现已存在Release ${TAG}，准备删除Release并清理tag"
    gh release delete "${TAG}" -y --cleanup-tag
fi

info "清理本地&远端Git tag: ${TAG}"
git tag -d "${TAG}" 2>/dev/null || true
git push origin --delete "${TAG}" 2>/dev/null || true

# ===================== 版本号 bump =====================
info "执行版本号更新 ${TARGET_VER}"
BUMP_FILES=("backend/app/version.py")
for f in "${BUMP_FILES[@]}"; do
    [[ ! -f "${f}" ]] && error "缺失文件 ${f}"
done

BUILD_DATE="$(date +%F)"
sed -i "s/^VERSION = .*/VERSION = \"v${TARGET_VER}\"/" backend/app/version.py
sed -i "s/^BUILD_DATE = .*/BUILD_DATE = \"${BUILD_DATE}\"/" backend/app/version.py

info "版本号确认:"
grep -n '^VERSION =' backend/app/version.py
grep -n '^BUILD_DATE =' backend/app/version.py

# ===================== Git 提交 & Tag =====================
info "提交版本变更"
git add backend/app/version.py
git commit -m "chore: bump version to ${TARGET_VER}" || info "无版本文件变更，跳过提交"
git push origin main

git tag "${TAG}"
git push origin "${TAG}"

# ===================== 交由 CI 自动构建发布 =====================
info "✅ 已推送 tag ${TAG}，GitHub Actions 将自动完成打包与 Release 创建"

info "查看发布结果: gh release view ${TAG}"
info "查看镜像: docker pull mobufan/fan-shop:${TAG}"