# CardPocket — Flutter 前端规格文档

> 基于多轮需求确认 | 面向开发者 | 与后端 api.md / prd.md 配套使用

---

## 技术栈

| 类别 | 选型 |
|------|------|
| Flutter SDK | 3.44.x Stable channel |
| 状态管理 | Riverpod + riverpod_generator |
| 导航 | go_router |
| 本地存储 | Isar |
| HTTP 客户端 | Dio |
| 代码生成 | riverpod_generator + freezed + json_serializable |
| 条码扫描 | mobile_scanner |
| 条码渲染 | barcode_widget |
| 安全存储 | flutter_secure_storage（Refresh Token） |
| 崩溃上报 | sentry_flutter（Phase 1 起） |
| 国际化 | flutter_localizations + gen-l10n（ARB） |
| 加载占位 | shimmer |

---

## 平台与标识

| 项目 | 值 |
|------|-----|
| 目标平台 | iOS 16+ / Android 6.0 (API 23)+ |
| iOS Bundle ID (prod) | `com.cardpocket.app` |
| iOS Bundle ID (dev) | `com.cardpocket.app.dev` |
| Android App ID (prod) | `com.cardpocket.app` |
| Android App ID (dev) | `com.cardpocket.app.dev` |
| App 名称 | CardPocket |

---

## Flavor 配置（dev / prod）

- 两套 Flavor 可同时安装在设备上
- `dev` Flavor：API base URL = `https://localhost:8000`（开发时用 Symfony local server）
- `prod` Flavor：API base URL = `https://PLACEHOLDER_PROD_DOMAIN`（VPS 域名待定，上线前替换）
- Sentry DSN 通过 Flavor 配置区分 dev/prod 环境

---

## 仓库结构

monorepo，Flutter 项目位于根目录下的 `mobile/` 目录：

```
cardPocket/
├── backend/          # Symfony 后端（已完成）
├── mobile/           # Flutter 前端（新建）
│   ├── lib/
│   ├── test/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
└── .claude/
```

---

## 目录结构（feature-first）

```
mobile/lib/
├── core/
│   ├── api/            # Dio client、JWT 拦截器、Token 刷新逻辑
│   ├── auth/           # AuthState、Token 内存存储、SecureStorage
│   ├── isar/           # Isar 数据库初始化、schema 注册
│   ├── router/         # go_router 路由配置、路由守卫
│   ├── theme/          # Material 3 主题（light/dark）、色彩常量
│   └── widgets/        # 共用组件（OfflineBanner、ShimmerList 等）
├── features/
│   ├── auth/
│   │   ├── data/       # AuthRepository、API 调用
│   │   ├── domain/     # 模型（freezed）、接口定义
│   │   └── presentation/ # 登录/注册/验证等待页
│   ├── cards/
│   │   ├── data/       # CardRepository、Isar CardSchema、增量同步
│   │   ├── domain/     # Card 模型、CardShare 模型
│   │   └── presentation/ # 卡片列表、全屏条码、添加卡片、条码扫描
│   ├── friends/
│   │   ├── data/       # FriendshipRepository
│   │   ├── domain/     # Friendship 模型
│   │   └── presentation/ # 好友列表、待处理请求、搜索用户
│   └── profile/
│       ├── data/       # UserRepository
│       ├── domain/     # User 模型
│       └── presentation/ # 个人信息、修改用户名、修改密码、注销、删除账户
└── l10n/               # ARB 文件（en/de/fr/es/zh）
```

---

## 设计系统

### 颜色

- **设计语言**：Material 3 为基础，日期选择器等场景局部使用 Cupertino 控件
- **主题 Seed Color**：`#4F6BED`（蓝靛色，简洁现代，适合工具类应用）
- Material 3 ColorScheme 从 seed color 自动生成 light/dark 全套色板
- **深色模式**：跟随系统设置自动切换

### 排版与组件规范

- 卡片列表项：卡片名称（大字，`titleMedium`）+ 背景色（Phase 1 用占位统一色）
- Phase 2 起 `color` / `gradient` 字段开放后，列表项背景切换为用户自定义色

---

## 页面清单与导航结构

### 未登录区域

```
/login              登录页
/register           注册页
/verify-pending     验证邮件等待页（含"重新发送"按钮）
```

注册成功后跳转到 `/verify-pending`，不自动登录。

### 已登录区域（底部导航 3 Tab）

```
底部导航：[ 卡包 ]  [ 好友 ]  [ 我的 ]

卡包 Tab (/cards)
  ├── 卡片列表（两区块）
  │     ├── "我的卡片"区块（owned cards，分页无限滚动）
  │     └── "共享给我的"区块（viewed cards）
  ├── /cards/scan          条码扫描页（创建卡片第一步）
  ├── /cards/create        手动输入条码页（扫描失败后备）
  └── /cards/:id/barcode   全屏条码展示页

好友 Tab (/friends)
  ├── 好友列表
  │     └── 顶部"X 条待处理请求"可点击横幅（有待处理请求时显示）
  ├── /friends/requests    待处理请求页（接受/拒绝）
  └── /friends/search      搜索添加好友页

我的 Tab (/profile)
  ├── 用户名 + 邮箱展示
  ├── /profile/edit-name   修改用户名
  ├── /profile/change-password  修改密码
  ├── 退出登录（操作，无独立页面）
  └── 删除账户（操作，需二次确认 Dialog）
```

### 弹层（非路由页面）

- **Owner 三点菜单**（卡片列表项右上角）：编辑名称 / 管理共享成员 / 删除
- **Viewer 三点菜单**（卡片列表项右上角）：设置昵称 / 退出共享
- **共享管理 Modal Bottom Sheet**（Owner）：Viewer 列表 + 各自的"移除"按钮 + 顶部"从好友中添加"搜索入口
- **设置昵称 Modal**（Viewer）：输入框 + 保存/清除

