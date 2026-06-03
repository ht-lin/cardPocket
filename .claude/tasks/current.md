# 当前任务：Phase 1 MVP — 后端认证模块

> 开发顺序：后端 TDD → 前端同步  
> 当前专注：**[BE-INFRA] 基础设施 + [BE-AUTH] 认证模块**

---

## 进行中

### BE-AUTH-05：登出（下一个任务）

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

### BE-AUTH-01：User 实体 ✅

**测试** `tests/Integration/Auth/RegisterTest.php`（11 个，全部通过）：
- [x] `testRegisterSuccessfully`：POST /api/auth/register 返回 201，包含 id/userName/emailVerified=false
- [x] `testRegisterFailsWithDuplicateEmail`：重复 email 返回 422
- [x] `testRegisterFailsWithDuplicateUserName`：重复 userName 返回 422
- [x] `testRegisterFailsWithoutGdprConsent`：缺少 gdprConsent 返回 422
- [x] `testRegisterFailsWithWeakPassword`：密码太弱返回 422
- [x] `testRegisterFailsWithBlankEmail`：空 email 返回 422
- [x] `testRegisterFailsWithInvalidEmailFormat`：无效 email 格式返回 422
- [x] `testRegisterFailsWithBlankPassword`：空密码返回 422
- [x] `testRegisterFailsWithBlankUserName`：空 userName 返回 422
- [x] `testRegisterFailsWithUserNameTooShort`：userName < 2 字符返回 422
- [x] `testRegisterFailsWithUserNameTooLong`：userName > 50 字符返回 422

**实现**：
- [x] 创建 `src/Entity/User.php`（所有字段：id, email, password, userName, emailVerifiedAt, createdAt, updatedAt, deletedAt, gdprConsentAt）
- [x] 创建 `src/ApiResource/User/UserRegisterInput.php`（POST Input DTO，含 UniqueEntity + PasswordStrength 验证）
- [x] 创建 `src/ApiResource/User/UserRegisterOutput.php`（POST Output DTO，携带 #[ApiResource] 注解）
- [x] 创建 `src/Factory/UserFactory.php`（Foundry v2 PersistentObjectFactory）
- [x] 创建 Doctrine 迁移：`migrations/Version20260601231109.php`（app_user 表）
- [x] 实现注册 State Processor：`src/State/Processor/UserRegisterProcessor.php`

### BE-AUTH-02：邮箱验证 ✅

**先写测试** `tests/Integration/Auth/VerifyEmailTest.php`（6 个，全部通过）：
- [x] `testVerifyEmailSuccessfully`：有效 token 返回 200，emailVerifiedAt 和 usedAt 均被设置
- [x] `testVerifyEmailFailsWithExpiredToken`：过期 token 返回 422
- [x] `testVerifyEmailFailsWithUsedToken`：已使用 token 返回 422
- [x] `testVerifyEmailFailsWithNonExistentToken`：不存在的 token 返回 422
- [x] `testVerifyEmailFailsWithBlankToken`：空字符串 token 返回 422
- [x] `testVerifyEmailFailsWithMissingTokenField`：缺少 token 字段返回 422

**再实现**：
- [x] 创建 `EmailVerificationToken` 实体（id, user, token, expiresAt, usedAt）
- [x] 实现邮件发送 Service（`src/Service/EmailVerificationService.php`）
- [x] 配置 Symfony Mailer（SMTP DSN 从环境变量读取）
- [x] 实现 POST /api/auth/verify-email 端点

### BE-AUTH-03：登录 ✅

**测试** `tests/Integration/Auth/LoginTest.php`（9 个，全部通过）：
- [x] `testLoginSuccessfully`：正确凭据返回 200 含 access_token（JWT 三段式正则验证）+ refresh_token（数据库持久化验证）
- [x] `testLoginFailsWithWrongPassword`：错误密码返回 401，响应体无 token，detail 为 "Invalid credentials."
- [x] `testLoginFailsWithNonExistentEmail`：不存在的 email 返回 401，同上
- [x] `testLoginFailsWithSoftDeletedUser`：软删除用户返回 401，同上
- [x] `testWrongPasswordAndNonExistentEmailReturnIdenticalResponse`：两个 401 场景 detail 字段完全相同（防用户枚举）
- [x] `testLoginFailsWithBlankEmail`：空 email 返回 422
- [x] `testLoginFailsWithInvalidEmailFormat`：无效 email 格式返回 422
- [x] `testLoginFailsWithBlankPassword`：空 password 返回 422
- [x] `testLoginSucceedsWithUnverifiedEmail`：未验证邮箱用户可以正常登录（设计意图）

