import React from 'react';
import { renderHook, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockGetFriendRequests = jest.fn();
jest.mock('@/lib/api/endpoints/friends', () => ({
  getFriendRequests: () => mockGetFriendRequests(),
}));

import { useFriendRequests } from '@/hooks/useFriendRequests';
import { FRIENDSHIP_PENDING } from './mocks/handlers';

function makeWrapper() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return Wrapper;
}

describe('useFriendRequests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns pending requests on success', async () => {
    mockGetFriendRequests.mockResolvedValue([FRIENDSHIP_PENDING]);

    const { result } = await renderHook(() => useFriendRequests(), { wrapper: makeWrapper() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.requests).toEqual([FRIENDSHIP_PENDING]);
  });

  it('returns empty array when no pending requests', async () => {
    mockGetFriendRequests.mockResolvedValue([]);

    const { result } = await renderHook(() => useFriendRequests(), { wrapper: makeWrapper() });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.requests).toEqual([]);
  });
});
