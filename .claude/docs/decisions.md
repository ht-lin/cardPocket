# CardPocket — 架构决策记录（ADR）

> 记录关键设计决策、决策原因和已知权衡。新决策追加到末尾，不修改历史条目。

---

## ADR-001：条码存储为原始字符串，前端渲染

**状态**：已采纳  
**日期**：2026-06-01

**决策**：只存 `barcodeContent`（字符串）+ `barcodeType`（枚举），不在后端生成条码图片。

**原因**：
- 数据量极小（纯文本），不产生图片文件存储压力
- 前端库（react-native-barcode-svg）可动态渲染所有格式
- 修改灵活（改名称不需要重新生成图片）

**权衡**：前端需要引入条码渲染库；浏览器端渲染 SVG 有极小的性能开销（可忽略）。

---

## ADR-002：条码内容创建后不可修改

**状态**：已采纳  
**日期**：2026-06-01

**决策**：`barcodeType` 和 `barcodeContent` 在 PATCH 请求中静默忽略（不报错）。

**原因**：条码代表实体卡片的物理编号，修改等同于换了一张卡。用户应删除旧卡并新建。

**权衡**：用户如果真的输错了条码，只能删了重建。但这个场景比较罕见，且行为更清晰。

---

## ADR-003：好友关系是共享的前置条件

**状态**：已采纳  
**日期**：2026-06-01

**决策**：CardShare 创建时强制验证双方存在 `Friendship(status=ACCEPTED)`。

**原因**：CardPocket 是公开应用，需要防止陌生人向用户强制推送共享内容（类似"被关注才能发 DM"）。好友系统提供信任屏障。

**权衡**：增加了共享的操作步骤（先加好友再共享）。但对于家庭场景来说，一次性成本可接受。

---

## ADR-004：解除好友自动级联删除 CardShare

**状态**：已采纳  
**日期**：2026-06-01

**决策**：DELETE /api/friendships/{id} 触发数据库 CASCADE，删除该好友对之间所有 CardShare。

**原因**：好友关系是共享授权的前提。解除好友后继续保留共享权限会产生"悬空授权"——逻辑上不一致，且是潜在的安全隐患。

**权衡**：用户可能不知道解除好友会同时失去对方的卡片。需要在 UI 上明确提示（"解除好友将同时撤销所有卡片共享"）。

---

## ADR-005：无标签系统，用全文搜索代替

**状态**：已采纳  
**日期**：2026-06-01

**决策**：不实现标签/分类系统，Phase 2 实现全文搜索（按名称 + viewerNickname）。

**原因**：
- 标签需要用户提前分类和维护标签库，增加认知负担
- 对于个人卡包（通常 10-50 张卡），搜索完全够用
- 简化数据模型（去掉 Tag、CardTag 实体）

**权衡**：用户无法按类别浏览（如"看所有超市卡"），需要记住卡片的关键词。在卡片数量少时不是问题。

---

## ADR-006：无卡片备注（notes）字段

**状态**：已采纳  
**日期**：2026-06-01

**决策**：Card 和 CardShare 均不设 notes 字段。CardShare 仅保留 `viewerNickname`。

**原因**：
- 卡片名称本身已有足够描述性（如"家庭 Costco 会员卡"）
- 去掉备注简化数据模型和 UI，降低开发复杂度
- Viewer 的私有昵称已满足个性化核心需求

**权衡**：用户无法记录卡片相关信息（如密码提示、积分规则）。如果将来有强烈需求，可以重新评估。

---

## ADR-007：邮箱验证必须，未验证限制核心功能

**状态**：已采纳  
**日期**：2026-06-01

**决策**：注册后发送验证邮件；未验证账号不能创建卡片、不能发送好友请求；但可以登录、查看已有数据。

**原因**：CardPocket 是公开应用，无邮箱验证会导致垃圾账号大量注册，并被用于骚扰（发送好友请求）。

**权衡**：增加了注册摩擦。缓解方案：注册流程中明显展示"验证邮箱后即可开始使用"的说明。

---

## ADR-008：推送通知使用 Expo Push API，Phase 2 实现

**状态**：已采纳  
**日期**：2026-06-01

**决策**：推送通知延迟到 Phase 2；实现时只使用 Expo Push API（统一封装 FCM + APNs），不直接对接 FCM HTTP v1 或 APNs HTTP/2。

