import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/auth/auth_state.dart';
import 'package:card_pocket/core/auth/auth_state_provider.dart';
import 'package:card_pocket/core/router/route_names.dart';
import 'package:card_pocket/core/router/router_provider.dart';
import 'package:card_pocket/features/friends/application/friend_requests_notifier.dart';
import 'package:card_pocket/features/friends/domain/friend_model.dart';
import 'package:card_pocket/features/notifications/application/push_notification_controller.dart';
import 'package:card_pocket/features/notifications/data/push_messaging_service.dart';
import 'package:card_pocket/features/notifications/data/push_token_repository.dart';

class MockPushTokenRepository extends Mock implements PushTokenRepository {}

class MockGoRouter extends Mock implements GoRouter {}

class FakePushMessagingService implements PushMessagingService {
  bool permissionGranted = true;
  String? token = 'fcm-token';
  PushMessage? initialMessage;
  int requestPermissionCalls = 0;

  final tokenRefreshController = StreamController<String>.broadcast();
  final messageController = StreamController<PushMessage>.broadcast();
  final openedAppController = StreamController<PushMessage>.broadcast();

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalls++;
    return permissionGranted;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => tokenRefreshController.stream;

  @override
  Stream<PushMessage> get onMessage => messageController.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp => openedAppController.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => initialMessage;

  Future<void> close() async {
    await tokenRefreshController.close();
    await messageController.close();
    await openedAppController.close();
  }
}

/// Fake that records every (re)build so we can detect invalidation.
class _CountingRequestsNotifier extends FriendRequestsNotifier {
  _CountingRequestsNotifier(this._onBuild);
  final void Function() _onBuild;

  @override
  Future<List<FriendRequest>> build() async {
    _onBuild();
    return const [];
  }
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(() => registerFallbackValue(''));

  late FakePushMessagingService messaging;
  late MockPushTokenRepository tokenRepo;
  late MockGoRouter router;

  setUp(() {
    messaging = FakePushMessagingService();
    tokenRepo = MockPushTokenRepository();
    router = MockGoRouter();
    when(() => tokenRepo.register(any())).thenAnswer((_) async {});
  });

  tearDown(() => messaging.close());

  ProviderContainer makeContainer({
    bool pushAvailable = true,
    AuthState authState = const AuthState.authenticated(userId: 'u1'),
    void Function()? onRequestsBuild,
  }) {
    final container = ProviderContainer(
      overrides: [
        pushAvailableProvider.overrideWithValue(pushAvailable),
        authStateProvider.overrideWithValue(authState),
        pushMessagingServiceProvider.overrideWithValue(messaging),
        pushTokenRepositoryProvider.overrideWithValue(tokenRepo),
        routerProvider.overrideWithValue(router),
        friendRequestsProvider.overrideWith(
          () => _CountingRequestsNotifier(onRequestsBuild ?? () {}),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('does nothing when push is unavailable', () async {
    final container = makeContainer(pushAvailable: false);
    await container.read(pushNotificationControllerProvider.future);

    expect(messaging.requestPermissionCalls, 0);
    verifyNever(() => tokenRepo.register(any()));
  });

  test('does nothing when unauthenticated', () async {
    final container =
        makeContainer(authState: const AuthState.unauthenticated());
    await container.read(pushNotificationControllerProvider.future);

    expect(messaging.requestPermissionCalls, 0);
    verifyNever(() => tokenRepo.register(any()));
  });

  test('requests permission and registers token when authenticated', () async {
    final container = makeContainer();
    await container.read(pushNotificationControllerProvider.future);

    expect(messaging.requestPermissionCalls, 1);
    verify(() => tokenRepo.register('fcm-token')).called(1);
  });

  test('does not register when permission denied', () async {
    messaging.permissionGranted = false;
    final container = makeContainer();
    await container.read(pushNotificationControllerProvider.future);

    verifyNever(() => tokenRepo.register(any()));
  });

  test('re-registers on token refresh', () async {
    final container = makeContainer();
    await container.read(pushNotificationControllerProvider.future);

    messaging.tokenRefreshController.add('rotated-token');
    await _pump();

    verify(() => tokenRepo.register('rotated-token')).called(1);
  });

  test('refreshes pending requests on foreground message', () async {
    var buildCount = 0;
    final container = makeContainer(onRequestsBuild: () => buildCount++);
    // Keep friendRequestsProvider alive so invalidation triggers a rebuild.
    container.listen(friendRequestsProvider, (_, _) {});
    await container.read(pushNotificationControllerProvider.future);
    await container.read(friendRequestsProvider.future);
    expect(buildCount, 1);

    messaging.messageController.add(const PushMessage(type: 'friend_request'));
    await _pump();
    await container.read(friendRequestsProvider.future);

    expect(buildCount, 2);
  });

  test('deep-links to friend requests when a notification is tapped',
      () async {
    final container = makeContainer();
    await container.read(pushNotificationControllerProvider.future);

    messaging.openedAppController
        .add(const PushMessage(type: 'friend_request'));
    await _pump();

    verify(() => router.goNamed(RouteNames.friendsRequests)).called(1);
  });

  test('deep-links when launched from a terminated state', () async {
    messaging.initialMessage = const PushMessage(type: 'friend_request');
    final container = makeContainer();
    await container.read(pushNotificationControllerProvider.future);

    verify(() => router.goNamed(RouteNames.friendsRequests)).called(1);
  });
}
