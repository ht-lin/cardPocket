import { useQuery } from '@tanstack/react-query';
import { getShares } from '@/lib/api/endpoints/shares';
import { queryKeys } from '@/lib/query/keys';

export function useGetShares(cardId: string) {
  return useQuery({
    queryKey: queryKeys.shares.card(cardId),
    queryFn: () => getShares(cardId),
    enabled: !!cardId,
  });
}
