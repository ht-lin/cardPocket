import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockCreateShare = jest.fn();
jest.mock('@/lib/api/endpoints/shares', () => ({
  createShare: (...args: unknown[]) => mockCreateShare(...args),
}));

import { useCreateShare } from '@/hooks/useCreateShare';
import type { CardShareOutput } from '@/schemas/cardShare';

const SHARE: CardShareOutput = {
  id: 'share-1',
  viewer: { id: 'viewer-1', userName: 'jane_doe' },
  viewerNickname: null,
  createdAt: '2026-06-01T10:00:00Z',
};

function makeWrapper() {
  const client = new QueryClient({
    defaultOptions: { mutations: { retry: false } },
  });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useCreateShare', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls createShare with cardId and viewerId', async () => {
    mockCreateShare.mockResolvedValue(SHARE);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useCreateShare('card-1'), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ viewerId: 'viewer-1' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockCreateShare).toHaveBeenCalledWith('card-1', { viewerId: 'viewer-1' });
  });

  it('invalidates shares.card query on success', async () => {
    mockCreateShare.mockResolvedValue(SHARE);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useCreateShare('card-1'), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ viewerId: 'viewer-1' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['shares', 'card-1'] });
  });
});
