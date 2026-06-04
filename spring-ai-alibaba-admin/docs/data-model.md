# Spring AI Alibaba Admin — 核心数据模型

> 来源：SQL 建表脚本（`docker/middleware/init/mysql/`）、JPA/MyBatis Entity 类、DTO 类  
> 共 **27 张表**，分属 **4 大域**，分布在 2 个数据库（`admin` / `agentscope`）

---

## 域一：Agent 平台（agentscope 库）

### 1. account — 用户账户

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **account_id** | VARCHAR(64) UNIQUE | 账户唯一标识 |
| username | VARCHAR(64) | 用户名 |
| password | VARCHAR(255) | 密码（Argon2 哈希） |
| email | VARCHAR(128) | 邮箱 |
| mobile | VARCHAR(32) | 手机号 |
| nickname | VARCHAR(128) | 昵称 |
| icon | VARCHAR(255) | 头像 URL |
| type | TINYINT | **AccountType**: ADMIN(1)=管理员, USER(0)=普通用户 |
| status | TINYINT | **AccountStatus**: 0=删除, 1=正常, 2=禁用 |
| gmt_last_login | DATETIME | 最后登录时间 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键关系**: 无（顶层实体，被 workspace 和 api_key 引用）

---

### 2. workspace — 工作空间

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **workspace_id** | VARCHAR(64) UNIQUE | 工作空间唯一标识 |
| account_id | VARCHAR(64) | **FK → account.account_id** |
| name | VARCHAR(255) | 工作空间名称 |
| description | VARCHAR(500) | 描述 |
| config | TEXT (JSON) | 工作空间配置 |
| status | TINYINT | **CommonStatus**: 0=删除, 1=正常 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `account_id` → `account.account_id`

---

### 3. application — 应用（Agent / Workflow）

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **app_id** | VARCHAR(64) UNIQUE | 应用唯一标识 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| name | VARCHAR(255) | 应用名称 |
| description | VARCHAR(500) | 描述 |
| icon | VARCHAR(255) | 图标 URL |
| source | VARCHAR(32) | 来源（console/graph-studio/import） |
| type | TINYINT | **AppType**: 1=Agent(basic), 2=Workflow |
| status | TINYINT | **AppStatus**: 0=删除, 1=草稿, 2=已发布, 3=发布后编辑中 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`

---

### 4. application_version — 应用版本

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| app_id | VARCHAR(64) | **FK → application.app_id** |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| version | VARCHAR(32) | 版本号（默认 "0.0.1"） |
| config | LONGTEXT (JSON) | 应用配置（Agent/Workflow 定义） |
| status | TINYINT | **AppStatus**: 1=草稿, 2=已发布 |
| description | VARCHAR(500) | 版本描述 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `app_id` → `application.app_id`, `workspace_id` → `workspace.workspace_id`

---

### 5. application_component — 应用组件

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| code | VARCHAR(64) | 组件编码 |
| name | VARCHAR(255) | 组件名称 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| type | VARCHAR(32) | 组件类型 |
| app_id | VARCHAR(64) | 关联应用 ID |
| config | LONGTEXT (JSON) | 组件配置 |
| description | VARCHAR(500) | 描述 |
| status | TINYINT | 0=删除, 1=正常, 2=已发布 |
| need_update | TINYINT | 是否需要更新 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`

---

