# 默认 group_id 安全兜底（DEFAULT_GROUP_ID）

为避免调用方忘记传 `group_id` 造成记忆落到 `default` 组，现在可以通过环境变量配置全局默认组：

## 使用方法

在 `.env` 或部署环境里设置：

```
DEFAULT_GROUP_ID=global
```

重启服务后，所有未显式传 `group_id/group_ids` 的调用将默认写入/检索 `global`（或你设置的值）。

## 适用场景
- 团队想统一默认写入到 `global`，避免散落在 `default`
- 某个工作区只做某项目：设置 `DEFAULT_GROUP_ID=proj-xxx`

## 注意
- 这只是兜底，强烈建议调用时显式传 `group_id` 或 `group_ids`
- 如果开启了管理端配置缓存，请在改动 .env 后删除 `/mnt/docker/graphiti-mcp/db/manager.db` 并重启
