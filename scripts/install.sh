#!/bin/bash
#
# fan-shop - 安装脚本（systemd 服务直装）
# 从 GitHub Releases 下载自包含源码包，创建 Python venv，注册 systemd 服务。
# 与 Docker 部署等价（同源代码、同运行方式），适应"设备上直接跑"的场景。
#
# Usage:
#   bash scripts/install.sh                # 安装最新 Release
#   bash scripts/install.sh v2.1.7        # 安装指定版本
set -euo pipefail

info() { echo -e "\033[32m>>> $*\033[0m"; }
warn() { echo -e "\033[33m!!! $*\033[0m"; }
error() { echo -e "\033[31mERROR: $*\033[0m"; exit 1; }

VERSION_ARG="${1:-}"

# ===================== 环境检查 =====================
command -v python3 >/dev/null 2>&1 || error "缺少 python3"
command -v curl >/dev/null 2>&1 || error "缺少 curl"
command -v tar >/dev/null 2>&1 || error "缺少 tar"
[[ "$(id -u)" -eq 0 ]] || error "请以 root 运行（需安装 systemd 服务并访问 Docker）"
command -v systemctl >/dev/null 2>&1 || error "未检测到 systemd（systemctl 不存在）"
command -v docker >/dev/null 2>&1 || warn "未检测到 docker CLI（fan-shop 管理 Docker 容器的功能将不可用）"

INSTALL_DIR="/opt/fan-shop"
DATA_DIR="${INSTALL_DIR}/backend/data"
LOG_DIR="${INSTALL_DIR}/logs"
BACKUP_DIR="${INSTALL_DIR}/backup"
PORT=8001

if systemctl list-unit-files fan-shop.service >/dev/null 2>&1 && \
   systemctl is-active --quiet fan-shop.service 2>/dev/null; then
    warn "fan-shop 服务已安装且正在运行，将覆盖安装（数据保留）"
fi

# ===================== 解析版本 =====================
REPO="meimolihan/fan-shop"
if [[ -z "${VERSION_ARG}" ]]; then
    info "解析最新 Release 版本"
    TAG="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p')"
    [[ -n "$TAG" ]] || error "无法获取最新版本号"
else
    TAG="${VERSION_ARG}"
    [[ "${TAG}" == v* ]] || TAG="v${TAG}"
fi
VER="${TAG#v}"
echo "VERSION=${VER}"

ARCHIVE="fan-shop-${VER}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${TAG}/${ARCHIVE}"

# ===================== 下载与解压 =====================
mkdir -p "${INSTALL_DIR}"
TMP_ARCHIVE="$(mktemp /tmp/fan-shop-XXXXXX.tar.gz)"
trap 'rm -f "${TMP_ARCHIVE}"' EXIT

info "下载 ${URL}"
curl -fL --retry 3 -o "${TMP_ARCHIVE}" "${URL}"

info "解压到 ${INSTALL_DIR}"
tar -xzf "${TMP_ARCHIVE}" -C "${INSTALL_DIR}" --strip-components=1

[[ -f "${INSTALL_DIR}/backend/app/main.py" ]] || error "源码包结构不完整，安装中止"
[[ -d "${INSTALL_DIR}/frontend/src" ]] || error "前端源码缺失，安装中止"

mkdir -p "${DATA_DIR}" "${LOG_DIR}" "${BACKUP_DIR}"

# ===================== 依赖安装（venv） =====================
info "创建 Python venv 并安装依赖"
python3 -m venv "${INSTALL_DIR}/venv"
"${INSTALL_DIR}/venv/bin/pip" install --upgrade pip -q
"${INSTALL_DIR}/venv/bin/pip" install -r "${INSTALL_DIR}/backend/requirements.txt" -q

# ===================== 注册 systemd 服务 =====================
info "注册 systemd 服务 fan-shop.service"
cat > /etc/systemd/system/fan-shop.service <<EOF
[Unit]
Description=fan-shop
Wants=network-online.target
After=network-online.target docker.service

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}/backend
ExecStart=${INSTALL_DIR}/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port ${PORT}
Environment=HOST_MOUNT=/
Environment=APP_LOG_DIR=${LOG_DIR}
Environment=BACKUP_DIR=${BACKUP_DIR}
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fan-shop.service
systemctl restart fan-shop.service

sleep 2
if systemctl is-active --quiet fan-shop.service; then
    info "✅ fan-shop ${VER} 安装完成并已启动"
else
    warn "服务启动失败，查看日志: journalctl -u fan-shop -n 50"
fi

info "服务地址: http://$(hostname -I 2>/dev/null | awk '{print $1}'):${PORT}"
info "常用命令:"
info "  systemctl status fan-shop          # 查看状态"
info "  systemctl restart fan-shop         # 重启"
info "  journalctl -u fan-shop -f          # 实时日志"
info "卸载: bash /opt/fan-shop/scripts/uninstall.sh"