### 6. plugin — 插件

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **plugin_id** | VARCHAR(64) UNIQUE | 插件唯一标识 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| name | VARCHAR(255) | 插件名称 |
| description | VARCHAR(500) | 描述 |
| type | VARCHAR(32) | **PluginType**: official=官方, custom=自定义 |
| status | TINYINT | **PluginStatus**: 0=删除, 1=正常 |
| config | TEXT (JSON) | 插件配置 |
| source | VARCHAR(32) | 来源 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`

---

### 7. tool — 工具（属于插件）

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **tool_id** | VARCHAR(64) UNIQUE | 工具唯一标识 |
| plugin_id | VARCHAR(64) | **FK → plugin.plugin_id** |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| name | VARCHAR(255) | 工具名称 |
| description | VARCHAR(500) | 描述 |
| config | LONGTEXT (JSON) | 工具配置 |
| api_schema | LONGTEXT (JSON) | API Schema（OpenAPI 格式） |
| status | TINYINT | **ToolStatus**: 0=删除, 1=草稿, 2=已发布, 3=发布后编辑 |
| enabled | BOOLEAN | 是否启用 |
| test_status | TINYINT | **ToolTestStatus**: 1=未测试, 2=通过, 3=失败 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `plugin_id` → `plugin.plugin_id`, `workspace_id` → `workspace.workspace_id`

> **⚠️ 注意：同一张 `tool` 表承载两种使用场景**
> - **插件内工具**：`plugin_id` 有值，通过 `/console/v1/plugins/{pluginId}/tools` 管理，API 使用 `Tool` DTO（`runtime/domain/plugin/`）
> - **独立工具**：`plugin_id = NULL`，通过 `/console/v1/tools` 管理，API 使用 `ToolEntity`（`core/base/entity/`）
> - 两者字段结构完全相同，区别仅在于 `plugin_id` 是否为 NULL

---

### 8. knowledge_base — 知识库

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **kb_id** | VARCHAR(64) UNIQUE | 知识库唯一标识 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| name | VARCHAR(255) | 知识库名称 |
| type | VARCHAR(32) | **KnowledgeBaseType**: unstructured=非结构化, structured=结构化 |
| status | TINYINT | **CommonStatus**: 0=删除, 1=正常 |
| process_config | TEXT (JSON) | 处理配置（分块策略） |
| index_config | TEXT (JSON) | 索引配置 |
| search_config | TEXT (JSON) | 检索配置 |
| total_docs | BIGINT | 文档总数 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`

---

### 9. document — 文档（属于知识库）

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **doc_id** | VARCHAR(64) UNIQUE | 文档唯一标识 |
| kb_id | VARCHAR(64) | **FK → knowledge_base.kb_id** |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| name | VARCHAR(255) | 文档名称 |
| type | VARCHAR(32) | **DocumentType**: file=文件, url=URL, oss=OSS |
| format | VARCHAR(32) | 文件格式（pdf/docx/md/txt） |
| size | BIGINT | 文件大小（字节） |
| metadata | TEXT (JSON) | 元数据 |
| status | TINYINT | **CommonStatus**: 0=删除, 1=正常 |
| enabled | BOOLEAN | 是否启用 |
| index_status | TINYINT | **DocumentIndexStatus**: 1=待处理, 2=处理中, 3=已完成, 4=失败 |
| path | VARCHAR(500) | 文件存储路径 |
| parsed_path | VARCHAR(500) | 解析后路径 |
| process_config | TEXT (JSON) | 处理配置 |
| source | VARCHAR(32) | 来源 |
| error | TEXT | 错误信息 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `kb_id` → `knowledge_base.kb_id`, `workspace_id` → `workspace.workspace_id`

---

### 10. mcp_server — MCP 服务器

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| server_code | VARCHAR(64) | MCP Server 编码 |
| name | VARCHAR(255) | 名称 |
| description | VARCHAR(500) | 描述 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| account_id | VARCHAR(64) | **FK → account.account_id** |
| type | VARCHAR(32) | OFFICIAL=官方, CUSTOMER=自定义 |
| status | TINYINT | 0=不可用, 1=正常, 3=删除 |
| deploy_env | VARCHAR(32) | 部署环境 |
| deploy_config | TEXT (JSON) | 部署配置 |
| detail_config | TEXT (JSON) | 详细配置 |
| host | VARCHAR(255) | 主机地址 |
| install_type | VARCHAR(32) | 安装方式：npx / uvx / sse |
| biz_type | VARCHAR(64) | 业务类型 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |

**外键**: `workspace_id` → `workspace.workspace_id`, `account_id` → `account.account_id`

---

