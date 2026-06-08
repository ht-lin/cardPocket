import { useQuery } from '@tanstack/react-query';
import { searchUsers } from '@/lib/api/endpoints/users';
import { queryKeys } from '@/lib/query/keys';

export function useSearchUsers(q: string) {
  return useQuery({
    queryKey: queryKeys.users.search(q),
    queryFn: () => searchUsers(q),
    enabled: q.trim().length > 0,
    staleTime: 30_000,
  });
}
