import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/auth/auth_state_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/router/router_provider.dart';
import '../../friends/application/friend_requests_notifier.dart';
import '../data/push_messaging_service.dart';
import '../data/push_token_repository.dart';

part 'push_notification_controller.g.dart';

/// Whether Firebase initialised successfully at startup. Defaults to false and
/// is overridden to true from `bootstrap.dart` once `Firebase.initializeApp`
/// succeeds, so the app still runs when push credentials are absent (e.g. dev).
@Riverpod(keepAlive: true)
bool pushAvailable(Ref ref) => false;

/// Wires FCM into the app: requests permission, registers the token, keeps it
/// fresh, refreshes in-app state on foreground messages, and deep-links on
/// notification taps. Activated by watching it from `app.dart`.
@Riverpod(keepAlive: true)
class PushNotificationController extends _$PushNotificationController {
  final List<StreamSubscription<void>> _subscriptions = [];

  @override
  Future<void> build() async {
    ref.onDispose(_cancelSubscriptions);

    if (!ref.watch(pushAvailableProvider)) return;

    final isAuthenticated = ref.watch(authStateProvider) is Authenticated;
    if (!isAuthenticated) return;

    await _initialise();
  }

  Future<void> _initialise() async {
    final messaging = ref.read(pushMessagingServiceProvider);

    final granted = await messaging.requestPermission();
    if (!granted) return;

    final token = await messaging.getToken();
    if (token != null) {
      await ref.read(pushTokenRepositoryProvider).register(token);
    }

    // Re-register whenever FCM rotates the token.
    _subscriptions.add(
      messaging.onTokenRefresh.listen(
        (refreshed) => ref.read(pushTokenRepositoryProvider).register(refreshed),
      ),
    );

    // Foreground messages don't show a system notification; refresh the badge.
    _subscriptions.add(
      messaging.onMessage.listen((_) => ref.invalidate(friendRequestsProvider)),
    );

    // Notification tap from background -> deep link.
    _subscriptions.add(messaging.onMessageOpenedApp.listen(_handleDeepLink));

    // Notification that launched the app from a terminated state.
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleDeepLink(initial);
  }

  void _handleDeepLink(PushMessage message) {
    // The only push type today is friend requests; unknown types fall back to
    // the same screen as a safe default. `message.type` is read here so the
    // routing table is easy to extend later.
    ref.read(routerProvider).goNamed(RouteNames.friendsRequests);
  }

  void _cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
