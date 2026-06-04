# Spring AI Alibaba Admin — REST API 接口清单

> 统计：**32 个 Controller**，**183 个 REST 接口**，覆盖 8 大功能模块

---

## 一、认证与系统（`/console/v1/auth`、`/console/v1/system`、`/oauth2`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/auth/login` | 用户登录 | `LoginRequest` | `Result<TokenResponse>` |
| POST | `/console/v1/auth/refresh-token` | 刷新 Token | `RefreshTokenRequest` | `Result<TokenResponse>` |
| POST | `/console/v1/auth/logout` | 用户登出 | Authorization Header | `Result<Void>` |
| GET | `/console/v1/system/health` | 系统健康检查 | 无 | `String` |
| GET | `/console/v1/system/global-config` | 获取全局配置 | 无 | `Result<GlobalConfig>` |
| GET | `/oauth2/login/github` | GitHub OAuth 登录入口 | 无 | `Result<String>` |
| GET | `/oauth2/callback/github` | GitHub OAuth 回调 | `code` | 重定向 |

---

## 二、应用管理（`/console/v1/apps`、`/graph-studio/api/app`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/apps` | 创建应用 | `Application` | `Result<String>` |
| GET | `/console/v1/apps` | 分页查询应用 | `AppQuery` | `Result<PagingList<Application>>` |
| GET | `/console/v1/apps/{appId}` | 获取应用详情 | `appId` | `Result<Application>` |
| PUT | `/console/v1/apps/{appId}` | 更新应用 | `appId`, `Application` | `Result<String>` |
| DELETE | `/console/v1/apps/{appId}` | 删除应用 | `appId` | `Result<Void>` |
| POST | `/console/v1/apps/{appId}/publish` | 发布应用 | `appId` | `Result<Void>` |
| POST | `/console/v1/apps/{appId}/copy` | 复制应用 | `appId` | `Result<String>` |
| GET | `/console/v1/apps/{appId}/versions` | 查询应用版本列表 | `appId`, `AppQuery` | `Result<PagingList<ApplicationVersion>>` |
| GET | `/console/v1/apps/{appId}/versions/{version}` | 获取应用指定版本 | `appId`, `version` | `Result<ApplicationVersion>` |
| POST | `/console/v1/apps/chat/completions` | 应用对话（SSE 流式） | `AgentRequest` | SseEmitter / JSON |
| POST | `/graph-studio/api/app` | Graph Studio 创建应用 | `CreateAppParam` | `R<App>` |
| GET | `/graph-studio/api/app` | Graph Studio 应用列表 | 无 | `R<List<App>>` |
| GET | `/graph-studio/api/app/{id}` | Graph Studio 应用详情 | `id` | `R<App>` |
| PUT | `/graph-studio/api/app` | Graph Studio 更新应用 | `App` | `R<App>` |
| DELETE | `/graph-studio/api/app/{id}` | Graph Studio 删除应用 | `id` | `R<Boolean>` |
| POST | `/graph-studio/api/dsl/import` | DSL 导入 | `DSLParam` | `R<App>` |
| POST | `/graph-studio/api/dsl/import-file` | DSL 文件导入 | `file`, `dialect` | `R<App>` |
| GET | `/graph-studio/api/dsl/export/{id}` | DSL 导出 | `id`, `dialect` | `R<String>` |
| GET | `/graph-studio/api/dsl/export-file/{id}` | DSL 文件导出 | `id`, `dialect` | `Resource` |
| POST | `/graph-studio/api/run/app/{id}/stream` | Graph Studio 流式运行 | `id`, `inputs` | `Flux<RunEvent>` |
| POST | `/graph-studio/api/run/app/{id}/sync` | Graph Studio 同步运行 | `id`, `inputs` | `R<RunEvent>` |

---

