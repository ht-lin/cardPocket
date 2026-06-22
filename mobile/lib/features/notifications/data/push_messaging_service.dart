import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_messaging_service.g.dart';

/// Normalised view of an FCM message's data payload, decoupled from the
/// `firebase_messaging` types so the controller stays unit-testable.
class PushMessage {
  const PushMessage({this.type, this.data = const {}});

  /// `data['type']` — drives deep-link routing (e.g. `friend_request`).
  final String? type;
  final Map<String, String> data;
}

/// Thin, mockable boundary around [FirebaseMessaging]. Tests override
/// [pushMessagingServiceProvider] with a fake to avoid touching the plugin.
abstract interface class PushMessagingService {
  /// Requests notification permission (iOS / Android 13+). Returns whether
  /// the user granted (or provisionally granted) permission.
  Future<bool> requestPermission();

  /// Current FCM registration token, or null if unavailable.
  Future<String?> getToken();

  /// Emits a new token whenever FCM rotates it.
  Stream<String> get onTokenRefresh;

  /// Messages received while the app is in the foreground.
  Stream<PushMessage> get onMessage;

  /// Fired when the user taps a notification that resumed the app from the
  /// background.
  Stream<PushMessage> get onMessageOpenedApp;

  /// The notification that launched the app from a terminated state, if any.
  Future<PushMessage?> getInitialMessage();
}

class FirebasePushMessagingService implements PushMessagingService {
  const FirebasePushMessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get onMessage =>
      FirebaseMessaging.onMessage.map(_toPushMessage);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_toPushMessage);

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toPushMessage(message);
  }

  PushMessage _toPushMessage(RemoteMessage message) => PushMessage(
        type: message.data['type'] as String?,
        data: message.data.map((k, v) => MapEntry(k, '$v')),
      );
}

@Riverpod(keepAlive: true)
PushMessagingService pushMessagingService(Ref ref) =>
    FirebasePushMessagingService(FirebaseMessaging.instance);
