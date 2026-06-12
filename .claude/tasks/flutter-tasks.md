# Flutter 前端任务清单

> Phase 1 MVP | 对应 flutter-spec.md 规格 | 与后端 BE- 任务并行

---

## Phase 1：Flutter MVP

### [FE-INFRA] 基础设施与项目初始化

- [x] FE-INFRA-01：`flutter create mobile/`，配置 dev/prod Flavor（Bundle ID `com.cardpocket.app[.dev]`、API base URL、Sentry DSN）
- [x] FE-INFRA-02：配置 `pubspec.yaml`（riverpod + riverpod_generator、go_router、drift + drift_flutter + sqlite3_flutter_libs、dio、mobile_scanner、barcode_widget、flutter_secure_storage、sentry_flutter、shimmer、freezed + json_serializable + drift_dev + build_runner）
- [x] FE-INFRA-03：Dio 客户端 + JWT 拦截器（请求自动附加 `Authorization: Bearer`，401 时自动调用 `POST /api/auth/refresh`，refresh 失败则清除 Token 并跳转 /login）
- [x] FE-INFRA-04：AuthTokenStorage（Access Token 存内存变量、Refresh Token 存 flutter_secure_storage 硬件加密）
- [x] FE-INFRA-05：Drift 数据库初始化（`AppDatabase` 单例、`CardsTable` + `SyncMetaTable` 定义、`drift_flutter` NativeDatabase，`build_runner` 生成代码）
- [x] FE-INFRA-06：go_router 路由配置（所有路由定义、路由守卫：未登录重定向 /login，已登录且访问 /login 则重定向 /cards）
- [x] FE-INFRA-07：Material 3 主题（seed color `#4F6BED`，light/dark 跟随系统，ThemeData 全局注册到 MaterialApp）
- [x] FE-INFRA-08：共用组件（`OfflineBanner` 顶部静默横幅、`ShimmerList` 加载占位、底部 3-Tab 导航骨架）
- [x] FE-INFRA-09：Sentry Flutter 集成（dev/prod DSN 通过 Flavor 区分，全局 `runZonedGuarded` + `FlutterError.onError` 捕获）
- [x] FE-INFRA-10：i18n 配置（`flutter_localizations` + `gen-l10n`，ARB 文件 en/de/fr/es/zh 至 `mobile/lib/l10n/`，跟随系统语言）

### [FE-AUTH] 认证

- [x] FE-AUTH-00：Auth 领域模型（freezed：`User`、`LoginRequest`、`RegisterRequest`、`AuthTokens`）
- [x] FE-AUTH-01：`AuthRepository`（`POST /api/auth/login`、`/register`、`/refresh`、`/logout`、`/resend-verification` API 调用）
- [x] FE-AUTH-02：`AuthNotifier`（Riverpod AsyncNotifier，管理 `AuthState`：unauthenticated / authenticated / unverified；初始化时从 SecureStorage 读取 Refresh Token 静默刷新）
- [x] FE-AUTH-03：登录页 `/login`（表单校验、422 字段内联错误、提交后更新 AuthState）
- [x] FE-AUTH-04：注册页 `/register`（表单校验，注册成功后跳转 `/verify-pending`，不自动登录）
- [x] FE-AUTH-05：邮箱验证等待页 `/verify-pending`（说明文案 + "重新发送验证邮件"按钮）
- [x] FE-AUTH-06：邮箱未验证横幅（AuthState 为 unverified 时顶部警告 Banner，点击触发重发；受限操作返回 403 时 SnackBar 说明原因）
- [x] FE-AUTH-07：编写认证模块测试（`AuthRepository` 单元测试、登录 / 注册页 Widget 测试）

### [FE-CARDS] 卡片

- [x] FE-CARDS-00：Card 领域模型（freezed：`Card` 含 `id`、`name`、`barcodeType`、`barcodeContent`、`isOwner`、`viewerNickname String?`、`ownerUsername String?`、`updatedAt`）
- [x] FE-CARDS-01：Drift `CardsTable`（`TextColumn` id/name/barcodeType/barcodeContent/viewerNickname/ownerUsername、`BoolColumn` isOwner、`DateTimeColumn` updatedAt；`insertOrReplace` 支持 upsert）
- [x] FE-CARDS-02：`CardRepository`（`GET /api/cards` 分页、`POST` 创建、`PATCH /:id` 编辑名称、`DELETE /:id`，含 Drift 读写）
- [x] FE-CARDS-03：卡片列表页 `/cards`（两区块：owned / viewed，各自独立无限滚动每页 20 条，FAB 触发扫描流程，空状态插图）
- [x] FE-CARDS-04：全屏条码展示页 `/cards/:id/barcode`（进入时亮度调最高、退出恢复，`barcode_widget` 渲染对应 `barcodeType`，深色背景；Viewer 标题显示"昵称(共享者用户名)"或"卡片名(共享者用户名)"）
- [x] FE-CARDS-05：条码扫描页 `/cards/scan`（`mobile_scanner` 相机，扫描成功跳确认页，底部"手动输入"按钮跳 `/cards/create`）
- [x] FE-CARDS-06：扫描确认页（显示识别到的条码内容 + 类型 + 输入卡片名称，提交调用 `CardRepository.create`）
- [x] FE-CARDS-07：手动输入页 `/cards/create`（条码内容 TextField + 类型 DropdownMenu + 名称 TextField）
- [x] FE-CARDS-08：Owner 三点菜单（编辑名称 AlertDialog + 管理共享 ModalBottomSheet 入口 + 删除二次确认）
- [x] FE-CARDS-09：编写卡片模块测试（`CardRepository` 单元测试、卡片列表 Widget 测试）

