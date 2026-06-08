import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockDeleteFriendship = jest.fn();
jest.mock('@/lib/api/endpoints/friends', () => ({
  deleteFriendship: (...args: unknown[]) => mockDeleteFriendship(...args),
}));

import { useRemoveFriend } from '@/hooks/useRemoveFriend';

function makeWrapper() {
  const client = new QueryClient({ defaultOptions: { mutations: { retry: false } } });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useRemoveFriend', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls deleteFriendship with the friendship id', async () => {
    mockDeleteFriendship.mockResolvedValue(undefined);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useRemoveFriend(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate('fs-1');
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockDeleteFriendship).toHaveBeenCalledWith('fs-1');
  });

  it('invalidates friends.all and friends.requests on success', async () => {
    mockDeleteFriendship.mockResolvedValue(undefined);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useRemoveFriend(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate('fs-1');
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['friends'] });
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['friends', 'requests'] });
  });
});
