import { useMutation, useQueryClient } from '@tanstack/react-query';
import { deleteFriendship } from '@/lib/api/endpoints/friends';
import { queryKeys } from '@/lib/query/keys';

export function useRemoveFriend() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => deleteFriendship(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.friends.all });
      queryClient.invalidateQueries({ queryKey: queryKeys.friends.requests });
    },
  });
}
