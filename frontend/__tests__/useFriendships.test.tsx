import React from 'react';
import { renderHook, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockGetFriendships = jest.fn();
jest.mock('@/lib/api/endpoints/friends', () => ({
  getFriendships: () => mockGetFriendships(),
}));

import { useFriendships } from '@/hooks/useFriendships';
import { FRIENDSHIP_ACCEPTED } from './mocks/handlers';

function makeWrapper() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return Wrapper;
}

describe('useFriendships', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns friends list on success', async () => {
    mockGetFriendships.mockResolvedValue([FRIENDSHIP_ACCEPTED]);

    const { result } = await renderHook(() => useFriendships(), { wrapper: makeWrapper() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.friends).toEqual([FRIENDSHIP_ACCEPTED]);
  });

  it('returns empty array when no friends', async () => {
    mockGetFriendships.mockResolvedValue([]);

    const { result } = await renderHook(() => useFriendships(), { wrapper: makeWrapper() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.friends).toEqual([]);
  });
});
