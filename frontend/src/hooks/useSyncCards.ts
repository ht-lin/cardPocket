import { useMutation, useQueryClient } from '@tanstack/react-query';
import { getCardSync } from '@/lib/api/endpoints/cards';
import { insertOrReplaceCards, deleteCardsByIds } from '@/lib/storage/db';
import { secureStore } from '@/lib/storage/secureStore';
import { toCardRow } from '@/lib/storage/cardMapper';
import { queryKeys } from '@/lib/query/keys';

export function useSyncCards() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      const lastSync = (await secureStore.getLastSync()) ?? '1970-01-01T00:00:00.000Z';
      const { updated, deleted } = await getCardSync({ updatedAfter: lastSync });
      await insertOrReplaceCards(updated.map(toCardRow));
      await deleteCardsByIds(deleted);
      await secureStore.setLastSync(new Date().toISOString());
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
    },
  });
}