## 三、Prompt 管理（`/api`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/api/prompt` | 创建 Prompt | `PromptCreateRequest` | `Result<Prompt>` |
| PUT | `/api/prompt` | 更新 Prompt | `PromptUpdateRequest` | `Result<Prompt>` |
| GET | `/api/prompt` | 获取 Prompt 详情 | `promptKey` | `Result<Prompt>` |
| DELETE | `/api/prompt` | 删除 Prompt | `promptKey` | `Result<Boolean>` |
| GET | `/api/prompts` | 分页查询 Prompt 列表 | `PromptListRequest` | `Result<PageResult<Prompt>>` |
| POST | `/api/prompt/version` | 创建 Prompt 版本 | `PromptVersionCreateRequest` | `Result<PromptVersion>` |
| GET | `/api/prompt/version` | 获取 Prompt 版本详情 | `promptKey`, `version` | `Result<PromptVersionDetail>` |
| GET | `/api/prompt/versions` | 分页查询版本列表 | `PromptVersionListRequest` | `Result<PageResult<PromptVersion>>` |
| GET | `/api/prompt/template` | 获取 Prompt 模板详情 | `promptTemplateKey` | `Result<PromptTemplateDetail>` |
| GET | `/api/prompt/templates` | 分页查询模板列表 | `PromptTemplateListRequest` | `Result<PageResult<PromptTemplate>>` |
| POST | `/api/prompt/run` | 运行 Prompt（流式） | `PromptRunRequest` | `Flux<PromptRunResponse>` |
| GET | `/api/prompt/session` | 获取会话详情 | `sessionId` | `Result<ChatSession>` |
| DELETE | `/api/prompt/session` | 删除会话 | `sessionId` | `Result<Void>` |

---

## 四、数据集与评估（`/api/dataset`、`/api/evaluator`、`/api/experiment`）

### 4.1 数据集

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/api/dataset/dataset` | 创建数据集 | `DatasetCreateRequest` | `Result<Dataset>` |
| GET | `/api/dataset/datasets` | 分页查询数据集 | `DatasetListRequest` | `Result<PageResult<Dataset>>` |
| GET | `/api/dataset/dataset` | 获取数据集详情 | `datasetId` | `Result<Dataset>` |
| PUT | `/api/dataset/dataset` | 更新数据集 | `DatasetUpdateRequest` | `Result<Dataset>` |
| DELETE | `/api/dataset/dataset` | 删除数据集 | `datasetId` | `Result<Void>` |
| POST | `/api/dataset/datasetVersion` | 创建数据集版本 | `DatasetVersionCreateRequest` | `Result<DatasetVersion>` |
| PUT | `/api/dataset/datasetVersion` | 更新数据集版本 | `DatasetVersionUpdateRequest` | `Result<DatasetVersion>` |
| GET | `/api/dataset/datasetVersions` | 分页查询版本列表 | `DatasetVersionListRequest` | `Result<PageResult<DatasetVersion>>` |
| POST | `/api/dataset/dataItem` | 创建数据项 | `DatasetItemCreateRequest` | `Result<List<DatasetItem>>` |
| PUT | `/api/dataset/dataItem` | 更新数据项 | `DatasetItemUpdateRequest` | `Result<DatasetItem>` |
| GET | `/api/dataset/dataItems` | 分页查询数据项 | `DatasetItemListRequest` | `Result<PageResult<DatasetItem>>` |
| GET | `/api/dataset/dataItem` | 获取数据项详情 | `id` | `Result<DatasetItem>` |
| DELETE | `/api/dataset/dataItem` | 删除数据项 | `id` | `Result<Void>` |
| POST | `/api/dataset/dataItemFromTrace` | 从 Trace 创建数据项 | `DataItemCreateFromTraceRequest` | `Result<List<DatasetItem>>` |
| GET | `/api/dataset/experiments` | 查询关联实验列表 | `DatasetExperimentsListRequest` | `Result<PageResult<Experiment>>` |

### 4.2 评估器

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/api/evaluator/evaluator` | 创建评估器 | `EvaluatorCreateRequest` | `Result<Evaluator>` |
| GET | `/api/evaluator/evaluators` | 分页查询评估器 | `EvaluatorListRequest` | `Result<PageResult<Evaluator>>` |
| GET | `/api/evaluator/evaluator` | 获取评估器详情 | `id` | `Result<Evaluator>` |
| PUT | `/api/evaluator/evaluator` | 更新评估器 | `EvaluatorUpdateRequest` | `Result<Evaluator>` |
| DELETE | `/api/evaluator/evaluator` | 删除评估器 | `id` | `Result<Void>` |
| POST | `/api/evaluator/evaluatorVersion` | 创建评估器版本 | `EvaluatorVersionCreateRequest` | `Result<EvaluatorVersion>` |
| GET | `/api/evaluator/evaluatorVersions` | 分页查询版本列表 | `EvaluatorVersionListRequest` | `Result<PageResult<EvaluatorVersion>>` |
| POST | `/api/evaluator/debug` | 在线调试评估器 | `EvaluatorTestRequest` | `Result<EvaluatorDebugResult>` |
| GET | `/api/evaluator/templates` | 分页查询评估器模板 | `EvaluatorTemplateListRequest` | `Result<PageResult<EvaluatorTemplate>>` |
| GET | `/api/evaluator/template` | 获取模板详情 | `templateId` | `Result<EvaluatorTemplate>` |
| GET | `/api/evaluator/experiments` | 查询关联实验列表 | `EvaluatorExperimentsListRequest` | `Result<PageResult<Experiment>>` |

