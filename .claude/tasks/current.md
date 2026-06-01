# 当前任务：Phase 1 MVP — 后端认证模块

> 开发顺序：后端 TDD → 前端同步  
> 当前专注：**[BE-INFRA] 基础设施 + [BE-AUTH] 认证模块**

---

## 进行中

（移入正在做的任务）

---

## 待完成：后端基础设施 [BE-INFRA]

### BE-INFRA-01：Docker Compose 配置
- [x] 创建 `docker-compose.yml`（postgres:16）
- [x] 配置两个数据库：`cardpocket_dev` 和 `cardpocket_test`
- [x] 配置数据库端口 5432 映射到 localhost
- [x] 验证：`docker compose up -d && docker ps` 正常运行

### BE-INFRA-02：Symfony 项目初始化
- [x] `composer create-project symfony/skeleton api`
- [x] 安装依赖：
  ```
  composer require api-platform/api-pack
  composer require lexik/jwt-authentication-bundle
  composer require symfony/mailer
  composer require symfony/rate-limiter
  composer require symfony/uid
  composer require phpunit/phpunit --dev
  composer require symfony/test-pack --dev
  ```
- [x] 配置 `.env` 中的 `DATABASE_URL`（dev 数据库）
- [x] 配置 `.env.test` 中的 `DATABASE_URL`（test 数据库）

### BE-INFRA-03：Doctrine 基础配置
- [x] 确认 UUID 支持：`doctrine/doctrine-bundle` 配置 `uuid` 类型
- [x] 配置软删除过滤器（Doctrine Filter，过滤 `deletedAt IS NOT NULL`）
- [x] 验证数据库连接：`php bin/console doctrine:database:create`

### BE-INFRA-04：测试环境配置
- [x] 配置 `phpunit.xml.dist`（使用 test 数据库）
- [x] 创建 `tests/` 目录结构：`Integration/Auth/`、`Integration/Card/` 等
- [x] 编写 `AbstractApiTestCase`（封装 HTTP 客户端 + 认证 helper）
- [x] 验证：`php bin/phpunit` 运行（空测试通过）

### BE-INFRA-05：JWT 配置
- [x] 生成 JWT 密钥对：`php bin/console lexik:jwt:generate-keypair`
- [x] 配置 `config/packages/lexik_jwt_authentication.yaml`（15min TTL）
- [x] 配置 `config/packages/security.yaml`（防火墙 + JWT Authenticator）

---

## 待完成：认证模块 [BE-AUTH]

### BE-AUTH-01：User 实体

**先写测试** `tests/Integration/Auth/RegisterTest.php`：
- [ ] `testRegisterSuccessfully`：POST /api/auth/register 返回 201，包含 id/userName/emailVerified=false
- [ ] `testRegisterFailsWithDuplicateEmail`：重复 email 返回 422
- [ ] `testRegisterFailsWithDuplicateUserName`：重复 userName 返回 422
- [ ] `testRegisterFailsWithoutGdprConsent`：缺少 gdprConsent 返回 422
- [ ] `testRegisterFailsWithWeakPassword`：密码太弱返回 422

**再实现**：
- [ ] 创建 `src/Entity/User.php`（所有字段：id, email, password, userName, emailVerifiedAt, createdAt, updatedAt, deletedAt, gdprConsentAt）
- [ ] 创建 `src/ApiResource/User/UserRegisterInput.php`（POST 注册用的 Input DTO）
- [ ] 创建 Doctrine 迁移：`php bin/console make:migration`
- [ ] 实现注册 State Processor

### BE-AUTH-02：邮箱验证

**先写测试** `tests/Integration/Auth/VerifyEmailTest.php`：
- [ ] `testVerifyEmailSuccessfully`：有效 token 返回 200，emailVerifiedAt 被设置
- [ ] `testVerifyEmailFailsWithExpiredToken`：24 小时后 token 失效
- [ ] `testVerifyEmailFailsWithUsedToken`：Token 只能用一次

**再实现**：
- [ ] 创建 `EmailVerificationToken` 实体（id, user, token, expiresAt, usedAt）
- [ ] 实现邮件发送 Service（`src/Service/EmailVerificationService.php`）
- [ ] 配置 Symfony Mailer（SMTP DSN 从环境变量读取）
- [ ] 实现 POST /api/auth/verify-email 端点

### BE-AUTH-03：登录

**先写测试** `tests/Integration/Auth/LoginTest.php`：
- [ ] `testLoginSuccessfully`：正确凭据返回 200 含 access_token + refresh_token
- [ ] `testLoginFailsWithWrongPassword`：错误密码返回 401
- [ ] `testLoginFailsWithNonExistentEmail`：不存在的 email 返回 401（不泄露用户存在性）
- [ ] `testLoginFailsWithSoftDeletedUser`：软删除用户返回 401

