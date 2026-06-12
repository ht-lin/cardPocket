import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:card_pocket/features/friends/application/friend_requests_notifier.dart';
import 'package:card_pocket/features/friends/application/friends_notifier.dart';
import 'package:card_pocket/features/friends/domain/friend_model.dart';
import 'package:card_pocket/features/friends/presentation/friends_screen.dart';

final _friend1 = Friendship(
  id: 'fs-1',
  friend: const UserSummary(id: 'user-2', userName: 'jane_doe'),
  createdAt: DateTime(2026, 6, 1),
);

final _friend2 = Friendship(
  id: 'fs-2',
  friend: const UserSummary(id: 'user-3', userName: 'john_doe'),
  createdAt: DateTime(2026, 6, 2),
);

final _request1 = FriendRequest(
  id: 'req-1',
  requester: const UserSummary(id: 'user-4', userName: 'alice'),
  createdAt: DateTime(2026, 6, 3),
);

Widget _buildTestApp({
  required List<Friendship> friends,
  required List<FriendRequest> requests,
}) {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const FriendsScreen(),
    ),
    GoRoute(path: '/friends/requests', builder: (_, __) => const SizedBox()),
    GoRoute(path: '/friends/search', builder: (_, __) => const SizedBox()),
  ]);

  return ProviderScope(
    overrides: [
      friendsProvider.overrideWith(() => _FakeFriendsNotifier(friends)),
      friendRequestsProvider
          .overrideWith(() => _FakeFriendRequestsNotifier(requests)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeFriendsNotifier extends FriendsNotifier {
  _FakeFriendsNotifier(this._state);
  final List<Friendship> _state;

  @override
  Future<List<Friendship>> build() async => _state;
}

class _FakeFriendRequestsNotifier extends FriendRequestsNotifier {
  _FakeFriendRequestsNotifier(this._state);
  final List<FriendRequest> _state;

  @override
  Future<List<FriendRequest>> build() async => _state;
}

void main() {
  group('FriendsScreen', () {
    testWidgets('shows empty state when no friends', (tester) async {
      await tester.pumpWidget(_buildTestApp(friends: [], requests: []));
      await tester.pumpAndSettle();

      expect(find.text('No friends yet'), findsOneWidget);
    });

    testWidgets('renders friend username in list', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(friends: [_friend1, _friend2], requests: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('jane_doe'), findsOneWidget);
      expect(find.text('john_doe'), findsOneWidget);
    });

    testWidgets('does not show pending banner when no requests', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(friends: [_friend1], requests: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 pending friend request'), findsNothing);
    });

    testWidgets('shows pending banner when there are requests', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(friends: [], requests: [_request1]),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 pending friend request'), findsOneWidget);
    });

    testWidgets('shows plural banner for multiple requests', (tester) async {
      final req2 = FriendRequest(
        id: 'req-2',
        requester: const UserSummary(id: 'user-5', userName: 'bob'),
        createdAt: DateTime(2026, 6, 4),
      );
      await tester.pumpWidget(
        _buildTestApp(friends: [], requests: [_request1, req2]),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 pending friend requests'), findsOneWidget);
    });

    testWidgets('shows search icon button', (tester) async {
      await tester.pumpWidget(_buildTestApp(friends: [], requests: []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_search_outlined), findsOneWidget);
    });
  });
}