### 4.3 实验

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/api/experiment` | 创建实验 | `ExperimentCreateRequest` | `Result<Experiment>` |
| GET | `/api/experiments` | 分页查询实验列表 | `ExperimentListRequest` | `Result<PageResult<Experiment>>` |
| GET | `/api/experiment` | 获取实验详情 | `experimentId` | `Result<Experiment>` |
| GET | `/api/experiment/results` | 获取实验结果摘要 | `experimentId` | `Result<List<ExperimentEvaluatorResult>>` |
| GET | `/api/experiment/result` | 分页查询结果详情 | `ExperimentEvaluatorResultDetailListRequest` | `Result<PageResult<ExperimentEvaluatorResultDetail>>` |
| PUT | `/api/experiment/stop` | 停止实验 | `experimentId` | `Result<Experiment>` |
| PUT | `/api/experiment/restart` | 重启实验 | `experimentId` | `Result<Void>` |
| DELETE | `/api/experiment` | 删除实验 | `experimentId` | `Result<Void>` |

---

## 五、模型管理（`/console/v1/providers`、`/console/v1/models`、`/api/model`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/providers` | 添加模型提供商 | `AddProviderRequest` | `Result<Boolean>` |
| GET | `/console/v1/providers` | 查询所有提供商 | `QueryProviderRequest` | `Result<List<ProviderConfigInfo>>` |
| GET | `/console/v1/providers/{provider}` | 获取提供商详情 | `provider` | `Result<ProviderConfigInfo>` |
| PUT | `/console/v1/providers/{provider}` | 更新提供商配置 | `provider`, `UpdateProviderRequest` | `Result<Boolean>` |
| DELETE | `/console/v1/providers/{provider}` | 删除提供商 | `provider` | `Result<Boolean>` |
| GET | `/console/v1/providers/protocols` | 查询支持协议列表 | 无 | `Result<List<String>>` |
| POST | `/console/v1/providers/{provider}/models` | 添加模型 | `provider`, `AddModelRequest` | `Result<Boolean>` |
| GET | `/console/v1/providers/{provider}/models` | 查询模型列表 | `provider` | `Result<List<ModelConfigInfo>>` |
| GET | `/console/v1/providers/{provider}/models/{modelId}` | 获取模型详情 | `provider`, `modelId` | `Result<ModelConfigInfo>` |
| PUT | `/console/v1/providers/{provider}/models/{modelId}` | 更新模型 | `provider`, `modelId`, `UpdateModelRequest` | `Result<Boolean>` |
| DELETE | `/console/v1/providers/{provider}/models/{modelId}` | 删除模型 | `provider`, `modelId` | `Result<Boolean>` |
| GET | `/console/v1/providers/{provider}/models/{modelId}/parameter_rules` | 获取模型参数规则 | `provider`, `modelId` | `Result<List<ParameterRule>>` |
| GET | `/console/v1/models/{modelType}/selector` | 按类型查询模型选择器 | `modelType` | `Result<List<ModelProviderGroup>>` |
| GET | `/console/v1/models/enabled` | 获取已启用模型列表 | 无 | `Result<List<Map>>` |
| GET | `/api/model/supported` | 获取支持的模型类型 | 无 | `Result<List<String>>` |
| GET | `/api/models` | 分页查询模型配置 | `ModelConfigQueryRequest` | `Result<PageResult<ModelConfigResponse>>` |
| GET | `/api/model` | 获取模型配置详情 | `id` | `Result<ModelConfigResponse>` |
| GET | `/api/models/enabled` | 获取已启用模型配置 | 无 | `Result<List<ModelConfigResponse>>` |

---

