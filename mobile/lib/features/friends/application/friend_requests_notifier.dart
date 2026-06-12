import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/friendship_repository.dart';
import '../domain/friend_model.dart';
import 'friends_notifier.dart';

part 'friend_requests_notifier.g.dart';

@riverpod
class FriendRequestsNotifier extends _$FriendRequestsNotifier {
  @override
  Future<List<FriendRequest>> build() =>
      ref.read(friendshipRepositoryProvider).getPendingRequests();

  Future<void> accept(String id) async {
    await ref.read(friendshipRepositoryProvider).acceptRequest(id);
    ref.invalidateSelf();
    ref.invalidate(friendsProvider);
  }

  Future<void> reject(String id) async {
    await ref.read(friendshipRepositoryProvider).deleteOrReject(id);
    ref.invalidateSelf();
  }
}
