import { useMutation } from '@tanstack/react-query';
import { useAuthStore } from '@/store/authStore';
import { updateMe } from '@/lib/api/endpoints/users';

export function useUpdateUserName() {
  const { setUser } = useAuthStore();

  return useMutation({
    mutationFn: (userName: string) => updateMe({ userName }),
    onSuccess: (result) => setUser(result),
  });
}
