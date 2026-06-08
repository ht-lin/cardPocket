import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockDeleteShare = jest.fn();
jest.mock('@/lib/api/endpoints/shares', () => ({
  deleteShare: (...args: unknown[]) => mockDeleteShare(...args),
}));

const mockDeleteCardsByIds = jest.fn();
jest.mock('@/lib/storage/db', () => ({
  deleteCardsByIds: (...args: unknown[]) => mockDeleteCardsByIds(...args),
}));

import { useViewerLeaveShare } from '@/hooks/useViewerLeaveShare';

function makeWrapper() {
  const client = new QueryClient({
    defaultOptions: { mutations: { retry: false } },
  });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useViewerLeaveShare', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls deleteShare and deleteCardsByIds', async () => {
    mockDeleteShare.mockResolvedValue(undefined);
    mockDeleteCardsByIds.mockResolvedValue(undefined);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useViewerLeaveShare(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ shareId: 'share-1', cardId: 'card-1' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockDeleteShare).toHaveBeenCalledWith('share-1');
    expect(mockDeleteCardsByIds).toHaveBeenCalledWith(['card-1']);
  });

  it('invalidates cards.all on success', async () => {
    mockDeleteShare.mockResolvedValue(undefined);
    mockDeleteCardsByIds.mockResolvedValue(undefined);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useViewerLeaveShare(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ shareId: 'share-1', cardId: 'card-1' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['cards'] });
  });
});
