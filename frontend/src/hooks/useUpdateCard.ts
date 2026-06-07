import { useMutation, useQueryClient } from '@tanstack/react-query';
import { updateCard } from '@/lib/api/endpoints/cards';
import { insertOrReplaceCards } from '@/lib/storage/db';
import { toCardRow } from '@/lib/storage/cardMapper';
import { queryKeys } from '@/lib/query/keys';
import type { CardUpdateInput } from '@/schemas/card';

export function useUpdateCard() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: CardUpdateInput }) => {
      const card = await updateCard(id, data);
      await insertOrReplaceCards([toCardRow(card)]);
      return card;
    },
    onSuccess: (card) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.detail(card.id) });
    },
  });
}
