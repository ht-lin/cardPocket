import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { secureStore } from '@/lib/storage/secureStore';
import { logout } from '@/lib/api/endpoints/auth';

export function useLogout() {
  const { clear } = useAuthStore();
  const router = useRouter();

  return useMutation<void, Error, void>({
    mutationFn: async () => {
      const rt = await secureStore.getRefreshToken();
      if (rt) await logout(rt);
    },
    onSettled: async () => {
      clear();
      await secureStore.deleteRefreshToken();
      router.replace('/login');
    },
  });
}
