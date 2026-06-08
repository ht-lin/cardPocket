import { useMutation, useQueryClient } from '@tanstack/react-query';
import { deleteShare } from '@/lib/api/endpoints/shares';
import { deleteCardsByIds } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';

export function useViewerLeaveShare() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ shareId, cardId }: { shareId: string; cardId: string }) => {
      await deleteShare(shareId);
      await deleteCardsByIds([cardId]);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
    },
  });
}