## 六、知识库与 RAG（`/console/v1/knowledge-bases`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/knowledge-bases` | 创建知识库 | `KnowledgeBase` | `Result<String>` |
| GET | `/console/v1/knowledge-bases` | 分页查询知识库 | `BaseQuery` | `Result<PagingList<KnowledgeBase>>` |
| GET | `/console/v1/knowledge-bases/{kbId}` | 获取知识库详情 | `kbId` | `Result<KnowledgeBase>` |
| PUT | `/console/v1/knowledge-bases/{kbId}` | 更新知识库 | `kbId`, `KnowledgeBase` | `Result<String>` |
| DELETE | `/console/v1/knowledge-bases/{kbId}` | 删除知识库 | `kbId` | `Result<Void>` |
| POST | `/console/v1/knowledge-bases/query-by-codes` | 批量查询知识库 | `KnowledgeBaseQuery` | `Result<List<KnowledgeBase>>` |
| POST | `/console/v1/knowledge-bases/retrieve` | 向量检索文档 | `DocumentRetrieverQuery` | `Result<List<DocumentChunk>>` |
| POST | `/console/v1/knowledge-bases/{kbId}/documents` | 创建文档 | `kbId`, `CreateDocumentRequest` | `Result<List<String>>` |
| GET | `/console/v1/knowledge-bases/{kbId}/documents` | 分页查询文档列表 | `kbId`, `DocumentQuery` | `Result<PagingList<Document>>` |
| GET | `/console/v1/knowledge-bases/{kbId}/documents/{docId}` | 获取文档详情 | `kbId`, `docId` | `Result<Document>` |
| PUT | `/console/v1/knowledge-bases/{kbId}/documents/{docId}` | 更新文档 | `kbId`, `docId`, `Document` | `Result<Void>` |
| DELETE | `/console/v1/knowledge-bases/{kbId}/documents/{docId}` | 删除文档 | `kbId`, `docId` | `Result<Void>` |
| DELETE | `/console/v1/knowledge-bases/{kbId}/documents/batch-delete` | 批量删除文档 | `kbId`, `DeleteDocumentRequest` | `Result<Void>` |
| PUT | `/console/v1/knowledge-bases/{kbId}/documents/{docId}/re-index` | 重新索引文档 | `kbId`, `docId`, `IndexDocumentRequest` | `Result<Void>` |
| POST | `/console/v1/documents/{docId}/chunks` | 创建文档分块 | `docId`, `DocumentChunk` | `Result<String>` |
| GET | `/console/v1/documents/{docId}/chunks` | 分页查询分块 | `docId`, `BaseQuery` | `Result<PagingList<DocumentChunk>>` |
| PUT | `/console/v1/documents/{docId}/chunks/{chunkId}` | 更新分块 | `docId`, `chunkId`, `DocumentChunk` | `Result<Void>` |
| DELETE | `/console/v1/documents/{docId}/chunks/{chunkId}` | 删除分块 | `docId`, `chunkId` | `Result<Void>` |
| DELETE | `/console/v1/documents/{docId}/chunks/batch-delete` | 批量删除分块 | `docId`, `DeleteChunkRequest` | `Result<Void>` |
| POST | `/console/v1/documents/{docId}/chunks/preview` | 预览索引分块 | `docId`, `IndexDocumentRequest` | `Result<List<DocumentChunk>>` |
| PUT | `/console/v1/documents/{docId}/chunks/update-status` | 更新分块状态 | `docId`, `UpdateChunkRequest` | `Result<Void>` |

---

## 七、Agent 与 Workflow（`/console/v1/agent-schemas`、`/console/v1/apps/workflow`）

