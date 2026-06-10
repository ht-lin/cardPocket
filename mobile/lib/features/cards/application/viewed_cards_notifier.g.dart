// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewed_cards_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ViewedCardsNotifier)
final viewedCardsProvider = ViewedCardsNotifierProvider._();

final class ViewedCardsNotifierProvider
    extends $AsyncNotifierProvider<ViewedCardsNotifier, CardsListState> {
  ViewedCardsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewedCardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewedCardsNotifierHash();

  @$internal
  @override
  ViewedCardsNotifier create() => ViewedCardsNotifier();
}

String _$viewedCardsNotifierHash() =>
    r'03c9e5dd1196cc1396ffea4e4bede8780d6c0c44';

abstract class _$ViewedCardsNotifier extends $AsyncNotifier<CardsListState> {
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
