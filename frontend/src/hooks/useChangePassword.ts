import { useMutation } from '@tanstack/react-query';
import { updateMe } from '@/lib/api/endpoints/users';

export function useChangePassword() {
  return useMutation({
    mutationFn: ({ currentPassword, newPassword }: { currentPassword: string; newPassword: string }) =>
      updateMe({ currentPassword, newPassword }),
  });
}
