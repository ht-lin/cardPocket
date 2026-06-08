import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockAcceptFriendship = jest.fn();
jest.mock('@/lib/api/endpoints/friends', () => ({
  acceptFriendship: (...args: unknown[]) => mockAcceptFriendship(...args),
}));

import { useAcceptFriendRequest } from '@/hooks/useAcceptFriendRequest';
import { FRIENDSHIP_ACCEPTED } from './mocks/handlers';

function makeWrapper() {
  const client = new QueryClient({ defaultOptions: { mutations: { retry: false } } });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useAcceptFriendRequest', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls acceptFriendship with the friendship id', async () => {
    mockAcceptFriendship.mockResolvedValue(FRIENDSHIP_ACCEPTED);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useAcceptFriendRequest(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate('fs-2');
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockAcceptFriendship).toHaveBeenCalledWith('fs-2');
  });

  it('invalidates friends.all and friends.requests on success', async () => {
    mockAcceptFriendship.mockResolvedValue(FRIENDSHIP_ACCEPTED);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useAcceptFriendRequest(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate('fs-2');
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['friends'] });
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['friends', 'requests'] });
  });
});
