import { apiFetch, type AuthHandlers } from './api';
import type { UserOutput, UserUpdateRequest } from '@/types/api';

export async function getMe(auth: AuthHandlers): Promise<UserOutput> {
  const res = await apiFetch('/api/users/me', { method: 'GET' }, auth);
  if (!res.ok) throw new Error(`Failed to fetch user: ${res.status}`);
  return res.json() as Promise<UserOutput>;
}

export async function updateMe(auth: AuthHandlers, data: UserUpdateRequest): Promise<UserOutput> {
  const res = await apiFetch(
    '/api/users/me',
    { method: 'PATCH', body: JSON.stringify(data) },
    auth,
  );
  if (!res.ok) throw res;
  return res.json() as Promise<UserOutput>;
}

export async function deleteMe(auth: AuthHandlers): Promise<void> {
  const res = await apiFetch('/api/users/me', { method: 'DELETE' }, auth);
  if (res.status !== 204) throw new Error(`Failed to delete account: ${res.status}`);
}
