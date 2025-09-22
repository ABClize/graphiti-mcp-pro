# Graphiti MCP Pro - VS Code 配置指南

## 当前配置状态

✅ **服务状态**
- MCP 服务器：运行在 `http://localhost:8082`
- 管理后端：运行在 `http://localhost:7072`
- Neo4j 数据库：运行在 `http://localhost:7474`

✅ **VS Code MCP 配置**
- 配置文件：`~/.config/Code/User/mcp.json`
- 服务器名称：`graphiti-mcp-pro`
- 传输协议：HTTP
- 服务地址：`http://localhost:8082`

## 配置内容

```json
{
  "servers": {
    "graphiti-mcp-pro": {
      "type": "http",
      "url": "http://localhost:8082",
      "description": "Graphiti MCP Pro - Enhanced memory repository with management platform"
    }
  }
}
```

## 使用步骤

### 1. 重启 VS Code
配置文件更新后，需要重启 VS Code 以加载新的 MCP 服务器配置。

### 2. 验证连接
在 VS Code 中，MCP 服务器应该会自动连接。您可以通过以下方式验证：

- 查看 VS Code 的输出面板中的 MCP 相关日志
- 使用 Copilot Chat 时，应该能看到 Graphiti 相关的工具

### 3. 可用工具
Graphiti MCP Pro 提供以下增强功能：

**核心工具：**
- `add_memory` - 添加记忆（支持异步并行处理）
- `search_memory_facts` - 搜索记忆事实
- `search_memory_nodes` - 搜索记忆节点
- `get_episodes` - 获取记忆片段
- `delete_episode` - 删除记忆片段

**新增任务管理工具：**
- `list_add_memory_tasks` - 列出所有添加记忆任务
- `get_add_memory_task_status` - 获取任务状态
- `wait_for_add_memory_task` - 等待任务完成
- `cancel_add_memory_task` - 取消任务

**图管理工具：**
- `clear_graph` - 清空图数据
- `get_entity_edge` - 获取实体边
- `delete_entity_edge` - 删除实体边

## 配置特点

### AI 模型配置
- **大模型**：DeepSeek Chat（实体关系提取）
- **小模型**：DeepSeek Chat（轻量任务）
- **嵌入模型**：OpenAI text-embedding-ada-002

### 增强功能
- ✅ 异步并行处理（同组 ID 最多 5 个并行任务）
- ✅ 任务管理和监控
- ✅ 统一配置管理
- ✅ Web 管理界面（端口 7072）
- ✅ 主机挂载数据持久化

## 故障排除

### 如果连接失败
1. 确认服务正在运行：`docker compose ps`
2. 检查端口是否可访问：`curl http://localhost:8082/health`
3. 查看服务日志：`docker logs graphiti-mcp-pro-server`

### 如果工具不可用
1. 重启 VS Code
2. 检查 MCP 配置文件语法是否正确
3. 确认服务器 URL 和端口配置正确

## 管理界面
虽然前端界面暂时未构建，但您可以通过管理后端 API 进行配置：
- 健康检查：`http://localhost:7072/health`
- API 文档：`http://localhost:7072/docs`（如果可用）

## 数据持久化
- Neo4j 数据：`/mnt/docker/neo4j/`
- 管理数据：`/mnt/docker/graphiti-mcp/db/`

数据将在容器重启后保持完整。