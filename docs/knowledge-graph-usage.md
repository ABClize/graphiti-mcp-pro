# Graphiti MCP Pro 知识图谱使用建议（多项目 & 全局记忆）

本文档提供在 VS Code 多项目协作场景下，基于 Graphiti MCP Pro 构建“项目隔离 + 全局共享”的最佳实践方案。

## 核心概念速览

- group_id：知识图谱的“命名空间”。同一 group_id 下的记忆彼此可见、可检索；不同 group_id 相互隔离。
- 默认 group：默认值为 `default`（见 `graphiti_pro_core/mcp_server/settings.py`）。工具未显式传 `group_id` 时将落在该组。
- 工具参数：核心工具均支持传入 `group_id` 或 `group_ids`（如 `add_memory`, `search_memory_facts`, `search_memory_nodes`, `get_episodes`）。

## 组织策略（建议）

1. 项目分组（强烈推荐）
   - 每个 VS Code 项目/仓库使用独立 group_id，例如：`proj-{repoName}`、`proj-{team}-{service}`。
   - 命名建议：全小写、短横线分隔，便于在 UI 与日志中快速识别。

2. 全局分组（可选）
   - 建立一个全局 group：`global`，存放跨项目复用的“知识与规范”，如：
     - 团队编码规范 / 评审清单
     - 常用 Prompt 与工具调用范式
     - 通用 DevOps / 发布流程 / 安全基线
     - 公司或团队内部通用术语表

3. 组合查询（检索层合并）
   - 在检索类工具中将 `group_ids` 设置为 `[currentProject, "global"]`，即可实现“先项目、再全局”的联合召回。
   - 如需严格区分优先级，可在客户端侧对结果打分排序（先项目组，再全局组）。

4. 生命周期与演进
   - 每个项目在关键里程碑时（迭代结项/发布）做一次“知识快照”写入项目组。
   - 对全局组的知识需有“版本标签”和“失效策略”（如：新增 `invalid_at` 时间或更新同名 fact）。

5. 权限与边界
   - 管理端暂未做鉴权，建议仅在内网使用；
   - 团队内可约定：只有 Maintainer 可以写入 `global`；项目组成员只能写入各自 `proj-*`。

## VS Code 集成用法

1. MCP 客户端配置
   - `.vscode/mcp.json` 已指向 MCP 服务端：http://localhost:8082/mcp/

2. 常用工具与参数
   - `add_memory(name, episode_body, group_id?, source?, source_description?)`
   - `search_memory_facts(query, group_ids?, max_facts?, center_node_uuid?)`
   - `search_memory_nodes(query, group_ids?, max_nodes?)`
   - `get_episodes(group_id?, last_n?)`

3. 建议的调用范式
   - 写入项目知识（当前项目组）：
     - group_id = 当前项目的 `proj-xxx`
   - 写入可复用知识（全局组）：
     - group_id = `global`
   - 检索时：
     - group_ids = `[proj-xxx, global]`

## 命名规范建议

- group_id：`proj-{repo}`, `proj-{team}-{service}`, `global`
- name：`[领域] 主题 - 版本/日期`，例如：`[RAG] Chunk 策略 - 2025-09`
- source：`text`（默认）/ `json` / `message`
- source_description：对来源的 1 句描述，如 "设计评审纪要"

## 示例（以 VS Code 工具面板为准）

- 写入
  - name: `项目依赖基线`
  - episode_body: `Node 20 / Python 3.10 / pnpm / uv`
  - group_id: `proj-abc-web`

- 检索（项目+全局）
  - query: `发布流程 与 回滚`
  - group_ids: `["proj-abc-web", "global"]`
  - max_facts: `10`

## 维护与巡检

- 周期清理：用 `CLEAN_LOGS_AT_HOUR` 及 `LOG_SAVE_DAYS` 控制日志；
- Neo4j 后台：`http://localhost:7474` 可视化巡检边与节点；
- 管理前端：`http://localhost:6062` 查看任务与使用记录；
- 配置更新：记得在 `.env` 变更后删除缓存 `/mnt/docker/graphiti-mcp/db/manager.db` 并重启。

## 常见问题（FAQ）

- 忘记传 group_id？
  - 会落到 `default`，后续检索记得包含 `default` 或迁移数据。
- 跨项目污染？
  - 标准做法是固定每个项目独立 group_id，并仅在检索时合并 `global`。
- 查询不到新数据？
  - 确认使用了正确的 `group_id/group_ids`，以及任务已完成（可在管理前端查看）。

---

> 提示：本指南与实践建议可结合团队流程继续完善。如需把这份建议写入知识图谱，建议以 `global` 组写入，便于各项目检索时联动获取。