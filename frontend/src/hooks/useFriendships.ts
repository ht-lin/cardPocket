import { useQuery } from '@tanstack/react-query';
import { getFriendships } from '@/lib/api/endpoints/friends';
import { queryKeys } from '@/lib/query/keys';

export function useFriendships() {
  const query = useQuery({
    queryKey: queryKeys.friends.all,
    queryFn: getFriendships,
    staleTime: 60_000,
  });

  return {
    friends: query.data ?? [],
    isLoading: query.isLoading,
    isSuccess: query.isSuccess,
    refetch: query.refetch,
  };
}
