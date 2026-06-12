// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_requests_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FriendRequestsNotifier)
final friendRequestsProvider = FriendRequestsNotifierProvider._();

final class FriendRequestsNotifierProvider
    extends
        $AsyncNotifierProvider<FriendRequestsNotifier, List<FriendRequest>> {
  FriendRequestsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendRequestsNotifierHash();

  @$internal
  @override
  FriendRequestsNotifier create() => FriendRequestsNotifier();
}

String _$friendRequestsNotifierHash() =>
    r'b9e2051cc032be6acbfbcdeae03ca54d81147248';

abstract class _$FriendRequestsNotifier
    extends $AsyncNotifier<List<FriendRequest>> {
  FutureOr<List<FriendRequest>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FriendRequest>>, List<FriendRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FriendRequest>>, List<FriendRequest>>,
              AsyncValue<List<FriendRequest>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
