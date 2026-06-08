import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockDeleteShare = jest.fn();
jest.mock('@/lib/api/endpoints/shares', () => ({
  deleteShare: (...args: unknown[]) => mockDeleteShare(...args),
}));

import { useOwnerRemoveShare } from '@/hooks/useOwnerRemoveShare';

function makeWrapper() {
  const client = new QueryClient({
    defaultOptions: { mutations: { retry: false } },
  });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useOwnerRemoveShare', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls deleteShare with shareId', async () => {
    mockDeleteShare.mockResolvedValue(undefined);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useOwnerRemoveShare('card-1'), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate('share-1');
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockDeleteShare).toHaveBeenCalledWith('share-1');
  });

  it('invalidates shares.card query on success', async () => {
    mockDeleteShare.mockResolvedValue(undefined);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useOwnerRemoveShare('card-1'), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate('share-1');
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['shares', 'card-1'] });
  });
});
