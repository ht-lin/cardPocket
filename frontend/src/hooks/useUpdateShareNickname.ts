import { useMutation, useQueryClient } from '@tanstack/react-query';
import { updateShare } from '@/lib/api/endpoints/shares';
import { updateCardNicknameByShareId } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';

export function useUpdateShareNickname() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      shareId,
      viewerNickname,
    }: {
      shareId: string;
      viewerNickname: string | null;
    }) => {
      await updateShare(shareId, { viewerNickname });
      await updateCardNicknameByShareId(shareId, viewerNickname);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
    },
  });
}
