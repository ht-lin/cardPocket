# 已完成模块归档（Phase 1）

> 此文件仅供回溯参考，不自动加载到 context。当前活跃任务见 current.md。

---

## ✅ 后端基础设施 [BE-INFRA]

### BE-INFRA-01：Docker Compose 配置
- [x] 创建 `docker-compose.yml`（postgres:16）
- [x] 配置两个数据库：`cardpocket_dev` 和 `cardpocket_test`
- [x] 配置数据库端口 5432 映射到 localhost
- [x] 验证：`docker compose up -d && docker ps` 正常运行

### BE-INFRA-02：Symfony 项目初始化
- [x] `composer create-project symfony/skeleton backend`
- [x] 安装依赖：`api-platform/api-pack`、`lexik/jwt-authentication-bundle`、`symfony/mailer`、`symfony/rate-limiter`、`symfony/uid`、`phpunit/phpunit --dev`、`symfony/test-pack --dev`
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

## ✅ 认证模块 [BE-AUTH]

### BE-AUTH-01：User 实体（11 个测试）
- [x] `testRegisterSuccessfully`、`testRegisterFailsWithDuplicateEmail`、`testRegisterFailsWithDuplicateUserName`
- [x] `testRegisterFailsWithoutGdprConsent`、`testRegisterFailsWithWeakPassword`、`testRegisterFailsWithBlankEmail`
- [x] `testRegisterFailsWithInvalidEmailFormat`、`testRegisterFailsWithBlankPassword`、`testRegisterFailsWithBlankUserName`
- [x] `testRegisterFailsWithUserNameTooShort`、`testRegisterFailsWithUserNameTooLong`

实现：`User.php`、`UserRegisterInput.php`、`UserRegisterOutput.php`、`UserFactory.php`、`UserRegisterProcessor.php`、迁移 `Version20260601231109.php`

### BE-AUTH-02：邮箱验证（6 个测试）
- [x] `testVerifyEmailSuccessfully`、`testVerifyEmailFailsWithExpiredToken`、`testVerifyEmailFailsWithUsedToken`
- [x] `testVerifyEmailFailsWithNonExistentToken`、`testVerifyEmailFailsWithBlankToken`、`testVerifyEmailFailsWithMissingTokenField`

实现：`EmailVerificationToken` 实体、`EmailVerificationService.php`

### BE-AUTH-03：登录（9 个测试）
- [x] `testLoginSuccessfully`、`testLoginFailsWithWrongPassword`、`testLoginFailsWithNonExistentEmail`
- [x] `testLoginFailsWithSoftDeletedUser`、`testWrongPasswordAndNonExistentEmailReturnIdenticalResponse`
- [x] `testLoginFailsWithBlankEmail`、`testLoginFailsWithInvalidEmailFormat`、`testLoginFailsWithBlankPassword`
- [x] `testLoginSucceedsWithUnverifiedEmail`

实现：`gesdinet/jwt-refresh-token-bundle` v2.0.0、`RefreshToken.php`、`LoginInput/Output/Processor`

### BE-AUTH-04：Refresh Token Rotation（4 个测试）
- [x] `testRefreshSuccessfully`、`testRefreshFailsWithExpiredToken`、`testRefreshFailsWithNonExistentToken`、`testOldRefreshTokenIsRevokedAfterRotation`

实现：`single_use: true`、`AuthenticationSuccessSubscriber.php`（`token` → `access_token` 重命名）

### BE-AUTH-05：登出（5 个测试）
- [x] `testLogoutSuccessfully`、`testRefreshFailsAfterLogout`、`testLogoutWithNonExistentTokenReturns204`
- [x] `testLogoutFailsWithBlankRefreshToken`、`testLogoutFailsWithMissingRefreshToken`

实现：`LogoutInput.php`、`LogoutOutput.php`、`LogoutProcessor.php`

### BE-AUTH-06：速率限制
- [x] 注册限制：5 次/小时/IP；登录限制：10 次/分钟/IP；重发验证：3 次/小时/用户
- [ ] `testRegisterRateLimitReturns429`（⏸️ 暂缓：Symfony 编译容器私有服务覆盖问题）

---

## ✅ 用户模块 [BE-USER]

### BE-USER-01：GET /api/users/me（3 个测试）
- [x] `testGetMeSuccessfully`、`testGetMeReturnsEmailVerifiedTrueWhenVerified`、`testGetMeFailsWithoutAuth`

实现：`UserOutput.php`、`UserMeProvider.php`

