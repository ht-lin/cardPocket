import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/is_offline_provider.dart';
import '../../cards/application/owned_cards_notifier.dart';
import '../data/trash_repository.dart';
import '../domain/trash_card_model.dart';

part 'trash_notifier.g.dart';

@riverpod
class TrashNotifier extends _$TrashNotifier {
  static const _pageSize = 20;
  int _offset = 0;

  @override
  Future<TrashListState> build() async {
    // Trash is online-only; skip the request when offline so the UI can show
    // an offline empty state instead of a network error.
    final offline = ref.read(isOfflineProvider).value ?? false;
    if (offline) return const TrashListState(hasMore: false);

    final items = await ref.read(trashRepositoryProvider).getTrash(0);
    _offset = items.length;
    return TrashListState(
      items: items,
      hasMore: items.length == _pageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final more = await ref.read(trashRepositoryProvider).getTrash(_offset);
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

  /// Restores a card and removes it from the trash list. The main owned-cards
  /// list is invalidated so the card reappears there.
  Future<void> restore(String id) async {
    await ref.read(trashRepositoryProvider).restore(id);
    _removeFromState(id);
    ref.invalidate(ownedCardsProvider);
  }

  /// Permanently deletes a card and removes it from the trash list.
  Future<void> permanentDelete(String id) async {
    await ref.read(trashRepositoryProvider).permanentDelete(id);
    _removeFromState(id);
  }

  void _removeFromState(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: current.items.where((c) => c.id != id).toList(),
    ));
  }
}