**原因**：
- Expo Push API 大幅简化服务端实现，无需分平台处理
- Phase 1 MVP 不需要推送（用户打开 App 时同步即可）
- 避免过早引入 Firebase/APNs 证书配置的复杂度

**权衡**：依赖 Expo 的推送基础设施（可用性风险极低，Expo 是 React Native 生态主流）。

---

## ADR-009：开发采用后端 TDD + 前端同步模式

**状态**：已采纳  
**日期**：2026-06-01

**决策**：后端每个功能先写测试（PHPUnit + ApiTestCase），通过后前端才开始实现对应 UI。

**原因**：
- TDD 确保 API 契约在实现前就被明确（测试即文档）
- 防止前端和后端并行开发导致的接口不一致问题
- 单人开发时顺序开发比并行更高效（避免上下文切换）

**权衡**：初期进度可能感觉较慢（写测试有额外成本），但后期 debug 和重构成本大幅降低。

---

## ADR-010：本地开发使用 Docker PostgreSQL

**状态**：已采纳  
**日期**：2026-06-01

**决策**：开发环境统一使用 Docker 运行 PostgreSQL，不使用 SQLite。

**原因**：
- 生产环境是 PostgreSQL，开发用同一数据库避免兼容性问题
- PostgreSQL 特有语法（ILIKE、UUID、JSON 字段）在 SQLite 下不可用
- Docker Compose 一行命令即可启动，学习成本低

**权衡**：需要在开发机上安装 Docker（小成本）。

---

## ADR-011：图片录入方式延迟到 Phase 3

**状态**：已采纳  
**日期**：2026-06-01

**决策**：从相册导入图片解码 QR、iOS Share Sheet / Android Intent 接收图片均为 Phase 3 功能；MVP 只有相机扫码 + 手动输入。

**原因**：
- 相机扫码覆盖 95% 的日常添加场景
- Share Extension / Intent 需要额外的 native 配置（Expo bare workflow 或 EAS Build 插件），增加 MVP 复杂度
- MVP 应专注核心流程稳定性

**权衡**：用户拿到截图 QR Code 时只能手动输入，体验稍差。Phase 3 解决。

---

## ADR-012：API Resource 使用独立 DTO 类，不放在 Entity 上

**状态**：已采纳  
**日期**：2026-06-02

**决策**：`#[ApiResource]` 只注解在 `src/ApiResource/` 下的独立 DTO 类上，Entity 不携带任何 API Platform 注解。

**原因**：
- Entity 耦合 API 契约导致字段控制困难：`viewerNickname` 隔离、`barcodeType/barcodeContent` 不可改、用户搜索不暴露 `email` 等需求，在 Entity 上实现需要堆积复杂的 Group 注解逻辑
- DTO 类本身即 API 契约——有哪些字段就暴露哪些字段，无需额外过滤
- 与 Entity 解耦后，域模型可独立演化，不受 API 格式影响

**权衡**：需要额外的 DTO 类文件和 State Provider/Processor 做映射，样板代码更多。但对于本项目的 Owner/Viewer 角色差异、字段不可变性等需求，这是唯一干净的方案。

---

## ADR-013：不使用 Serialization Groups，每种视图用独立 DTO

**状态**：已采纳  
**日期**：2026-06-02

**决策**：不在 DTO 上使用 `#[Groups([...])]` 注解。每种视图（Owner/Viewer）用独立 Output DTO，每种写操作（POST/PATCH）用独立 Input DTO。

**原因**：
- Serialization Groups 将角色判断逻辑散落在两处：DTO 注解（声明哪些字段属于哪个 Group）和 State Provider（设置 context groups）。独立 DTO 让每个类的字段一目了然，角色逻辑集中在 State Provider 中
- 独立 DTO 可以独立测试，也无需 `stateOptions(entityClass:...)` 告知内置 Provider 查哪张表
- `CardViewerOutput` 有 `viewerNickname`，`CardOwnerOutput` 没有——这比 `#[Groups(['card:viewer'])]` 更显式、更安全

**推论**：不使用 `stateOptions: new Options(entityClass: ...)` ——该配置专为内置 Doctrine Provider 设计，使用自定义 Provider 后完全不需要。

