import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { register } from '@/lib/api/endpoints/auth';
import type { RegisterInput, UserOutput } from '@/schemas/auth';

export function useRegister() {
  const router = useRouter();

  return useMutation<UserOutput, Error, RegisterInput>({
    mutationFn: (data) => register(data),
    onSuccess: (_, variables) => {
      router.replace({
        pathname: '/verify-email',
        params: { email: variables.email },
      });
    },
  });
}
