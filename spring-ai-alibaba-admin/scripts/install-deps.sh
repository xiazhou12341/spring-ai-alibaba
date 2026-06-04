#!/bin/bash
###############################################################################
# Spring AI Alibaba Admin — 本地环境依赖一键安装脚本
# 平台：macOS (brew + docker)
# 策略：brew 装 Redis，其余中间件统一用 Docker（MySQL brew 在 ARM64 编译失败）
# 日志：scripts/install-log.md
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$SCRIPT_DIR/install-log.md"

ADMIN_SQL="$PROJECT_DIR/docker/middleware/init/mysql/admin-schema.sql"
AGENT_SQL="$PROJECT_DIR/docker/middleware/init/mysql/agentscope-schema.sql"
LC_CONF="$PROJECT_DIR/docker/middleware/conf/loongcollector"

log()  { echo ">>> $*"; }
warn() { echo "⚠️  $*"; }
fail() { echo "❌ $*"; }
ok()   { echo "✅ $*"; }

echo "========================================"
echo "  Spring AI Alibaba Admin"
echo "  本地环境依赖安装 (macOS + Docker)"
echo "========================================"
echo ""

# ===== 0. Docker check =====
log "--- 检查 Docker ---"
if ! docker info &>/dev/null; then
    log "Docker 未运行，正在启动..."
    open -a Docker
    for i in $(seq 1 30); do
        docker info &>/dev/null && { ok "Docker 已就绪"; break; }
        sleep 2
    done
    docker info &>/dev/null || { fail "Docker 无法启动，请手动打开 Docker Desktop"; exit 1; }
fi

# ===== 1. JDK 17 =====
log ""
log "--- JDK 17 ---"
if java -version 2>&1 | grep -q "17\."; then
    ok "JDK 17 已安装: $(java -version 2>&1 | head -1)"
else
    log "安装 JDK 17..."
    brew install openjdk@17
    sudo ln -sf /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
    ok "JDK 17 安装完成"
fi

# ===== 2. MySQL 8.0 (Docker) =====
log ""
log "--- MySQL 8.0 (Docker) ---"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q mysql; then
    ok "MySQL 已运行"
else
    docker rm -f mysql 2>/dev/null || true
    docker pull mysql:8.0.35
    docker run -d --name mysql -p 3306:3306 \
        -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_DATABASE=admin \
        -e MYSQL_USER=admin -e MYSQL_PASSWORD=admin \
        --health-cmd="mysqladmin ping -h localhost" \
        --health-interval=5s --health-timeout=10s --health-retries=10 \
        mysql:8.0.35
    for i in $(seq 1 30); do
        docker exec mysql mysqladmin ping -h localhost &>/dev/null && { ok "MySQL 就绪"; break; }
        sleep 2
    done
fi

# MySQL init
log "初始化数据库..."
for auth in "-u root -padmin" "-u root" "-u admin -padmin"; do
    docker exec mysql mysql $auth -e "SELECT 1" &>/dev/null && { MYSQL_AUTH="$auth"; break; }
done
docker exec mysql mysql $MYSQL_AUTH -e "CREATE DATABASE IF NOT EXISTS agentscope DEFAULT CHARSET utf8mb4;"
docker exec -i mysql mysql $MYSQL_AUTH agentscope < "$AGENT_SQL"
docker exec -i mysql mysql $MYSQL_AUTH admin < "$ADMIN_SQL"
ok "MySQL 初始化完成 ($(docker exec mysql mysql $MYSQL_AUTH -e "SHOW DATABASES;" 2>/dev/null | grep -c -E 'admin|agentscope') 个库)"

# ===== 3. Redis (brew) =====
log ""
log "--- Redis ---"
if redis-cli ping 2>/dev/null | grep -q "PONG"; then
    ok "Redis 已运行"
else
    brew list redis &>/dev/null || brew install redis
    brew services start redis
    sleep 2
    redis-cli ping && ok "Redis 就绪"
fi

# ===== 4. Nacos (Docker) =====
log ""
log "--- Nacos (Docker) ---"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q nacos; then
    ok "Nacos 已运行"
else
    docker rm -f nacos 2>/dev/null || true
    docker pull nacos/nacos-server:latest
    docker run -d --name nacos -p 8848:8848 -p 9848:9848 -p 7848:7848 \
        -e MODE=standalone \
        -e NACOS_AUTH_TOKEN=dG9rZW5hbHNka2ZqbGFza2RqZmxhc2tkamZsYXNrZGpmb3dpZWpmbztzZGxm \
        -e NACOS_AUTH_IDENTITY_KEY=admin -e NACOS_AUTH_IDENTITY_VALUE=admin \
        nacos/nacos-server:latest
    for i in $(seq 1 20); do
        curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8848/nacos/ 2>/dev/null | grep -q "200" && { ok "Nacos 就绪"; break; }
        sleep 3
    done
fi

# ===== 5. Elasticsearch (Docker) =====
log ""
log "--- Elasticsearch (Docker) ---"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q elasticsearch; then
    ok "Elasticsearch 已运行"