### 11. provider — 模型提供商

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| name | VARCHAR(255) | 提供商名称 |
| provider | VARCHAR(64) | 提供商编码 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| icon | VARCHAR(255) | 图标 URL |
| enable | BOOLEAN | 是否启用 |
| protocol | VARCHAR(32) | 协议（默认 openai） |
| source | VARCHAR(32) | preset=预设, custom=自定义 |
| credential | TEXT (JSON) | 凭证信息 |
| supported_model_types | VARCHAR(255) | 支持的模型类型 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`

---

### 12. model — 模型

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| model_id | VARCHAR(64) | 模型 ID |
| name | VARCHAR(255) | 模型名称 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| provider | VARCHAR(64) | **FK → provider.provider** |
| type | VARCHAR(32) | 模型类型（默认 LLM） |
| mode | VARCHAR(32) | 模式（默认 chat） |
| tags | VARCHAR(255) | 标签 |
| enable | BOOLEAN | 是否启用 |
| source | VARCHAR(32) | preset=预设, custom=自定义 |
| icon | VARCHAR(255) | 图标 URL |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`, `provider` → `provider.provider`

---

### 13. api_key — API 密钥

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **api_key** | VARCHAR(255) UNIQUE | API Key 值 |
| account_id | VARCHAR(64) | **FK → account.account_id** |
| status | TINYINT | **CommonStatus**: 0=删除, 1=正常 |
| description | VARCHAR(500) | 描述 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `account_id` → `account.account_id`

---

### 14. agent_schema — Agent 定义（YAML Schema）

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **agent_id** | VARCHAR(64) UNIQUE | Agent 唯一标识 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| name | VARCHAR(255) | Agent 名称 |
| description | VARCHAR(500) | 描述 |
| type | VARCHAR(32) | **AgentType**: ReactAgent / ParallelAgent / SequentialAgent / LLMRoutingAgent / LoopAgent |
| instruction | TEXT | 指令文本 |
| input_keys | TEXT (JSON) | 输入参数定义 |
| output_key | VARCHAR(64) | 输出参数名 |
| handle | LONGTEXT | 处理逻辑代码 |
| sub_agents | LONGTEXT (JSON) | 子 Agent 列表 |
| yaml_schema | LONGTEXT | YAML 格式 Agent 定义 |
| status | VARCHAR(32) | **AgentStatus**: DRAFT / PUBLISHED / ARCHIVED |
| enabled | BOOLEAN | 是否启用 |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |
| creator / modifier | VARCHAR(64) | 创建人/修改人 |

**外键**: `workspace_id` → `workspace.workspace_id`

---

### 15. reference — 实体引用（通用关联表）

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| main_code | VARCHAR(64) | 主实体编码 |
| main_type | TINYINT | 主实体类型（1=应用, 2=知识库...） |
| refer_code | VARCHAR(64) | 被引用实体编码 |
| refer_type | TINYINT | 被引用实体类型 |
| workspace_id | VARCHAR(64) | **FK → workspace.workspace_id** |
| gmt_create / gmt_modified | DATETIME | 创建/修改时间 |

**外键**: `workspace_id` → `workspace.workspace_id`（多态关联，无数据库级 FK）

---

## 域二：Prompt 管理（admin 库）

### 16. prompt — Prompt 定义

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **prompt_key** | VARCHAR(128) UNIQUE | Prompt 唯一标识 |
| prompt_desc | VARCHAR(500) | 描述 |
| latest_version | VARCHAR(32) | 最新版本号 |
| tags | VARCHAR(255) | 标签 |
| create_time / update_time | DATETIME | 创建/更新时间 |

---

### 17. prompt_version — Prompt 版本

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| version | VARCHAR(32) | 版本号 |
| prompt_key | VARCHAR(128) | **FK → prompt.prompt_key** |
| version_desc | VARCHAR(500) | 版本描述 |
| template | LONGTEXT | Prompt 模板内容 |
| variables | TEXT (JSON) | 变量定义 |
| model_config | TEXT (JSON) | 模型配置 |
| previous_version | VARCHAR(32) | 前一个版本 |
| status | VARCHAR(32) | pre=预发布, release=正式 |
| create_time | DATETIME | 创建时间 |

**外键**: `prompt_key` → `prompt.prompt_key`

---

### 18. prompt_build_template — Prompt 预构建模板

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **prompt_template_key** | VARCHAR(128) UNIQUE | 模板唯一标识 |
| template_desc | VARCHAR(500) | 模板描述 |
| tags | VARCHAR(255) | 标签 |
| template | LONGTEXT | 模板内容 |
| variables | TEXT (JSON) | 变量定义 |
| model_config | TEXT (JSON) | 模型配置 |