**权衡**：Output DTO 类数量增加（每个资源 2-3 个类）。对于本项目规模完全可控。

---

## ADR-014：在 Input DTO 上使用 `#[UniqueEntity(entityClass:)]` 验证唯一性

**状态**：已采纳  
**日期**：2026-06-02

**决策**：唯一性约束（如 email、userName 是否已被注册）写在 Input DTO 上，使用
`#[UniqueEntity(fields: [...], entityClass: User::class, errorPath: '...')]`，
而非在 Entity 上标注 `#[UniqueEntity]` 后在 Processor 中手动调用 `$validator->validate($entity)`。

**原因**：
- API Platform 的 `ValidateProcessor` 在调用自定义 Processor 之前自动对 Input DTO 运行 Symfony Validator，唯一性检查自动发生，Processor 不需要处理违规情况，保持纯净
- `entityClass` 参数告诉 `UniqueEntityValidator` 查询哪张表（Entity），而非 DTO 本身（DTO 没有对应的数据库表）
- `fields` 中的属性名须同时存在于 Input DTO（作为取值来源）和 Entity（作为 repository 查询 key）——两者命名一致时自动匹配
- `errorPath` 确保违规错误附加到正确的字段路径，API Platform 自动生成标准 422 响应体（含 `violations[].propertyPath`）

**适用场景**：所有 Input DTO 中需要检查数据库唯一性的字段（email、userName、卡片名称去重等）。

**权衡**：`fields` 名称需要在 Input DTO 和 Entity 上保持一致；如果将来 Entity 字段改名，Input DTO 中的 `fields` 参数也要同步更新。Race condition 极小（个人项目并发极低，可接受）。

---

## ADR-015：邮箱验证 token 失败统一返回 422，不区分"不存在/已过期/已使用"

**状态**：已采纳  
**日期**：2026-06-03

**决策**：`VerifyEmailProcessor` 对"token 不存在"、"token 已过期"、"token 已使用"三种失败情况统一抛出相同的 `ValidationException`（422），消息为 `"Invalid or expired token."`，不做区分。

**原因**：
- 防止 token 枚举攻击：若 404 表示"不存在"、422 表示"已过期"，攻击者可以推断 token 存在状态，进而暴力枚举有效 token
- 与项目已有 422 响应格式一致（`violations[].propertyPath: "token"`）

**权衡**：前端无法区分"token 不存在"和"token 已过期"，须统一显示"链接已失效，请重新请求验证邮件"。这对 UX 影响极小。

---

## ADR-016：使用 gesdinet/jwt-refresh-token-bundle 管理 Refresh Token

**状态**：已采纳（v2.0.0 实装）  
**日期**：2026-06-03

**决策**：使用 `gesdinet/jwt-refresh-token-bundle` v2.0.0 管理 Refresh Token 的持久化、轮换（Rotation）和撤销，不手写 `RefreshToken` 实体与轮换逻辑。

**原因**：
- 该 bundle 内置 Token Rotation（`single_use: true`）、过期清理，手写会重复实现相同逻辑
- 与 `lexik/jwt-authentication-bundle` 天然集成，无需额外桥接代码
- `/api/auth/refresh` 端点由 bundle 的 `RefreshTokenAuthenticator`（security firewall）接管，无需实现 State Processor
- Logout（撤销 token）通过 bundle 的 `RefreshTokenManagerInterface::delete()` 一行完成

**权衡**：
- gesdinet 的 `RefreshToken` 实体字段固定（`username`、`refreshToken`、`valid`），不包含 `usedAt`（重用检测）和 `revokedAt`（精细审计）。本项目不需要重用检测（Rotation 本身已保证旧 token 失效），放弃这两个字段可接受
- 实体表名默认为 `refresh_tokens`

