import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { secureStore } from '@/lib/storage/secureStore';
import { deleteMe } from '@/lib/api/endpoints/users';

export function useDeleteAccount() {
  const { clear } = useAuthStore();
  const router = useRouter();

  return useMutation<void, Error, void>({
    mutationFn: () => deleteMe(),
    onSuccess: async () => {
      clear();
      await secureStore.deleteRefreshToken();
      router.replace('/login');
    },
  });
}