### [FE-SYNC] 离线与同步

- [x] FE-SYNC-01：增量同步逻辑（读取 Drift `SyncMetaTable.lastSyncAt` → `GET /api/cards?updatedAfter={ts}` → `insertOrReplace` upsert `updated` 数组 → 删除 `deleted` 数组 → 更新 `lastSyncAt`；首次无 `lastSyncAt` 时全量加载分页至多 200 张）
- [x] FE-SYNC-02：`AppLifecycle` 监听（`AppLifecycleState.resumed` 时触发 FE-SYNC-01）
- [x] FE-SYNC-03：下拉刷新（卡片列表 `RefreshIndicator` 触发 FE-SYNC-01）
- [x] FE-SYNC-04：离线检测 + `OfflineBanner`（网络不可用时顶部静默横幅显示，恢复后自动消失；不弹 Dialog）

### [FE-SHARE] 共享 UI

- [x] FE-SHARE-01：`ShareRepository`（`POST /api/cards/:id/shares` 添加 Viewer、`DELETE /api/cards/:id/shares/:userId` 移除 Viewer、`DELETE /api/cards/:id/shares/me` Viewer 退出、`PATCH /api/cards/:id/shares/me` 设置昵称）
- [x] FE-SHARE-02：共享管理 ModalBottomSheet（Owner 视图）：当前 Viewer 列表 + 各自"移除"按钮 + 顶部"从好友中添加"搜索入口
- [x] FE-SHARE-03：Viewer 三点菜单（退出共享操作，调用 `ShareRepository.leave`）
- [x] FE-SHARE-04：设置昵称 Modal（Viewer）：TextFormField + 保存 / 清除按钮，调用 `ShareRepository.setNickname`

### [FE-FRIENDS] 好友

- [x] FE-FRIENDS-00：Friendship 领域模型（freezed：`UserSummary`、`FriendRequest`、`FriendshipStatus` enum）
- [x] FE-FRIENDS-01：`FriendshipRepository`（`GET /api/friends`、`GET /api/friends/requests`、`POST /api/friends/requests` 发请求、`PATCH /api/friends/requests/:id` 接受/拒绝、`DELETE /api/friends/:id` 删除好友）
- [x] FE-FRIENDS-02：好友列表页 `/friends`（好友列表，有待处理请求时顶部显示"X 条待处理请求"横幅，点击跳 `/friends/requests`；空状态插图）
- [x] FE-FRIENDS-03：待处理请求页 `/friends/requests`（请求列表，接受 / 拒绝按钮，无请求时文字提示）
- [x] FE-FRIENDS-04：搜索好友页 `/friends/search`（TextFormField 搜索 `GET /api/users?q=`，无结果提示，发送好友请求按钮）
- [x] FE-FRIENDS-05：编写好友模块测试（`FriendshipRepository` 单元测试、好友列表 Widget 测试）

### [FE-PROFILE] 个人信息

- [x] FE-PROFILE-00：User 领域模型（freezed：`UserProfile` 含 `id`、`email`、`username`、`isVerified`）
- [x] FE-PROFILE-01：`UserRepository`（`GET /api/profile`、`PATCH /api/profile/username` 改用户名、`PATCH /api/profile/password` 改密码、`DELETE /api/users/me` 注销）
- [x] FE-PROFILE-02：个人信息页 `/profile`（用户名 + 邮箱展示，退出登录 ListTile，删除账户 ListTile）
- [x] FE-PROFILE-03：修改用户名页 `/profile/edit-name`（TextFormField + 422 内联错误）
- [x] FE-PROFILE-04：修改密码页 `/profile/change-password`（当前密码 + 新密码 + 确认密码，422 内联错误）
- [x] FE-PROFILE-05：退出登录（`AuthNotifier.logout` 调用 `/api/auth/logout` + 清除 SecureStorage + 重定向 /login；无独立页面）
- [x] FE-PROFILE-06：删除账户（AlertDialog 二次确认，确认后调用 `UserRepository.deleteAccount` + 清除 Drift 数据库 + 重定向 /login）
- [x] FE-PROFILE-07：编写个人信息模块测试（`UserRepository` 单元测试、个人信息页 Widget 测试）

### [FE-CI] CI/CD

- [x] FE-CI-01：GitHub Actions workflow（触发：push to main + PR；步骤：`flutter analyze` → `flutter test` → build dev APK → build dev IPA on macOS runner）

---

## 执行顺序建议

```
[1] FE-INFRA（全部）
    ├── 项目骨架、Dio、Drift、路由、主题、i18n
    └── 完成后所有模块可并行开始

[2] FE-AUTH（依赖 FE-INFRA）
    └── 认证流打通后路由守卫生效

[3] FE-CARDS + FE-SYNC（依赖 FE-AUTH）
    ├── 卡片是核心功能，优先完成
    └── FE-SYNC 依赖 FE-CARDS-01（Drift CardsTable）

[4] FE-SHARE（依赖 FE-CARDS）
    └── 共享 UI 依赖卡片列表菜单入口

[5] FE-FRIENDS（依赖 FE-AUTH）
    └── 可与 FE-CARDS 并行

[6] FE-PROFILE（依赖 FE-AUTH）
    └── 可与 FE-CARDS / FE-FRIENDS 并行

[7] FE-CI（任意阶段均可配置）
```
