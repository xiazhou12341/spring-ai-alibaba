#!/bin/bash
###############################################################################
# deps-compose-stop.sh — 一键停止 docker-compose.dev.yml 所有依赖容器
#
# 用法：
#   bash scripts/deps-compose-stop.sh          # 停止容器，保留数据卷
#   bash scripts/deps-compose-stop.sh --clean  # 停止容器 + 删除数据卷
###############################################################################
set -e

COMPOSE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docker-compose.dev.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "❌ 未找到 $COMPOSE_FILE"
    exit 1
fi

echo ""
echo "========================================"
echo "  停止所有依赖中间件容器"
echo "========================================"
echo ""

if [[ "${1:-}" == "--clean" ]] || [[ "${1:-}" == "-c" ]]; then
    echo "模式: 停止容器 + 删除数据卷"
    docker compose -f "$COMPOSE_FILE" down -v
    echo ""
    echo "✅ 所有容器已停止，数据卷已清理。"
else
    echo "模式: 停止容器（保留数据卷，下次启动数据不丢失）"
    docker compose -f "$COMPOSE_FILE" down
    echo ""
    echo "✅ 所有容器已停止。"
    echo "💡 如需删除数据卷: bash scripts/deps-compose-stop.sh --clean"
fi

echo ""
