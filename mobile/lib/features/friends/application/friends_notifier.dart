import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/friendship_repository.dart';
import '../domain/friend_model.dart';

part 'friends_notifier.g.dart';

@riverpod
class FriendsNotifier extends _$FriendsNotifier {
  @override
  Future<List<Friendship>> build() =>
      ref.read(friendshipRepositoryProvider).getFriends();

  Future<void> refresh() {
    ref.invalidateSelf();
    return future;
  }
}
