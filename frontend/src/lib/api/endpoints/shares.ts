import { client } from '@/lib/api/client';
import type {
  CardShareOutput,
  CardShareCreateInput,
  CardShareUpdateInput,
} from '@/schemas/cardShare';

export const getShares = (cardId: string): Promise<CardShareOutput[]> =>
  client.get<CardShareOutput[]>(`/api/cards/${cardId}/shares`).then((r) => r.data);

export const createShare = (
  cardId: string,
  data: CardShareCreateInput,
): Promise<CardShareOutput> =>
  client.post<CardShareOutput>(`/api/cards/${cardId}/shares`, data).then((r) => r.data);

export const updateShare = (
  id: string,
  data: CardShareUpdateInput,
): Promise<CardShareOutput> =>
  client.patch<CardShareOutput>(`/api/card-shares/${id}`, data).then((r) => r.data);

export const deleteShare = (id: string): Promise<void> =>
  client.delete(`/api/card-shares/${id}`).then(() => undefined);
