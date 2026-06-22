import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles FCM messages delivered while the app is in the background or
/// terminated. Runs in a separate isolate, so it must be a top-level function.
///
/// Notification-type messages are rendered by the OS tray automatically; this
/// handler is the hook for data-only messages and is intentionally a no-op for
/// the MVP.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
