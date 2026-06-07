import { client } from '@/lib/api/client';
import type { UserOutput, UserUpdateInput, UserSearchOutput } from '@/schemas/auth';

export const getMe = (): Promise<UserOutput> =>
  client.get<UserOutput>('/api/users/me').then((r) => r.data);

export const updateMe = (data: UserUpdateInput): Promise<UserOutput> =>
  client.patch<UserOutput>('/api/users/me', data).then((r) => r.data);

export const searchUsers = (q: string): Promise<UserSearchOutput[]> =>
  client
    .get<UserSearchOutput[]>('/api/users/search', { params: { q } })
    .then((r) => r.data);

export const deleteMe = (): Promise<void> =>
  client.delete('/api/users/me').then(() => undefined);
