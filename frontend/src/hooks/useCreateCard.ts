import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createCard } from '@/lib/api/endpoints/cards';
import { insertOrReplaceCards } from '@/lib/storage/db';
import { toCardRow } from '@/lib/storage/cardMapper';
import { queryKeys } from '@/lib/query/keys';
import type { CardCreateInput } from '@/schemas/card';

export function useCreateCard() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: CardCreateInput) => {
      const card = await createCard(data);
      await insertOrReplaceCards([toCardRow(card)]);
      return card;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
    },
  });
}
