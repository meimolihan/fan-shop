#!/bin/bash
#
# fan-shop - 卸载脚本
# 默认停止并删除 systemd 服务与程序文件，保留数据目录；
# 传 --purge 则连数据一起删除。
#
# Usage:
#   bash scripts/uninstall.sh          # 保留数据
#   bash scripts/uninstall.sh --purge  # 连数据一起删除
set -euo pipefail

info() { echo -e "${gl_lv}>>> $*${reset}"; }
warn() { echo -e "${gl_huang}!!! $*${reset}"; }
error() { echo -e "${gl_hong}ERROR: $*${reset}"; exit 1; }

# ================== terminal colors ==================
list_color_init() {
    export gl_hui=$'\033[38;5;59m'
    export gl_hong=$'\033[38;5;9m'
    export gl_lv=$'\033[38;5;10m'
    export gl_huang=$'\033[38;5;11m'
    export gl_lan=$'\033[38;5;32m'
    export gl_bai=$'\033[38;5;15m'
    export gl_zi=$'\033[38;5;13m'
    export gl_bufan=$'\033[38;5;14m'
    export reset=$'\033[0m'
}
list_color_init

PURGE=0
for arg in "$@"; do
    case "${arg}" in
        --purge) PURGE=1 ;;
        *) error "未知参数: ${arg}（仅支持 --purge）" ;;
    esac
done

[[ "$(id -u)" -eq 0 ]] || error "请以 root 运行"

INSTALL_DIR="/opt/fan-shop"
DATA_DIR="${INSTALL_DIR}/backend/data"

# ===================== 移除 systemd 服务 =====================
if systemctl list-unit-files fan-shop.service >/dev/null 2>&1; then
    info "停止并移除服务 fan-shop.service"
    systemctl disable --now fan-shop.service 2>/dev/null || true
    rm -f /etc/systemd/system/fan-shop.service
    systemctl daemon-reload
else
    info "未检测到 fan-shop.service，跳过"
fi

# ===================== 删除程序文件 =====================
info "删除程序目录 ${INSTALL_DIR}"
if [[ -d "${INSTALL_DIR}" ]]; then
    if [[ "${PURGE}" -eq 1 ]]; then
        rm -rf "${INSTALL_DIR}"
        info "✅ 已彻底卸载（含数据目录 ${DATA_DIR}）"
    else
        rm -rf "${INSTALL_DIR}/venv" "${INSTALL_DIR}/frontend" "${INSTALL_DIR}/logs" "${INSTALL_DIR}/backup"
        warn "已保留程序与数据目录: ${INSTALL_DIR}"
        warn "数据位于: ${DATA_DIR}，如需清理请手动执行: rm -rf ${INSTALL_DIR}"
        info "✅ 已卸载服务与运行依赖"
    fi
else
    info ""
fi

info "如需重新安装: bash <(curl -fsSL https://raw.githubusercontent.com/meimolihan/fan-shop/main/scripts/install.sh)"