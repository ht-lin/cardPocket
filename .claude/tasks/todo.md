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
- [x] BE-CARD-01：创建 Card 实体（含所有字段，expiresAt/archivedAt 预留）
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
- [ ] BE-BUGFIX-10：Phase 2 — 添加 Symfony Scheduler 定期清理 90 天前 `CardDeletion` 记录，防止表无限增长

### 前端

> 架构选型（2026-06-07 确认）：TanStack Query v5 + Zustand | Axios | React Hook Form + Zod | expo-sqlite（卡片缓存）| StyleSheet + theme.ts | Jest + RNTL + MSW | react-native-qrcode-svg + jsbarcode + react-native-svg

#### [FE-INFRA] 前端基础设施

- [x] FE-INFRA-01：更新依赖（移除 expo-barcode-scanner、react-native-barcode-svg；安装 axios、zustand、expo-camera、expo-brightness、react-native-qrcode-svg、jsbarcode、@react-native-community/netinfo）
- [x] FE-INFRA-02：安装测试依赖（jest、@testing-library/react-native、msw、jest-expo）
- [x] FE-INFRA-03：theme.ts（颜色 / 字体大小 / 间距 / 圆角设计 Token）
- [x] FE-INFRA-04：Expo Router 路由骨架（`(auth)/` 和 `(app)/` 分组，Tab 结构，各 `_layout.tsx`）
- [x] FE-INFRA-05：Axios client（`src/lib/api/client.ts`：实例 + 请求拦截器注入 Bearer Token + 响应拦截器处理 401 + 并发刷新去重 pending promise）
- [x] FE-INFRA-06：endpoints/ 骨架（`auth.ts` / `cards.ts` / `users.ts` / `friends.ts` / `shares.ts`）
- [x] FE-INFRA-07：Zustand authStore（`user` + `accessToken` 内存存储，`clear()`）
- [x] FE-INFRA-08：secureStore.ts 封装（Refresh Token 专用，类型安全读/写/删）
- [x] FE-INFRA-09：db.ts（expo-sqlite 初始化 + `cards` 表 + `insertOrReplace` / `selectAll` / `deleteByIds`）
- [x] FE-INFRA-10：QueryProvider（TanStack Query v5 QueryClient 全局配置）
- [x] FE-INFRA-11：`(app)/_layout.tsx` Auth Guard（读 Zustand `isAuthenticated` → 未登录 `router.replace('/(auth)/login')`）
- [x] FE-INFRA-12：MSW + Jest 测试基础配置（`__tests__/setup.ts`，server handlers 骨架）
- [x] FE-INFRA-13：Zod schemas 骨架（`schemas/auth.ts` / `card.ts` / `friend.ts` / `cardShare.ts`）

#### [FE-AUTH] 认证界面（后端 BE-AUTH 完成后）

- [x] FE-AUTH-01：登录页（React Hook Form + `LoginSchema` + 调用 `auth.ts` endpoint + 写 Zustand + 写 SecureStore RefreshToken）
- [x] FE-AUTH-02：注册页（React Hook Form + `RegisterSchema` + GDPR 同意勾选）
- [x] FE-AUTH-03：邮箱验证等待页（提示文案 + 重发验证邮件按钮）
- [x] FE-AUTH-04：`EmailVerificationBanner` 组件（已登录但 `emailVerifiedAt` 为 null 时顶部显示）
- [x] FE-AUTH-05：登出功能（`POST /api/auth/logout` + `authStore.clear()` + 清 SecureStore）
- [x] FE-AUTH-06：App 启动会话恢复（读 SecureStore RefreshToken → `POST /refresh` → 写 Zustand user + accessToken）
- [x] FE-AUTH-07：**测试**：Axios 拦截器（token 注入 / 401 触发刷新 / 并发 401 只发一次 refresh）

#### [FE-USER] 用户设置界面（后端 BE-USER 完成后）

- [x] FE-USER-01：个人信息页（展示 `userName` / `email`）
- [x] FE-USER-02：修改 userName（React Hook Form + 422 重名错误提示）
- [x] FE-USER-03：修改密码（当前密码验证 + `ChangePasswordSchema` Zod 规则）
- [x] FE-USER-04：账户注销确认流程（二次确认弹窗 + GDPR 数据清除说明）

#### [FE-CARD] 卡片模块（后端 BE-CARD 完成后）

