# CardPocket — 全量任务列表

> 按 Phase 组织。当前进度见 current.md。

---

## Phase 1：MVP

### 后端

#### [BE-AUTH] 认证模块
- [x] BE-AUTH-01：创建 User 实体（含所有字段、软删除、GDPR 字段）
- [x] BE-AUTH-02：创建 User 数据库迁移
- [x] BE-AUTH-03：配置 LexikJWTAuthenticationBundle
- [x] BE-AUTH-04：实现 POST /api/auth/register（含 GDPR consent 验证）
- [x] BE-AUTH-05：实现邮箱验证邮件发送（Symfony Mailer + Resend SMTP）
- [x] BE-AUTH-06：实现 POST /api/auth/verify-email（Token 验证 + 一次性使用）
- [x] BE-AUTH-07：实现 POST /api/auth/login（返回 AccessToken + RefreshToken）
- [x] BE-AUTH-08：实现 Refresh Token Rotation（`single_use: true` + `AuthenticationSuccessSubscriber`）
- [x] BE-AUTH-09：实现 POST /api/auth/refresh
- [x] BE-AUTH-10：实现 POST /api/auth/logout（使 RefreshToken 失效）
- [x] BE-AUTH-11：配置速率限制（注册 5/h/IP，登录 10/min/IP，验证邮件 3/h/user）
- [x] BE-AUTH-12：编写所有认证端点的集成测试

#### [BE-USER] 用户模块
- [x] BE-USER-00：创建 User DTO 类（UserRegisterInput / UserOutput / UserSearchOutput / UserUpdateInput）
- [x] BE-USER-01：实现 GET /api/users/me
- [x] BE-USER-02：实现 PATCH /api/users/me（userName + 修改密码）
- [x] BE-USER-03：实现 GET /api/users/search（精确匹配，只返回 id+userName）
- [x] BE-USER-04：实现 DELETE /api/users/me（软删除；级联删除测试推迟到对应实体模块）
- [x] BE-USER-05：编写用户模块集成测试（级联删除：Cards/CardShares/Friendships）

#### [BE-CARD] 卡片模块
- [x] BE-CARD-01：创建 Card 实体（含核心字段；`expiresAt` 及账户级 `User.expiryPolicy`、回收箱物理清理为 Phase 2，**当前实体未预留 expiresAt/archivedAt**）
- [x] BE-CARD-02：创建 Card 数据库迁移
- [x] BE-CARD-02b：创建 Card DTO 类（CardCreateInput / CardUpdateInput / CardOwnerOutput / CardViewerOutput）
- [x] BE-CARD-03：创建 CardVoter（CARD_VIEW, CARD_EDIT, CARD_DELETE）
- [x] BE-CARD-04：实现 POST /api/cards（含邮箱验证门控 + 200张上限）
- [x] BE-CARD-05：实现 GET /api/cards（含共享卡片，viewerNickname 隔离）
- [x] BE-CARD-06：实现 GET /api/cards/{id}
- [x] BE-CARD-07：实现 PATCH /api/cards/{id}（barcodeType/Content 静默忽略）
- [x] BE-CARD-08：实现 DELETE /api/cards/{id}
- [x] BE-CARD-09：编写卡片模块集成测试

#### [BE-SYNC] 增量同步
- [x] BE-SYNC-01：实现 GET /api/cards?updatedAfter=（返回 updated + deleted）
- [x] BE-SYNC-02：deleted 列表包含已删除 Card + 已撤销共享的 Card ID
- [x] BE-SYNC-03：编写增量同步集成测试
- [x] BE-SYNC-04：重构增量同步以消除 Hydra 嵌套 Collection（技术债，见 ADR-023）—— 增量同步迁出 `GetCollection`，改为独立单资源操作 `GET /api/cards/sync`（`CardSyncProvider`）；`CardSyncOutput.updated` 改承载普通关联数组以避免 JSON-LD item 把内嵌 DTO 当关系；前端移除 `_hydraList()` 容错、直读扁平 `updated`/`deleted`；`IncrementalSyncTest` 断言改为扁平形状

#### [BE-FRIEND] 好友模块
- [x] BE-FRIEND-00：创建 Friendship DTO 类（FriendshipOutput / FriendshipCreateInput）
- [x] BE-FRIEND-01：创建 Friendship 实体（含联合唯一约束）
- [x] BE-FRIEND-02：创建 Friendship 数据库迁移
- [x] BE-FRIEND-03：实现 POST /api/friendships（含邮箱验证门控 + 20/day 限制）
- [x] BE-FRIEND-04：实现 GET /api/friendships（ACCEPTED 列表）
- [x] BE-FRIEND-05：实现 GET /api/friendships/requests（PENDING 列表）
- [x] BE-FRIEND-06：实现 PATCH /api/friendships/{id}/accept
- [x] BE-FRIEND-07：实现 DELETE /api/friendships/{id}（含 CardShare 级联删除逻辑）
- [x] BE-FRIEND-08：编写好友模块集成测试（含级联删除测试）

#### [BE-SHARE] 共享模块
- [x] BE-SHARE-00：创建 CardShare DTO 类（CardShareOutput / CardShareCreateInput / CardShareUpdateInput）
- [x] BE-SHARE-01：创建 CardShare 实体（含联合唯一约束）
- [x] BE-SHARE-02：创建 CardShare 数据库迁移
- [x] BE-SHARE-03：创建 CardShareVoter
- [x] BE-SHARE-04：实现 POST /api/cards/{id}/shares（含好友前置验证）
- [x] BE-SHARE-05：实现 GET /api/cards/{id}/shares（Owner only）
- [x] BE-SHARE-06：实现 PATCH /api/card-shares/{id}（Viewer 设置 viewerNickname）
- [x] BE-SHARE-07：实现 DELETE /api/card-shares/{id}（Owner 移除 或 Viewer 退出）
- [x] BE-SHARE-08：编写共享模块集成测试