### BE-USER-02：PATCH /api/users/me（4 个测试）
- [x] `testUpdateUserNameSuccessfully`、`testUpdateUserNameFailsWithDuplicate`、`testChangePasswordSuccessfully`、`testChangePasswordFailsWithWrongCurrentPassword`

实现：`UserUpdateInput.php` + State Processor

### BE-USER-03：GET /api/users/search（8 个测试）
- [x] `testSearchByUserName`、`testSearchByEmail`、`testSearchReturnsEmptyArrayWhenNotFound`
- [x] `testSearchReturnsEmptyArrayWhenQIsEmpty`、`testSearchReturnsEmptyArrayWhenQParamMissing`
- [x] `testSearchDoesNotReturnSoftDeletedUser`、`testSearchFailsWhenEmailNotVerified`、`testSearchFailsWithoutAuth`

实现：`UserSearchOutput.php`、`UserSearchProvider.php`

### BE-USER-04：DELETE /api/users/me（9 个测试）
- [x] `testDeleteAccountReturns204`、`testDeleteAccountFailsWithoutAuth`、`testDeletedUserCannotLogin`、`testDeleteAccountCascadesCards`
- [x] `testDeleteAccountCascadesCardShares`（在 BE-SHARE 阶段实现）、`testDeleteAccountCascadesFriendships`（在 BE-SHARE 阶段实现）
- [x] `testDeleteAccountAnonymizesUserPersonalData`、`testDeleteAccountAnonymizesCardContent`、`testDeleteAccountClearsCardDeletionRecords`（在 BE-GDPR 阶段实现）

实现：`DeleteAccountProcessor.php`

---

## ✅ 卡片模块 [BE-CARD]

### BE-CARD-01：Card 实体和 Voter（21 个测试）
- [x] CreateCardTest (9)、GetCardTest (4)、UpdateCardTest (4)、DeleteCardTest (4)

实现：`BarcodeType.php`、`Card.php`、`CardRepository.php`、`CardFactory.php`、Card DTO 类（Create/Update/OwnerOutput/ViewerOutput）、`CardVoter.php`、CRUD Processors/Providers、迁移 `Version20260604161247.php`

### BE-CARD-02：GET /api/cards 含 Viewer 昵称隔离（7 个测试）
- [x] `testOwnerSeesOwnCards`、`testViewerSeesSharedCards`、`testViewerNicknameIsIncludedForViewer`
- [x] `testViewerNicknameIsHiddenFromOwner`、`testListCardsFailsWithoutAuth`、`testDeletedCardIsHiddenFromOwner`、`testOwnerAndViewerCardsAreMerged`

实现：`CardShare.php`（最小实体）、`CardShareRepository.php`、`CardShareFactory.php`、`CardListProvider.php`、迁移 `Version20260604192248.php`

---

## ✅ 增量同步 [BE-SYNC]（3 个测试）

- [x] `testUpdatedAfterReturnsOnlyChangedCards`、`testDeletedIncludesRemovedCards`、`testDeletedIncludesRevokedShares`

实现：`CardDeletion.php`、`CardDeletionRepository.php`、`CardSyncOutput.php`、`IncrementalSyncProvider.php`、迁移 `Version20260604210840.php`

---

## ✅ 好友模块 [BE-FRIEND]（6 个测试）

- [x] `testSendFriendRequestSuccessfully`、`testCannotSendDuplicateRequest`、`testCannotSendRequestToSelf`
- [x] `testAcceptFriendRequestSuccessfully`、`testRejectFriendRequestDeletesRecord`、`testRemoveFriendshipCascadesAllCardShares`

实现：`FriendshipStatus.php`、`Friendship.php`、`FriendshipRepository.php`、`FriendshipFactory.php`、Friend DTO/Voter/Providers/Processors、迁移 `Version20260605125646.php`

---

## ✅ 共享模块 [BE-SHARE]（20 个测试）

### CardShare 集成测试（18 个）

`tests/Integration/CardShare/ShareCardTest.php`（9 个）：
- [x] `testShareCardWithFriendSuccessfully` — POST 201，验证响应字段含 `viewerNickname: null`
- [x] `testGetSharesReturnsEmptyArray` — GET 返回空数组
- [x] `testShareCardFailsIfNotFriends` — 非好友 → 403
- [x] `testShareCardFailsIfAlreadyShared` — 重复共享 → 422
- [x] `testOwnerCannotSeeViewerNickname` — GET 列表中 viewerNickname 恒为 null
- [x] `testGetSharesRequiresAuth` — 未认证 GET → 401
- [x] `testCreateShareRequiresAuth` — 未认证 POST → 401
- [x] `testViewerCannotListShares` — viewer 调用 GET → 403
- [x] `testNonOwnerCannotShareCard` — 第三方调用 POST → 403

