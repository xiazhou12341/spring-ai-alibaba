# Spring AI Alibaba Admin — 环境依赖安装日志

> 生成时间: 2026-06-03
> 平台: arm64 macOS (Darwin 25.5.0, Apple Silicon M1)
> Homebrew: 5.1.14

---

## 安装记录

### JDK 17

- **安装命令**: 已存在（Temurin 17.0.18+8）
- **版本**: OpenJDK 17.0.18
- **问题与修复**: 无，已安装

---

### MySQL 8.0

- **安装命令**: `docker run mysql:8.0.35`
- **版本**: 8.0.35 (Docker)
- **端口**: 3306
- **初始化**: 
  - 建库: `admin`, `agentscope`（均含默认 admin/admin 账号）
  - 导入 agentscope-schema.sql → 15 张表
  - 导入 admin-schema.sql → 12 张表
- **问题与修复**: 
  1. `brew install mysql@8.0` → ARM64 编译失败（非 Tier 1 架构）
  2. `brew install mysql@8.4` → 同样编译失败
  3. 改用 Docker 方式：`docker run mysql:8.0.35` → 成功
  4. 初次导入 agentscope-schema.sql 时 `SHOW TABLES` 显示 0 表 → 用 `docker exec -i` 重新导入后确认 15 张表

---

### Redis

- **安装命令**: `brew install redis` + `brew services start redis`
- **版本**: 最新版（brew 无 redis@7）
- **端口**: 6379
- **初始化**: 无（启动即用）
- **问题与修复**: 无

---

### Nacos 2.x

- **安装命令**: `docker run nacos/nacos-server:latest`
- **版本**: latest (2.x)
- **端口**: 8848 (HTTP), 9848 (gRPC), 7848
- **初始化**: 单机模式，无需额外配置
- **问题与修复**:
  1. 首次启动失败：`env NACOS_AUTH_TOKEN must be set with Base64 String`
  2. 添加 `-e NACOS_AUTH_TOKEN=dG9rZW5hbHNka2ZqbGFza2RqZmxhc2tkamZsYXNrZGpmb3dpZWpmbztzZGxm` 环境变量后成功

---

### Elasticsearch 9.x

- **安装命令**: `docker run docker.elastic.co/elasticsearch/elasticsearch:9.1.2`
- **版本**: 9.1.2 (Docker)
- **端口**: 9200 (HTTP), 9300 (Transport)
- **初始化**: `xpack.security.enabled=false`, 集群状态 green
- **问题与修复**: 无

---

### Kibana 9.x

- **安装命令**: `docker run docker.elastic.co/kibana/kibana:9.1.2`
- **版本**: 9.1.2 (Docker)
- **端口**: 5601
- **初始化**: `ELASTICSEARCH_HOSTS=http://host.docker.internal:9200`, `xpack.security.enabled=false`
- **问题与修复**: 无

---

### RocketMQ 5.3

- **安装命令**: `docker run apache/rocketmq:5.3.2`（NameServer + Broker + Proxy 三个容器）
- **版本**: 5.3.2 (Docker)
- **端口**: 9876 (NameServer), 10909/10911/10912 (Broker), 18080 (Proxy)
- **初始化**: 
  - 创建 Topic: `topic_saa_studio_document_index`
  - 创建 ConsumerGroup: `group_saa_studio_document_index`
- **问题与修复**: 无

---

### LoongCollector 3.1.4

- **安装命令**: `docker run sls-opensource-registry.cn-shanghai.cr.aliyuncs.com/loongcollector-community-edition/loongcollector:3.1.4`
- **版本**: 3.1.4 (Docker)
- **端口**: 4318 (OTLP HTTP)
- **初始化**: 挂载项目配置文件 `docker/middleware/conf/loongcollector/`
- **问题与修复**: 无

---

## 最终状态汇总

| 中间件 | 安装方式 | 版本 | 端口 | 状态 |
|--------|---------|------|------|------|
| JDK | 已存在 | 17.0.18 (Temurin) | — | ✅ |
| MySQL | Docker | 8.0.35 | 3306 | ✅ 15+12 表 |
| Redis | brew | 最新版 | 6379 | ✅ |
| Nacos | Docker | latest (2.x) | 8848 | ✅ |
| Elasticsearch | Docker | 9.1.2 | 9200 | ✅ green |
| Kibana | Docker | 9.1.2 | 5601 | ✅ |
| RocketMQ | Docker | 5.3.2 | 9876/18080 | ✅ Topic 已创建 |
| LoongCollector | Docker | 3.1.4 | 4318 | ✅ |

## 关键问题总结

1. **MySQL ARM64 编译失败**: brew 的 mysql@8.0 和 mysql@8.4 均无法在 Apple Silicon 上从源码编译，改用 Docker 解决
2. **Redis 版本**: brew 无 redis@7，使用最新版 redis（向后兼容）
3. **Nacos AUTH_TOKEN**: 新版 Nacos 强制要求设置 NACOS_AUTH_TOKEN 环境变量
4. **其余中间件**（ES/Kibana/RocketMQ/LoongCollector）: brew 均不可用，统一使用 Docker

## 环境变量配置

启动后端前需要设置：
```shell
export SPRING_DATASOURCE_URL="jdbc:mysql://127.0.0.1:3306/admin?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&allowMultiQueries=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai"
export SPRING_DATASOURCE_USERNAME="admin"
export SPRING_DATASOURCE_PASSWORD="admin"
export SPRING_REDIS_HOST="127.0.0.1"
export SPRING_REDIS_PORT="6379"
export SPRING_ELASTICSEARCH_URIS="http://127.0.0.1:9200"
export NACOS_SERVER_ADDR="127.0.0.1:8848"
export ROCKETMQ_ENDPOINTS="127.0.0.1:18080"
export MANAGEMENT_OTLP_TRACING_EXPORT_ENDPOINT="http://127.0.0.1:4318/v1/traces"
```

## 容器管理

```shell
# 查看所有容器
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 停止所有
docker stop mysql redis nacos elasticsearch kibana rmq_namesrv rmq_broker rmq_proxy loongcollector

# 启动所有
docker start mysql redis nacos elasticsearch kibana rmq_namesrv rmq_broker rmq_proxy loongcollector
```
