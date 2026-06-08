import { useMutation, useQueryClient } from '@tanstack/react-query';
import { acceptFriendship } from '@/lib/api/endpoints/friends';
import { queryKeys } from '@/lib/query/keys';

export function useAcceptFriendRequest() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => acceptFriendship(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.friends.all });
      queryClient.invalidateQueries({ queryKey: queryKeys.friends.requests });
    },
  });
}
