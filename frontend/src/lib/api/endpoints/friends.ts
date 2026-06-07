import { client } from '@/lib/api/client';
import type { FriendshipOutput, FriendshipCreateInput } from '@/schemas/friend';

export const getFriendships = (): Promise<FriendshipOutput[]> =>
  client.get<FriendshipOutput[]>('/api/friendships').then((r) => r.data);

export const getFriendRequests = (): Promise<FriendshipOutput[]> =>
  client.get<FriendshipOutput[]>('/api/friendships/requests').then((r) => r.data);

export const createFriendship = (data: FriendshipCreateInput): Promise<FriendshipOutput> =>
  client.post<FriendshipOutput>('/api/friendships', data).then((r) => r.data);

export const acceptFriendship = (id: string): Promise<FriendshipOutput> =>
  client.patch<FriendshipOutput>(`/api/friendships/${id}/accept`, {}).then((r) => r.data);

export const deleteFriendship = (id: string): Promise<void> =>
  client.delete(`/api/friendships/${id}`).then(() => undefined);