### 7.1 Agent Schema

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/agent-schemas` | 创建 Agent 定义 | `AgentSchemaEntity` | `Result<AgentSchemaEntity>` |
| GET | `/console/v1/agent-schemas` | 查询 Agent 定义列表 | 无 | `Result<List<AgentSchemaEntity>>` |
| GET | `/console/v1/agent-schemas/page` | 分页查询 Agent 定义 | `current`, `size` | `Result<PagingList<AgentSchemaEntity>>` |
| GET | `/console/v1/agent-schemas/{id}` | 获取 Agent 定义详情 | `id` | `Result<AgentSchemaEntity>` |
| PUT | `/console/v1/agent-schemas/{id}` | 更新 Agent 定义 | `id`, `AgentSchemaEntity` | `Result<AgentSchemaEntity>` |
| DELETE | `/console/v1/agent-schemas/{id}` | 删除 Agent 定义 | `id` | `Result<Void>` |
| GET | `/console/v1/agent-schemas/search` | 搜索 Agent 定义 | `name` | `Result<List<AgentSchemaEntity>>` |
| PATCH | `/console/v1/agent-schemas/{id}/enabled` | 启用/禁用 Agent | `id`, `enabled` | `Result<Void>` |

### 7.2 Workflow 调试

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/apps/workflow/debug/init` | 初始化调试任务 | `InitRequest` | `Result<List<TaskRunParam>>` |
| POST | `/console/v1/apps/workflow/debug/run-task` | 运行调试任务 | `TaskRunRequest` | `Result<TaskRunResponse>` |
| POST | `/console/v1/apps/workflow/debug/resume-task` | 恢复调试任务 | `TaskResumeRequest` | `Result<TaskResumeResponse>` |
| POST | `/console/v1/apps/workflow/debug/get-task-process` | 获取任务执行进度 | `ProcessGetRequest` | `Result<ProcessGetResponse>` |
| POST | `/console/v1/apps/workflow/debug/part-graph/run-task` | 运行子图任务 | `TaskPartGraphRequest` | `Result<TaskPartGraphResponse>` |
| POST | `/console/v1/apps/workflow/debug/part-graph/stop-task` | 停止子图任务 | `TaskStopRequest` | `Result<Boolean>` |
| POST | `/console/v1/apps/workflow/{appId}/run_stream` | 流式运行 Workflow | `appId`, `ApiTaskRunRequest` | SseEmitter |

---

## 八、插件、工具与 MCP（`/console/v1/plugins`、`/console/v1/tools`、`/console/v1/mcp-servers`）

### 8.1 插件与工具

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/plugins` | 创建插件 | `Plugin` | `Result<String>` |
| GET | `/console/v1/plugins` | 分页查询插件 | `BaseQuery` | `Result<PagingList<Plugin>>` |
| GET | `/console/v1/plugins/{pluginId}` | 获取插件详情 | `pluginId` | `Result<Plugin>` |
| PUT | `/console/v1/plugins/{pluginId}` | 更新插件 | `pluginId`, `Plugin` | `Result<Void>` |
| DELETE | `/console/v1/plugins/{pluginId}` | 删除插件 | `pluginId` | `Result<Void>` |
| POST | `/console/v1/plugins/{pluginId}/tools` | 为插件添加工具 | `pluginId`, `Tool` | `Result<String>` |
| GET | `/console/v1/plugins/{pluginId}/tools` | 查询插件工具列表 | `pluginId`, `ToolQuery` | `Result<PagingList<Tool>>` |
| GET | `/console/v1/plugins/{pluginId}/tools/{toolId}` | 获取工具详情 | `pluginId`, `toolId` | `Result<Tool>` |
| PUT | `/console/v1/plugins/{pluginId}/tools/{toolId}` | 更新工具 | `pluginId`, `toolId`, `Tool` | `Result<String>` |
| DELETE | `/console/v1/plugins/{pluginId}/tools/{toolId}` | 删除工具 | `pluginId`, `toolId` | `Result<Void>` |
| POST | `/console/v1/plugins/{pluginId}/tools/{toolId}/test` | 测试工具调用 | `pluginId`, `toolId`, `ToolExecutionRequest` | `Result<ToolExecutionResult>` |
| POST | `/console/v1/plugins/{pluginId}/tools/{toolId}/publish` | 发布工具 | `pluginId`, `toolId` | `Result<Void>` |
| POST | `/console/v1/tools/{toolId}/enable` | 启用工具 | `toolId` | `Result<Void>` |
| POST | `/console/v1/tools/{toolId}/disable` | 禁用工具 | `toolId` | `Result<Void>` |
| POST | `/console/v1/tools/query-by-ids` | 批量查询工具 | `ToolQuery` | `Result<List<Tool>>` |
| POST | `/console/v1/tools` | 创建独立工具 | `ToolEntity` | `Result<ToolEntity>` |
| GET | `/console/v1/tools` | 查询独立工具列表 | 无 | `Result<List<ToolEntity>>` |
| GET | `/console/v1/tools/page` | 分页查询独立工具 | `current`, `size` | `Result<PagingList<ToolEntity>>` |
| GET | `/console/v1/tools/{id}` | 获取独立工具详情 | `id` | `Result<ToolEntity>` |
| PUT | `/console/v1/tools/{id}` | 更新独立工具 | `id`, `ToolEntity` | `Result<ToolEntity>` |
| DELETE | `/console/v1/tools/{id}` | 删除独立工具 | `id` | `Result<Void>` |
| GET | `/console/v1/tools/search` | 搜索独立工具 | `name` | `Result<List<ToolEntity>>` |
| GET | `/console/v1/tools/plugin/{pluginId}` | 按插件查询工具 | `pluginId` | `Result<List<ToolEntity>>` |
| PATCH | `/console/v1/tools/{id}/enabled` | 启用/禁用独立工具 | `id`, `enabled` | `Result<Void>` |

### 8.2 MCP Server

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/mcp-servers` | 创建 MCP Server | `McpServerDetail` | `Result<String>` |
| PUT | `/console/v1/mcp-servers` | 更新 MCP Server | `McpServerDetail` | `Result<String>` |
| GET | `/console/v1/mcp-servers` | 分页查询 MCP Server | `McpQuery` | `Result<PagingList<McpServerDetail>>` |
| GET | `/console/v1/mcp-servers/{serverCode}` | 获取 MCP Server 详情 | `serverCode`, `needTools` | `Result<McpServerDetail>` |
| DELETE | `/console/v1/mcp-servers/{serverCode}` | 删除 MCP Server | `serverCode` | `Result<Void>` |
| POST | `/console/v1/mcp-servers/query-by-codes` | 批量查询 MCP Server | `McpQuery` | `Result<List<McpServerDetail>>` |
| POST | `/console/v1/mcp-servers/debug-tools` | 调试 MCP 工具调用 | `McpServerCallToolRequest` | `Result<McpServerCallToolResponse>` |

