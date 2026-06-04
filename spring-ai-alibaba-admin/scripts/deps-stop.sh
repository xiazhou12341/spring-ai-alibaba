#!/bin/bash
###############################################################################
# deps-stop.sh — 一键停止所有中间件
# 用法: bash scripts/deps-stop.sh [中间件标签...]
###############################################################################
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/deps-common.sh"

filter="${*:-}"

echo ""
bold "=== 中间件停止 ==="
echo ""

stopped=0
failed=0

for line in "${deps[@]}"; do
    parse_dep "$line"

    # 过滤
    if [[ -n "$filter" ]]; then
        match=0
        for f in $filter; do
            [[ "$tag" == "$f" ]] && match=1 && break
        done
        (( match )) || continue
    fi

    printf "  %-18s  " "$tag"

    case "$mgr" in
        docker)
            current=$(docker inspect --format='{{.State.Running}}' "$name" 2>/dev/null)
            if [[ "$current" != "true" ]]; then
                yellow "(not running)"
            else
                docker stop "$name" &>/dev/null && green "stopped" || { red "FAILED"; ((failed++)); continue; }
            fi
            ;;
        brew)
            if brew services list 2>/dev/null | grep "$name" | grep -q "none"; then
                yellow "(not running)"
            else
                brew services stop "$name" &>/dev/null && green "stopped" || { red "FAILED"; ((failed++)); continue; }
            fi
            ;;
        systemd)
            if ! systemctl is-active --quiet "$name" 2>/dev/null; then
                yellow "(not active)"
            else
                sudo systemctl stop "$name" &>/dev/null && green "stopped" || { red "FAILED"; ((failed++)); continue; }
            fi
            ;;
        jar)
            pidfile="/tmp/${name}.pid"
            if [[ -f "$pidfile" ]]; then
                pid=$(cat "$pidfile")
                kill "$pid" 2>/dev/null && green "stopped (pid=$pid)" || { red "FAILED to kill pid=$pid"; ((failed++)); continue; }
                rm -f "$pidfile"
            else
                yellow "(no pidfile, skip)"
            fi
            ;;
    esac

    ((stopped++))
done

echo ""
echo "  ─────────────────────────"
printf "  停止: %d  失败: %d\n" "$stopped" "$failed"
echo "  ─────────────────────────"

(( failed > 0 )) && exit 1 || exit 0
