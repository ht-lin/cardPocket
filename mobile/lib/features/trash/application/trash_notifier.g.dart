// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrashNotifier)
final trashProvider = TrashNotifierProvider._();

final class TrashNotifierProvider
    extends $AsyncNotifierProvider<TrashNotifier, TrashListState> {
  TrashNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashNotifierHash();

  @$internal
  @override
  TrashNotifier create() => TrashNotifier();
}

String _$trashNotifierHash() => r'30b50e0b6204889b9e674f69b23ed385795a2db9';

abstract class _$TrashNotifier extends $AsyncNotifier<TrashListState> {
  FutureOr<TrashListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TrashListState>, TrashListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TrashListState>, TrashListState>,
              AsyncValue<TrashListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