**v2.0 实装说明**：
- `App\Entity\RefreshToken` 继承 `Gesdinet\JWTRefreshTokenBundle\Entity\RefreshToken`（XML mapped-superclass），需在 `doctrine.yaml` 的 `mappings` 中显式注册 bundle 的 XML 映射路径（`vendor/gesdinet/jwt-refresh-token-bundle/config/doctrine`）
- **路由必须显式注册**：`RouterListener`（priority 32）先于 Firewall（priority 8）运行；若 `/api/auth/refresh` 未在路由表中注册，RouterListener 直接 404，firewall 无法介入。在 `config/routes/security.yaml` 添加 `api_auth_refresh` 路由即可
- 配置使用 `single_use: true`（**非** `ttl_update: true`）：`ttl_update` 只延长同一 token 的有效期（滑动窗口，token 值不变），`single_use` 才是真正 Rotation——每次刷新删除旧 token、颁发新 token
- `RefreshTokenGeneratorInterface::createForUserWithTtl()` 只创建实体，不自动持久化，必须显式调用 `RefreshTokenManagerInterface::save()`
- 登录 Processor 中手动调用 Generator + Manager::save()，不依赖 `AttachRefreshTokenOnSuccessListener`（该 listener 仅在 Lexik JWT 触发 AUTHENTICATION_SUCCESS 事件时生效，自定义 Processor 不会触发该事件）
- **响应格式转换**：bundle 默认返回 `{"token": "..."}` 而非 `{"access_token": "..."}`。通过 `AuthenticationSuccessSubscriber` 监听 `Lexik Events::AUTHENTICATION_SUCCESS`（priority -10，在 Gesdinet 的 `AttachRefreshTokenOnSuccessListener` 之后），将 `token` 重命名为 `access_token` 并注入 `expires_in`。此事件仅由 gesdinet refresh 流程触发，不影响 `LoginProcessor` 的自定义响应

---

## ADR-017：速率限制使用专用 Redis 实例，降级策略为安全优先

**状态**：已采纳  
**日期**：2026-06-03

**决策**：`symfony/rate-limiter` 使用独立于应用缓存的专用 Redis 实例作为存储后端；该实例设置 `maxmemory-policy noeviction`；当 Redis 不可用时，降级策略为**安全优先**（拒绝请求而非放行）。

**原因**：
- **存储隔离**：若速率限制计数器与应用缓存（响应缓存、Session 等）共用同一 Redis 实例，高负载下缓存淘汰策略（如 `allkeys-lru`）可能意外驱逐限速计数器，导致限速窗口静默重置，形成安全漏洞
- **noeviction 策略**：限速计数器必须精确、不可丢失；`noeviction` 在内存满时返回写入错误而非静默删除数据，维护计数器完整性；若触发则发出告警并扩容
- **安全优先降级**：速率限制的核心目的是防暴力破解和滥用；若 Redis 故障时放行所有请求，等同于限速完全失效，攻击者可趁故障窗口攻击登录/注册端点；故障时应拒绝请求（返回 503），而非静默放行

**权衡**：
- 需要额外运维一个 Redis 实例（成本轻微增加）
- 安全优先降级在 Redis 故障期间会影响合法用户（受限端点暂时不可用）；通过监控告警缩短故障恢复时间来缓解

**实装说明（Phase 1）**：
- 三个 limiter 定义在 `config/packages/rate_limiter.yaml`，`dev` / `test` 环境通过同文件内的 `when@dev` / `when@test` 块覆盖为 `no_limit`：

  | limiter 名称 | 策略 | 阈值 | 窗口 |
  |---|---|---|---|
  | `register_by_ip` | sliding_window | 5 次 | 1 小时 |
  | `login_by_ip` | sliding_window | 10 次 | 1 分钟 |
  | `resend_verification_by_user` | sliding_window | 3 次 | 1 小时 |

- Redis 服务：根目录 `docker-compose.yml` 中的 `redis_rate_limiter`（`redis:7-alpine`，`--maxmemory-policy noeviction`，本地端口 6379）；原 `backend/compose.yaml` 已于 BE-AUTH-06 合并到根目录并删除
- Cache pool：`config/packages/cache.yaml` 中的 `cache.rate_limiter`（`cache.adapter.redis`，读取环境变量 `REDIS_URL_RATE_LIMITER`）
- Redis 客户端：使用 `predis/predis`（纯 PHP 实现），而非 php-redis C 扩展；原因：php-redis v6.x 的 `pubsub()` 签名与 Symfony `RedisProxy` 不兼容，导致测试环境 fatal error
- 限速器集成：`UserRegisterProcessor`（`limiter.register_by_ip`）和 `LoginProcessor`（`limiter.login_by_ip`）通过 `#[Autowire(service: '...')]` 注入 `RateLimiterFactory`，超限时抛 `TooManyRequestsHttpException`（429）
- `testRegisterRateLimitReturns429` 测试：⏸️ 暂缓。Symfony 编译容器对私有服务的 `$privates[]` 直接访问导致 `getContainer()->set()` 无法替换，需调查更可靠的覆盖方式
- 503 降级行为（Redis 不可用时拒绝请求）的集成测试同样待实现

