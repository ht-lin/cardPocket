// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CardsSearchNotifier)
final cardsSearchProvider = CardsSearchNotifierProvider._();

final class CardsSearchNotifierProvider
    extends $AsyncNotifierProvider<CardsSearchNotifier, CardsSearchState> {
  CardsSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardsSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardsSearchNotifierHash();

  @$internal
  @override
  CardsSearchNotifier create() => CardsSearchNotifier();
}

String _$cardsSearchNotifierHash() =>
    r'9acef405780d64f67ea7042c1e8ec381274423ea';

abstract class _$CardsSearchNotifier extends $AsyncNotifier<CardsSearchState> {
  FutureOr<CardsSearchState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CardsSearchState>, CardsSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CardsSearchState>, CardsSearchState>,
              AsyncValue<CardsSearchState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