---

## 域三：数据集与评估（admin 库）

### 19. dataset — 数据集

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| name | VARCHAR(255) | 数据集名称 |
| description | VARCHAR(500) | 描述 |
| columns_config | TEXT (JSON) | 列定义（字段名/类型/格式） |
| deleted | TINYINT | 软删除标记 |
| create_time / update_time | DATETIME | 创建/更新时间 |

---

### 20. dataset_version — 数据集版本

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| dataset_id | BIGINT | **FK → dataset.id** |
| version | VARCHAR(32) | 版本号 |
| description | VARCHAR(500) | 版本描述 |
| data_count | INT | 数据项数量 |
| status | VARCHAR(32) | **VersionStatus**: DRAFT / PUBLISHED / ARCHIVED |
| experiments | TEXT (JSON) | 关联实验列表（JSON 嵌入） |
| dataset_items | TEXT (JSON) | 包含的数据项 ID 列表（JSON 嵌入） |
| create_time / update_time | DATETIME | 创建/更新时间 |

**外键**: `dataset_id` → `dataset.id`

---

### 21. dataset_item — 数据集条目

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| dataset_id | BIGINT | **FK → dataset.id** |
| columns_config | TEXT (JSON) | 列配置 |
| data_content | TEXT (JSON) | 数据内容 |
| deleted | TINYINT | 软删除标记 |
| create_time / update_time | DATETIME | 创建/更新时间 |

**外键**: `dataset_id` → `dataset.id`

---

### 22. evaluator — 评估器

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| name | VARCHAR(255) | 评估器名称 |
| description | VARCHAR(500) | 描述 |
| deleted | TINYINT | 软删除标记 |
| create_time / update_time | DATETIME | 创建/更新时间 |

---

### 23. evaluator_version — 评估器版本

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| evaluator_id | BIGINT | **FK → evaluator.id** |
| description | VARCHAR(500) | 描述 |
| version | VARCHAR(32) | 版本号 |
| model_config | TEXT (JSON) | 模型配置 |
| prompt | TEXT (JSON) | 评估 Prompt |
| variables | TEXT (JSON) | 变量定义 |
| status | VARCHAR(32) | **VersionStatus**: DRAFT / PUBLISHED / ARCHIVED |
| experiments | TEXT (JSON) | 关联实验列表 |
| create_time / update_time | DATETIME | 创建/更新时间 |

**外键**: `evaluator_id` → `evaluator.id`

---

### 24. evaluator_template — 评估器模板

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **evaluator_template_key** | VARCHAR(128) UNIQUE | 模板唯一标识 |
| template_desc | VARCHAR(500) | 模板描述 |
| template | LONGTEXT | 评估模板内容 |
| variables | TEXT (JSON) | 变量定义 |
| model_config | TEXT (JSON) | 模型配置 |

---

### 25. experiment — 实验

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| name | VARCHAR(255) | 实验名称 |
| description | VARCHAR(500) | 描述 |
| dataset_id | BIGINT | **FK → dataset.id** |
| dataset_version_id | BIGINT | **FK → dataset_version.id** |
| dataset_version | VARCHAR(32) | 版本快照 |
| evaluation_object_config | TEXT (JSON) | 评估对象配置 |
| evaluator_config | TEXT (JSON) | 评估器配置 |
| status | VARCHAR(32) | **ExperimentStatus**: DRAFT / RUNNING / COMPLETED / FAILED / STOPPED |
| progress | INT | 进度（0-100） |
| complete_time | DATETIME | 完成时间 |
| create_time / update_time | DATETIME | 创建/更新时间 |

**外键**: `dataset_id` → `dataset.id`, `dataset_version_id` → `dataset_version.id`

---

### 26. experiment_result — 实验结果

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| experiment_id | BIGINT | **FK → experiment.id** |
| evaluator_version_id | BIGINT | **FK → evaluator_version.id** |
| input | LONGTEXT | 输入内容 |
| actual_output | LONGTEXT | 实际输出 |
| reference_output | LONGTEXT | 参考输出 |
| score | DECIMAL(3,2) | 评分（0.00 - 1.00） |
| reason | TEXT | 评分原因 |
| evaluation_time | DATETIME | 评估时间 |
| create_time / update_time | DATETIME | 创建/更新时间 |

