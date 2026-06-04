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
- [ ] BE-AUTH-10：实现 POST /api/auth/logout（使 RefreshToken 失效）
- [ ] BE-AUTH-11：配置速率限制（注册 5/h/IP，登录 10/min/IP，验证邮件 3/h/user）
- [ ] BE-AUTH-12：编写所有认证端点的集成测试

#### [BE-USER] 用户模块
- [ ] BE-USER-00：创建 User DTO 类（UserRegisterInput / UserOutput / UserSearchOutput / UserUpdateInput）
- [ ] BE-USER-01：实现 GET /api/users/me
- [ ] BE-USER-02：实现 PATCH /api/users/me（userName + 修改密码）
- [ ] BE-USER-03：实现 GET /api/users/search（精确匹配，只返回 id+userName）
- [ ] BE-USER-04：实现 DELETE /api/users/me（GDPR 级联清除）
- [ ] BE-USER-05：编写用户模块集成测试

#### [BE-CARD] 卡片模块
- [ ] BE-CARD-01：创建 Card 实体（含所有字段，expiresAt/archivedAt 预留）
- [ ] BE-CARD-02：创建 Card 数据库迁移
- [ ] BE-CARD-02b：创建 Card DTO 类（CardCreateInput / CardUpdateInput / CardOwnerOutput / CardViewerOutput）
- [ ] BE-CARD-03：创建 CardVoter（CARD_VIEW, CARD_EDIT, CARD_DELETE）
- [ ] BE-CARD-04：实现 POST /api/cards（含邮箱验证门控 + 200张上限）
- [ ] BE-CARD-05：实现 GET /api/cards（含共享卡片，viewerNickname 隔离）
- [ ] BE-CARD-06：实现 GET /api/cards/{id}
- [ ] BE-CARD-07：实现 PATCH /api/cards/{id}（barcodeType/Content 静默忽略）
- [ ] BE-CARD-08：实现 DELETE /api/cards/{id}
- [ ] BE-CARD-09：编写卡片模块集成测试

#### [BE-SYNC] 增量同步
- [ ] BE-SYNC-01：实现 GET /api/cards?updatedAfter=（返回 updated + deleted）
- [ ] BE-SYNC-02：deleted 列表包含已删除 Card + 已撤销共享的 Card ID
- [ ] BE-SYNC-03：编写增量同步集成测试

#### [BE-FRIEND] 好友模块
- [ ] BE-FRIEND-00：创建 Friendship DTO 类（FriendshipOutput / FriendshipCreateInput）
- [ ] BE-FRIEND-01：创建 Friendship 实体（含联合唯一约束）
- [ ] BE-FRIEND-02：创建 Friendship 数据库迁移
- [ ] BE-FRIEND-03：实现 POST /api/friendships（含邮箱验证门控 + 20/day 限制）
- [ ] BE-FRIEND-04：实现 GET /api/friendships（ACCEPTED 列表）
- [ ] BE-FRIEND-05：实现 GET /api/friendships/requests（PENDING 列表）
- [ ] BE-FRIEND-06：实现 PATCH /api/friendships/{id}/accept
- [ ] BE-FRIEND-07：实现 DELETE /api/friendships/{id}（含 CardShare 级联删除逻辑）
- [ ] BE-FRIEND-08：编写好友模块集成测试（含级联删除测试）

#### [BE-SHARE] 共享模块
- [ ] BE-SHARE-00：创建 CardShare DTO 类（CardShareOutput / CardShareCreateInput / CardShareUpdateInput）
- [ ] BE-SHARE-01：创建 CardShare 实体（含联合唯一约束）
- [ ] BE-SHARE-02：创建 CardShare 数据库迁移
- [ ] BE-SHARE-03：创建 CardShareVoter
- [ ] BE-SHARE-04：实现 POST /api/cards/{id}/shares（含好友前置验证）
- [ ] BE-SHARE-05：实现 GET /api/cards/{id}/shares（Owner only）
- [ ] BE-SHARE-06：实现 PATCH /api/card-shares/{id}（Viewer 设置 viewerNickname）
- [ ] BE-SHARE-07：实现 DELETE /api/card-shares/{id}（Owner 移除 或 Viewer 退出）
- [ ] BE-SHARE-08：编写共享模块集成测试

