# CardPocket — 系统架构文档

> 基于 SPEC.md v1.2

---

## 技术栈总览

```
前端（Expo React Native）
  ↕ HTTPS + JWT
后端（Symfony 7 + API Platform 4）
  ↕
PostgreSQL（主数据库）
Redis（速率限制专用，maxmemory-policy noeviction）

Phase 2：Symfony Messenger Worker → Expo Push API → FCM/APNs
Phase 3：Expo Web（PWA）+ Service Worker
```

---

## 组件架构

### 前端（Expo React Native）

```
src/
├── app/                    # Expo Router 页面
│   ├── (auth)/             # 认证相关页（注册/登录/验证）
│   ├── (tabs)/             # 主 Tab 导航
│   │   ├── index.tsx       # 我的卡片列表
│   │   ├── shared.tsx      # 共享给我的卡片
│   │   └── friends.tsx     # 好友管理
│   └── cards/
│       ├── [id].tsx        # 卡片详情（条码展示）
│       ├── new.tsx         # 添加卡片
│       └── [id]/shares.tsx # 共享管理
├── components/             # 复用 UI 组件
│   ├── BarcodeDisplay.tsx  # 条码渲染（react-native-barcode-svg）
│   └── BarcodeScanner.tsx  # 相机扫码（expo-barcode-scanner）
├── hooks/
│   ├── useAuth.ts          # 认证状态 + Token 管理
│   └── useCards.ts         # 卡片数据 + 离线同步
├── services/
│   ├── api.ts              # API 客户端（fetch + 自动刷新）
│   └── sync.ts             # 离线同步逻辑
└── storage/
    └── secureStore.ts      # expo-secure-store 封装
```

**状态管理**：优先使用 React Query（服务端状态） + Context（认证状态），不引入 Redux。

**离线同步策略**：
1. App 进入前台时触发 `GET /api/cards?updatedAfter=<lastSync>`
2. 响应的 `updated` 覆盖本地缓存，`deleted` 从本地删除
3. 本地缓存使用 expo-secure-store（AES-256）

---

### 后端（Symfony 7 + API Platform 4）

```
src/
├── Entity/
│   ├── User.php
│   ├── Card.php
│   ├── CardShare.php
│   ├── Friendship.php
│   └── PushToken.php       # Phase 2
│   # RefreshToken 由 gesdinet/jwt-refresh-token-bundle 提供，不在 src/Entity/ 下
├── ApiResource/            # API Platform 4 DTO（独立于实体，无 Serialization Groups）
│   ├── Card/
│   │   ├── CardCreateInput.php     # POST body
│   │   ├── CardUpdateInput.php     # PATCH body
│   │   ├── CardOwnerOutput.php     # GET - owner view
│   │   └── CardViewerOutput.php    # GET - viewer view
│   ├── User/
│   │   ├── UserRegisterInput.php
│   │   ├── UserOutput.php
│   │   ├── UserSearchOutput.php
│   │   └── UserUpdateInput.php
│   ├── Friendship/
│   │   ├── FriendshipOutput.php
│   │   └── FriendshipCreateInput.php
│   └── CardShare/
│       ├── CardShareOutput.php
│       ├── CardShareCreateInput.php
│       └── CardShareUpdateInput.php
├── Security/
│   └── Voter/
│       ├── CardVoter.php
│       ├── CardShareVoter.php
│       └── FriendshipVoter.php
├── State/
│   ├── Provider/           # API Platform State Providers（自定义读取逻辑）
│   └── Processor/          # API Platform State Processors（写操作逻辑）
├── Controller/
│   └── Auth/               # 认证端点（非 API Platform 资源）
├── Service/
│   ├── EmailVerification.php
│   └── IncrementalSync.php # updatedAfter 查询逻辑
├── Message/                # Phase 2 Messenger Messages
└── MessageHandler/         # Phase 2 异步 Handler
```

**API Platform 4 关键配置**：
- `#[ApiResource]` 注解在独立 DTO 上，不注解 Entity
- **不使用 Serialization Groups**：每种视图/角色用独立 Output DTO，每种写操作用独立 Input DTO
- **不使用 `stateOptions(entityClass:...)`**：始终用自定义 State Provider/Processor
- State Provider/Processor 负责 DTO ↔ Entity 映射与业务逻辑，Entity 保持纯净
- Voter 只负责授权（能否访问资源）；State Provider 判断角色并返回对应 Output DTO

**关键依赖**：
- `lexik/jwt-authentication-bundle`：JWT 签发与验证（Access Token）
- `gesdinet/jwt-refresh-token-bundle`：Refresh Token 持久化、Rotation、撤销（见 ADR-016）
- `symfony/rate-limiter`：速率限制（专用 Redis 实例，noeviction，安全优先降级，见 ADR-017）

---

## 数据模型

### 实体 ER 图

