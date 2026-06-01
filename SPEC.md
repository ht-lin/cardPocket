# CardPocket — 产品规格说明书

> 版本：v1.2  
> 日期：2026-06-01  
> 作者：Haotao Lin

---

## 目录

1. [项目概览](#1-项目概览)
2. [技术栈](#2-技术栈)
3. [系统架构](#3-系统架构)
4. [数据模型](#4-数据模型)
5. [认证与授权](#5-认证与授权)
6. [核心功能规格](#6-核心功能规格)
   - 6.1 卡片管理
   - 6.2 条码支持
   - 6.3 共享与权限（MVP）
   - 6.4 离线支持（MVP）
   - 6.5 卡片有效期与归档（Phase 2）
   - 6.6 推送通知（Phase 2）
7. [API 设计规范](#7-api-设计规范)
8. [GDPR 合规](#8-gdpr-合规)
9. [安全模型](#9-安全模型)
10. [部署架构](#10-部署架构)
11. [边界情况与设计决策](#11-边界情况与设计决策)
12. [待解决的开放性问题](#12-待解决的开放性问题)
13. [功能路线图（分阶段）](#13-功能路线图分阶段)

---

## 1. 项目概览

**CardPocket** 是一款 mobile-first 的数字卡包应用，允许用户将会员卡、门票、优惠券等各类条形码卡片数字化存储，并与好友共享访问权限。

### 核心价值主张

- **存储**：将实体卡片的条码数字化，永久存于云端
- **访问**：离线可用，随时展示条码核验
- **共享**：家庭/朋友共享同一张卡（如超市会员卡），权限清晰

### 项目定位

- **公开社区应用**，供任何人注册使用，非商业化运营
- 独立开发者（全职），优先保证 MVP 可交付
- 目标用户：主要欧洲用户（GDPR 适用）
- 原生 App（iOS/Android）是主要客户端；Web 版为次要（Phase 3）

### 主要设计决策

| 决策点 | 决策 | 原因 |
|--------|------|------|
| 卡片组织方式 | 全文搜索，无标签系统 | 标签增加认知负担，搜索足以满足查找需求 |
| 卡片备注 | 不支持 Owner 备注；仅 Viewer 可设私有昵称 | 简化数据模型，Viewer 昵称满足个性化需求 |
| 共享前提 | 好友关系（双方互相接受） | 防止陌生人强制共享，提供信任屏障 |
| 好友解除级联 | 自动撤销所有 CardShare | 避免悬空授权，保持权限一致性 |
| 图片录入方式 | Phase 3 实现（相机扫码是 MVP 主要方式） | MVP 先保证核心流程稳定 |

---

## 1.5 开发方法论

| 端 | 方法 | 说明 |
|----|------|------|
| 后端（Symfony） | **测试驱动开发（TDD）** | 先写测试（PHPUnit + ApiTestCase），再实现功能；每个 API 端点至少覆盖正常路径、权限拒绝、边界异常三类用例 |
| 前端（Expo） | **同步后端开发** | 后端某一模块的 API 完成并通过测试后，前端才开始实现对应 UI；不并行开发未完成的接口 |

> **TDD 节奏**（后端）：Red → Green → Refactor。功能分支合并前必须所有测试通过，不允许 `--no-coverage` 跳过。

---

## 2. 技术栈

### 前端

| 层次 | 技术 | 备注 |
|------|------|------|
| 原生 App | **Expo (React Native)** | iOS + Android，MVP 主要客户端 |
| 条码渲染 | react-native-barcode-svg 或同类库 | 客户端动态渲染，不依赖后端图片 |
| 条码扫描 | expo-camera + expo-barcode-scanner | 仅原生端可用 |
| 推送通知 | expo-notifications | Phase 2，统一封装 FCM + APNs |
| 本地加密存储 | expo-secure-store (iOS Keychain / Android Keystore) | 离线数据加密，PIN/生物识别保护 |
| Web 版本 | Expo Router + React Native Web | **Phase 3**，与原生同代码库 |

### 后端

| 层次 | 技术 | 备注 |
|------|------|------|
| 框架 | **Symfony 7.x** | PHP 主框架 |
| API 层 | **API Platform 4.x** | REST + JSON:LD，自动 OpenAPI 文档 |
| 认证 | **LexikJWTAuthenticationBundle** | Access Token (15 min) + Refresh Token (30 天) |
| ORM | Doctrine ORM | 配合 PostgreSQL |
| 数据库 | **PostgreSQL** | 主数据库 |
| 邮件发送 | Symfony Mailer + SMTP | 邮箱验证 |
| 测试框架 | PHPUnit + API Platform ApiTestCase | TDD；集成测试直接命中真实数据库（测试专用 DB） |
| 队列 | Symfony Messenger（Doctrine transport） | Phase 2 推送通知异步处理 |
| 定时任务 | Symfony Scheduler | Phase 2 自动归档过期卡片 |
| 推送下发 | Expo Push API | Phase 2；统一封装 FCM + APNs，无需直接对接 |

---

## 3. 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                       客户端层                           │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │         Expo Native App（iOS / Android）          │   │
│  │                                                  │   │
│  │  • 相机扫码                                       │   │
│  │  • 生物识别解锁                                   │   │
│  │  • 离线 SecureStore 缓存                          │   │
│  └────────────────────────┬─────────────────────────┘   │
│                           │                             │
└───────────────────────────┼─────────────────────────────┘
                            │ HTTPS / JWT
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   API 层（VPS）                          │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │   Symfony 7 + API Platform 4                    │    │
│  │                                                 │    │
│  │  /api/cards       /api/card-shares              │    │
│  │  /api/friendships /api/users                    │    │
│  │                                                 │    │
│  │  • Symfony Voters 细粒度授权                    │    │
│  │  • Symfony Mailer（邮箱验证）                   │    │
│  │  • Symfony Messenger（Phase 2 推送）            │    │
│  │  • Symfony Scheduler（Phase 2 归档）            │    │
│  └──────────────┬────────────────────┬────────────┘    │
│                 │                    │                   │
│         ┌───────▼──────┐    ┌────────▼──────────┐       │
│         │  PostgreSQL   │    │  本地磁盘（Nginx）  │       │
│         │（主数据）     │    │  （Phase 3 图片用） │       │
│         └──────────────┘    └───────────────────┘       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼（Phase 2）
               ┌────────────────────────┐
               │  Expo Push API         │
               │  → FCM (Android)       │
               │  → APNs (iOS)          │
               └────────────────────────┘
```

### 数据流：离线同步

```
App 启动
    │
    ├── 本地 SecureStore 有数据？
    │       ├── 是 → 立即展示缓存卡片（解锁后）
    │       └── 否 → 显示空状态
    │
    ├── 网络可用？
    │       ├── 是 → GET /api/cards?updatedAfter={lastSyncTimestamp}
    │       │         → 更新本地缓存（新增/修改/删除三种情况）
    │       └── 否 → 继续使用缓存（离线状态，条码可正常展示）
    │
    └── 用户展示卡片
            └── 渲染本地缓存中的 barcodeContent + barcodeType
```

---

## 4. 数据模型

### 实体关系图

```
User ──────< Card
 │
 └──< Friendship >── User
 │
 └──< CardShare >── Card
        │
        └── viewerNickname（Viewer 私有昵称）
```

### 实体详细定义

#### User

```php
id                : uuid (PK)
email             : string(180), unique     // 登录用，不对外暴露
password          : string                  // bcrypt hash（cost ≥ 12）
userName          : string(50), unique      // 唯一用户名，用于显示和好友搜索
emailVerifiedAt   : datetime|null           // 邮箱验证时间；null 表示未验证，限制使用
createdAt         : datetime
updatedAt         : datetime
deletedAt         : datetime|null           // 软删除 → 触发 GDPR 级联清除
gdprConsentAt     : datetime|null           // 注册时记录同意时间
```

> **邮箱验证**：注册后发送验证邮件。未验证的账号可以登录，但**无法创建卡片或发送好友请求**，App 内持续提示验证。验证后立即解锁全部功能。

> **用户搜索**：支持精确匹配 `userName` 或 `email`，结果仅返回 `id + userName`，email 本身不对外暴露。

#### Card

```php
id              : uuid (PK)
owner           : ManyToOne(User)           // 拥有者
name            : string(200)               // 用户自定义名称
barcodeType     : enum                      // 见 6.2 条码支持
barcodeContent  : text                      // 原始条码数据字符串
color           : string(7)|null            // 十六进制颜色，如 #FF5733（Phase 2 UI 增强）
gradient        : json|null                 // {"from":"#FF5733","to":"#C70039","direction":"horizontal"}（Phase 2）
icon            : string(50)|null           // emoji 或图标标识，如 "🎵"（Phase 2 UI 增强）
expiresAt       : datetime|null             // 有效期（Phase 2）
archivedAt      : datetime|null             // 归档时间（Phase 2）
createdAt       : datetime
updatedAt       : datetime
```

> **条码不可修改**：`barcodeType` 和 `barcodeContent` 创建后不可修改。条码代表真实卡片的物理编号，修改等同于换了一张卡，应删旧建新。

> **MVP 范围**：`color`/`gradient`/`icon` 字段在数据库中预留，MVP 阶段 UI 不提供自定义入口；`expiresAt`/`archivedAt` 同样预留，Phase 2 开放。

#### CardShare（共享关系）

```php
id              : uuid (PK)
card            : ManyToOne(Card)           // 被共享的卡片
viewer          : ManyToOne(User)           // 被共享给的用户
viewerNickname  : string(200)|null          // Viewer 对这张卡的私有昵称（不影响 Owner 的 name）
createdAt       : datetime
updatedAt       : datetime

// 约束：card.owner 与 viewer 之间必须存在 Friendship(status=ACCEPTED)，否则拒绝创建
// 联合唯一约束：(card_id, viewer_id)，防止重复共享
```

> **权限模型**：只有两种角色 —— **Owner**（拥有者）和 **Viewer**（查看者）。  
> Viewer 可以查看条码、设置私有昵称，但不能编辑原始卡片数据。

#### Friendship（好友关系）

```php
id              : uuid (PK)
requester       : ManyToOne(User)           // 发起好友请求的用户
addressee       : ManyToOne(User)           // 接收好友请求的用户
status          : enum                      // PENDING | ACCEPTED
createdAt       : datetime
updatedAt       : datetime

// 联合唯一约束：(min(requester_id, addressee_id), max(requester_id, addressee_id))
// 确保同一对用户只有一条记录
// ACCEPTED 后双方互为好友（无需两条记录）
```

> **解除好友的级联处理**：当 Friendship 记录被删除（任一方解除好友），**所有**关联的 CardShare 记录**自动级联删除**。好友关系是共享授权的前提，解除即撤销全部相关权限。

#### PushToken（Phase 2）

```php
id              : uuid (PK)
user            : ManyToOne(User)
token           : string                    // Expo Push Token
platform        : enum                      // IOS | ANDROID | WEB
isActive        : boolean                   // 推送失败后标记为 false，避免无效发送
createdAt       : datetime
updatedAt       : datetime
// 一个用户可有多个 Token（多设备）
```

---

## 5. 认证与授权

### 认证流程

```
POST /api/auth/register       → 注册，发送验证邮件，返回用户信息（功能受限状态）
POST /api/auth/verify-email   → 验证邮箱（携带 token 参数），解锁全部功能
POST /api/auth/login          → 登录，返回 { access_token, refresh_token }
POST /api/auth/refresh        → 刷新 Access Token
POST /api/auth/logout         → 使 Refresh Token 失效
DELETE /api/users/me          → GDPR 删除账户（级联删除所有数据）
```

### Token 策略

| Token | 有效期 | 存储位置 |
|-------|--------|----------|
| Access Token（JWT） | 15 分钟 | 内存（不持久化） |
| Refresh Token | 30 天 | SecureStore（原生）/ httpOnly Cookie（Web） |
| Email Verify Token | 24 小时 | 数据库（一次性使用后失效） |

### 授权（Symfony Voters）

所有资源操作通过 Voter 判断，不通过 Role 系统：

| 操作 | 允许条件 |
|------|----------|
| 查看/展示卡片条码 | Owner 或 Viewer（通过 CardShare） |
| 编辑卡片元数据 | Owner only |
| 删除卡片 | Owner only |
| 邀请/移除共享成员 | Owner only |
| 归档/取消归档（Phase 2） | Owner only |
| 编辑 viewerNickname | Viewer（仅自己那条 CardShare 记录） |
| 退出共享（自己离开） | Viewer only |
| 发送好友请求 | 已验证邮箱的任意用户 |

---

## 6. 核心功能规格

### 6.1 卡片管理

#### 添加卡片

**方式一：相机扫描（MVP，仅原生 App）**
1. 点击「扫描」→ 打开相机
2. 识别条码类型和内容（expo-barcode-scanner）
3. 自动填充 `barcodeType` 和 `barcodeContent`
4. 填写名称，确认保存

**方式二：手动输入（MVP）**
1. 手动输入条码字符串
2. 选择条码类型（下拉菜单）
3. 实时预览渲染效果
4. 填写名称并保存

**方式三：从相册选取图片解码（Phase 3，仅支持 QR Code）**
1. 点击「从图片导入」→ 打开系统相册
2. 选取含 QR Code 的图片
3. 前端 JS 解码（不上传图片到服务器）提取条码内容
4. 自动填充后进入与方式二相同的确认流程

**方式四：从其他 App 分享图片到 CardPocket（Phase 3，仅支持 QR Code）**
1. 在相机、微信、邮件等 App 中长按/选择含 QR Code 的图片
2. 通过 iOS Share Sheet / Android Intent 选择「添加到 CardPocket」
3. App 接收图片，前端解码提取条码内容
4. 进入确认流程，填写名称保存

> **方式三/四说明**：两者均在前端完成解码，图片不上传服务器。依赖 Expo/React Native 的图片选择 API 和 JS QR 解码库（如 jsQR）。

#### 编辑卡片

- 仅 Owner 可编辑
- **`barcodeType` 和 `barcodeContent` 创建后不可修改**
- MVP 可编辑字段：`name`
- Phase 2 可编辑字段：`icon`、`color`、`gradient`、`expiresAt`

#### 删除卡片

- 仅 Owner 可删除
- 级联删除所有 CardShare 记录
- Viewer 下次同步后该卡片从列表消失

#### 查看卡片

- 展示渲染后的条码（SVG）
- 调高屏幕亮度以便扫描（原生端）
- Owner 和 Viewer 均可展示，界面一致
- Viewer 看到的卡片名称：若已设 `viewerNickname`，优先显示；否则显示 Owner 设定的 `name`

#### 卡片全文搜索（Phase 2）

- 按卡片名称搜索（覆盖自己的卡片和共享给我的卡片）
- 共享卡片同时匹配 Owner 的 `name` 和 Viewer 的 `viewerNickname`
- 后端使用 PostgreSQL ILIKE 查询；数据量大时可升级为全文索引

### 6.2 条码支持

支持的格式（前端渲染 + 后端枚举）：

| 格式 | 枚举值 | 典型用途 |
|------|--------|----------|
| QR Code | `QR_CODE` | 会员卡、支付、链接 |
| Code 128 | `CODE_128` | 超市会员卡、物流 |
| EAN-13 | `EAN_13` | 商品条码、图书 |
| Code 39 | `CODE_39` | 工业、门禁 |
| PDF417 | `PDF_417` | 驾照、火车票、登机牌 |
| Aztec | `AZTEC` | 欧洲火车、部分航司 |
| EAN-8 | `EAN_8` | 小型商品 |
| UPC-A | `UPC_A` | 北美零售 |
| Data Matrix | `DATA_MATRIX` | 医疗、工业 |

> 图片解码（方式三/四）仅支持 QR Code，因为其他格式的图片解码精度和库支持不稳定。

### 6.3 共享与权限（MVP）

#### 好友系统（共享的前提条件）

**共享卡片必须在双方已互为好友（`Friendship.status = ACCEPTED`）的前提下才能发起。**

```
发起好友请求：
1. 搜索 → 输入对方 userName 或 email（精确匹配）
2. 找到用户 → 点击「添加好友」
3. 创建 Friendship(status=PENDING)
4. Phase 2：对方收到推送通知

接受 / 拒绝好友请求：
1. 进入「好友请求」列表
2. 接受 → Friendship.status = ACCEPTED
   拒绝 → 删除 Friendship 记录（不通知对方）

解除好友关系：
- 任一方可单方面解除（DELETE /api/friendships/{id}）
- 自动级联删除双方之间所有 CardShare 记录
```

#### 邀请流程（仅限好友间）

```
前提：Owner 与目标用户已互为好友。

1. 打开卡片详情 → 「共享管理」→「添加成员」
2. 从好友列表中选择（仅显示 ACCEPTED 好友，已共享的不再显示）
3. 点击「共享」→ 创建 CardShare
4. Phase 2：对方收到推送通知
```

#### Viewer 私有功能

Viewer 在「共享给我的卡片」列表中可以：
- **查看并展示条码**（主要功能）
- **设置私有昵称**（`viewerNickname`）：仅自己可见，不影响 Owner 的 `name`
- **退出共享**：自行删除 CardShare 记录

#### 权限对比

| 操作 | Owner | Viewer |
|------|-------|--------|
| 查看/展示条码 | ✅ | ✅ |
| 设置私有昵称 | — | ✅ |
| 编辑卡片原始信息 | ✅ | ❌ |
| 删除卡片 | ✅ | ❌ |
| 邀请/移除成员 | ✅ | ❌ |
| 归档（Phase 2） | ✅ | ❌ |
| 退出共享 | — | ✅ |

#### 并发展示

不做任何限制：同一张卡可以同时被 Owner 和多个 Viewer 在各自设备上展示条码。适合家庭共用超市会员卡等场景。

### 6.4 离线支持（MVP）

#### 原生 App

```
数据存储：expo-secure-store（AES-256，由设备 PIN/生物识别保护）
缓存内容：用户所有卡片的完整数据（barcodeContent, barcodeType, name, ...）
          包括共享给我的卡片（含 viewerNickname）
同步策略：App 进入前台时，拉取 GET /api/cards?updatedAfter={lastSyncTimestamp}
冲突策略：服务端优先（Server Wins）—— 无本地写冲突场景

同步响应格式：
{
  "updated": [ {...card}, {...card} ],   // 新增或修改的卡片
  "deleted": [ "uuid1", "uuid2" ]        // 已删除或共享已撤销的卡片 ID
}

特殊情况：
- 卡片被删除或共享被撤销：下次同步时从本地缓存移除
- 网络不可用：展示本地缓存，条码可正常展示（主要离线场景）
```

#### Web 端（Phase 3）

```
缓存策略：Service Worker Cache Storage（网络优先，缓存降级）
加密：Web Crypto API（安全性低于原生 SecureStore）
离线能力：仅缓存最近访问的卡片，不保证全量离线
```

### 6.5 卡片有效期与归档（Phase 2）

- **有效期**：`expiresAt` 字段，Owner 可选填
- **状态显示**：未过期 / 即将过期（7天内）/ 已过期
- **自动归档**：Symfony Scheduler 每天检查 `expiresAt < now()`，设置 `archivedAt`
- **手动归档**：Owner 可随时手动归档/取消归档
- **归档展示**：归档卡片进入独立「归档」分区，不在主列表显示
- **过期提醒**：Phase 2 推送通知 or 本地 Expo Notifications Local（待定）

### 6.6 推送通知（Phase 2）

#### 触发场景

| 事件 | 通知对象 | 内容示例 |
|------|----------|----------|
| 收到好友请求 | Addressee | "XXX 向你发送了好友请求" |
| 被邀请加入共享 | 被邀请的 Viewer | "XXX 共享了「Costco 会员卡」给你" |
| Owner 修改卡片名称 | 所有 Viewer | "「Costco 会员卡」已更新" |
| Owner 删除卡片 | 所有 Viewer | "「Costco 会员卡」已被移除" |
| 被移除共享权限 | 被移除的 Viewer | "你已被从「Costco 会员卡」中移除" |
| Viewer 退出共享 | Owner | "XXX 退出了「Costco 会员卡」的共享" |

#### 技术实现（Phase 2）

```
后端：
1. 事件发生 → Symfony Messenger 推入异步队列（Doctrine transport 初期）
2. Handler 查询目标用户的所有 PushToken（isActive=true）
3. 批量调用 Expo Push API（统一封装 FCM + APNs）
4. 处理响应：
   - DeviceNotRegistered → 将 PushToken.isActive 设为 false
   - 其他错误 → 记录日志，不重试

前端：
- expo-notifications 处理 Token 注册和通知接收
- App 启动时注册/更新 PushToken（POST /api/auth/push-token）
```

---

## 7. API 设计规范

### 基础规范

- 基础路径：`/api`
- 格式：JSON（Content-Type: application/json）
- API Platform 自动生成 OpenAPI 文档（`/api/docs`）
- 认证：Bearer JWT Token

### 主要端点

```
认证
POST   /api/auth/register            注册（email + password + userName）
POST   /api/auth/verify-email        验证邮箱（?token=xxx）
POST   /api/auth/login               登录
POST   /api/auth/refresh             刷新 Token
POST   /api/auth/logout              登出
POST   /api/auth/push-token          注册/更新 Expo Push Token（Phase 2）

用户
GET    /api/users/search?q=          精确匹配 userName 或 email，返回 id + userName
GET    /api/users/me                 获取自己信息
PATCH  /api/users/me                 更新 userName / password
DELETE /api/users/me                 GDPR 删除账户（级联清除所有数据）
GET    /api/users/me/data-export     GDPR 数据导出（JSON）（Phase 3）

好友
GET    /api/friendships              获取好友列表（status=ACCEPTED）
GET    /api/friendships/requests     获取待处理的好友请求（我收到的 PENDING）
POST   /api/friendships              发送好友请求（body: { addresseeId }）
PATCH  /api/friendships/{id}/accept  接受好友请求
DELETE /api/friendships/{id}         拒绝请求 或 解除好友关系（自动级联删除 CardShare）

卡片
GET    /api/cards                    获取当前用户所有卡片（含共享）
GET    /api/cards?updatedAfter=      增量同步（返回 updated + deleted 列表）
GET    /api/cards?q=                 全文搜索（Phase 2）
POST   /api/cards                    创建卡片
GET    /api/cards/{id}               获取单张卡片
PATCH  /api/cards/{id}               更新卡片元数据（Owner only；barcodeType/Content 忽略）
DELETE /api/cards/{id}               删除卡片（Owner only）

共享管理
GET    /api/cards/{id}/shares        获取共享成员列表（Owner only）
POST   /api/cards/{id}/shares        添加共享成员（Owner only；双方须为好友）
PATCH  /api/card-shares/{id}         Viewer 更新 viewerNickname
DELETE /api/card-shares/{id}         Owner 移除成员 或 Viewer 退出共享
```

### 分页与过滤

```
GET /api/cards?page=1&itemsPerPage=20
GET /api/cards?archived=false                          （Phase 2）
GET /api/cards?updatedAfter=2026-01-01T00:00:00Z       增量同步
GET /api/cards?q=超市                                  全文搜索（Phase 2）
```

### 增量同步响应格式

```json
GET /api/cards?updatedAfter=2026-05-01T00:00:00Z

{
  "updated": [
    { "id": "uuid", "name": "Costco", "barcodeType": "QR_CODE", ... }
  ],
  "deleted": ["uuid1", "uuid2"]
}
```

---

## 8. GDPR 合规

> 适用法规：EU GDPR（主要用户群：欧洲）

### 要求清单

| GDPR 条款 | 实现方式 |
|-----------|----------|
| 知情同意（Art. 6/7） | 注册时明确勾选隐私政策 + 服务条款，记录 `gdprConsentAt` |
| 访问权（Art. 15） | `GET /api/users/me/data-export`（JSON，Phase 3） |
| 更正权（Art. 16） | `PATCH /api/users/me` |
| 删除权/被遗忘权（Art. 17） | `DELETE /api/users/me` → 级联删除全部数据 |
| 数据可携性（Art. 20） | 与访问权同端点（Phase 3） |
| 数据泄露通知（Art. 33） | 维护应急流程文档（72小时内通知 DPA） |

### 账户删除级联规则

```
DELETE /api/users/me
  │
  ├── 软删除 User 记录（deletedAt = now()）
  ├── 硬删除此用户为 Owner 的所有 Card
  │     └── 级联删除这些 Card 的所有 CardShare
  ├── 硬删除此用户为 Viewer 的所有 CardShare（退出所有共享）
  ├── 硬删除所有 Friendship 记录（含双方之间所有 CardShare 级联）
  └── 硬删除所有 PushToken（Phase 2 后）
```

### 数据存储

- 所有数据存储在 VPS（欧盟数据中心，如 Hetzner 芬兰/德国）
- 不使用第三方数据分析或追踪
- 日志保留期不超过 30 天

---

## 9. 安全模型

### 传输安全

- 全程 HTTPS（Let's Encrypt + Certbot）
- HSTS 启用
- API 仅接受 `application/json`

### 认证安全

- Access Token：JWT，15 分钟过期，不存 localStorage
- Refresh Token：httpOnly Cookie（Web）/ SecureStore（原生），30 天，Rotation 策略
- 密码：bcrypt（cost factor ≥ 12）
- Email Verify Token：24 小时有效，一次性使用

### API 安全

**速率限制（公开应用必须配置）：**

| 端点 | 限制 | 说明 |
|------|------|------|
| 注册 | 5 次/小时/IP | 防止垃圾账号批量注册 |
| 登录 | 10 次/分钟/IP | 防止暴力破解 |
| 发送验证邮件 | 3 次/小时/用户 | 防止邮件轰炸 |
| 发送好友请求 | 20 次/天/用户 | 防止骚扰 |
| 通用 API | 120 次/分钟/用户 | 通用防滥用 |

**其他安全措施：**

- 所有资源通过 Symfony Voter 细粒度鉴权
- UUID 主键（防止 ID 遍历攻击）
- 每用户卡片上限：200 张（软限制，可通过后台调整）
- 用户搜索结果：精确匹配才返回，不支持模糊搜索（防止用户枚举）

### 本地数据安全（原生 App）

- 所有离线数据存储在 expo-secure-store
- iOS：Keychain（AES-256，TEE/SE 保护）
- Android：Keystore（硬件支持时 StrongBox/TEE 保护）
- App 进入后台超过 N 分钟后要求重新生物识别（默认 5 分钟，可在设置中调整）

### CORS

- Web 版域名（Phase 3 加入）加入白名单
- 原生 App 通过 HTTPS 请求，无 CORS 限制

---

## 10. 部署架构

```
VPS（Hetzner，欧盟节点，推荐芬兰/德国）
├── Nginx（反向代理 + SSL 终止 + 静态文件服务）
├── PHP-FPM（Symfony 应用）
├── PostgreSQL（主数据库）
│     └── 每日自动备份（pg_dump → 压缩 → 本地保留 7 天）
├── Certbot（Let's Encrypt SSL 自动续签）
└── 本地磁盘（Phase 3 图片上传时启用）

Phase 2 新增：
├── Symfony Messenger Worker（异步推送队列，Doctrine transport 初期）
└── Symfony Scheduler Worker（自动归档定时任务）

Web 前端（Phase 3）：
└── 部署到同一 VPS 或 Cloudflare Pages（Expo Web Build）
```

### 环境划分

| 环境 | 用途 | 工具 |
|------|------|------|
| `development` | 本地开发 | Symfony Local Server + **Docker PostgreSQL** |
| `production` | VPS 部署 | Nginx + PHP-FPM + PostgreSQL |

### 备份策略

```bash
# 每日凌晨 3:00 UTC（Crontab）
pg_dump cardpocket_prod | gzip > /backups/db_$(date +%Y%m%d).sql.gz
find /backups -name "*.sql.gz" -mtime +7 -delete   # 保留 7 天
```

> 建议将备份文件额外同步到另一 VPS 或 S3 兼容对象存储（如 Hetzner Object Storage），实现异地备份。

---

## 11. 边界情况与设计决策

### 已决策

| 场景 | 决策 | 理由 |
|------|------|------|
| 同一张卡同时被多人展示 | 不限制 | 家庭共用会员卡的正常场景 |
| 卡片组织方式 | 全文搜索，无标签系统 | 搜索足以满足查找需求，标签增加认知负担 |
| 卡片备注 | 不支持（Owner 和 Viewer 均无） | 简化数据模型；卡片名称本身足够描述性 |
| Viewer 个性化 | 仅私有昵称（`viewerNickname`） | 满足「给这张卡起个我认识的名字」的核心需求 |
| 条码数据存储方式 | 存原始字符串，前端渲染 | 数据量小、不产生冗余文件 |
| 条码创建后不可修改 | 是 | 条码代表物理卡片编号，修改等同换卡 |
| 账户删除级联 | 硬删除所有数据 | 符合 GDPR 遗忘权 |
| 好友解除后的 CardShare 处理 | 自动级联删除 | 避免悬空授权；好友关系是共享的前提 |
| Web 端优先级 | Phase 3（不是 MVP） | 原生 App 是主要客户端 |
| 推送通知优先级 | Phase 2，仅 Expo Push API | 简化实现，避免过早引入复杂依赖 |
| 邮箱验证 | 必须验证，未验证限制使用 | 公开应用防止垃圾账号 |
| 卡片数量上限 | 200 张/用户（软限制） | 防止单用户滥用存储资源 |
| 图片录入方式 | Phase 3（相机扫码是 MVP 主力） | MVP 先保证核心流程，图片解码复杂度留后 |
| Apple/Google Wallet 集成 | Phase 4（可选探索） | 高度依赖商家支持，不可控 |

### 设计取舍说明

**「无标签，用搜索」**  
标签需要用户提前分类、维护标签库，形成额外认知负担。全文搜索无需预设分类，直接输入关键词查找卡片，覆盖 80% 的组织需求，且实现成本低。

**「无 Owner 备注」**  
卡片名称（如"家庭 Costco 会员卡"）本身已有足够描述性。去掉备注字段简化数据模型和 UI，不影响核心使用场景。

**「好友必须互相接受才能共享」**  
对公开应用来说，好友系统提供一层信任屏障，防止陌生人向用户强制共享内容（类似"被关注才能发 DM"模型）。

---

## 12. 待解决的开放性问题

以下问题需在对应 Phase 开始前明确：

1. **Viewer 退出共享时是否通知 Owner？**（Phase 2 前决定）
   - 建议：是，Phase 2 推送通知上线时加入此场景

2. **搜索用户的隐私保护**：任何已登录用户都可以通过邮箱精确搜索其他用户——是否需要「不可被搜索」选项？
   - 建议：MVP 不做，Phase 3 添加隐私设置

3. **App 锁定超时时间**：用户离开 App 多久后需要重新生物识别？
   - 建议：提供设置选项（立即 / 1分钟 / 5分钟 / 不锁定），默认 5 分钟

4. **邮件发送服务**：自建 SMTP 还是第三方（如 Postmark / Resend）？
   - 建议：使用 Resend（免费额度够用，送达率有保障，避免 VPS IP 被邮件黑名单）

5. **Web 端 Refresh Token 方案**（Phase 3 前决定）：httpOnly Cookie 需要同域，若前端部署到 CDN 需额外配置

6. **图片上传服务**（Phase 3 前决定）：若支持卡面照片，需决定存储方案（本地磁盘扩容 or Hetzner Object Storage）

---

## 13. 功能路线图（分阶段）

### Phase 1：MVP（核心功能）

**目标**：可用的数字卡包 + 家庭共享基础

- [ ] 用户注册 / 登录（email + password + JWT）
- [ ] 邮箱验证（发送验证邮件，未验证限制功能）
- [ ] 创建 / 编辑 / 删除卡片（手动输入 + 相机扫码）
- [ ] 展示条码（全格式客户端渲染）
- [ ] 我的卡片列表
- [ ] 离线缓存（SecureStore，增量同步）
- [ ] 好友系统（搜索 / 发送请求 / 接受 / 拒绝 / 解除）
- [ ] 卡片共享（好友间邀请 / 移除 / 退出共享）
- [ ] Viewer 私有昵称（viewerNickname）
- [ ] 共享给我的卡片列表
- [ ] 账户删除（GDPR 级联清除）
- [ ] 速率限制（防滥用）

### Phase 2：体验完善

**目标**：让应用「好用」而不只是「能用」

- [ ] 卡片全文搜索（按名称和 viewerNickname）
- [ ] 卡片外观自定义（颜色 / 渐变 / 图标）
- [ ] 卡片有效期 + 自动归档（Symfony Scheduler）
- [ ] 推送通知（Expo Push API：好友请求 / 共享 / 卡片更新）
- [ ] 卡片即将过期本地提醒

### Phase 3：平台拓展

**目标**：扩展录入方式、可用平台，增强数据主权

- [ ] 从相册选取图片解码 QR Code（前端 JS 解码）
- [ ] iOS Share Sheet / Android Intent 接收图片解码
- [ ] Web 端（PWA / Expo Web），功能同原生（扫码除外）
- [ ] Web 端 Service Worker 离线缓存
- [ ] GDPR 数据导出（`GET /api/users/me/data-export`）
- [ ] 用户隐私设置（不可被搜索选项）

### Phase 4：高级功能（可选探索）

- [ ] Apple Wallet / Google Wallet 兼容性探索
- [ ] 深色模式
- [ ] 卡面照片上传与展示（需引入文件存储）
- [ ] 多语言界面（界面跟随设备语言，目前已默认支持）

---

*本文档随项目进展持续更新。重大架构变更需更新版本号并注明修改原因。*
