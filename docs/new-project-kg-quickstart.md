# 新项目使用知识图谱快速上手（Graphiti MCP Pro）

本文档帮助你在任意新项目里，快速、规范地使用知识图谱（Memory Graph）。

## 你将获得
- 一套可复用的 group_id 规划规范
- VS Code 快捷片段（Snippets）用于常用参数模板
- 常见操作范式：写入（add_memory）、检索（facts/nodes）、查看（episodes）
- 多项目联合检索与全局知识的使用建议
- 常见问题与排查

---

## 一次性准备
- 服务端
  - MCP HTTP Endpoint: http://localhost:8082/mcp/
  - 管理后台（前端）: http://localhost:6062/
  - 管理后台（后端 API）: http://localhost:7072/
  - Neo4j: http://localhost:7474/ （Bolt: 7687）
- 环境变量
  - 已设置 DEFAULT_GROUP_ID=global（兜底，避免误写入 default 组）
  - 变更 .env 后需删除 manager.db 并重启服务以生效
- 模型
  - 小模型：SiliconFlow Qwen/Qwen3-8B（支持函数/工具调用）
  - 向量模型：SiliconFlow Qwen3-Embedding-4B

> 端口与模型如有调整，以仓库 docker-compose 与 .env 为准。

---

## 为新项目确定 group_id
- 命名建议：`proj-<仓库名>` 或 `proj-<组织>-<仓库>`，全部小写，单词用连字符
- 示例：
  - proj-analytics-platform
  - proj-foo-bar
- 统一规则的好处：便于跨项目查询、治理与自动化检索组合

---

## VS Code 集成与片段
- VS Code 已配置 HTTP MCP 连接到 http://localhost:8082/mcp/
- 片段文件：`.vscode/graphiti-mcp.code-snippets`
- 现有片段（示例）：
  - mcp-add-project / mcp-add-global
  - mcp-search-project-global
  - mcp-episodes-project
- 通用片段（可在任意新项目使用）：
  - mcp-add：自定义 group_id 写入
  - mcp-search：自定义 group_ids 联合检索 facts
  - mcp-nodes：自定义 group_ids 检索 nodes
  - mcp-nodes-project-global：项目 + global 联合检索 nodes（当前仓库示例）
  - mcp-episodes：自定义 group_id 查看最近 episodes

> 使用方式：在请求参数输入位置键入片段前缀并回车，按提示填写变量。

---

## 常用操作范式

### 1) 写入记忆（add_memory）
必填：name, episode_body, group_id；可选：source（text/json/message），source_description。

示例（项目组）：
```json
{
  "name": "设计决策：缓存策略",
  "episode_body": "采用多级缓存：浏览器 Cache-Control + 服务端 Redis，失效策略 10 分钟。",
  "group_id": "proj-your-project",
  "source": "text",
  "source_description": "架构决策会议纪要"
}
```

示例（全局组）：
```json
{
  "name": "知识图谱最佳实践：条目粒度",
  "episode_body": "一条一事（One thing per episode），便于复用与精准检索。",
  "group_id": "global",
  "source": "text"
}
```

### 2) 联合检索事实（search_memory_facts）
- 推荐组合：[项目组, global]，同时命中项目知识与全局知识

```json
{
  "query": "缓存策略 失效 时间",
  "group_ids": ["proj-your-project", "global"],
  "max_facts": 10
}
```

### 3) 检索节点（search_memory_nodes）
- 节点返回的是实体聚合摘要，适合找“谁关联了什么”
- 可选 entity 过滤（如 Preference/Procedure），一般留空即可

```json
{
  "query": "缓存 策略",
  "group_ids": ["proj-your-project", "global"],
  "max_nodes": 10
}
```

### 4) 查看最近条目（get_episodes）
- 按单个 group_id 查看最近 n 条

```json
{
  "group_id": "proj-your-project",
  "last_n": 10
}
```

---

## 多项目与全局知识策略
- 每个项目使用自己独立的 `proj-...` 组，保证隔离与可维护性
- 通用知识、规范、最佳实践写入 `global` 组，供所有项目共享
- 检索时组合查询：`[proj-xxx, global]`，同时获得专有与通用信息
- 服务器已设置 DEFAULT_GROUP_ID=global，作为兜底；仍建议明确传 group_id/group_ids 以避免歧义

---

## 最佳实践
- 一条一事：每条 episode 聚焦一个概念/决策/流程
- 写好标题与来源：方便人/机检索；source_description 尽量简洁明了
- 结构化优先：可被程序消费的内容尽量用 JSON（例如流程、接口契约、步骤）
- 小步快写：多条小笔记比一条巨长文本更容易被命中与复用
- 联合检索：默认带上 `global`，减少“没搜到”的概率

---

## 故障排查
- 查不到内容：检查是否传了正确的 group_id/group_ids
- 配置变更无效：删除 manager.db 并重启服务
- 管理页面打不开：确认 docker-compose 中 manager-frontend 已启用并映射 6062
- 模型错误/限额：检查 API Key 与模型名称，必要时更换供应商或模型

---

如需为新项目批量初始化片段（把 `proj-your-project` 固化为你的项目 ID），可以复制 `.vscode/graphiti-mcp.code-snippets` 中的项目模板并替换 group_id。
