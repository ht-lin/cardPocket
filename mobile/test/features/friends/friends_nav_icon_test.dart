import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_pocket/features/friends/application/friend_requests_notifier.dart';
import 'package:card_pocket/features/friends/domain/friend_model.dart';
import 'package:card_pocket/features/friends/presentation/widgets/friends_nav_icon.dart';

class _FakeRequestsNotifier extends FriendRequestsNotifier {
  _FakeRequestsNotifier(this._requests);
  final List<FriendRequest> _requests;

  @override
  Future<List<FriendRequest>> build() async => _requests;
}

FriendRequest _request(String id) => FriendRequest(
      id: id,
      requester: UserSummary(id: 'u-$id', userName: 'user-$id'),
      createdAt: DateTime(2026, 6, 1),
    );

Future<void> _pumpIcon(WidgetTester tester, List<FriendRequest> requests) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        friendRequestsProvider.overrideWith(
          () => _FakeRequestsNotifier(requests),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: FriendsNavIcon(selected: false)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows badge with pending request count', (tester) async {
    await _pumpIcon(tester, [_request('1'), _request('2'), _request('3')]);

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('hides badge label when there are no pending requests',
      (tester) async {
    await _pumpIcon(tester, const []);

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
  });
}
