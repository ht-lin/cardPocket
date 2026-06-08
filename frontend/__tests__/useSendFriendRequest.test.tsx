import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockCreateFriendship = jest.fn();
jest.mock('@/lib/api/endpoints/friends', () => ({
  createFriendship: (...args: unknown[]) => mockCreateFriendship(...args),
}));

import { useSendFriendRequest } from '@/hooks/useSendFriendRequest';
import { FRIENDSHIP_PENDING } from './mocks/handlers';

function makeWrapper() {
  const client = new QueryClient({ defaultOptions: { mutations: { retry: false } } });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return { client, Wrapper };
}

describe('useSendFriendRequest', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls createFriendship with addresseeId', async () => {
    mockCreateFriendship.mockResolvedValue(FRIENDSHIP_PENDING);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useSendFriendRequest(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ addresseeId: 'friend-1' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockCreateFriendship).toHaveBeenCalledWith({ addresseeId: 'friend-1' });
  });

  it('invalidates friends.all query on success', async () => {
    mockCreateFriendship.mockResolvedValue(FRIENDSHIP_PENDING);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useSendFriendRequest(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ addresseeId: 'friend-1' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['friends'] });
  });
});
