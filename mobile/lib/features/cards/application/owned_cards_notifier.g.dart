// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owned_cards_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OwnedCardsNotifier)
final ownedCardsProvider = OwnedCardsNotifierProvider._();

final class OwnedCardsNotifierProvider
    extends $AsyncNotifierProvider<OwnedCardsNotifier, CardsListState> {
  OwnedCardsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownedCardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownedCardsNotifierHash();

  @$internal
  @override
  OwnedCardsNotifier create() => OwnedCardsNotifier();
}

String _$ownedCardsNotifierHash() =>
    r'1dd2a8ae6a4c2e5112033afc6b821e5af27fa9b5';

abstract class _$OwnedCardsNotifier extends $AsyncNotifier<CardsListState> {
  FutureOr<CardsListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CardsListState>, CardsListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CardsListState>, CardsListState>,
              AsyncValue<CardsListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