---

## 九、可观测性（`/api/observability`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| GET | `/api/observability/traces` | 分页查询 Trace 列表 | `TracesQueryRequest` | `Result<PageResult<TraceSpanDTO>>` |
| GET | `/api/observability/traces/{traceId}` | 获取 Trace 详情 | `traceId` | `Result<TraceDetailDTO>` |
| GET | `/api/observability/services` | 查询服务列表 | `ServicesQueryRequest` | `Result<ServicesResponseDTO>` |
| GET | `/api/observability/overview` | 获取观测概览统计 | `OverviewQueryRequest` | `Result<OverviewStatsDTO>` |

---

## 十、账户与权限（`/console/v1/accounts`、`/console/v1/workspaces`、`/console/v1/api-keys`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/console/v1/accounts` | 创建账户 | `Account` | `Result<String>` |
| GET | `/console/v1/accounts` | 分页查询账户 | `BaseQuery` | `Result<PagingList<Account>>` |
| GET | `/console/v1/accounts/{accountId}` | 获取账户详情 | `accountId` | `Result<Account>` |
| GET | `/console/v1/accounts/profile` | 获取当前用户资料 | 无 | `Result<Account>` |
| PUT | `/console/v1/accounts/{accountId}` | 更新账户 | `accountId`, `Account` | `Result<String>` |
| DELETE | `/console/v1/accounts/{accountId}` | 删除账户 | `accountId` | `Result<Void>` |
| PUT | `/console/v1/accounts/change-password` | 修改密码 | `ChangePasswordRequest` | `Result<String>` |
| POST | `/console/v1/workspaces` | 创建工作空间 | `Workspace` | `Result<String>` |
| GET | `/console/v1/workspaces` | 分页查询工作空间 | `BaseQuery` | `Result<PagingList<Workspace>>` |
| GET | `/console/v1/workspaces/{workspaceId}` | 获取工作空间详情 | `workspaceId` | `Result<Workspace>` |
| PUT | `/console/v1/workspaces/{workspaceId}` | 更新工作空间 | `workspaceId`, `Workspace` | `Result<String>` |
| DELETE | `/console/v1/workspaces/{workspaceId}` | 删除工作空间 | `workspaceId` | `Result<Void>` |
| POST | `/console/v1/api-keys` | 创建 API Key | `ApiKey` | `Result<String>` |
| GET | `/console/v1/api-keys` | 分页查询 API Key | `BaseQuery` | `Result<PagingList<ApiKey>>` |
| GET | `/console/v1/api-keys/{id}` | 获取 API Key 详情 | `id` | `Result<ApiKey>` |
| PUT | `/console/v1/api-keys/{id}` | 更新 API Key | `id`, `ApiKey` | `Result<String>` |
| DELETE | `/console/v1/api-keys/{id}` | 删除 API Key | `id` | `Result<Void>` |

---