else
    docker rm -f elasticsearch 2>/dev/null || true
    docker pull docker.elastic.co/elasticsearch/elasticsearch:9.1.2
    docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 \
        -e "discovery.type=single-node" -e "xpack.security.enabled=false" \
        -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
        docker.elastic.co/elasticsearch/elasticsearch:9.1.2
    for i in $(seq 1 30); do
        curl -s http://127.0.0.1:9200/_cluster/health 2>/dev/null | grep -q '"status":"green"' && { ok "Elasticsearch 就绪"; break; }
        sleep 2
    done
fi

# ===== 6. Kibana (Docker) =====
log ""
log "--- Kibana (Docker) ---"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q kibana; then
    ok "Kibana 已运行"
else
    docker rm -f kibana 2>/dev/null || true
    docker pull docker.elastic.co/kibana/kibana:9.1.2
    docker run -d --name kibana -p 5601:5601 \
        -e "ELASTICSEARCH_HOSTS=http://host.docker.internal:9200" \
        -e "xpack.security.enabled=false" \
        docker.elastic.co/kibana/kibana:9.1.2
    for i in $(seq 1 15); do
        curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5601/api/status 2>/dev/null | grep -q "200" && { ok "Kibana 就绪"; break; }
        sleep 4
    done
fi

# ===== 7. RocketMQ (Docker) =====
log ""
log "--- RocketMQ (Docker) ---"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q rmq_namesrv; then
    ok "RocketMQ 已运行"
else
    docker rm -f rmq_namesrv rmq_broker rmq_proxy 2>/dev/null || true
    docker pull apache/rocketmq:5.3.2
    docker run -d --name rmq_namesrv -p 9876:9876 \
        -e "JAVA_OPT_EXT=-Xms128M -Xmx256M -Xmn128M" \
        apache/rocketmq:5.3.2 sh mqnamesrv
    sleep 3
    docker run -d --name rmq_broker -p 10909:10909 -p 10911:10911 -p 10912:10912 \
        -e "NAMESRV_ADDR=host.docker.internal:9876" \
        -e "JAVA_OPT_EXT=-Xms256M -Xmx512M -Xmn256M" \
        apache/rocketmq:5.3.2 sh mqbroker
    sleep 3
    docker run -d --name rmq_proxy -p 18080:18080 -p 18081:18081 \
        -e "NAMESRV_ADDR=host.docker.internal:9876" \
        -e "JAVA_OPT_EXT=-Xms128M -Xmx256M -Xmn128M" \
        apache/rocketmq:5.3.2 sh mqproxy
    sleep 3
    docker exec rmq_broker sh mqadmin updateTopic -n host.docker.internal:9876 -t topic_saa_studio_document_index -c DefaultCluster 2>/dev/null
    docker exec rmq_broker sh mqadmin updateSubGroup -n host.docker.internal:9876 -g group_saa_studio_document_index -c DefaultCluster 2>/dev/null
    ok "RocketMQ 就绪 (NameServer+Broker+Proxy, Topic 已创建)"
fi

# ===== 8. LoongCollector (Docker) =====
log ""
log "--- LoongCollector (Docker) ---"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q loongcollector; then
    ok "LoongCollector 已运行"
else
    docker rm -f loongcollector 2>/dev/null || true
    docker pull sls-opensource-registry.cn-shanghai.cr.aliyuncs.com/loongcollector-community-edition/loongcollector:3.1.4
    docker run -d --name loongcollector -p 4318:4318 \
        -v "${LC_CONF}:/usr/local/loongcollector/conf/continuous_pipeline_config/local" \
        sls-opensource-registry.cn-shanghai.cr.aliyuncs.com/loongcollector-community-edition/loongcollector:3.1.4
    ok "LoongCollector 就绪"
fi

# ===== Summary =====
echo ""
echo "========================================"
echo "  安装完成！"
echo "========================================"
echo ""
echo "📋 运行中的容器:"
docker ps --format "  {{.Names}}: {{.Status}}" | grep -E 'mysql|redis|nacos|elastic|kibana|rmq|loong' || true
echo ""
echo "📄 详细日志: $LOG_FILE"
echo ""
echo "🚀 启动后端:"
echo "  export SPRING_DATASOURCE_URL='jdbc:mysql://127.0.0.1:3306/admin?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&allowMultiQueries=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai'"
echo "  export SPRING_DATASOURCE_USERNAME='admin'"
echo "  export SPRING_DATASOURCE_PASSWORD='admin'"
echo "  export SPRING_REDIS_HOST='127.0.0.1'"
echo "  export SPRING_ELASTICSEARCH_URIS='http://127.0.0.1:9200'"
echo "  export NACOS_SERVER_ADDR='127.0.0.1:8848'"
echo "  export ROCKETMQ_ENDPOINTS='127.0.0.1:18080'"
echo "  export MANAGEMENT_OTLP_TRACING_EXPORT_ENDPOINT='http://127.0.0.1:4318/v1/traces'"
echo "  cd spring-ai-alibaba-admin-server-start && mvn spring-boot:run"
echo ""
