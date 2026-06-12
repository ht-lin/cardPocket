import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../application/friend_requests_notifier.dart';
import '../application/friends_notifier.dart';
import '../data/friendship_repository.dart';
import '../domain/friend_model.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);
    final pendingCount =
        ref.watch(friendRequestsProvider).value?.length ?? 0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Friends'),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_search_outlined),
                  tooltip: 'Search',
                  onPressed: () =>
                      context.pushNamed(RouteNames.friendsSearch),
                ),
              ],
            ),
            if (pendingCount > 0)
              SliverToBoxAdapter(
                child: _PendingRequestsBanner(
                  count: pendingCount,
                  onTap: () =>
                      context.pushNamed(RouteNames.friendsRequests),
                ),
              ),
            friends.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
              data: (list) => list.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyFriends())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _FriendTile(friendship: list[index]),
                        childCount: list.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestsBanner extends StatelessWidget {
  const _PendingRequestsBanner({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.person_add_outlined,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$count pending friend request${count > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 64),
          const SizedBox(height: 12),
          Text(
            'No friends yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Search for friends using the icon above',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends ConsumerWidget {
  const _FriendTile({required this.friendship});
  final Friendship friendship;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(friendship.friend.userName),
      trailing: PopupMenuButton<_Action>(
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _Action.unfriend,
            child: Text('Remove friend'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _Action action,
  ) async {
    if (action != _Action.unfriend) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove friend'),
        content: Text(
          'Remove ${friendship.friend.userName}? '
          'All shared cards will be revoked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(friendshipRepositoryProvider)
          .deleteOrReject(friendship.id);
      ref.invalidate(friendsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend removed'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        final message = switch (e) {
          NetworkException() => 'Network error, check your connection',
          ForbiddenException() => 'Permission denied',
          ServerException() => 'Server error, try later',
          UnprocessableException(:final errors) =>
            errors.values.expand((v) => v).join(', '),
          _ => 'An error occurred',
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}

enum _Action { unfriend }
