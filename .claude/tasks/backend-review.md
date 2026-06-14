# CardPocket 后端代码审查 — 待修复任务

> 来源：2026-06-13 全量后端代码审查（实体 / State Processor·Provider / Voter / 配置 / 迁移 / 测试）。
> 容器 lint 与 ORM mapping 校验均通过；按严重程度排列，逐条修复后勾选。
> 总体评价：质量高于平均水平。DTO 优先的 API Platform 4 设计、Voter 统一鉴权、软删除 + tombstone 增量同步、refresh token 单次轮换、Redis 滑窗限流、~147 个集成测试 + DAMA 事务隔离、`failOnDeprecation` 全开。

---

## 🔴 高优先级（上线前必修）

### [REV-H1] 无效 UUID / 无效 `updatedAfter` 返回 500 ✅ 已修复
- [x] 7 个 Provider/Processor 直接 `Uuid::fromString((string)($uriVariables['id'] ?? ''))`，传 `/api/cards/not-a-uuid` 抛未捕获 `\InvalidArgumentException` → 500（应 404）
- [x] `CardListProvider.php:38` 的 `new \DateTimeImmutable($updatedAfterParam)` 对垃圾输入抛异常 → 500（应 400）
- [x] 涉及：CardViewProvider、CardUpdateProcessor、CardDeleteProcessor、CardShareCreateProcessor、CardShareUpdateProcessor、FriendAcceptProcessor、FriendDeleteProcessor、CardShareViewProvider
- 方案：带 `{id}`/`{cardId}` 的操作加路由 `requirements`（宽松 UUID 正则，挡在 Provider 前 → 404）；`updatedAfter` 解析 try/catch → 400
- 注意：勿用 Symfony `Requirement::UUID`（版本敏感，全零 UUID 不匹配，会改变现有 404 测试语义）
- 测试：补 `not-a-uuid` → 404、`updatedAfter=garbage` → 400 用例
- 实现：新增 `src/Routing/ApiRequirement::UUID`（宽松 36 字符十六进制正则，接受 v7 + nil UUID）；在 CardOwnerOutput/CardShareOutput/FriendshipOutput 的全部 `{id}`/`{cardId}` 操作加 `requirements`；CardListProvider 对 `updatedAfter` try/catch → `BadRequestHttpException`（空串归入无参数分支）。补 8 条 `not-a-uuid`→404 + 1 条 `updatedAfter=garbage`→400 测试。全量 156 测试绿。
- 关键确认：项目未配置 uid 版本，Symfony 7.x 默认生成 **UUID v7**，若误用 `Requirement::UUID`（版本位 `[1-5]`）会使所有真实 ID 路由 404 —— 这是必须用宽松正则的硬性原因。

### [REV-H2] `app_card_share` 缺 `(card_id, viewer_id)` 唯一约束 ✅ 已修复
- [x] `CardShareCreateProcessor` 仅应用层查重，并发请求可插入重复分享记录（Friendship 有 DB 级约束，CardShare 没有）
- 方案：CardShare 实体加 `#[ORM\UniqueConstraint(fields: ['card', 'viewer'])]` + 新建迁移 `CREATE UNIQUE INDEX uniq_card_share_card_viewer`；Processor 兜 `UniqueConstraintViolationException` → 422
- 实现：`CardShare.php` 加 `uniq_card_share_card_viewer` 唯一约束；`migrations/Version20260614111309.php`（diff 生成）建唯一索引；`CardShareCreateProcessor` 保留应用层快路径并把 `flush()` 包 try/catch → 422。测试断言 `pg_indexes` 中索引存在。

### [REV-H3] 删账号不给 viewer 写 tombstone（同步数据不一致）✅ 已修复
- [x] `DeleteAccountProcessor` 用 `deleteByOwner()` 批量删分享，但未写 `CardDeletion` tombstone
- [x] 后果：卡主注销后，viewer 的设备增量同步永远收不到删除通知，本地残留幽灵卡
- 方案：在 `deleteByOwner()` 之前遍历 owner 的分享，为每个 viewer 写 `CardDeletion`（复用 CardDeleteProcessor 逻辑）；需在 CardShareRepository 加 `findByOwner()`
- 实现：`CardShareRepository::findByOwner()` 新增；`DeleteAccountProcessor` 在 `deleteByOwner()` 前为每个 viewer 写 `CardDeletion` tombstone。测试断言注销后 viewer 收到对应 tombstone 行。

### [REV-H4] 改密码 / 删账号不撤销 refresh token + 不清验证 token ✅ 已修复
- [x] `UserUpdateProcessor` 改密码后，已签发 refresh token 仍有效 30 天，无法踢出被盗 token
- [x] `DeleteAccountProcessor` 不清 `refresh_tokens` 表，其 `username` 列存原始 email → 注销后个人数据仍保留最长 30 天（与字段匿名化矛盾）
- [x] `email_verification_token` 行也不清（user 软删，`ON DELETE CASCADE` 不触发）
- 方案：两处用 DQL `DELETE FROM App\Entity\RefreshToken rt WHERE rt.username = :username` 撤销（删账号须在改 email 前执行）；删账号附带 DQL 删 EmailVerificationToken
- 实现：`UserUpdateProcessor` 改密码分支内按 `getUserIdentifier()`(=email) DQL 删 refresh token；`DeleteAccountProcessor` 开头（匿名化覆盖 email 前）DQL 删 refresh token + EmailVerificationToken。测试覆盖改密码后旧 refresh token 失效(401)、注销后 refresh/验证 token 清零。
- 全量测试：161 绿（含本次新增 5 条）。

---

## 🟡 中优先级