**再实现**：
- [ ] 创建 `RefreshToken` 实体（id, user, token, expiresAt, usedAt, revokedAt）
- [ ] 实现 POST /api/auth/login 控制器
- [ ] 实现 RefreshToken 生成逻辑（随机 64 字节，存数据库）

### BE-AUTH-04：Refresh Token Rotation

**先写测试** `tests/Integration/Auth/RefreshTest.php`：
- [ ] `testRefreshSuccessfully`：有效 refreshToken 返回新 accessToken + 新 refreshToken
- [ ] `testRefreshFailsWithExpiredToken`：30 天后 token 失效返回 401
- [ ] `testOldRefreshTokenIsRevokedAfterRotation`：旧 refreshToken 刷新后立即失效

**再实现**：
- [ ] 实现 POST /api/auth/refresh 控制器（验证 → 撤销旧 token → 生成新 token pair）

### BE-AUTH-05：登出

**先写测试** `tests/Integration/Auth/LogoutTest.php`：
- [ ] `testLogoutSuccessfully`：登出后 refreshToken 失效
- [ ] `testRefreshFailsAfterLogout`：登出后不能用旧 refreshToken 刷新

**再实现**：
- [ ] 实现 POST /api/auth/logout（设置 revokedAt = now()）

### BE-AUTH-06：速率限制

- [ ] 安装配置 `symfony/rate-limiter`
- [ ] 配置注册限制：5 次/小时/IP（sliding window）
- [ ] 配置登录限制：10 次/分钟/IP
- [ ] 配置验证邮件重发限制：3 次/小时/用户
- [ ] 编写限制触发测试：`testRegisterRateLimitReturns429`

---

## 待完成：用户模块 [BE-USER]

### BE-USER-01：GET /api/users/me

**先写测试** `tests/Integration/User/MeTest.php`：
- [ ] `testGetMeSuccessfully`：返回当前用户信息（不含 password）
- [ ] `testGetMeFailsWithoutAuth`：未认证返回 401

**再实现**：
- [ ] 创建 `src/ApiResource/User/UserOutput.php`（GET /me 响应 DTO，不含 password）
- [ ] 配置 API Platform 自定义 `/me` 端点，State Provider 返回 `UserOutput`

### BE-USER-02：PATCH /api/users/me

**先写测试**：
- [ ] `testUpdateUserNameSuccessfully`
- [ ] `testUpdateUserNameFailsWithDuplicate`：已存在的 userName 返回 422
- [ ] `testChangePasswordSuccessfully`
- [ ] `testChangePasswordFailsWithWrongCurrentPassword`

**再实现**：创建 `UserUpdateInput.php`，State Processor 读取后更新 Entity

### BE-USER-03：GET /api/users/search

**先写测试** `tests/Integration/User/SearchTest.php`：
- [ ] `testSearchByUserName`：精确匹配 userName 返回 [{id, userName}]
- [ ] `testSearchByEmail`：精确匹配 email 返回 [{id, userName}]（响应不含 email）
- [ ] `testSearchReturnsEmptyArrayWhenNotFound`：无匹配返回 []（不是 404）
- [ ] `testSearchFailsWhenEmailNotVerified`：未验证用户返回 403

**再实现**：创建 `UserSearchOutput.php`（只含 id + userName），自定义 State Provider 精确匹配后返回

### BE-USER-04：DELETE /api/users/me（GDPR）

**先写测试** `tests/Integration/User/DeleteAccountTest.php`：
- [ ] `testDeleteAccountCascadesCards`：删后该用户的 Card 被删除
- [ ] `testDeleteAccountCascadesCardShares`：删后相关 CardShare 被删除
- [ ] `testDeleteAccountCascadesFriendships`：删后 Friendship 被删除
- [ ] `testDeletedUserCannotLogin`：软删除后无法登录

**再实现**：State Processor 执行级联清除，最后软删除 User

---

## 待完成：卡片模块 [BE-CARD]

### BE-CARD-01：Card 实体和 Voter

**先写测试** `tests/Integration/Card/CreateCardTest.php`：
- [ ] `testCreateCardSuccessfully`
- [ ] `testCreateCardFailsWhenEmailNotVerified`：返回 403
- [ ] `testCreateCardFailsWhenLimitReached`：200 张上限返回 422
- [ ] `testBarcodeTypeAndContentCannotBeUpdated`：PATCH 时静默忽略

