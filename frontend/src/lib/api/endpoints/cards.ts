import { client } from '@/lib/api/client';
import type {
  CardOwnerOutput,
  CardViewerOutput,
  CardCreateInput,
  CardUpdateInput,
} from '@/schemas/card';

export type CardListParams = {
  updatedAfter?: string;
};

export type CardSyncResponse = {
  updated: (CardOwnerOutput | CardViewerOutput)[];
  deleted: string[];
};

export const getCards = (params?: CardListParams): Promise<CardOwnerOutput[]> =>
  client.get<CardOwnerOutput[]>('/api/cards', { params }).then((r) => r.data);

export const getCardSync = (params: CardListParams): Promise<CardSyncResponse> =>
  client.get<CardSyncResponse>('/api/cards', { params }).then((r) => r.data);

export const getCard = (id: string): Promise<CardOwnerOutput> =>
  client.get<CardOwnerOutput>(`/api/cards/${id}`).then((r) => r.data);

export const createCard = (data: CardCreateInput): Promise<CardOwnerOutput> =>
  client.post<CardOwnerOutput>('/api/cards', data).then((r) => r.data);

export const updateCard = (id: string, data: CardUpdateInput): Promise<CardOwnerOutput> =>
  client.patch<CardOwnerOutput>(`/api/cards/${id}`, data).then((r) => r.data);

export const deleteCard = (id: string): Promise<void> =>
  client.delete(`/api/cards/${id}`).then(() => undefined);