**实现**：
- [x] 安装 `gesdinet/jwt-refresh-token-bundle` v2.0.0，配置 `config/packages/gesdinet_jwt_refresh_token.yaml`（TTL 30天，`ttl_update: true`）
- [x] 创建 `src/Entity/RefreshToken.php` 继承 `Gesdinet\JWTRefreshTokenBundle\Entity\RefreshToken`（mapped-superclass），表名 `refresh_tokens`，生成迁移
- [x] 在 `config/packages/doctrine.yaml` 注册 bundle 的 XML 映射（gesdinet v2 使用安全 firewall authenticator 而非路由控制器）
- [x] 在 `config/packages/security.yaml` 新增 `api_auth_refresh` firewall（`refresh_jwt` authenticator，`check_path: /api/auth/refresh`）
- [x] 实现 POST /api/auth/login State Processor（`LoginInput`/`LoginOutput`/`LoginProcessor`），注入 `RefreshTokenGeneratorInterface` + `RefreshTokenManagerInterface`
- [x] 在 `config/services.yaml` 绑定 `$jwtTtl: '%lexik_jwt_authentication.token_ttl%'`

### BE-AUTH-04：Refresh Token Rotation ✅

**测试** `tests/Integration/Auth/RefreshTest.php`（4 个，全部通过）：
- [x] `testRefreshSuccessfully`：有效 refreshToken 返回新 accessToken + 新 refreshToken（新旧不同，新 token 入库，旧 token 已删除）
- [x] `testRefreshFailsWithExpiredToken`：过期 token 返回 401，响应体无 token 字段
- [x] `testRefreshFailsWithNonExistentToken`：不存在的 token 返回 401
- [x] `testOldRefreshTokenIsRevokedAfterRotation`：旧 token 刷新后立即失效，新 token 仍可继续使用

**实现**：
- [x] 在 `config/routes/security.yaml` 显式注册 `api_auth_refresh` 路由（`RouterListener` priority 32 先于 Firewall priority 8，未注册则 404）
- [x] 将 gesdinet 配置从 `ttl_update: true` 改为 `single_use: true`（`ttl_update` 只延长同一 token 有效期；`single_use` 才是真正 Rotation：刷新时删除旧 token、生成新 token）
- [x] 创建 `src/EventSubscriber/AuthenticationSuccessSubscriber.php`，监听 `Lexik Events::AUTHENTICATION_SUCCESS`（priority -10），将 bundle 默认的 `token` 字段重命名为 `access_token` 并注入 `expires_in`（仅影响 refresh 流，LoginProcessor 走 API Platform Processor 路径，不触发该事件）
- [x] 在 `config/services.yaml` 为 Subscriber 绑定 `$jwtTtl: '%lexik_jwt_authentication.token_ttl%'`

### BE-AUTH-05：登出

**先写测试** `tests/Integration/Auth/LogoutTest.php`：
- [x] `testLogoutSuccessfully`：登出后 refreshToken 失效（DB 校验已删除）
- [x] `testRefreshFailsAfterLogout`：登出后不能用旧 refreshToken 刷新
- [x] `testLogoutWithNonExistentTokenReturns204`：不存在的 token 幂等返回 204
- [x] `testLogoutFailsWithBlankRefreshToken`：空字符串返回 422
- [x] `testLogoutFailsWithMissingRefreshToken`：缺少字段返回 422

**再实现**：
- [x] 创建 `src/ApiResource/Auth/LogoutInput.php`（`refresh_token` 字段，`#[Assert\NotBlank]`）
- [x] 创建 `src/ApiResource/Auth/LogoutOutput.php`（`#[ApiResource]`，`output: false, status: 204`）
- [x] 创建 `src/State/Processor/LogoutProcessor.php`，注入 `RefreshTokenManagerInterface`，调用 `delete()` 撤销 token，token 不存在时幂等忽略，返回 204

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
