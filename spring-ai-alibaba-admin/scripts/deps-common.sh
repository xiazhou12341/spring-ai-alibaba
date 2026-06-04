#!/bin/bash
###############################################################################
# deps-common.sh — 中间件统一定义（被 start/stop/status 共享）
#
# 管理方式字段取值：
#   docker      — Docker 容器（容器名）
#   brew        — brew services（服务名）
#   systemd     — Linux systemd 单元名
#   jar         — 手动 Java 进程（pidfile + start 命令）
#
# 添加新中间件：按下面格式在 deps[] 数组末尾加一行即可。
#   格式: "标签|管理方式|名称|端口|健康检查类型|检查目标|最大等待秒"
#   健康检查类型: http | tcp | mysql | redis | pidfile | docker-health
###############################################################################

# ---- 中间件定义 ----
deps=(
    "MySQL   |docker   |mysql          |3306 |mysql  |mysqladmin ping -h localhost|30"
    "Redis   |brew     |redis          |6379 |redis  |127.0.0.1:6379              |10"
    "Nacos   |docker   |nacos          |8848 |http   |http://127.0.0.1:8848/nacos/|30"
    "ES      |docker   |elasticsearch  |9200 |http   |http://127.0.0.1:9200/_cluster/health|30"
    "Kibana  |docker   |kibana         |5601 |http   |http://127.0.0.1:5601/api/status |30"
    "RocketMQ|docker   |rmq_namesrv    |9876 |docker-health|rmq_namesrv         |30"
    "RocketMQ-Broker|docker|rmq_broker |10911|docker-health|rmq_broker          |30"
    "RocketMQ-Proxy |docker|rmq_proxy  |18080|docker-health|rmq_proxy           |30"
    "LoongCol|docker   |loongcollector |4318 |tcp    |4318                        |30"
)

# ---- 颜色 ----
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_BOLD='\033[1m'

# ---- 通用工具 ----
green() { printf "${C_GREEN}%s${C_RESET}\n" "$*"; }
red()   { printf "${C_RED}%s${C_RESET}\n" "$*"; }
yellow(){ printf "${C_YELLOW}%s${C_RESET}\n" "$*"; }
bold()  { printf "${C_BOLD}%s${C_RESET}\n" "$*"; }

# 检查端口是否有进程监听
port_listening() {
    local port=$1
    lsof -iTCP:"$port" -sTCP:LISTEN -nP &>/dev/null
}

# Docker 容器健康检查（仅 Docker 内置 HEALTHCHECK）
docker_healthy() {
    local container=$1
    docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null | grep -q "healthy"
}

# 综合健康检查：先试 Docker HEALTHCHECK，回退到服务级检查
# 返回 0=健康, 1=不健康
check_healthy() {
    local tag=$1 mgr=$2 name=$3 port=$4 check_type=$5 check_target=$6
    local v

    case "$check_type" in
        mysql)
            if [[ "$mgr" == "docker" ]]; then
                docker exec "$name" $check_target &>/dev/null && return 0
            else
                mysqladmin ping -h localhost &>/dev/null && return 0
            fi
            ;;
        redis)
            redis-cli -h "${check_target%%:*}" -p "${check_target##*:}" ping 2>/dev/null | grep -qi pong && return 0
            ;;
        http)
            v=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 --max-time 5 "$check_target" 2>/dev/null)
            echo "$v" | grep -qE "^(200|301|302|401|403)$" && return 0
            ;;
        tcp)
            port_listening "$check_target" && return 0
            ;;
        docker-health)
            # 先试 Docker HEALTHCHECK
            docker_healthy "$check_target" 2>/dev/null && return 0
            # 回退：容器跑着就算 UP(boot)
            v=$(docker inspect --format='{{.State.Running}}' "$check_target" 2>/dev/null)
            test "$v" == "true" && return 0
            ;;
    esac
    return 1
}

# 解析 deps 数组中的一行
# 用法: parse_dep "行" → 设置 $tag $mgr $name $port $check_type $check_target $max_wait
parse_dep() {
    local line="$1"
    IFS='|' read -r tag mgr name port check_type check_target max_wait <<< "$line"
    tag=$(echo "$tag" | xargs)
    mgr=$(echo "$mgr" | xargs)
    name=$(echo "$name" | xargs)
    port=$(echo "$port" | xargs)
    check_type=$(echo "$check_type" | xargs)
    check_target=$(echo "$check_target" | xargs)
    max_wait=$(echo "$max_wait" | xargs)
}

# 轮询等待单个服务就绪
wait_ready() {
    local tag=$1 mgr=$2 name=$3 port=$4 check_type=$5 check_target=$6 max_wait=$7
    local waited=0

    while (( waited < max_wait )); do
        case "$check_type" in
            mysql)
                if [[ "$mgr" == "docker" ]]; then
                    docker exec "$name" $check_target &>/dev/null && return 0
                else
                    mysqladmin ping -h localhost &>/dev/null && return 0
                fi
                ;;
            redis)
                redis-cli -h "${check_target%%:*}" -p "${check_target##*:}" ping 2>/dev/null | grep -qi pong && return 0
                ;;
            http)
                curl -s -o /dev/null -w "%{http_code}" "$check_target" 2>/dev/null | grep -qE "^(200|30[12])$" && return 0
                ;;
            tcp)
                port_listening "$check_target" && return 0
                ;;
            pidfile)
                test -f "$check_target" && kill -0 "$(cat "$check_target")" 2>/dev/null && return 0
                ;;
            docker-health)
                docker_healthy "$check_target" 2>/dev/null && return 0
                # fallback: check if running
                docker inspect --format='{{.State.Running}}' "$check_target" 2>/dev/null | grep -q "true" && return 0
                ;;
        esac
        sleep 1
        ((waited++))
    done
    return 1
}

# 获取进程 PID（通过端口）
pid_by_port() {
    lsof -iTCP:"$1" -sTCP:LISTEN -t -nP 2>/dev/null | head -1
}

# 获取进程命令行
cmd_by_port() {
    local pid; pid=$(pid_by_port "$1")
    test -n "$pid" && ps -p "$pid" -o command= 2>/dev/null | head -1 || echo "-"
}
