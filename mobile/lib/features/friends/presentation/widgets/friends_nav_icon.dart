import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/friend_requests_notifier.dart';

/// Friends bottom-nav icon with a badge showing the pending friend-request
/// count. Updates live as [friendRequestsProvider] is invalidated (e.g. on an
/// incoming push).
class FriendsNavIcon extends ConsumerWidget {
  const FriendsNavIcon({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(friendRequestsProvider).value?.length ?? 0;
    return Badge.count(
      count: pendingCount,
      isLabelVisible: pendingCount > 0,
      child: Icon(selected ? Icons.people : Icons.people_outline),
    );
  }
}
