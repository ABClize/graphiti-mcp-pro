# Graphiti MCP Pro

[English](README.md) | **中文**

> **关于 Graphiti**
> Graphiti 是一个用于构建和查询具有时间感知的知识图谱的框架，专门针对在动态环境中运行的 AI 代理。与传统的检索增强生成（RAG）方法不同，Graphiti 持续地将用户交互、结构化和非结构化企业数据以及外部信息整合到一个连贯、可查询的图谱中。该框架支持增量数据更新、高效检索和精确的历史查询，无需重新计算整个图谱，使其适用于开发交互式、情境感知的 AI 应用。

本项目是基于 [Graphiti](https://github.com/getzep/graphiti) 实现的增强版记忆库 MCP 服务及管理端，相比原项目的 [MCP 服务](https://github.com/getzep/graphiti/tree/main/mcp_server)，具有以下核心优势：增强的核心能力、更广泛的 AI 模型兼容性、完备的可视化管理界面。

## 特性

### 增强的核心能力

#### 异步并行处理

添加记忆是 MCP 服务的核心功能，我们在原实现基础上引入了异步并行处理机制。同一个 group id（如不同的开发项目）可并行执行最多 5 个添加记忆任务，显著提升处理效率。

#### 任务管理工具

新增四个 MCP 工具用于管理添加记忆任务：

- `list_add_memory_tasks` - 列出所有任务
- `get_add_memory_task_status` - 获取任务状态
- `wait_for_add_memory_task` - 等待任务完成
- `cancel_add_memory_task` - 取消任务

#### 统一配置管理

优化了配置项管理，解决了命令行参数、环境变量及管理后端数据库配置不一致的问题。

> [!NOTE]
> 启用管理后端时，.env 环境配置文件中的 MCP 服务参数仅在初次启动时生效，后续配置将以管理后端数据库中的参数为准。

### 更广的 AI 模型兼容性和灵活性

#### 增强模型兼容性

通过集成 [instructor](https://github.com/567-labs/instructor) 库，显著改善了模型兼容性。现在支持 DeepSeek、Qwen 等多种模型，甚至可以使用通过 Ollama、vLLM 本地运行的模型，只要它们提供 OpenAI API 兼容接口。

#### 分离式模型配置

将原来的统一 LLM 配置拆分为三个独立配置，可根据实际需求灵活搭配：

- **大模型 (LLM)**：负责实体和关系提取
- **小模型 (Small LLM)**：处理实体属性归纳、关系去重、重排序等轻量任务
- **嵌入模型 (Embedder)**：专门负责文本向量化

> [!NOTE]
> 配置 embedding 模型时需要注意，其调用的路径和上面两个 LLM 是不一样的，LLM 调用的路径是对话补全的路径，即 `{base_url}/chat/completions`，而文本嵌入的路径调用的是 `{base_url}/embeddings`，如果你通过管理后台配置时选择了「与大模型相同」，请确保你配置的大模型支持文本嵌入
>
> 另外，如果你通过 docker compose 方式运行服务，而 embedding 模型是通过本地运行的，那么 embedding 的 base_url 需要配置为 `http://host.docker.internal:{port}`，其中的端口需要根据你本地运行的端口进行调整

### 完备的管理端

为了提供更好的使用体验和可观测性，我们开发了完整的管理后端和 Web UI。通过管理界面，你可以：

- **服务控制**：启动、停止、重启 MCP 服务
- **配置管理**：实时更新和调整配置参数
- **用量监控**：查看详细的 token 使用统计
- **日志查看**：实时日志和历史日志查询

## 运行

### Docker Compose 方式 (推荐)

> [!CAUTION]
> 国内用户需要确保网络畅通，包括但不限于可正常访问 docker hub, pypi, npmjs 等站点

1. **克隆项目**

   ```bash
   git clone http://github.com/ueworks/graphiti-mcp-pro
   cd graphiti-mcp-pro
   ```

2. **配置环境变量**（可选）

   ```bash
   # 复制示例配置文件
   mv .env.example.cn .env
   # 编辑 .env 文件，根据说明配置参数
   ```

3. **启动服务**

   ```bash
   docker compose up -d
   ```

   > [!TIP]
   > 如果项目有更新，需要重新构建镜像，请使用 `docker compose up -d --build` 命令。
   > 请放心，数据会持久保存在容器外的数据库中，不会丢失。

4. **访问管理界面**
   默认地址：http://localhost:6062

### 手动运行

> [!NOTE]
> 先决条件：
>
> 1. Python 3.10+ 及 uv 管理工具
> 2. Node.js 20+
> 3. 可访问的 Neo4j 5.26 数据库服务
> 4. AI 模型服务

1. **克隆项目**

   ```bash
   git clone http://github.com/ueworks/graphiti-mcp-pro
   cd graphiti-mcp-pro
   ```

2. **安装依赖**

   ```bash
   uv sync
   ```

3. **配置环境变量**

   ```bash
   # 复制示例配置文件
   mv .env.example.cn .env
   # 编辑 .env 文件，根据说明配置参数
   ```

4. **运行 MCP 服务**

   ```bash
   # 运行带管理后端的服务
   uv run main.py -m
   # 或仅运行 MCP 服务
   # uv run main.py
   ```

5. **编译与运行管理前端**

   进入前端目录并安装依赖：

   ```bash
   cd manager/frontend
   pnpm install  # 或 npm install / yarn
   ```

   编译并运行前端：

   ```bash
   pnpm run build   # 或 npm run build / yarn build
   pnpm run preview # 或 npm run preview / yarn preview
   ```

   访问管理界面：http://localhost:6062

## 注意事项

### 已知限制

- **🔒 安全提醒**：管理后端未实现授权访问机制，请勿在公共服务器上暴露服务
- **🧪 测试覆盖**：受资源限制，项目未进行充分测试，仅建议个人使用
- **📡 传输协议**：仅支持 streamable-http 传输协议，移除了原项目的 stdio 和 sse 支持
- **⚙️ 代码优化**：部分架构设计（依赖注入、异常处理、客户端解耦等）仍有优化空间

### 使用建议

- **配置说明**：请仔细阅读运行说明和 `.env.example.cn` 中的注释内容
- **模型选择**：如使用 GPT/Gemini/Claude 等原生支持的模型且不需要详细运行信息，建议使用原版 [Graphiti MCP](https://github.com/getzep/graphiti/tree/main/mcp_server)
- **问题反馈**：遇到使用问题欢迎提交 Issue 或 Pull Request

---

由 🤖 [Augment Code](https://augmentcode.com) 协助开发