---

## ADR-018：前端表单处理使用 React Hook Form + Zod

**状态**：已采纳（2026-06-07 前端架构重新规划后确认保留）
**日期**：2026-06-04

**决策**：从 Phase 1 认证界面起，所有前端表单使用 `react-hook-form` 管理状态，通过 `@hookform/resolvers/zod` 桥接 `zod` schema 进行验证。

**原因**：
- React Hook Form 基于非受控组件，减少不必要的 re-render，性能优于受控方案
- Zod schema 作为 single source of truth：同时提供运行时验证逻辑和 `z.infer<>` 推导出的 TypeScript 类型，避免类型定义与验证规则分离导致的漂移
- 认证页面（注册/登录）是输入最密集的界面，也是最先开发的，在此统一引入可为后续卡片编辑、用户设置表单建立规范

**权衡**：
- 增加两个依赖（`react-hook-form`、`zod`）和一个桥接包（`@hookform/resolvers`）
- 团队需要了解 `useForm` + `zodResolver` 的使用模式；对于极简单的单字段输入（如搜索框）可直接用 `useState`，无需 RHF

---

## ADR-019：错误监控使用 Sentry，Phase 2 引入

**状态**：已采纳
**日期**：2026-06-04

**决策**：Phase 2 引入 Sentry 作为错误监控与性能追踪方案。前端使用 `@sentry/react-native`，后端使用 `sentry/sentry-symfony` bundle。

**原因**：
- Phase 1 目标是 MVP 可运行，运维工具属于体验完善阶段的基础设施
- Sentry 同时覆盖前后端，统一告警入口，避免前后端错误分散在不同系统
- React Native SDK 支持 Expo，集成成本低；Symfony bundle 支持自动捕获未处理异常和慢请求

**权衡**：
- 需要创建 Sentry 项目并管理 DSN 配置（环境变量）
- 需注意 PII 过滤：用户邮箱、卡片内容等敏感字段不得上报到 Sentry（须配置 `beforeSend` 过滤）

---

## ADR-020：BE-USER-04 级联删除测试推迟到各实体模块

**状态**：已完成（2026-06-06）
**日期**：2026-06-04

**决策**：DELETE /api/users/me 的级联删除测试（Cards/CardShares/Friendships）推迟到对应实体创建时实现，BE-USER-04 只覆盖软删除核心逻辑（3 个测试：返回 204、未认证 401、软删除后无法登录）。

**原因**：
- 编写 BE-USER-04 时，Card/CardShare/Friendship 实体尚未创建，级联测试无法编译运行
- 创建最小实体桩（stub）会与 BE-CARD-01/BE-FRIEND/BE-SHARE 的实体定义产生耦合，增加后续迁移摩擦
- 软删除核心逻辑（`deletedAt`）完全独立于级联逻辑，可先行测试验证

**权衡**：
- BE-USER-04 的测试覆盖暂不完整，需在 BE-CARD/BE-FRIEND/BE-SHARE 模块中各自补充级联场景
- `DeleteAccountProcessor` 预留了 `EntityManagerInterface` 注入，后续直接添加级联删除查询即可，扩展成本低

**后续**：级联测试已在 BE-SHARE 阶段全部补齐；GDPR 匿名化测试（3 个）在 BE-GDPR 阶段追加（见 ADR-021）。`DeleteAccountTest.php` 现共 9 个测试。

---

## ADR-021：账户删除使用软删除 + 字段匿名化，而非物理删除

**状态**：已采纳
**日期**：2026-06-06

**决策**：`DELETE /api/users/me` 时，User 和 Card 记录保留行但立即覆写所有个人数据字段：User 的 `email`/`userName`/`password` 替换为无意义占位符，Card 的 `name`/`barcodeContent` 清空。`CardDeletion` 审计行则物理删除。详见 `DeleteAccountProcessor.php`。

