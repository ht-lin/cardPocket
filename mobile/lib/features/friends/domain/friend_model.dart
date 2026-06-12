import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_model.freezed.dart';

enum FriendshipStatus { pending, accepted }

@freezed
abstract class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String id,
    required String userName,
  }) = _UserSummary;
}

@freezed
abstract class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required String id,
    required UserSummary requester,
    required DateTime createdAt,
  }) = _FriendRequest;
}

@freezed
abstract class Friendship with _$Friendship {
  const factory Friendship({
    required String id,
    required UserSummary friend,
    required DateTime createdAt,
  }) = _Friendship;
}
