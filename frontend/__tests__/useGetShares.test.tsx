import React from 'react';
import { renderHook, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockGetShares = jest.fn();
jest.mock('@/lib/api/endpoints/shares', () => ({
  getShares: (...args: unknown[]) => mockGetShares(...args),
}));

import { useGetShares } from '@/hooks/useGetShares';
import type { CardShareOutput } from '@/schemas/cardShare';

const SHARE: CardShareOutput = {
  id: 'share-1',
  viewer: { id: 'viewer-1', userName: 'jane_doe' },
  viewerNickname: null,
  createdAt: '2026-06-01T10:00:00Z',
};

function makeWrapper() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useGetShares', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls getShares with the given cardId', async () => {
    mockGetShares.mockResolvedValue([SHARE]);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useGetShares('card-1'), { wrapper: Wrapper });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockGetShares).toHaveBeenCalledWith('card-1');
    expect(result.current.data).toEqual([SHARE]);
  });

  it('does not fetch when cardId is empty', async () => {
    const { Wrapper } = makeWrapper();

    await renderHook(() => useGetShares(''), { wrapper: Wrapper });

    expect(mockGetShares).not.toHaveBeenCalled();
  });
});
