# 当前任务：Phase 1 MVP

> 开发顺序：后端 TDD → 前端同步 | 已完成模块详情见 **completed.md**

## 模块状态

| 模块 | 状态 | 测试数 |
|------|------|--------|
| BE-INFRA | ✅ | — |
| BE-AUTH  | ✅ | 37 |
| BE-USER  | ✅ | 17 |
| BE-CARD  | ✅ | 28 |
| BE-SYNC  | ✅ | 3  |
| BE-FRIEND | ✅ | 6 |
| BE-SHARE | ✅ | 20 |
| **BE-BUGFIX** | ✅ | — |
| FE-INFRA | ✅ | — |
| FE-AUTH  | ✅ | — |
| FE-USER  | ✅ | — |
| FE-CARD  | 🔒 等待 BE-BUGFIX | — |
| FE-FRIEND | 🔒 等待 BE-BUGFIX | — |
| FE-SHARE  | 🔒 等待 FE-CARD + FE-FRIEND | — |

> BE-USER 测试数从 15 → 17（补充 `testDeleteAccountCascadesCardShares` + `testDeleteAccountCascadesFriendships`）

---

## BE-BUGFIX 架构修复清单（按优先级逐步执行）

> 2026-06-05 架构审查后发现。全部完成后方可开始前端模块。

### 🔴 Step 1 — 数据一致性 Bug（必须先修）

- [x] **BE-BUGFIX-01**：`FriendDeleteProcessor` — 删除 CardShare 时为每个 Viewer 写 `CardDeletion` 记录
  - 文件：`src/State/Processor/FriendDeleteProcessor.php`
  - 要点：遍历 `$shares`，每个 share 在 `remove()` 前 `persist(new CardDeletion(...))` for viewer
  - 需补充测试：解除好友后增量同步能感知到 deleted 卡片

- [x] **BE-BUGFIX-02**：`CardShare` 加 `updatedAt` — viewerNickname 更新进增量同步
  - 文件：`src/Entity/CardShare.php`（加字段 + `#[ORM\PreUpdate]`）、`src/Repository/CardShareRepository.php`（`findUpdatedSharesSince` 改用 `cs.updatedAt`）
  - 需新建 migration

- [x] **BE-BUGFIX-03**：Friendship 双向唯一约束 — 新 migration 加表达式索引
  - SQL：`CREATE UNIQUE INDEX IF NOT EXISTS uniq_friendship_pair ON app_friendship (LEAST(requester_id::text, addressee_id::text), GREATEST(requester_id::text, addressee_id::text))`

### 🟡 Step 2 — 边界 Case 修复

- [x] **BE-BUGFIX-04**：`security.yaml` `auth_public` pattern 加 `resend-verification`
  - 文件：`config/packages/security.yaml:25`

- [x] **BE-BUGFIX-05**：`UserRegisterProcessor` — 预检 email / userName 重复，返回 422
  - 文件：`src/State/Processor/UserRegisterProcessor.php`

- [x] **BE-BUGFIX-06**：`UserUpdateProcessor` — UUID 比较改用 `->equals()`
  - 文件：`src/State/Processor/UserUpdateProcessor.php:50`

- [x] **BE-BUGFIX-07**：`DeleteAccountProcessor` — 消除 N+1，加 `CardShareRepository::deleteByOwner(User)`
  - 文件：`src/Repository/CardShareRepository.php`、`src/State/Processor/DeleteAccountProcessor.php`

### 🔵 Step 3 — 防御性设计（可与前端并行）

- [x] **BE-BUGFIX-08**：`CardRepository::findActiveByOwner` / `countActiveByOwner` 显式加 `deletedAt IS NULL`
- [x] **BE-BUGFIX-09**：`Card.php` owner FK 改 `onDelete: 'CASCADE'`（需新 migration）

---

## 待解锁前端模块

| 模块 | 依赖 | 状态 |
|------|------|------|
| FE-CARD（卡片列表/添加/详情） | BE-BUGFIX Step 1+2 ✅ | 等待 BE-BUGFIX |
| FE-FRIEND（好友管理页面） | BE-BUGFIX Step 1+2 ✅ | 等待 BE-BUGFIX |
| FE-OFFLINE（离线缓存 + 增量同步） | FE-CARD + BE-SYNC ✅ | 等待 FE-CARD |
| FE-SHARE（共享管理） | FE-CARD + FE-FRIEND + BE-SHARE ✅ | 等待 FE-CARD + FE-FRIEND |

---

## Phase 1 完成标准

- [x] 所有后端集成测试通过（144 tests, 1 skipped）
- [x] 每个端点至少有 Happy Path + 401 + 403 测试
- [x] BE-BUGFIX Step 1+2 全部修复并补充测试
- [ ] OpenAPI 文档可访问（`/api/docs`）
- [x] 速率限制配置完毕（注册/登录/好友请求）
- [x] Docker Compose 启动后一键可运行测试
