#!/bin/bash
###############################################################################
# deps-status.sh — 查看所有中间件运行状态和端口监听情况
# 用法: bash scripts/deps-status.sh
###############################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/deps-common.sh"

echo ""
bold "=== 中间件状态 ==="
echo ""

# 表头
printf "  %-18s %-8s %-12s %-6s %s\n" "NAME" "STATUS" "MANAGER" "PORT" "LISTEN"
printf "  %-18s %-8s %-12s %-6s %s\n" "──────────────────" "────────" "────────────" "──────" "────────────────────"

overall_ok=true

for line in "${deps[@]}"; do
    parse_dep "$line"

    s="DOWN"
    sc="$C_RED"
    listen="-"
    running=false

    # ---- 检查进程是否在跑 ----
    case "$mgr" in
        docker)
            docker inspect --format='{{.State.Running}}' "$name" 2>/dev/null | grep -q "true" && running=true
            ;;
        brew)
            brew services list 2>/dev/null | grep "$name" | grep -q "started" && running=true
            ;;
        systemd)
            systemctl is-active --quiet "$name" 2>/dev/null && running=true
            ;;
        jar)
            local_pid=$(cat "/tmp/${name}.pid" 2>/dev/null || true)
            [[ -n "$local_pid" ]] && kill -0 "$local_pid" 2>/dev/null && running=true
            ;;
    esac

    if ! $running; then
        overall_ok=false
    fi

    # ---- 端口监听 ----
    if pid=$(pid_by_port "$port"); then
        listen="pid=$pid"
    fi

    # ---- 综合健康检查 ----
    if $running; then
        if check_healthy "$tag" "$mgr" "$name" "$port" "$check_type" "$check_target"; then
            s="UP"
            sc="$C_GREEN"
            [[ -z "$listen" ]] && listen="ok (no port bind)"
        else
            s="BOOT"
            sc="$C_YELLOW"
            [[ -n "$listen" ]] && listen="$listen (starting...)"
        fi
    fi

    printf "  %-18s ${sc}%-8s${C_RESET} %-12s %-6s %s\n" "$tag" "$s" "$mgr" "$port" "$listen"
done

echo ""
echo "  Legend: UP=正常  BOOT=启动中(健康检查未通过)  DOWN=未运行"
echo ""

$overall_ok || exit 1
