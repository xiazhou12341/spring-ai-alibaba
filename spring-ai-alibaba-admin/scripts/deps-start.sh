#!/bin/bash
###############################################################################
# deps-start.sh — 一键启动所有中间件，等待就绪后返回
# 用法: bash scripts/deps-start.sh [中间件标签...]
#   不带参数 = 启动全部
#   带标签   = 只启动指定的，如 bash scripts/deps-start.sh MySQL Redis
###############################################################################
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/deps-common.sh"

filter="${*:-}"

echo ""
bold "=== 中间件启动 ==="
echo ""

started=0
failed=0

for line in "${deps[@]}"; do
    parse_dep "$line"

    # 如果指定了过滤标签，只启动匹配的
    if [[ -n "$filter" ]]; then
        match=0
        for f in $filter; do
            [[ "$tag" == "$f" ]] && match=1 && break
        done
        (( match )) || continue
    fi

    printf "  %-18s  " "$tag"

    # ---- 启动 ----
    case "$mgr" in
        docker)
            current=$(docker inspect --format='{{.State.Running}}' "$name" 2>/dev/null)
            if [[ "$current" == "true" ]]; then
                yellow "(already running)"
            else
                docker start "$name" &>/dev/null && echo -n "started " || { red "FAILED to start"; ((failed++)); continue; }
            fi
            ;;
        brew)
            if brew services list 2>/dev/null | grep "$name" | grep -q "started"; then
                yellow "(already started)"
            else
                brew services start "$name" &>/dev/null && echo -n "started " || { red "FAILED to start"; ((failed++)); continue; }
            fi
            ;;
        systemd)
            if systemctl is-active --quiet "$name" 2>/dev/null; then
                yellow "(already active)"
            else
                sudo systemctl start "$name" &>/dev/null && echo -n "started " || { red "FAILED to start"; ((failed++)); continue; }
            fi
            ;;
        jar)
            pidfile="/tmp/${name}.pid"
            if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
                yellow "(already running pid=$(cat "$pidfile"))"
            else
                echo "MANUAL: 请手动启动 $tag (管理方式=jar, 无法自动启动)" && ((failed++)); continue
            fi
            ;;
    esac

    # ---- 等待就绪 ----
    printf "waiting... "
    if wait_ready "$tag" "$mgr" "$name" "$port" "$check_type" "$check_target" "$max_wait"; then
        green "READY ($port)"
        ((started++))
    else
        red "TIMEOUT (${max_wait}s, port $port 无响应)"
        ((failed++))
    fi
done

echo ""
echo "  ─────────────────────────"
printf "  启动: %d  失败: %d\n" "$started" "$failed"
echo "  ─────────────────────────"

if (( failed > 0 )); then
    exit 1
fi