### [REV-M5] 唯一性检查竞态返回 500 ✅ 已修复
- [x] UserRegisterProcessor / UserUpdateProcessor「先查后插」，并发时 DB 约束兜底但表现为 500 → 应 catch `UniqueConstraintViolationException` 转 422
- [x] UserRegisterInput 上的 `#[UniqueEntity]` 与 processor 手动查重重复 → 确认哪个生效后删另一个
- 实现：Register 删除 processor 内手动 `findOneBy` 查重（保留 Input 的 `#[UniqueEntity]` 作前置校验），两处 processor 的 `flush()` 包 try/catch `UniqueConstraintViolationException` → 422 兜并发竞态。

### [REV-M6] `CardShareUpdateInput::viewerNickname` 无长度校验 ✅ 已修复
- [x] DB 列 255，超长输入触发 DB 错误 500 → 加 `#[Assert\Length(max: 255)]`
- 实现：`CardShareUpdateInput` 加 `#[Assert\Length(max: 255)]`；测试补 256 字符 → 422。

### [REV-M7] 登录用户枚举 + 防爆破缺口 ✅ 已修复
- [x] LoginProcessor 用户不存在时跳过密码哈希，存在时序差异可枚举注册邮箱 → 对不存在用户跑 dummy hash
- [x] 只有 by-IP 限流，无 by-account 限流，防不住分布式撞库 → 加按 email 键的宽松限流器
- 实现：`LoginProcessor` user 为 null 时对 `DUMMY_HASH`(预生成 bcrypt) 跑一次 `isPasswordValid` 消除时序差异；新增 `login_by_account` 限流器(5/15min，键=email)。现有 `testWrongPasswordAndNonExistentEmailReturnIdenticalResponse` 已覆盖等价响应。

### [REV-M8] `resend-verification` 限流维度不对 ✅ 已修复
- [x] 限流键是攻击者提供的 email（每目标 3 次/h），无 by-IP 限制 → 可对任意已注册邮箱发垃圾验证邮件 → 补 by-IP 限流器
- 实现：新增 `resend_verification_by_ip` 限流器(10/h)；`ResendVerificationProcessor` 注入 `RequestStack`，by-IP 限流先于 by-user，保持不泄露邮箱注册状态语义。

### [REV-M9] 增量同步时钟问题 ✅ 已修复
- [x] `updatedAt > since` 严格比较且秒级精度，同秒更新可能丢失；`since` 由客户端时钟生成，时钟偏移直接丢数据
- 方案：CardSyncOutput 返回服务器端 `syncedAt`，客户端下次以此作 `updatedAfter`
- 实现：`CardSyncOutput` 加 `syncedAt`；`IncrementalSyncProvider` 在查询前捕获 `$serverNow` 并下发，消除客户端时钟依赖。范围限增量响应（全量列表初始高水位属前端首启策略）。

### [REV-M10] `/users/search` 暴露 email → userName 映射 ✅ 已记录
- [x] 任何已验证用户可用 email 精确查询确认「该邮箱是否注册及其用户名」→ 若为好友搜索的产品决定可接受，但应在 PRD 明确记录该隐私权衡
- 处理：与用户确认「仅文档记录」（保持行为）。已在 `prd.md` FR-07 与 `api.md` search 章节补隐私权衡说明（仅精确匹配 / 响应不含 email / 限已验证用户；未来可改为仅按 userName 搜索）。

> M5~M10 完成后全量测试：163 绿（含本轮新增 M6/M9 共 2 条）。

---

## 🟢 低优先级 / 工程化

- [ ] [REV-L11] 无 monolog，生产出错无迹可查 → 尽早补日志组件
- [ ] [REV-L12] 邮件同步发送阻塞注册请求（EmailVerificationService），发件人 `noreply@cardpocket.app` 硬编码 → 引入 messenger 异步化 + 发件人走配置
- [ ] [REV-L13] 无数据清理机制：过期 email_verification_token / refresh_tokens（有 `gesdinet:jwt:clear` 但无 cron）/ app_card_deletion tombstone 无限增长 → 定保留期（如 90 天）+ 定时清理，客户端超期则全量同步
- [ ] [REV-L14] 后端无 CI（`.github/workflows/` 只有 flutter-ci.yml）→ 加 PHP CI（phpunit + 引入 PHPStan，目前无静态分析）
- [ ] [REV-L15] `LoginProcessor` 硬编码 `2592000` 与 gesdinet 配置 `ttl` 重复 → 注入参数
- [ ] [REV-L16] 软删过滤器与各 repository 手写 `deletedAt IS NULL` 冗余 → 统一约定依赖哪一层
- [ ] [REV-L17] prod `doctrine.result_cache_pool` 走 `cache.app`（默认文件系统）→ 多实例部署需切 Redis
- [ ] [REV-L18] `framework.yaml` 开了 `session: true`，纯 stateless API 用不到 → 可关闭
- [ ] [REV-L19] Viewer 无法 GET 单张共享卡：CardVoter::CARD_VIEW 仅允许 owner（注明 Phase 2），但列表接口会返回共享卡 → 前端对共享卡发 `GET /cards/{id}` 会拿 403，注意别踩坑

---

## ✅ 安全方面已做好的点（无需修改，记录备查）

- JWT 密钥未入库（`.gitignore` 正确）
- HSTS 仅 prod 注册；trusted proxies 配置正确
- refresh token 真轮换（`single_use: true`）
- 验证 token 用 `random_bytes(32)`
- resend 接口不泄露邮箱是否注册
- GDPR 删除做了字段匿名化
- `.env` 提交的 `APP_SECRET`/`JWT_PASSPHRASE` 是 dev 值（符合 Symfony 惯例，prod 须用 secrets 管理）
- `uniq_friendship_pair` 用 `LEAST/GREATEST` 实现对称唯一索引
