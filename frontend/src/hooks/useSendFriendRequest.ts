import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createFriendship } from '@/lib/api/endpoints/friends';
import { queryKeys } from '@/lib/query/keys';
import type { FriendshipCreateInput } from '@/schemas/friend';

export function useSendFriendRequest() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: FriendshipCreateInput) => createFriendship(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.friends.all });
    },
  });
}
