import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { secureStore } from '@/lib/storage/secureStore';
import { login } from '@/lib/api/endpoints/auth';
import { getMe } from '@/lib/api/endpoints/users';
import type { LoginInput, AuthResponse } from '@/schemas/auth';

export function useLogin() {
  const { setAccessToken, setUser } = useAuthStore();
  const router = useRouter();

  return useMutation<AuthResponse, Error, LoginInput>({
    mutationFn: (data) => login(data),
    onSuccess: async (response) => {
      setAccessToken(response.access_token);
      await secureStore.setRefreshToken(response.refresh_token);
      const me = await getMe();
      setUser(me);
      router.replace('/(app)/(tabs)/');
    },
  });
}
