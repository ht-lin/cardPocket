import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createShare } from '@/lib/api/endpoints/shares';
import { queryKeys } from '@/lib/query/keys';
import type { CardShareCreateInput } from '@/schemas/cardShare';

export function useCreateShare(cardId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CardShareCreateInput) => createShare(cardId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.shares.card(cardId) });
    },
  });
}