#### [BE-INFRA] 基础设施
- [x] BE-INFRA-01：Docker Compose 配置（PostgreSQL dev + test 两个数据库）
- [x] BE-INFRA-02：配置测试数据库（DAMA 事务隔离，每次测试自动回滚）
- [ ] BE-INFRA-03：配置 symfony/rate-limiter
- [x] BE-INFRA-04：配置 UUID 主键（Doctrine UuidType）
- [x] BE-INFRA-05：配置 Doctrine 软删除过滤器（deletedAt is null）

### 前端

#### [FE-INFRA] 前端基础设施（可与后端并行开始）
- [x] FE-INFRA-01：Expo 项目初始化 + 依赖安装
- [x] FE-INFRA-02：TypeScript strict 配置
- [x] FE-INFRA-03：Expo Router 路由骨架（layout 文件 + Tab 结构）
- [x] FE-INFRA-04：API 客户端（fetch wrapper + Authorization header + 401 自动刷新）
- [x] FE-INFRA-05：Auth Context + Token 管理（内存 AccessToken + SecureStore RefreshToken）
- [ ] FE-INFRA-06：React Query 配置（QueryClient + 全局 Provider）
- [ ] FE-INFRA-07：SecureStore 封装（类型安全读/写/删）
- [ ] FE-INFRA-08：开发环境配置（API_BASE_URL + app.config.ts）

#### [FE-AUTH] 认证界面（后端 BE-AUTH 完成后）
- [ ] FE-AUTH-00：安装 react-hook-form、zod、@hookform/resolvers
- [ ] FE-AUTH-01：注册页面（Zod schema 验证 + GDPR 同意勾选）
- [ ] FE-AUTH-02：邮箱验证提示页（提示去邮箱验证）
- [ ] FE-AUTH-03：登录页面（Zod schema 验证）
- [ ] FE-AUTH-04：JWT Token 管理（AccessToken 存内存，RefreshToken 存 SecureStore）
- [ ] FE-AUTH-05：自动 Token 刷新（请求拦截 + 401 时自动 refresh）
- [ ] FE-AUTH-06：未验证用户的功能限制提示

#### [FE-CARD] 卡片基础界面（后端 BE-CARD 完成后）
- [ ] FE-CARD-01：我的卡片列表页
- [ ] FE-CARD-02：添加卡片页（手动输入 + 条码类型选择 + 实时预览）
- [ ] FE-CARD-03：相机扫码（expo-barcode-scanner）
- [ ] FE-CARD-04：卡片详情页（条码展示 + 屏幕亮度提升）
- [ ] FE-CARD-05：编辑卡片名称
- [ ] FE-CARD-06：删除卡片（确认弹窗）
- [ ] FE-CARD-07：BarcodeDisplay 组件（支持所有 9 种条码类型）

#### [FE-OFFLINE] 离线支持（后端 BE-SYNC 完成后）
- [ ] FE-OFFLINE-01：expo-secure-store 封装（读/写/删卡片缓存）
- [ ] FE-OFFLINE-02：进入前台时触发增量同步（AppState 监听，1秒防抖）
- [ ] FE-OFFLINE-03：处理 deleted 列表（从本地缓存移除）
- [ ] FE-OFFLINE-04：离线状态展示（banner 提示）

#### [FE-FRIEND] 好友界面（后端 BE-FRIEND 完成后）
- [ ] FE-FRIEND-01：用户搜索页（输入 userName 或 email 精确搜索）
- [ ] FE-FRIEND-02：发送好友请求（搜索结果页内操作）
- [ ] FE-FRIEND-03：好友请求列表页（接受/拒绝）
- [ ] FE-FRIEND-04：好友列表页

#### [FE-SHARE] 共享界面（后端 BE-SHARE 完成后）
- [ ] FE-SHARE-01：卡片共享管理页（查看成员列表 + 添加 + 移除）
- [ ] FE-SHARE-02：从好友列表选择共享对象
- [ ] FE-SHARE-03：共享给我的卡片列表页
- [ ] FE-SHARE-04：Viewer 设置私有昵称（内联编辑）
- [ ] FE-SHARE-05：Viewer 退出共享（确认弹窗）
- [ ] FE-SHARE-06：解除好友时提示共享会被撤销

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
