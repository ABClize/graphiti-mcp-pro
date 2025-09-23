# 多项目 group_id 清单与 VS Code 快捷用法

## 建议的 group_id 命名
- proj-graphiti-mcp-pro   （本仓库）
- proj-app-web
- proj-app-backend
- proj-data-platform
- global                  （全局共享）

可按团队/服务扩展：`proj-{team}-{service}`，如 `proj-growth-dashboard`、`proj-ops-cmdb`。

## VS Code 快捷用法（参数模板）

> 在 VS Code MCP 工具面板里，按以下模板填入参数即可。

### 写入项目知识（add_memory）
- name: 任意标题
- episode_body: 你的内容
- group_id: proj-graphiti-mcp-pro
- source: text（默认可省略）
- source_description: 可选

### 写入全局知识（add_memory）
- name: 团队规范 / Prompt 模板 / 术语表
- episode_body: 你的内容
- group_id: global

### 检索项目 + 全局（search_memory_facts / search_memory_nodes）
- query: 你要查的内容
- group_ids: ["proj-graphiti-mcp-pro", "global"]
- max_facts 或 max_nodes: 10（默认）

### 查看最近写入（get_episodes）
- group_id: proj-graphiti-mcp-pro
- last_n: 10

## Tips
- 建议将常用的 group_ids 片段保存为 VS Code 代码片段或复制板，减少输入。
- 如需更强的固定化，可在管理端或前端做“组切换”快捷入口（未来可扩展）。
