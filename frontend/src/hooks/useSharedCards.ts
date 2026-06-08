import { useQuery } from '@tanstack/react-query';
import { selectSharedCards } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';

export function useSharedCards() {
  const query = useQuery({
    queryKey: queryKeys.cards.shared,
    queryFn: selectSharedCards,
    staleTime: Infinity,
  });

  return {
    sharedCards: query.data ?? [],
    isLoading: query.isLoading,
    refetch: query.refetch,
  };
}
