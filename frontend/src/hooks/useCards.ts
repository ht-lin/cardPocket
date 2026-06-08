import { useEffect } from 'react';
import { AppState } from 'react-native';
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

  useEffect(() => {
    let timer: ReturnType<typeof setTimeout> | null = null;
    const sub = AppState.addEventListener('change', (nextState) => {
      if (nextState === 'active') {
        if (timer) clearTimeout(timer);
        timer = setTimeout(() => sync.mutate(), 1000);
      }
    });
    return () => {
      sub.remove();
      if (timer) clearTimeout(timer);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return {
    cards: query.data ?? [],
    isLoading: query.isLoading,
    isSyncing: sync.isPending,
    refresh: () => sync.mutate(),
  };
}