`tests/Integration/CardShare/UpdateCardShareTest.php`（4 个）：
- [x] `testViewerCanSetNickname` — PATCH 200，viewerNickname 更新
- [x] `testUpdateCardShareRequiresAuth` — 未认证 PATCH → 401
- [x] `testOwnerCannotSetViewerNickname` — owner 调用 PATCH → 403
- [x] `testThirdPartyCannotUpdateShare` — 第三方 PATCH → 403

`tests/Integration/CardShare/DeleteCardShareTest.php`（5 个）：
- [x] `testOwnerCanRemoveViewer` — owner DELETE → 204
- [x] `testViewerCanLeaveShare` — viewer DELETE → 204
- [x] `testDeleteActuallyRemovesRecord` — 验证 DB 记录真实消失
- [x] `testDeleteCardShareRequiresAuth` — 未认证 DELETE → 401
- [x] `testThirdPartyCannotDeleteShare` — 第三方 DELETE → 403

### 账号删除级联测试（2 个，追加到 DeleteAccountTest）

- [x] `testDeleteAccountCascadesCardShares` — 删除 owner 账号后其卡片的 CardShare 全部消失
- [x] `testDeleteAccountCascadesFriendships` — 删除账号后关联 Friendship 全部消失

### 实现文件

| 文件 | 说明 |
|------|------|
| `src/ApiResource/CardShare/CardShareOutput.php` | 资源定义（4 个操作，两套 URI） |
| `src/ApiResource/CardShare/CardShareCreateInput.php` | POST 输入（viewerId） |
| `src/ApiResource/CardShare/CardShareUpdateInput.php` | PATCH 输入（viewerNickname） |
| `src/Security/Voter/CardShareVoter.php` | CARDSHARE_UPDATE / CARDSHARE_DELETE 权限 |
| `src/State/Provider/CardShareListProvider.php` | GET `/cards/{cardId}/shares`，viewerNickname 对 owner 隐藏 |
| `src/State/Provider/CardShareViewProvider.php` | PATCH/DELETE 单条查询 |
| `src/State/Processor/CardShareCreateProcessor.php` | 好友验证 + 重复检测 + 创建 |
| `src/State/Processor/CardShareUpdateProcessor.php` | viewer 昵称更新 |
| `src/State/Processor/CardShareDeleteProcessor.php` | owner 踢出 / viewer 离开 |
| `src/Repository/CardShareRepository.php` | 新增 `findByCardAndViewer()` |
| `src/Repository/FriendshipRepository.php` | 新增 `findAllInvolvingUser()` |
| `src/State/Processor/DeleteAccountProcessor.php` | 补充删除账号时级联清理 CardShare + Friendship |

---

## ✅ GDPR 合规修复 [BE-GDPR]

### BE-GDPR-01：账户删除匿名化（3 个测试）
- [x] `testDeleteAccountAnonymizesUserPersonalData` — email/userName/password 替换为占位符
- [x] `testDeleteAccountAnonymizesCardContent` — name/barcodeContent 清空
- [x] `testDeleteAccountClearsCardDeletionRecords` — CardDeletion 审计行物理删除

### BE-GDPR-02：IP 地址保留策略文档化
- [x] `rate_limiter.yaml` 补充注释：sliding_window TTL 与窗口时长一致，IP 数据自动过期

### BE-GDPR-03：HTTPS 强制（生产环境）
- [x] `framework.yaml` 添加 `trusted_proxies`（prod）确保 X-Forwarded-Proto 受信
- [x] `HstsHeaderSubscriber.php` 新建（prod-only），所有响应注入 HSTS 头

### 实现文件

| 文件 | 说明 |
|------|------|
| `src/State/Processor/DeleteAccountProcessor.php` | 注入 CardDeletionRepository + User/Card 匿名化 |
| `src/Repository/CardDeletionRepository.php` | 新增 `deleteByUserId(string $userId): void` |
| `src/EventSubscriber/HstsHeaderSubscriber.php` | prod-only HSTS 响应头 |
| `src/Factory/CardDeletionFactory.php` | Foundry 工厂（测试用） |
| `tests/Integration/User/DeleteAccountTest.php` | 追加 3 个 GDPR 测试 |
| `config/packages/framework.yaml` | prod trusted_proxies 配置 |
| `config/packages/rate_limiter.yaml` | TTL 说明注释 |
| `config/services.yaml` | when@prod 注册 HstsHeaderSubscriber |