**再实现**：
- [ ] 创建 Card 实体（含 barcodeType enum）
- [ ] 创建 Card DTO 类（`src/ApiResource/Card/`）：
  - `CardCreateInput.php`（POST body）
  - `CardUpdateInput.php`（PATCH body，不含 barcodeType/barcodeContent）
  - `CardOwnerOutput.php`（Owner 视图）
  - `CardViewerOutput.php`（Viewer 视图，含 viewerNickname）
- [ ] 创建 CardVoter（CARD_VIEW, CARD_EDIT, CARD_DELETE）
- [ ] 实现 CRUD 端点

### BE-CARD-02：GET /api/cards 含 Viewer 昵称隔离

**先写测试** `tests/Integration/Card/ListCardsTest.php`：
- [ ] `testOwnerSeesOwnCards`
- [ ] `testViewerSeesSharedCards`：共享卡片出现在列表中
- [ ] `testViewerNicknameIsIncludedForViewer`：Viewer 能看到自己的 viewerNickname
- [ ] `testViewerNicknameIsHiddenFromOwner`：Owner 看不到 Viewer 的昵称

**再实现**：自定义 State Provider，判断当前用户是 Owner 还是 Viewer，返回对应的 `CardOwnerOutput` 或 `CardViewerOutput`

---

## 待完成：增量同步 [BE-SYNC]

**先写测试** `tests/Integration/Card/IncrementalSyncTest.php`：
- [ ] `testUpdatedAfterReturnsOnlyChangedCards`
- [ ] `testDeletedIncludesRemovedCards`：被删除的 Card ID 在 deleted 数组中
- [ ] `testDeletedIncludesRevokedShares`：被撤销共享的 Card ID 也在 deleted 数组中

**再实现**：
- [ ] 实现 `IncrementalSyncProvider`（查询 updatedAt > lastSyncTimestamp + 查询已删除记录）
- [ ] 建议：增加 `CardDeletion` 日志表，记录删除事件和撤销共享事件，供 deleted 查询使用

---

## 待完成：好友模块 [BE-FRIEND]

**先写测试** `tests/Integration/Friendship/`：
- [ ] `testSendFriendRequestSuccessfully`
- [ ] `testCannotSendDuplicateRequest`：重复发请求返回 422
- [ ] `testCannotSendRequestToSelf`：发给自己返回 422
- [ ] `testAcceptFriendRequestSuccessfully`：只有 Addressee 能接受
- [ ] `testRejectFriendRequestDeletesRecord`
- [ ] `testRemoveFriendshipCascadesAllCardShares`：**关键测试**
  - A 共享 2 张卡给 B，B 共享 1 张卡给 A
  - A 解除与 B 的好友关系
  - 验证：3 条 CardShare 记录全部删除

**再实现**：
- 创建 Friendship DTO（`src/ApiResource/Friendship/`）：`FriendshipOutput.php`、`FriendshipCreateInput.php`
- Friendship 实体 + 所有端点 + 应用层级联删除逻辑

---

## 待完成：共享模块 [BE-SHARE]

**先写测试** `tests/Integration/CardShare/`：
- [ ] `testShareCardWithFriendSuccessfully`
- [ ] `testShareCardFailsIfNotFriends`：非好友关系返回 403
- [ ] `testShareCardFailsIfAlreadyShared`：重复共享返回 422
- [ ] `testViewerCanSetNickname`
- [ ] `testOwnerCannotSeeViewerNickname`：权限隔离验证
- [ ] `testOwnerCanRemoveViewer`
- [ ] `testViewerCanLeaveShare`

**再实现**：
- 创建 CardShare DTO（`src/ApiResource/CardShare/`）：`CardShareOutput.php`、`CardShareCreateInput.php`、`CardShareUpdateInput.php`
- CardShare 实体 + CardShareVoter + 所有端点

---

## 完成标准（Phase 1 后端）

- [ ] 所有集成测试通过（`php bin/phpunit`）
- [ ] 覆盖率：每个端点至少有 Happy Path + 403 + 404 测试
- [ ] OpenAPI 文档可访问（`/api/docs`）
- [ ] 所有速率限制配置完毕
- [ ] Docker Compose 启动后一键可运行测试

---

## 前端启动条件

前端模块只在对应后端模块**完全完成且测试通过**后才开始。

| 后端模块完成 | 前端可开始 |
|------------|-----------|
| BE-INFRA + BE-AUTH | FE-AUTH（注册/登录/验证页面）|
| BE-USER | FE-USER（个人设置页）|
| BE-CARD | FE-CARD（卡片列表/添加/详情）|
| BE-SYNC | FE-OFFLINE（离线缓存 + 增量同步）|
| BE-FRIEND | FE-FRIEND（好友管理页面）|
| BE-SHARE | FE-SHARE（共享管理 + 共享列表）|
