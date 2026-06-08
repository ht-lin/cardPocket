import { useMutation, useQueryClient } from '@tanstack/react-query';
import { deleteShare } from '@/lib/api/endpoints/shares';
import { queryKeys } from '@/lib/query/keys';

export function useOwnerRemoveShare(cardId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (shareId: string) => deleteShare(shareId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.shares.card(cardId) });
    },
  });
}
