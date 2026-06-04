# Spring AI Alibaba Admin — 环境依赖清单

> 运行本项目需要 **7 类中间件** + **至少 1 个 AI 模型 API**。  
> 来源：`docker-compose-prod.yaml`、`application*.yml`、`pom.xml`、`external-deps.svg`、README。

---

## 一、数据库层

### 1. MySQL

| 项目 | 值 |
|------|-----|
| **版本** | 8.0.x（推荐 8.0.35） |
| **端口** | 3306 |
| **连接 URL** | `jdbc:mysql://{host}:3306/admin?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&allowMultiQueries=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai` |
| **默认账号** | `admin` / `admin` |
| **数据库名** | 需建两个：`admin`（评估+Prompt）+ `agentscope`（Agent 平台） |

**初始化要求**：

```shell
# 建库
mysql -u admin -padmin -e "CREATE DATABASE IF NOT EXISTS admin DEFAULT CHARSET utf8mb4;"
mysql -u admin -padmin -e "CREATE DATABASE IF NOT EXISTS agentscope DEFAULT CHARSET utf8mb4;"

# 导入表结构
mysql -u admin -padmin agentscope < docker/middleware/init/mysql/agentscope-schema.sql
mysql -u admin -padmin admin     < docker/middleware/init/mysql/admin-schema.sql
```

**环境变量**：`SPRING_DATASOURCE_URL`、`SPRING_DATASOURCE_USERNAME`、`SPRING_DATASOURCE_PASSWORD`

---

### 2. Redis

| 项目 | 值 |
|------|-----|
| **版本** | 7.x（推荐 7.2.5） |
| **端口** | 6379 |
| **默认 DB** | 0（可通过 `SPRING_REDIS_DATABASE` 覆盖） |
| **连接** | `SPRING_REDIS_HOST` + `SPRING_REDIS_PORT` |

**用途**：Session 缓存、分布式锁（Redisson）、限流计数器。

**初始化要求**：无（启动即用）。

---

## 二、服务发现与配置

### 3. Nacos

| 项目 | 值 |
|------|-----|
| **版本** | 2.x（docker 使用 `nacos/nacos-server:latest`） |
| **端口** | 8848（HTTP）、9848（gRPC） |
| **连接** | `NACOS_SERVER_ADDR`（如 `127.0.0.1:8848`） |
| **默认认证** | `admin` / `admin`（`NACOS_AUTH_IDENTITY_KEY` / `NACOS_AUTH_IDENTITY_VALUE`） |
| **模式** | 单机（`MODE=standalone`） |

**用途**：动态配置中心、服务注册发现、外部 Agent Prompt 同步。

**初始化要求**：无（首次启动自动初始化，配置由 Spring Boot 启动时自动加载）。

---

## 三、消息与检索

### 4. Elasticsearch

| 项目 | 值 |
|------|-----|
| **版本** | 9.x（推荐 9.1.2） |
| **端口** | 9200（HTTP）、9300（Transport） |
| **连接** | `SPRING_ELASTICSEARCH_URIS`（如 `http://127.0.0.1:9200`） |
| **集群名** | `es-cluster` |
| **安全** | 已关闭（`xpack.security.enabled=false`） |
| **JVM** | 建议 `-Xms1g -Xmx1g` |

**用途**：RAG 向量检索、全文搜索、Trace 索引。

**初始化要求**：

```shell
# ES 启动后自动执行 init-indices.sh 创建索引
# 手动验证
curl http://127.0.0.1:9200/_cat/indices?v
```

---

### 5. RocketMQ

| 组件 | 端口 | 说明 |
|------|------|------|
| **NameServer** | 9876 | 路由中心 |
| **Broker** | 10909/10911/10912 | 消息存储 |
| **Proxy** | 18080 | GRPC 代理（应用连接端） |

| 项目 | 值 |
|------|-----|
| **版本** | 5.3.x（推荐 5.3.2） |
| **连接端点** | `ROCKETMQ_ENDPOINTS`（如 `127.0.0.1:18080`） |
| **默认 Topic** | `topic_saa_studio_document_index` |
| **默认 Consumer Group** | `group_saa_studio_document_index` |

**用途**：文档异步索引、RAG 事件总线。

**初始化要求**：

```shell
# docker-compose 启动时自动创建 Topic
# 手动验证
mqadmin topicList -n 127.0.0.1:9876
```

---

## 四、可观测性

### 6. LoongCollector（OTel 收集器）

| 项目 | 值 |
|------|-----|
| **版本** | 3.1.x（推荐 3.1.4） |
| **端口** | 4318（OTLP HTTP 接收） |
| **连接** | `MANAGEMENT_OTLP_TRACING_EXPORT_ENDPOINT`（如 `http://127.0.0.1:4318/v1/traces`） |
| **输出** | Span → Elasticsearch |

