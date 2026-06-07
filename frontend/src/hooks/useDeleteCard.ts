import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { deleteCard } from '@/lib/api/endpoints/cards';
import { deleteCardsByIds } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';

export function useDeleteCard() {
  const queryClient = useQueryClient();
  const router = useRouter();

  return useMutation({
    mutationFn: async (id: string) => {
      await deleteCard(id);
      await deleteCardsByIds([id]);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
      router.back();
    },
  });
}
