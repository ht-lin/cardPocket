import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cards_repository.dart';
import '../domain/card_model.dart';

part 'viewed_cards_notifier.g.dart';

@riverpod
class ViewedCardsNotifier extends _$ViewedCardsNotifier {
  static const _pageSize = 20;
  int _offset = 0;

  @override
  Future<CardsListState> build() async {
    // Sync already triggered by OwnedCardsNotifier; read directly from Drift.
    final items = await ref.read(cardsRepositoryProvider).getViewedCards(0);
    _offset = items.length;
    return CardsListState(
      items: items,
      hasMore: items.length == _pageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final more =
          await ref.read(cardsRepositoryProvider).getViewedCards(_offset);
      _offset += more.length;
      state = AsyncData(current.copyWith(
        items: [...current.items, ...more],
        isLoadingMore: false,
        hasMore: more.length == _pageSize,
      ));
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> refresh() async {
    _offset = 0;
    ref.invalidateSelf();
    await future;
  }
}
