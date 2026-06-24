# 系统分享接收（US-23）— 原生配置

Dart 侧（监听分享、解析图片条码、路由到确认页/手动输入）已在
`lib/features/cards/application/sharing_import_controller.dart` +
`lib/features/cards/data/sharing_intent_service.dart` 实现并有测试覆盖。

`SharingImportController` 由 `app.dart` 激活，**未完成下列原生配置前 App 仍正常运行**，
只是从其他 App「分享图片到 CardPocket」不会出现 CardPocket 选项。

## Android（已就绪）

`android/app/src/main/AndroidManifest.xml` 的 `MainActivity` 已加入
`ACTION_SEND` / `ACTION_SEND_MULTIPLE`（`image/*`）的 intent-filter，
`launchMode` 为 `singleTop`。无需额外步骤——从相册/相机分享图片即可看到 CardPocket。

> 若后续要支持「多图分享」体验优化，再评估 `SEND_MULTIPLE` 的 UI。

## iOS（待 Mac + Xcode 配置）

`receive_sharing_intent` 在 iOS 需要一个 **Share Extension target** + **App Group**
（扩展与主 App 通过 App Group 共享分享进来的文件）。这一步必须在 Xcode 完成，
照 `receive_sharing_intent` 官方 README 的 iOS 章节执行：

1. Xcode 打开 `ios/Runner.xcworkspace` → File → New → Target → **Share Extension**，
   命名如 `Share Extension`。
2. 为 **Runner** 与 **Share Extension** 两个 target 都开启 **App Groups** capability，
   使用同一个 group id，例如 `group.com.cardpocket.app`（与 dev/prod flavor 的
   Bundle ID `com.cardpocket.app[.dev]` 对应；dev 可用 `group.com.cardpocket.app.dev`）。
3. 用 README 提供的 `ShareViewController.swift` 覆盖扩展自动生成的实现，
   并把扩展的 `Info.plist` 的 `NSExtensionActivationRule` 配置为接收图片
   （`NSExtensionActivationSupportsImageWithMaxCount` > 0）。
4. 在扩展与 Runner 的 `Info.plist`/entitlements 中填入上面的 App Group id。
5. 主 App 的 `ios/Runner/Info.plist` 已添加 `NSPhotoLibraryUsageDescription`
   （US-22 相册选图需要；分享接收本身不依赖它）。

完成后用 dev flavor 真机验证：从「照片」App 选一张含二维码的图片 → 分享 → CardPocket，
应自动进入扫描确认页（识别成功）或手动输入页（识别失败）。

> 与 FCM 一样，iOS 这部分留作后续（见 `fcm-setup.md` 末尾的 iOS 说明）。
