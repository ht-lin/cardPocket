import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

// ---------------------------------------------------------------------------
// Mocks — must be declared before any imports that depend on these modules
// ---------------------------------------------------------------------------

const mockGetCardSync = jest.fn();
jest.mock('@/lib/api/endpoints/cards', () => ({
  getCardSync: (...args: unknown[]) => mockGetCardSync(...args),
}));

const mockInsertOrReplaceCards = jest.fn<Promise<void>, [unknown[]]>().mockResolvedValue(undefined);
const mockDeleteCardsByIds = jest.fn<Promise<void>, [string[]]>().mockResolvedValue(undefined);
const mockSelectAllCards = jest.fn().mockResolvedValue([]);
jest.mock('@/lib/storage/db', () => ({
  insertOrReplaceCards: (...args: unknown[]) => mockInsertOrReplaceCards(...args),
  deleteCardsByIds: (...args: unknown[]) => mockDeleteCardsByIds(...args),
  selectAllCards: () => mockSelectAllCards(),
}));

const mockGetLastSync = jest.fn<Promise<string | null>, []>();
const mockSetLastSync = jest.fn<Promise<void>, [string]>().mockResolvedValue(undefined);
jest.mock('@/lib/storage/secureStore', () => ({
  secureStore: {
    getLastSync: () => mockGetLastSync(),
    setLastSync: (...args: [string]) => mockSetLastSync(...args),
  },
}));

jest.mock('@/lib/storage/cardMapper', () => ({
  toCardRow: jest.fn((card: unknown) => card),
  toViewerCardRow: jest.fn((card: unknown) => card),
}));

// ---------------------------------------------------------------------------
// Import after mocks
// ---------------------------------------------------------------------------
import { useSyncCards } from '@/hooks/useSyncCards';
import { toCardRow } from '@/lib/storage/cardMapper';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeWrapper() {
  const client = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
  return Wrapper;
}

const CARD_1 = {
  id: 'card-1',
  name: 'Test Card',
  barcodeType: 'QR_CODE',
  barcodeContent: '1234',
  isOwner: true as const,
  color: null,
  gradient: null,
  icon: null,
  expiresAt: null,
  archivedAt: null,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-02T00:00:00.000Z',
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('useSyncCards', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockGetLastSync.mockResolvedValue(null);
    mockGetCardSync.mockResolvedValue({ updated: [], deleted: [] });
  });

  it('updated 卡片写入 SQLite', async () => {
    mockGetCardSync.mockResolvedValue({ updated: [CARD_1], deleted: [] });

    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockInsertOrReplaceCards).toHaveBeenCalledWith([(toCardRow as jest.Mock)(CARD_1)]);
  });

  it('deleted ID 从 SQLite 删除', async () => {
    mockGetCardSync.mockResolvedValue({ updated: [], deleted: ['id-1', 'id-2'] });

    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockDeleteCardsByIds).toHaveBeenCalledWith(['id-1', 'id-2']);
  });

  it('lastSyncTimestamp 更新（setLastSync 被调用，参数为 ISO 字符串）', async () => {
    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockSetLastSync).toHaveBeenCalledTimes(1);
    const ts: string = mockSetLastSync.mock.calls[0][0];
    expect(() => new Date(ts)).not.toThrow();
    expect(new Date(ts).getTime()).toBeGreaterThan(0);
  });

  it('上次同步时间戳作为 updatedAfter 参数传给 getCardSync', async () => {
    const LAST_SYNC = '2026-05-01T12:00:00.000Z';
    mockGetLastSync.mockResolvedValue(LAST_SYNC);

    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockGetCardSync).toHaveBeenCalledWith({ updatedAfter: LAST_SYNC });
  });

  it('lastSync 为 null 时使用 epoch 时间戳', async () => {
    mockGetLastSync.mockResolvedValue(null);

    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockGetCardSync).toHaveBeenCalledWith({ updatedAfter: '1970-01-01T00:00:00.000Z' });
  });

  it('updated 为空时 insertOrReplaceCards 以空数组调用', async () => {
    mockGetCardSync.mockResolvedValue({ updated: [], deleted: [] });

    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockInsertOrReplaceCards).toHaveBeenCalledWith([]);
  });

  it('deleted 为空时 deleteCardsByIds 以空数组调用', async () => {
    mockGetCardSync.mockResolvedValue({ updated: [], deleted: [] });

    const { result } = await renderHook(() => useSyncCards(), { wrapper: makeWrapper() });

    await act(async () => { result.current.mutate(); });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(mockDeleteCardsByIds).toHaveBeenCalledWith([]);
  });
});
