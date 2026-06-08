import { useQuery } from '@tanstack/react-query';
import { getFriendRequests } from '@/lib/api/endpoints/friends';
import { queryKeys } from '@/lib/query/keys';

export function useFriendRequests() {
  const query = useQuery({
    queryKey: queryKeys.friends.requests,
    queryFn: getFriendRequests,
    staleTime: 60_000,
  });

  return {
    requests: query.data ?? [],
    isLoading: query.isLoading,
    isSuccess: query.isSuccess,
    refetch: query.refetch,
  };
}