---

## 认证与 Token 管理

```
Access Token  → 存内存（不持久化，重启 App 后通过 Refresh 获取新 Token）
Refresh Token → flutter_secure_storage（硬件加密持久化）

Dio 拦截器逻辑：
  请求前：自动附加 Authorization: Bearer <access_token>
  收到 401：自动调用 POST /api/auth/refresh
    → 成功：更新内存中的 Access Token + SecureStorage 中的 Refresh Token，重试原请求
    → 失败（Refresh 也过期）：清除所有 Token，跳转到登录页
```

---

## 离线策略

- **缓存内容**：仅缓存卡片列表（含 `barcodeContent`），支持离线展示条码
- **好友列表、请求列表不缓存**（离线时好友 Tab 显示空状态）
- **离线提示**：顶部细横幅 `"离线模式"` 静默显示，不弹 Dialog
- **Isar 本地 Schema**：存储 Card 完整字段 + `isOwner` + `viewerNickname`（仅 Viewer 有值）

---

## 增量同步

触发时机：
1. App 从后台进入前台（`AppLifecycleState.resumed`）
2. 用户下拉刷新卡片列表

逻辑：
```
1. 读取本地 lastSyncAt 时间戳（Isar 中存储）
2. 调用 GET /api/cards?updatedAfter={lastSyncAt}
3. 将 updated 数组 upsert 到 Isar
4. 将 deleted 数组对应的本地记录删除
5. 更新 lastSyncAt = 本次同步时间
```

首次启动（无 lastSyncAt）：调用全量 `GET /api/cards`，分页加载全部（最多 200 张）。

---

## 卡片列表分页

- 无限滚动，每页 20 条（`itemsPerPage=20`）
- 滚动到底时自动触发下一页请求
- "我的卡片"和"共享给我的"分区块，各自独立分页

---

## 全屏条码展示页

- 进入时：屏幕亮度调到最高
- 离开时：恢复进入前的亮度
- 顶部：返回按钮 + 卡片名称（Viewer 若设置了 `viewerNickname` 则显示昵称）
- 中间：`barcode_widget` 渲染对应 `barcodeType` 的条码
- 背景：深色，确保条码对比度最大

---

## 创建卡片流程（Phase 1）

```
点击 FAB（+）
  → /cards/scan（mobile_scanner 相机页）
      → 扫描成功：跳转到"确认页"（显示识别出的条码内容 + 类型 + 输入卡片名称）→ 提交
      → 点击"手动输入"：跳转到 /cards/create（手动填写条码内容、选择类型、输入名称）
```

Phase 3 在"手动输入"页追加"从相册识别"入口（US-22）。

---

## 未验证用户体验

- 登录后邮箱未验证：可进入 App 主界面
- 顶部显示警告横幅："邮箱未验证，部分功能不可用。[重新发送验证邮件]"
- 点击横幅上的链接 → 后端重发验证邮件，浏览器打开完成验证后用户回到 App
- 受限操作：创建卡片、发送好友请求（返回 403，前端提示横幅说明原因）

---

## 错误处理

| 场景 | 展示方式 |
|------|---------|
| 表单字段校验失败（422） | 字段下方内联红色提示文字 |
| 网络超时 / 无网络 | 顶部 SnackBar |
| 403 权限不足（如邮箱未验证） | SnackBar + 横幅说明 |
| 500 服务器错误 | SnackBar（"服务器异常，请稍后再试"）|
| 操作成功 | 轻量 SnackBar（绿色，1.5 秒自动消失）|

---

## 空状态

| 页面 | 空状态内容 |
|------|----------|
| 卡片列表（我的卡片为空） | 简单插图 + "还没有卡片，点击 + 添加第一张" |
| 好友列表为空 | 简单插图 + "还没有好友，搜索用户添加" |
| 待处理请求为空 | 文字提示"暂无待处理请求" |
| 搜索用户无结果 | 文字提示"未找到该用户" |

插图使用 Flutter 内置简单图形（非 SVG），保持轻量。

---

## 国际化（i18n）

- 工具：`flutter_localizations` + `gen-l10n`（ARB 文件）
- 语言：`en`（默认）、`de`、`fr`、`es`、`zh`
- **跟随系统语言**，不提供应用内手动切换
- ARB 文件路径：`mobile/lib/l10n/`

---

## 测试策略

| 类型 | 工具 | 范围 |
|------|------|------|
| 单元测试 | `flutter_test` | Repository、Provider 逻辑 |
| Widget 测试 | `flutter_test` | 关键页面组件、交互逻辑 |
| 集成测试 | `integration_test` | 核心用户流程（登录、添加卡片、展示条码）|

不强制 TDD 顺序，但功能提交时必须附带对应测试。

---

## CI/CD（GitHub Actions）

```
触发：Push to main + PR
流程：
  1. flutter analyze（静态分析）
  2. flutter test（单元 + Widget 测试）
  3. Build dev APK（Android）
  4. Build dev IPA（iOS，需 macOS runner）

发布流程（手动触发）：
  prod flavor → 
    iOS: 打包 → TestFlight → App Store
    Android: 打包 → Play Store Internal Testing → Production
```

---

## Phase 2 规划（前端部分）

- 接入 Expo Push Token → `POST /api/auth/push-token`（与后端 Phase 2 推送同步）
- 好友 Tab 角标 + 推送通知（好友请求到达时）
- 卡片颜色/渐变/图标自定义（`color` / `gradient` / `icon` 字段开放）
- 卡片搜索（`GET /api/cards?q=`）
- 卡片归档与过期（`expiresAt` / `archivedAt` 字段）