**外键**: `experiment_id` → `experiment.id`, `evaluator_version_id` → `evaluator_version.id`

---

## 域四：模型配置（admin 库）

### 27. model_config — 模型连接配置

| 字段 | 类型 | 说明 |
|------|------|------|
| **id** | BIGINT (PK, AUTO_INCREMENT) | 主键 |
| **name** | VARCHAR(100) NOT NULL UNIQUE | 配置名称 |
| provider | VARCHAR(50) NOT NULL | 提供商编码 |
| model_name | VARCHAR(100) NOT NULL | 模型名称 |
| base_url | VARCHAR(500) NOT NULL | API Base URL |
| api_key | VARCHAR(500) NOT NULL | API Key |
| default_parameters | TEXT (JSON) | 默认参数 |
| supported_parameters | TEXT (JSON) | 支持的参数列表 |
| status | TINYINT (default 1) | 0=禁用, 1=启用 |
| deleted | TINYINT | 软删除标记 |
| create_time / update_time | DATETIME | 创建/更新时间 |

---

## 附录 A：全部枚举值

| 枚举名 | 值 |
|--------|-----|
| **AccountType** | ADMIN("admin"), USER("user") |
| **AccountStatus** | 0=deleted, 1=normal, 2=disabled |
| **AppType** | 1=basic(Agent), 2=workflow |
| **AppStatus** | 0=deleted, 1=draft, 2=published, 3=published_editing |
| **CommonStatus** | 0=deleted, 1=normal |
| **PluginType** | official, custom |
| **PluginStatus** | 0=deleted, 1=normal |
| **ToolStatus** | 0=deleted, 1=draft, 2=published, 3=published_editing |
| **ToolTestStatus** | 1=not_test, 2=passed, 3=failed |
| **KnowledgeBaseType** | unstructured, structured |
| **DocumentType** | file, url, oss |
| **DocumentIndexStatus** | 1=uploaded, 2=processing, 3=processed, 4=failed |
| **AgentType** | ReactAgent, ParallelAgent, SequentialAgent, LLMRoutingAgent, LoopAgent |
| **AgentStatus** | active, inactive, configuring, error |
| **VersionStatus** | DRAFT, PUBLISHED, ARCHIVED |
| **PromptVersionStatus** | pre, release |
| **ExperimentStatus** | DRAFT, RUNNING, COMPLETED, FAILED, STOPPED |

---

## 附录 B：数据库分布

| 数据库 | 表数 | 用途 |
|--------|------|------|
| **agentscope** | 15 张 | Agent 平台核心数据：账户/空间/应用/插件/工具/知识库/MCP/模型/Agent定义/关联 |
| **admin** | 12 张 | 评估系统 + Prompt 管理：数据集/评估器/实验/Prompt/模型配置 |
| **合计** | **27 张** | 15 + 12 |

---

## 附录 C：ORM 映射

| 数据库 | ORM 框架 | Entity 包路径 |
|--------|----------|--------------|
| agentscope | MyBatis Plus (`@TableName`) | `com.alibaba.cloud.ai.studio.core.base.entity` |
| admin | Spring Data JPA (`@Table`) | `com.alibaba.cloud.ai.studio.admin.entity` |

---

## 附录 D：API-list 中出现但本模型未详述的类型

以下类型出现在 API 接口的入参/返回中，但 **不是数据库实体**，属于内部 DTO 或 Controller 内部类：

| 类型 | 出现位置 | 实际定义 |
|------|---------|---------|
| `GlobalConfig` | `GET /console/v1/system/global-config` | `SystemController` 内部类，系统全局配置 |
| `ModelProviderGroup` | `GET /console/v1/models/{modelType}/selector` | `ModelController` 内部类，模型分组 |
| `LimitEntity` | `RedisManager` 限流 | 纯 POJO（无 `@TableName`），存 Redis 不存 DB |

以上三个类型无需数据模型表级定义。