**原因**：
- **外键完整性**：Card、CardShare、Friendship、RefreshToken 均有 FK 指向 User；物理删除 User 需要先删所有子记录或依赖 DB CASCADE，逻辑复杂且多步操作难以原子化
- **GDPR Art. 17 合规**：软删除后立即匿名化等同于"删除"个人数据的效果——email/userName/password 被覆写为无意义值，原始数据不可恢复，满足被遗忘权要求
- **`email`/`userName` UNIQUE 约束**：替换为 `deleted_{uuid}@deleted.invalid` / `deleted_{uuid}` 格式保证唯一性（UUID 天然唯一）
- **`CardDeletion` 特殊处理**：该表以普通 VARCHAR 存储 `userId`（无 FK 约束），不受 User 软删除保护，必须物理清除，否则 userId 永久残留构成 GDPR 违规

**权衡**：
- 匿名化后的 User/Card 行仍占用数据库空间（极小，每行约 100-200 字节）
- 前端 JWT 中携带的旧 email 在账户删除后立即失效（email 已变更，任何 JWT 验证都将因找不到用户而 401），无需额外的 token 黑名单机制

---

## ADR-022：前端状态管理：TanStack Query v5 + Zustand

**状态**：已采纳
**日期**：2026-06-07

**决策**：服务端状态（卡片、好友、共享数据）由 TanStack Query v5 管理；客户端状态（user profile、accessToken）由 Zustand 管理。不引入 Redux 或 Context-based auth state。

**原因**：
- TanStack Query 提供缓存、后台重新获取、Optimistic Update 等开箱即用能力，适合 REST API 数据
- Zustand 比 React Context 更适合多处读取的全局状态（如 Axios 拦截器直接调用 `useAuthStore.getState()` 读取 accessToken，不需要在组件树外传递 Context）
- 两者职责清晰，无重叠：Query 管"服务器数据的副本"，Zustand 管"当前会话的身份"

**Token 存储规则**：
- `accessToken`：Zustand 内存，不持久化（符合安全规范）
- `refreshToken`：expo-secure-store（硬件加密）
- `user` profile：Zustand 内存（App 重启后通过 `/refresh` 接口重新获取）

**权衡**：Zustand 增加一个依赖，但比手写 Context + useReducer 更少样板代码。

---

## ADR-023：前端 HTTP 客户端使用 Axios

**状态**：已采纳
**日期**：2026-06-07

**决策**：使用 Axios（单实例）作为 HTTP 客户端，不使用原生 `fetch` 包装。

**原因**：
- Axios 拦截器链（interceptors）是处理"请求注入 token + 响应处理 401 + 并发刷新去重"最直观的方式，避免手写状态机
- 响应拦截器天然支持异步等待（`async/await`），刷新逻辑清晰
- Axios 自动序列化请求体为 JSON，自动解析响应 JSON，减少样板代码

**并发 401 去重方案**：
```ts
let pendingRefresh: Promise<string> | null = null;

// 响应拦截器内
if (!pendingRefresh) {
  pendingRefresh = refreshAccessToken().finally(() => { pendingRefresh = null; });
}
const newToken = await pendingRefresh;
// 用 newToken 重试原请求
```

**权衡**：Axios 比原生 fetch 多一个依赖（~14KB gzip），对 React Native 包体积影响可忽略。

---

## ADR-024：前端不引入 UI 组件库，使用 StyleSheet + 设计 Token

**状态**：已采纳
**日期**：2026-06-07

**决策**：前端 UI 全部使用 React Native 原生 `StyleSheet` + `src/theme.ts` 设计 Token 文件，不引入 NativeWind、Tamagui、GlueStack 等 UI 库。

**原因**：
- CardPocket UI 极简（列表、条码展示、基础表单），不需要复杂组件库
- 任何第三方 UI 库都增加 Expo SDK 升级时的兼容摩擦
- `theme.ts` 统一颜色/间距/圆角常量，足以保证设计一致性

**权衡**：Button、Input、Modal 等基础组件需自行封装（成本低，一次性工作）。若将来暗色模式需求强烈，可引入 Shopify Restyle。

---

## ADR-025：前端离线卡片缓存使用 expo-sqlite

**状态**：已采纳
**日期**：2026-06-07

**决策**：卡片数据离线缓存存储在 `expo-sqlite`（`cards` 表），不使用 expo-secure-store 分条存储。Refresh Token 继续使用 expo-secure-store。

