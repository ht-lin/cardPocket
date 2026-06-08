import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const mockUpdateShare = jest.fn();
jest.mock('@/lib/api/endpoints/shares', () => ({
  updateShare: (...args: unknown[]) => mockUpdateShare(...args),
}));

const mockUpdateCardNicknameByShareId = jest.fn();
jest.mock('@/lib/storage/db', () => ({
  updateCardNicknameByShareId: (...args: unknown[]) => mockUpdateCardNicknameByShareId(...args),
}));

import { useUpdateShareNickname } from '@/hooks/useUpdateShareNickname';
import type { CardShareOutput } from '@/schemas/cardShare';

const SHARE: CardShareOutput = {
  id: 'share-1',
  viewer: { id: 'viewer-1', userName: 'jane_doe' },
  viewerNickname: '家庭超市卡',
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

describe('useUpdateShareNickname', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls updateShare and updateCardNicknameByShareId', async () => {
    mockUpdateShare.mockResolvedValue(SHARE);
    mockUpdateCardNicknameByShareId.mockResolvedValue(undefined);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useUpdateShareNickname(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ shareId: 'share-1', viewerNickname: '家庭超市卡' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockUpdateShare).toHaveBeenCalledWith('share-1', { viewerNickname: '家庭超市卡' });
    expect(mockUpdateCardNicknameByShareId).toHaveBeenCalledWith('share-1', '家庭超市卡');
  });

  it('supports clearing nickname with null', async () => {
    mockUpdateShare.mockResolvedValue({ ...SHARE, viewerNickname: null });
    mockUpdateCardNicknameByShareId.mockResolvedValue(undefined);
    const { Wrapper } = makeWrapper();

    const { result } = await renderHook(() => useUpdateShareNickname(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ shareId: 'share-1', viewerNickname: null });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockUpdateShare).toHaveBeenCalledWith('share-1', { viewerNickname: null });
    expect(mockUpdateCardNicknameByShareId).toHaveBeenCalledWith('share-1', null);
  });

  it('invalidates cards.all on success', async () => {
    mockUpdateShare.mockResolvedValue(SHARE);
    mockUpdateCardNicknameByShareId.mockResolvedValue(undefined);
    const { client, Wrapper } = makeWrapper();
    const invalidateSpy = jest.spyOn(client, 'invalidateQueries');

    const { result } = await renderHook(() => useUpdateShareNickname(), { wrapper: Wrapper });

    await act(async () => {
      result.current.mutate({ shareId: 'share-1', viewerNickname: '家庭超市卡' });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: ['cards'] });
  });
});
