# FCM 推送 — 原生配置（手动前置步骤）

Dart 侧（权限、token 注册、前台/后台/终止态处理、深链、角标）已在 `lib/features/notifications/` 实现并有测试覆盖。运行时 `bootstrap.dart` 会 `try/catch` 包裹 `Firebase.initializeApp()`：**在未完成下列配置前，App 仍可正常运行，推送只是被禁用（`pushAvailableProvider` 保持 false）。**

完成以下步骤后推送即可联调。先做 Android；iOS 留作后续（见末尾）。

## Android

应用使用 flavor，两个 applicationId：

| flavor | applicationId |
|---|---|
| dev | `com.cardpocket.app.dev` |
| prod | `com.cardpocket.app` |

1. **Firebase 控制台**：建项目 → 添加两个 Android 应用，package name 分别填上面两个 applicationId。
2. 各自下载 `google-services.json`，按 flavor 放置：
   - `android/app/src/dev/google-services.json`
   - `android/app/src/prod/google-services.json`
3. **`android/settings.gradle.kts`** 的 `plugins {}` 加入 google-services 插件（`apply false`）：
   ```kotlin
   id("com.google.gms.google-services") version "4.4.2" apply false
   ```
4. **`android/app/build.gradle.kts`** 的 `plugins {}` 应用插件：
   ```kotlin
   id("com.google.gms.google-services")
   ```
   > 注意：应用此插件后，构建会要求对应 flavor 目录下存在 `google-services.json`，否则 `flutter build` 失败。请在第 2 步完成后再加此插件。
5. minSdk 需 ≥ 21（firebase_messaging 要求）。当前用 `flutter.minSdkVersion`，新版 Flutter 默认满足；如报错则在 `defaultConfig` 显式设 `minSdk = 21`。

## 后端（BE-PUSH-04，部署侧）

- 配置环境变量 `FIREBASE_PROJECT_ID`、`GOOGLE_APPLICATION_CREDENTIALS`（Service Account JSON 路径）。
- 生产常驻 worker：`bin/console messenger:consume async`。

## 深链 data 约定（与后端协调）

前端按通知 `data['type']` 路由；当前所有推送默认深链到 `/friends/requests`。后端好友请求推送建议在 `SendPushMessage` 带上 `data: {'type': 'friend_request'}`（不阻塞前端，前端已对缺省做安全回退）。

## iOS（后续）

- `GoogleService-Info.plist`（按 flavor）加入 Runner。
- Firebase 控制台上传 APNs Auth Key。
- `Info.plist` / capabilities 开启 Push Notifications + Background Modes（remote notification）。
- 本期暂不实现（无 Mac / iOS flavor CI，见项目记忆）。