**原因**：
- expo-secure-store 单条 2KB 上限（iOS Keychain 约束），200 张卡的结构化查询无法高效实现
- expo-sqlite 是 Expo 56 内置模块，无需额外安装；支持事务、索引、SQL 查询
- 卡片条码内容的敏感级别：是会员卡条码（给收银台扫描用），非密码/金融数据，存明文 SQLite 可接受

**权衡**：SQLite 文件在 App 沙盒内（iOS/Android 均受系统级文件保护），安全性远高于 AsyncStorage，略低于 Keychain。对本项目场景可接受。

---

## ADR-026：条码渲染使用两个专用库（QR + 线性码分离）

**状态**：已采纳
**日期**：2026-06-07

**决策**：
- `QR_CODE` → `react-native-qrcode-svg`
- 其余线性条码（CODE_128 / EAN_13 / CODE_39 / PDF_417 / AZTEC / EAN_8 / UPC_A / DATA_MATRIX）→ `jsbarcode` 生成 SVG 字符串 + `react-native-svg` 的 `SvgXml` 渲染
- 两者均基于 `react-native-svg`，无额外 SVG 依赖

**渲染方式**：`jsbarcode` 通过虚拟 SVG 节点生成 SVG 标记字符串，`BarcodeDisplay` 用 `SvgXml` 显示：
```tsx
type === 'QR_CODE' ? <QRCode value={content} /> : <SvgXml xml={getBarcodeSvg(content, type)} />
```

**原因**：
- 原 `react-native-barcode-svg` 维护不活跃，API 覆盖不完整
- 原选 `@kichiyaki/react-native-barcode-generator` 但该包最新版本为 0.6.7，npm 无 1.x 版本，可靠性存疑
- `jsbarcode` 是业界标准条码库（3.12.x），支持所有所需格式，活跃维护，纯 JS 实现
- `react-native-qrcode-svg` 是 QR 渲染的事实标准，支持纠错级别、Logo 嵌入（Phase 2 外观自定义用）
- `BarcodeDisplay` 组件内按 `barcodeType` 分支：`type === 'QR_CODE' ? <QRCode /> : <SvgXml />`

**权衡**：jsbarcode 是 Web 库，需配合虚拟 SVG 节点或手动 XML 生成在 RN 中使用；实现略复杂，但格式覆盖完整、依赖可靠性高于 @kichiyaki。

---

## ADR-027：取消生物识别解锁功能（US-21）

**状态**：已采纳
**日期**：2026-06-07

**决策**：US-21（离开 App 一段时间后需要生物识别重新解锁）从项目范围中移除，不在任何 Phase 实现。

**原因**：
- CardPocket 存储的是会员卡条码，不是密码/支付信息，数据敏感级别不要求生物识别保护
- 增加 `expo-local-authentication` 依赖 + AppState 锁屏状态机的实现复杂度与安全收益不成比例
- MVP 应聚焦核心功能（卡片管理 + 共享），锁屏是体验附加功能

**权衡**：部分用户可能希望保护卡包（如家庭共用设备），但该需求属于 Phase 2+ 的体验完善，且可单独引入不影响核心架构。

---

## ADR-028：前端测试策略：Phase 1 写关键测试（Jest + RNTL + MSW）

**状态**：已采纳
**日期**：2026-06-07

**决策**：Phase 1 编写关键路径测试，不追求 100% 覆盖率。工具链：Jest + React Native Testing Library（RNTL）+ MSW（Mock Service Worker）。不引入 E2E 测试（Maestro/Detox 推迟到 Phase 2）。

**测试重点**：
1. Zod schemas（form 验证规则正确性）
2. Axios 拦截器（token 注入 + 401 刷新 + 并发去重）
3. `useSync` hook（增量同步逻辑：updated 写入 / deleted 删除）
4. `BarcodeDisplay` 组件（9 种类型均正确分支）
5. 认证流程屏幕（登录成功/失败，RNTL + MSW）

**原因**：
- 上述 5 类是"改动频繁、出错代价高"的关键路径，测试 ROI 最高
- MSW 在 React Native 中通过 `msw/native` 拦截 fetch/axios，无需启动真实后端
- RNTL 鼓励测试用户行为而非实现细节，避免脆性快照测试
