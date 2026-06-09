# CardPocket — 开发路线图

---

## Phase 1：MVP（当前阶段）

**目标**：一个可用的数字卡包 + 家庭共享基础

### 后端模块顺序

```
[1] 认证核心
    ├── User 实体 + 数据库迁移
    ├── POST /api/auth/register（含邮箱验证邮件）
    ├── POST /api/auth/verify-email
    ├── POST /api/auth/login（JWT）
    ├── POST /api/auth/refresh（Rotation）
    └── POST /api/auth/logout

[2] 用户管理
    ├── GET /api/users/me
    ├── PATCH /api/users/me（userName/password）
    ├── GET /api/users/search
    └── DELETE /api/users/me（GDPR 级联）

[3] 卡片 CRUD
    ├── Card 实体 + 数据库迁移
    ├── POST /api/cards（含邮箱验证门控）
    ├── GET /api/cards（含 viewerNickname 隔离）
    ├── GET /api/cards/{id}
    ├── PATCH /api/cards/{id}（条码字段静默忽略）
    └── DELETE /api/cards/{id}

[4] 离线同步
    └── GET /api/cards?updatedAfter=（增量同步，updated+deleted）

[5] 好友系统
    ├── Friendship 实体 + 数据库迁移
    ├── POST /api/friendships（含邮箱验证门控）
    ├── GET /api/friendships
    ├── GET /api/friendships/requests
    ├── PATCH /api/friendships/{id}/accept
    └── DELETE /api/friendships/{id}（含 CardShare 级联删除）

[6] 卡片共享
    ├── CardShare 实体 + 数据库迁移
    ├── POST /api/cards/{id}/shares（含好友前置验证）
    ├── GET /api/cards/{id}/shares
    ├── PATCH /api/card-shares/{id}（viewerNickname）
    └── DELETE /api/card-shares/{id}

[7] 安全加固
    ├── 速率限制配置（symfony/rate-limiter）
    └── Voter 全面覆盖测试
```

---

## Phase 2：体验完善

**目标**：让应用"好用"而不只是"能用"

- [ ] 后端：Sentry 集成（sentry/sentry-symfony bundle，错误上报 + 性能监控）
- [ ] 后端：卡片全文搜索（ILIKE，GET /api/cards?q=）
- [ ] 后端：卡片有效期字段开放（PATCH expiresAt）
- [ ] 后端：Symfony Scheduler 自动归档（每日 3:00 UTC）
- [ ] 后端：归档过滤（GET /api/cards?archived=false）
- [ ] 后端：PushToken 实体 + POST /api/auth/push-token
- [ ] 后端：Symfony Messenger Worker + Expo Push API 集成

---

## Phase 3：平台拓展

**目标**：扩展录入方式、可用平台，增强数据主权

- [ ] 后端：GET /api/users/me/data-export（GDPR 数据导出）
- [ ] 后端：用户隐私设置（不可被搜索选项）

---

## Phase 4：高级功能（可选探索）

- [ ] Apple Wallet / Google Wallet 兼容性调研与实现
- [ ] 卡面照片上传与展示（需引入文件存储）

---

## 依赖关系

```
Phase 1 必须 100% 完成 → Phase 2 开始
Phase 2 推送通知完成 → Phase 3 Web 端推送支持
Phase 3 完成 → Phase 4
```