#### [BE-INFRA] 基础设施
- [x] BE-INFRA-01：Docker Compose 配置（PostgreSQL dev + test 两个数据库）
- [x] BE-INFRA-02：配置测试数据库（DAMA 事务隔离，每次测试自动回滚）
- [x] BE-INFRA-03：配置 symfony/rate-limiter
- [x] BE-INFRA-04：配置 UUID 主键（Doctrine UuidType）
- [x] BE-INFRA-05：配置 Doctrine 软删除过滤器（deletedAt is null）

#### [BE-BUGFIX] 架构审查修复（2026-06-05 审查后）

> 来源：架构审查报告。优先级：🔴 必修 → 🟡 应修 → 🔵 建议。

**🔴 必修 — 影响数据一致性**

- [x] BE-BUGFIX-01：FriendDeleteProcessor — 解除好友删除 CardShare 时同步写入 CardDeletion 记录，供 Viewer 增量同步感知撤销（`src/State/Processor/FriendDeleteProcessor.php:50-57`）
- [x] BE-BUGFIX-02：CardShare 实体加 `updatedAt` 字段 + migration + 更新 `findUpdatedSharesSince` 条件为 `cs.updatedAt > :since`，否则 viewerNickname 修改永远不进增量同步（`src/Entity/CardShare.php`，`src/Repository/CardShareRepository.php:73`）
- [x] BE-BUGFIX-03：Friendship 双向唯一约束 — 在 migration 中添加 PostgreSQL 表达式索引 `UNIQUE(LEAST(requester_id::text,addressee_id::text), GREATEST(...))` 防止竞态条件产生 (A→B)+(B→A) 双记录（`src/Entity/Friendship.php:17`）

**🟡 应修 — 边界 Case / 潜在 500**

- [x] BE-BUGFIX-04：security.yaml firewall `auth_public` pattern 补充 `resend-verification`，现状靠 LexikJWT pass-through 侥幸放行，应显式配置（`config/packages/security.yaml:25`）
- [x] BE-BUGFIX-05：UserRegisterProcessor — persist 前预检 email / userName 重复，抛 `UnprocessableEntityHttpException`（422），现状会触发 DB constraint 返回 500（`src/State/Processor/UserRegisterProcessor.php:48`）
- [x] BE-BUGFIX-06：UserUpdateProcessor — UUID 相等判断改用 `->equals()` 而非 `!==`（对象引用比较）（`src/State/Processor/UserUpdateProcessor.php:50`）
- [x] BE-BUGFIX-07：DeleteAccountProcessor — 提取 `CardShareRepository::deleteByOwner(User)` 批量删除，消除按卡片循环查询的 N+1（`src/State/Processor/DeleteAccountProcessor.php:39-43`）

**🔵 建议 — 防御性设计**

- [x] BE-BUGFIX-08：CardRepository `findActiveByOwner` / `countActiveByOwner` — 显式加 `deletedAt IS NULL` 条件，不依赖全局 Filter 隐式过滤，方法名与实现语义对齐（`src/Repository/CardRepository.php:23-31`）
- [x] BE-BUGFIX-09：Card.owner FK 改为 `onDelete: 'CASCADE'`，与架构规格 ER 图一致（现状为 `RESTRICT`）（`src/Entity/Card.php:35`）
- [x] BE-BUGFIX-10：定期清理 90 天前 `CardDeletion` tombstone 记录，防止表无限增长 —— 已由 **REV-L13** 完成（`App\Schedule` + `CleanupExpiredDataHandler`，见 `backend-review.md`）
- [ ] BE-BUGFIX-10b：Phase 2 — 物理删除回收箱中 30 天前的软删 `Card` 行及关联 `CardShare`（与上面的 tombstone 清理是不同的两段逻辑；物理删除时需临时禁用 `SoftDeleteFilter`，呼应 REV-L16）

---

## Phase 2：体验完善

- [ ] BE: 安装 sentry/sentry-symfony bundle，配置 DSN + 敏感字段过滤
- [ ] BE: 卡片全文搜索（GET /api/cards?q=，ILIKE）
- [ ] BE: Card.expiresAt 字段 + 迁移；PATCH /api/cards/{id} 开放 expiresAt
- [ ] BE: User.expiryPolicy 字段（enum KEEP|AUTO_TRASH，默认 KEEP）+ 迁移；PATCH /api/users/me 开放 expiryPolicy
- [ ] BE: 回收箱 API —— GET /api/cards/trash（列表，仅 Owner）/ POST /api/cards/{id}/restore（恢复）/ DELETE /api/cards/{id}/permanent（永久删除）
- [ ] BE: CleanupExpiredDataHandler 新增——AUTO_TRASH 用户过期卡片（expiresAt<now）自动软删入箱（写 CardDeletion 墓碑）
- [ ] BE: CleanupExpiredDataHandler 新增——物理删除 deletedAt 超 30 天的 Card + 关联 CardShare（临时禁用 SoftDeleteFilter）
- [ ] BE: PushToken 实体 + POST /api/auth/push-token
- [ ] BE: Symfony Messenger Worker 配置
- [ ] BE: Expo Push API 集成（含 isActive 处理）

---

## Phase 3：平台拓展

- [ ] BE: GET /api/users/me/data-export（GDPR 数据导出）
- [ ] BE: 用户隐私设置（不可被搜索）

---

## Phase 4：可选探索

- [ ] Apple Wallet / Google Wallet 调研
- [ ] 卡面照片上传（需文件存储方案）