```
User
 id: uuid PK
 email: string(180) UNIQUE
 password: string
 userName: string(50) UNIQUE
 emailVerifiedAt: datetime|null
 createdAt: datetime
 updatedAt: datetime
 deletedAt: datetime|null
 gdprConsentAt: datetime|null

Card
 id: uuid PK
 owner_id: uuid FK → User
 name: string(200)
 barcodeType: enum(QR_CODE|CODE_128|EAN_13|CODE_39|PDF_417|AZTEC|EAN_8|UPC_A|DATA_MATRIX)
 barcodeContent: text
 color: string(7)|null
 gradient: json|null
 icon: string(50)|null
 expiresAt: datetime|null
 archivedAt: datetime|null
 createdAt: datetime
 updatedAt: datetime

CardShare
 id: uuid PK
 card_id: uuid FK → Card (CASCADE DELETE)
 viewer_id: uuid FK → User
 viewerNickname: string(200)|null
 createdAt: datetime
 updatedAt: datetime
 UNIQUE(card_id, viewer_id)

Friendship
 id: uuid PK
 requester_id: uuid FK → User
 addressee_id: uuid FK → User
 status: enum(PENDING|ACCEPTED)
 createdAt: datetime
 updatedAt: datetime
 UNIQUE(LEAST(requester_id, addressee_id), GREATEST(requester_id, addressee_id))

PushToken [Phase 2]
 id: uuid PK
 user_id: uuid FK → User
 token: string
 platform: enum(IOS|ANDROID|WEB)
 isActive: boolean DEFAULT true
 createdAt: datetime
 updatedAt: datetime
```

### 级联关系

```
User 删除
  → Card (owner_id) CASCADE DELETE
    → CardShare (card_id) CASCADE DELETE
  → CardShare (viewer_id) CASCADE DELETE
  → Friendship (requester_id 或 addressee_id) CASCADE DELETE
    → CardShare（相关好友对的 CardShare）CASCADE DELETE
  → PushToken (user_id) CASCADE DELETE

Friendship 删除
  → 查找双方所有 CardShare（card.owner=A 且 viewer=B，或 card.owner=B 且 viewer=A）
  → 级联删除
  （注：此级联在应用层实现，非数据库外键，因为 CardShare 无直接 FK 到 Friendship）
```

---

## 认证流程

```
注册流程
  POST /register → 创建 User（emailVerifiedAt=null）→ 发送验证邮件
  POST /verify-email → 设置 emailVerifiedAt = now()

登录流程
  POST /login → 验证密码 → 返回 AccessToken(JWT,15min) + RefreshToken(30天)
  AccessToken → 存内存
  RefreshToken → 存 SecureStore（原生）/ httpOnly Cookie（Web）

Token 刷新
  POST /refresh → 验证 RefreshToken → 返回新 AccessToken + 新 RefreshToken（Rotation）
  → 旧 RefreshToken 立即失效

API 请求
  Authorization: Bearer <AccessToken>
  → Symfony JWT Authenticator 验证
  → 如果过期 → 前端自动调用 /refresh → 重试原请求
```

---

## 部署架构

### 生产环境（VPS）

```
Internet
  │ HTTPS (443)
  ▼
Nginx
  ├── /api/* → PHP-FPM (Symfony)
  ├── /api/docs → PHP-FPM (OpenAPI UI)
  └── /静态文件 → 本地磁盘
        │
        ├── PostgreSQL (5432, 仅本地访问)
        ├── Redis:rate-limiter (6380, 仅本地访问, maxmemory-policy noeviction)
        └── 本地磁盘（Phase 3 图片）

后台进程（Phase 2）
  ├── php bin/console messenger:consume async   # 推送队列 Worker
  └── php bin/console scheduler:run             # 归档定时任务
```

### 开发环境

```
Symfony Local Server (https://localhost:8000)
  ↕
Docker: postgres:16-alpine (localhost:5432)
  database: cardpocket_dev
  database: cardpocket_test  # 测试专用，每次测试前 reset
Docker: redis:7-alpine (localhost:6379)  # 速率限制专用，maxmemory-policy noeviction

Expo Dev Server (localhost:19000)
  ↕ 指向 https://localhost:8000
```

---

## 安全边界

| 层 | 机制 |
|----|------|
| 传输 | HTTPS + HSTS |
| 认证 | JWT（15min）+ Refresh Token Rotation |
| 授权 | Symfony Voter（每次操作独立判断） |
| 速率限制 | symfony/rate-limiter（专用 Redis，noeviction，安全优先降级；见 ADR-017） |
| 本地存储 | expo-secure-store（AES-256，TEE/SE）|
| 数据库 | UUID 主键（防 ID 枚举），软删除（deletedAt） |

---

## 测试架构（TDD）

```
tests/
├── Integration/
│   ├── Auth/
│   │   ├── RegisterTest.php
│   │   ├── VerifyEmailTest.php
│   │   ├── LoginTest.php
│   │   ├── RefreshTest.php
│   │   ├── LogoutTest.php
│   │   └── RateLimitTest.php
│   ├── Card/
│   │   ├── CreateCardTest.php
│   │   ├── ListCardsTest.php
│   │   ├── IncrementalSyncTest.php
│   │   ├── UpdateCardTest.php
│   │   └── DeleteCardTest.php
│   ├── Friendship/
│   │   ├── SendRequestTest.php
│   │   ├── AcceptRequestTest.php
│   │   └── RemoveFriendshipCascadeTest.php
│   └── CardShare/
│       ├── CreateShareTest.php
│       ├── ViewerNicknameTest.php
│       └── LeaveShareTest.php
└── Unit/
    ├── Voter/
    │   ├── CardVoterTest.php
    │   └── CardShareVoterTest.php
    └── Service/
        └── IncrementalSyncTest.php
```

**每个测试用例至少覆盖**：
1. 正常路径（Happy Path）
2. 权限拒绝（403 Forbidden）
3. 资源不存在（404）
4. 边界条件（如卡片数量超限）