## 十一、组件与文件（`/console/v1/component-servers`、`/console/v1/files`）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| GET | `/console/v1/component-servers` | 分页查询组件 | `AppComponentQuery` | `Result<PagingList<AppComponent>>` |
| POST | `/console/v1/component-servers` | 创建组件 | `AppComponentQuery` | `Result<String>` |
| GET | `/console/v1/component-servers/{code}/detail-by-code` | 按 code 查组件详情 | `code` | `Result<AppComponent>` |
| GET | `/console/v1/component-servers/{appId}/detail-by-appid` | 按 appId 查组件详情 | `appId` | `Result<AppComponent>` |
| GET | `/console/v1/component-servers/{code}/query-refer` | 查询组件引用 | `code` | `Result<List<AppComponent>>` |
| GET | `/console/v1/component-servers/{appId}/query-config` | 查询组件配置 | `appId` | `Result<AppComponent>` |
| GET | `/console/v1/component-servers/{code}/query-schema` | 查询组件 Schema | `code` | `Result<Map>` |
| POST | `/console/v1/component-servers/query-by-codes` | 批量查询组件 | `AppComponentQuery` | `Result<List<AppComponent>>` |
| POST | `/console/v1/component-servers/schema-by-codes` | 批量查询 Schema | `AppComponentQuery` | `Result<Map>` |
| PUT | `/console/v1/component-servers/{code}` | 更新组件 | `code`, `AppComponentQuery` | `Result<String>` |
| DELETE | `/console/v1/component-servers/{code}` | 删除组件 | `code` | `Result<Boolean>` |
| GET | `/console/v1/component-servers/app-publishable` | 查询可发布应用 | `AppComponentQuery` | `Result<PagingList<Application>>` |
| POST | `/console/v1/files/upload` | 文件上传 | `files` (MultipartFile[]), `category` | `Result<List<UploadPolicy>>` |
| GET | `/console/v1/files/download` | 文件下载/预览 | `path`, `preview` | void（写 response） |
| POST | `/console/v1/files/upload-policies` | 获取上传策略 | `WebUploadRequest` | `Result<List<WebUploadPolicy>>` |
| GET | `/console/v1/files/get-preview-url` | 获取预览 URL | `path` | `Result<String>` |

---

## 十二、开放接口（`/api/v1/apps` — 外部 Agent 调用）

| 方法 | 路径 | 说明 | 主要入参 | 返回 |
|------|------|------|----------|------|
| POST | `/api/v1/apps/chat/completions` | 对话补全（外部调用） | `AgentRequest` | SseEmitter / JSON |
| POST | `/api/v1/apps/workflow/completions` | Workflow 同步补全 | `WorkflowRequest` | SseEmitter / JSON |
| POST | `/api/v1/apps/workflow/async-completions` | Workflow 异步补全 | `WorkflowRequest` | `Result<TaskRunResponse>` |
| POST | `/api/v1/apps/workflow/stop-completions` | 停止异步任务 | `TaskStopRequest` | `Result<Boolean>` |
| POST | `/api/v1/apps/workflow/async-results` | 获取异步任务结果 | `AsyncResultRequest` | `Result<AsyncResultResponse>` |

---

## 附录：返回类型说明

| 类型 | 说明 |
|------|------|
| `Result<T>` | 统一响应包装，含 code/msg/data |
| `Result<PagingList<T>>` | 分页结果，含 total/page/size/items |
| `Result<PageResult<T>>` | 同上，admin 模块专用 |
| `SseEmitter` | SSE 流式响应（对话/Workflow 运行） |
| `Flux<T>` | WebFlux 流式响应（Prompt run） |
| `R<T>` | Graph Studio 模块专用响应包装 |
| `void` / `ResponseEntity` | 直接写 response（文件下载/重定向） |

## 附录：模块统计

| 模块 | Controller 数 | 接口数 |
|------|-------------|--------|
| 认证与系统 | 3 | 7 |
| 应用管理 | 4 | 21 |
| Prompt 管理 | 1 | 13 |
| 数据集与评估 | 3 | 34 |
| 模型管理 | 3 | 18 |
| 知识库与 RAG | 1 | 21 |
| Agent 与 Workflow | 2 | 15 |
| 插件、工具与 MCP | 3 | 31 |
| 可观测性 | 1 | 4 |
| 账户与权限 | 3 | 17 |
| 组件与文件 | 2 | 16 |
| 开放接口 | 1 | 5 |
| **合计** | **32** | **202** |