**用途**：OpenTelemetry 链路收集，将应用产生的 Trace 写入 ES 供 Kibana 查看。

**初始化要求**：

```shell
# 依赖 ES 先启动且初始化完成
# 启动后自动加载 conf/loongcollector/otlp_pipeline.yaml 配置
```

---

### 7. Kibana

| 项目 | 值 |
|------|-----|
| **版本** | 与 ES 一致（9.1.2） |
| **端口** | 5601 |
| **连接 ES** | `http://elasticsearch:9200`（docker 内网） |

**用途**：Trace/Span 可视化查询。

**初始化要求**：无（启动后自动连接 ES）。

---

## 五、AI 模型 API（至少配置 1 个）

### 8. 模型提供商

项目支持以下任意一个或多个：

| 提供商 | 用途 | 配置方式 |
|--------|------|---------|
| **OpenAI** | Chat / Embedding / 图像 | `model-config-openai.yaml` |
| **阿里云 DashScope / 百炼** | Chat / Embedding / 视觉模型 | `model-config-dashscope.yaml` |
| **DeepSeek** | 推理模型（V3/R1） | `model-config-deepseek.yaml` |
| **Ollama** | 本地推理模型 | `model-config-ollama.yaml`（需自行配置） |

**初始化要求**：

```shell
# 编辑对应模板
cp model-config-xxx.yaml model-config.yaml
# 填入 API Key 和模型参数
```

**关键配置项**（在 `model-config.yaml` 中）：

```yaml
model:
  provider: dashscope      # 或 openai / deepseek
  model-name: qwen-max     # 具体模型名
  api-key: sk-xxxx         # API Key
  base-url: https://...    # API 地址
```

---

## 六、应用服务自身

### 9. 后端服务

| 项目 | 值 |
|------|-----|
| **端口** | 8080 |
| **启动方式** | `mvn spring-boot:run` |
| **环境变量** | 见下表 |

**必需环境变量**：

```shell
# 数据库
export SPRING_DATASOURCE_URL="jdbc:mysql://127.0.0.1:3306/admin?..."
export SPRING_DATASOURCE_USERNAME="admin"
export SPRING_DATASOURCE_PASSWORD="admin"

# Redis
export SPRING_REDIS_HOST="127.0.0.1"
export SPRING_REDIS_PORT="6379"

# Elasticsearch
export SPRING_ELASTICSEARCH_URIS="http://127.0.0.1:9200"

# Nacos
export NACOS_SERVER_ADDR="127.0.0.1:8848"

# RocketMQ
export ROCKETMQ_ENDPOINTS="127.0.0.1:18080"

# OTel Tracing
export MANAGEMENT_OTLP_TRACING_EXPORT_ENDPOINT="http://127.0.0.1:4318/v1/traces"
```

### 10. 前端服务

| 项目 | 值 |
|------|-----|
| **端口** | 8000 |
| **启动方式** | `cd frontend/packages/main && npm run dev` |
| **代理** | 开发模式下代理 `/console/` `/api/` 请求到 `localhost:8080` |

---

## 七、启动顺序

```
1. MySQL        → 建库 + 导入 schema
2. Redis        → 启动即用
3. Nacos        → 启动即用
4. Elasticsearch → 等待 health check 通过
5. LoongCollector → 等 ES init 完成后启动
6. Kibana       → 等 ES 健康后启动
7. RocketMQ     → NameServer → Broker → Proxy → init-topic
8. 后端         → 设置环境变量 → mvn spring-boot:run
9. 前端         → npm run dev
```

---

## 八、一键启动（Docker Compose）

```shell
# 启动所有中间件（prod 模式 = 全部 7 类）
cd docker/middleware
bash run.sh prod

# 验证全部服务
docker compose -f docker-compose-prod.yaml ps

# 停止
bash stop.sh prod
```

---

## 九、环境自检表

启动后执行以下检查：

| 检查项 | 命令 | 预期 |
|--------|------|------|
| MySQL | `mysql -u admin -padmin -e "SHOW DATABASES"` | `admin`, `agentscope` |
| Redis | `redis-cli -h 127.0.0.1 ping` | `PONG` |
| Nacos | `curl http://127.0.0.1:8848/nacos/` | 200 OK |
| ES | `curl http://127.0.0.1:9200/_cluster/health` | `status: "green"` |
| RocketMQ | `mqadmin topicList -n 127.0.0.1:9876` | 包含 `topic_saa_studio_document_index` |
| LoongCollector | `curl http://127.0.0.1:4318/v1/traces -X POST -d '{}'` | 200 OK |
| Kibana | 浏览器打开 `http://127.0.0.1:5601` | 管理界面 |
| 后端 | `curl http://127.0.0.1:8080/actuator/health` | `{"status":"UP"}` |
| 前端 | 浏览器打开 `http://127.0.0.1:8000` | 登录页面 |
