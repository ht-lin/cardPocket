# CardPocket — 开发路线图

> 开发模式：后端 TDD → 前端同步实现

---

## Phase 1：MVP（当前阶段）

**目标**：一个可用的数字卡包 + 家庭共享基础

**后端 → 前端顺序（严格按序）**

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

### 前端模块顺序（跟随后端）

```
[后端[1]完成后] 认证界面
    ├── 安装 react-hook-form + zod + @hookform/resolvers
    ├── 注册页（含 GDPR 同意勾选，Zod schema 验证）
    ├── 邮箱验证提示页
    ├── 登录页（Zod schema 验证）
    ├── JWT 存储（内存）+ Refresh Token（SecureStore）
    └── 自动刷新逻辑

[后端[2]完成后] 用户设置界面
    ├── 个人信息页（查看/修改）
    └── 账户删除确认流程

[后端[3]完成后] 卡片基础界面
    ├── 卡片列表页（我的卡片）
    ├── 添加卡片（手动输入 + 条码预览）
    ├── 相机扫码（expo-barcode-scanner）
    ├── 卡片详情页（条码展示 + 亮度提升）
    └── 删除/编辑名称

[后端[4]完成后] 离线支持
    ├── SecureStore 本地缓存
    ├── 进入前台时触发增量同步
    └── 离线状态指示

[后端[5]完成后] 好友界面
    ├── 用户搜索页
    ├── 好友请求发送
    ├── 好友请求列表（接受/拒绝）
    └── 好友列表页

[后端[6]完成后] 共享界面
    ├── 卡片共享管理页（成员列表/添加/移除）
    ├── 共享给我的卡片列表
    ├── Viewer 设置私有昵称
    └── Viewer 退出共享
```

---

## Phase 2：体验完善

**目标**：让应用"好用"而不只是"能用"

- [ ] 前端+后端：Sentry 集成（`@sentry/react-native` + Sentry Symfony bundle，错误上报 + 性能监控）
- [ ] 后端：卡片全文搜索（ILIKE，GET /api/cards?q=）
- [ ] 前端：搜索界面（实时搜索，防抖）
- [ ] 后端：卡片有效期字段开放（PATCH expiresAt）
- [ ] 后端：Symfony Scheduler 自动归档（每日 3:00 UTC）
- [ ] 后端：归档过滤（GET /api/cards?archived=false）
- [ ] 前端：卡片有效期设置 + 即将过期提示
- [ ] 前端：归档分区界面
- [ ] 后端：PushToken 实体 + POST /api/auth/push-token
- [ ] 后端：Symfony Messenger Worker + Expo Push API 集成
- [ ] 前端：expo-notifications 集成（Token 注册 + 通知处理）
- [ ] 前端：卡片外观自定义（颜色选择器/图标选择器）

---

## Phase 3：平台拓展

**目标**：扩展录入方式、可用平台，增强数据主权

- [ ] 前端：从相册选取图片解码 QR（jsQR 库）
- [ ] 前端：iOS Share Extension / Android Intent 接收图片
- [ ] 前端+后端：Web 端（Expo Router + React Native Web）
- [ ] 前端：Web Service Worker 离线缓存
- [ ] 后端：GET /api/users/me/data-export（GDPR 数据导出）
- [ ] 后端+前端：用户隐私设置（不可被搜索选项）

---

## Phase 4：高级功能（可选探索）

- [ ] Apple Wallet / Google Wallet 兼容性调研与实现
- [ ] 深色模式完整支持
- [ ] 卡面照片上传与展示（需引入文件存储）
- [ ] 多语言界面（i18n）

---

## 依赖关系

```
Phase 1 必须 100% 完成 → Phase 2 开始
Phase 2 推送通知完成 → Phase 3 Web 端推送支持
Phase 3 完成 → Phase 4
```
