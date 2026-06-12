// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FriendsNotifier)
final friendsProvider = FriendsNotifierProvider._();

final class FriendsNotifierProvider
    extends $AsyncNotifierProvider<FriendsNotifier, List<Friendship>> {
  FriendsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendsNotifierHash();

  @$internal
  @override
  FriendsNotifier create() => FriendsNotifier();
}

String _$friendsNotifierHash() => r'a329138c33453a08957c043b55a66bb8d9cb3c11';

abstract class _$FriendsNotifier extends $AsyncNotifier<List<Friendship>> {
  FutureOr<List<Friendship>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Friendship>>, List<Friendship>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Friendship>>, List<Friendship>>,
              AsyncValue<List<Friendship>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
