回复用中文，代码、注释等用英文。

## 文档索引

### 产品与规格（.claude/docs/）

- **prd.md** — 产品需求文档：用户故事（US-01~US-23）、功能需求（FR-01~FR-08）、非功能需求
- **api.md** — API 参考：所有端点的请求/响应格式、状态码、速率限制汇总
- **roadmap.md** — 开发路线图：Phase 1-4 计划、后端/前端模块开发顺序
- **architecture.md** — 系统架构：技术栈、前后端目录结构、数据模型 ER 图、认证流程、部署架构、测试架构
- **decisions.md** — 架构决策记录（ADR-001~ADR-011）：关键设计决策与权衡

### 上下文（.claude/context/）

- **product.md** — 产品上下文速查：核心实体、关键业务规则、Owner/Viewer 权限对比、不存在的功能列表
- **coding-style.md** — 编码规范：TDD 规则、PHP/TypeScript 规范、API Platform 4 规范、Git 分支/Commit 格式

### 任务（.claude/tasks/）

- **current.md** — 当前任务：Phase 1 MVP 详细任务清单（含 TDD 测试用例名称），按模块分组（BE-INFRA/BE-AUTH/BE-USER/BE-CARD/BE-SYNC/BE-FRIEND/BE-SHARE）
- **todo.md** — 全量任务列表：所有 Phase（1-4）的任务，含前端模块（FE-AUTH/FE-CARD/FE-OFFLINE/FE-FRIEND/FE-SHARE）