- [x] FE-CARD-01：`BarcodeDisplay` 组件（`QR_CODE` → `react-native-qrcode-svg`；其余 → `jsbarcode` 生成 SVG 字符串 + `SvgXml` 渲染；按 `barcodeType` 分支）
- [x] FE-CARD-02：我的卡片列表页（从 SQLite 读取展示，后台 TanStack Query 刷新）
- [x] FE-CARD-03：卡片详情页（`BarcodeDisplay` 展示 + `expo-brightness` 进入时最大化亮度 / 离开时恢复）
- [x] FE-CARD-04：添加卡片页（手动输入条码 + 条码类型 Picker + `BarcodeDisplay` 实时预览）
- [x] FE-CARD-05：相机扫码页（`expo-camera` + `onBarcodeScanned` 回调，扫码后跳添加页预填）
- [x] FE-CARD-06：编辑卡片名称（React Hook Form + `PATCH /api/cards/{id}`）
- [x] FE-CARD-07：删除卡片（确认弹窗 + `DELETE /api/cards/{id}` + 删 SQLite 缓存记录）
- [x] FE-CARD-08：**测试**：`BarcodeDisplay` 组件（9 种 barcodeType 均正确分支渲染）

#### [FE-OFFLINE] 离线支持（后端 BE-SYNC 完成后）

- [x] FE-OFFLINE-01：`useSync` hook（`AppState` 'active' → `GET /api/cards?updatedAfter=lastSync` → 写 SQLite，防抖 1s）
- [x] FE-OFFLINE-02：处理增量同步 `deleted` 列表（`db.deleteByIds(deleted)`）
- [x] FE-OFFLINE-03：离线状态 Banner（`@react-native-community/netinfo` 检测无网络时显示）
- [x] FE-OFFLINE-04：**测试**：`useSync` hook（updated 写入 SQLite / deleted 删除 / lastSyncTimestamp 更新）

#### [FE-FRIEND] 好友模块（后端 BE-FRIEND 完成后）

- [ ] FE-FRIEND-01：用户搜索页（输入 userName 或 email，防抖 300ms，`GET /api/users/search`）
- [ ] FE-FRIEND-02：发送好友请求（搜索结果内操作 + Optimistic Update）
- [ ] FE-FRIEND-03：好友请求列表页（接受 / 拒绝 PENDING 请求）
- [ ] FE-FRIEND-04：好友列表页（含解除好友按钮 + 弹窗提示"将同时撤销所有共享"）

#### [FE-SHARE] 共享模块（后端 BE-SHARE 完成后）

- [ ] FE-SHARE-01：卡片共享管理页（Owner 视图：成员列表 + 添加 + 移除）
- [ ] FE-SHARE-02：从好友列表选择共享对象（`POST /api/cards/{id}/shares`）
- [ ] FE-SHARE-03：共享给我的卡片列表页（Viewer 视图）
- [ ] FE-SHARE-04：Viewer 设置私有昵称（内联编辑 + `PATCH /api/card-shares/{id}`）
- [ ] FE-SHARE-05：Viewer 退出共享（确认弹窗 + `DELETE /api/card-shares/{id}`）

---

## Phase 2：体验完善

- [ ] FE: 安装 @sentry/react-native，配置 DSN + beforeSend PII 过滤
- [ ] BE: 安装 sentry/sentry-symfony bundle，配置 DSN + 敏感字段过滤
- [ ] BE: 卡片全文搜索（GET /api/cards?q=，ILIKE）
- [ ] FE: 搜索界面（实时搜索，防抖 300ms）
- [ ] BE: expiresAt 字段开放（PATCH）
- [ ] BE: Symfony Scheduler 自动归档（每日 3:00 UTC）
- [ ] BE: GET /api/cards?archived=false 过滤
- [ ] FE: 有效期设置 UI + 归档分区
- [ ] FE: 即将过期卡片视觉提示
- [ ] BE: PushToken 实体 + POST /api/auth/push-token
- [ ] BE: Symfony Messenger Worker 配置
- [ ] BE: Expo Push API 集成（含 isActive 处理）
- [ ] FE: expo-notifications 集成
- [ ] FE: 卡片外观自定义（颜色 + 图标）

---

## Phase 3：平台拓展

- [ ] FE: 从相册导入 QR Code（jsQR 前端解码）
- [ ] FE: iOS Share Extension 配置
- [ ] FE: Android Intent 接收图片
- [ ] FE+BE: Web 端（Expo Router + React Native Web）
- [ ] FE: Web Service Worker 离线缓存
- [ ] BE: GET /api/users/me/data-export（GDPR 数据导出）
- [ ] BE+FE: 用户隐私设置（不可被搜索）

---

## Phase 4：可选探索

- [ ] Apple Wallet / Google Wallet 调研
- [ ] 深色模式
- [ ] 卡面照片上传（需文件存储方案）
- [ ] 多语言（i18n）
