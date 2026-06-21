import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/is_offline_provider.dart';
import '../data/cards_repository.dart';
import '../domain/card_model.dart';

part 'cards_search_notifier.g.dart';

@riverpod
class CardsSearchNotifier extends _$CardsSearchNotifier {
  @override
  Future<CardsSearchState> build() async => const CardsSearchState();

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      state = const AsyncData(CardsSearchState());
      return;
    }
    state = const AsyncLoading();

    try {
      final repo = ref.read(cardsRepositoryProvider);
      final local = await repo.searchLocal(q);
      if (local.isNotEmpty) {
        state = AsyncData(CardsSearchState(results: local, query: q));
        return;
      }

      // Local cache (full set, <=200 cards) had no hit. Only reach out to the
      // backend when we are actually online; offline yields an empty result.
      final offline = ref.read(isOfflineProvider).value ?? false;
      if (offline) {
        state = AsyncData(CardsSearchState(query: q));
        return;
      }

      final remote = await repo.searchRemote(q);
      state = AsyncData(
        CardsSearchState(results: remote, fromRemote: true, query: q),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
