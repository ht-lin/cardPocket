import { useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { selectAllCards } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';
import { useSyncCards } from '@/hooks/useSyncCards';

export function useCards() {
  const sync = useSyncCards();

  const query = useQuery({
    queryKey: queryKeys.cards.all,
    queryFn: selectAllCards,
    staleTime: Infinity,
  });

  useEffect(() => {
    sync.mutate();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return {
    cards: query.data ?? [],
    isLoading: query.isLoading,
    isSyncing: sync.isPending,
    refresh: () => sync.mutate(),
  };
}
