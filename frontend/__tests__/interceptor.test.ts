/**
 * @jest-environment node
 */
import axios from 'axios';
import { http, HttpResponse } from 'msw';
import { server } from './mocks/server';
import { TOKENS, REFRESHED_TOKENS, USER } from './mocks/handlers';

// Must mock expo-secure-store before importing modules that depend on it
const mockGetItemAsync = jest.fn<Promise<string | null>, [string]>();
const mockSetItemAsync = jest.fn<Promise<void>, [string, string]>().mockResolvedValue(undefined);
const mockDeleteItemAsync = jest.fn<Promise<void>, [string]>().mockResolvedValue(undefined);

jest.mock('expo-secure-store', () => ({
  getItemAsync: (...args: [string]) => mockGetItemAsync(...args),
  setItemAsync: (...args: [string, string]) => mockSetItemAsync(...args),
  deleteItemAsync: (...args: [string]) => mockDeleteItemAsync(...args),
}));

// Import after mocks are set up
import { client } from '@/lib/api/client';
import { useAuthStore } from '@/store/authStore';

const BASE = 'http://localhost:8000';

function resetStore() {
  useAuthStore.setState({
    user: null,
    accessToken: null,
    isRestoring: false,
  });
}

beforeEach(() => {
  resetStore();
  mockGetItemAsync.mockReset();
  mockSetItemAsync.mockReset().mockResolvedValue(undefined);
  mockDeleteItemAsync.mockReset().mockResolvedValue(undefined);
});

// ---------------------------------------------------------------------------
// 请求拦截器 — token 注入
// ---------------------------------------------------------------------------
describe('请求拦截器 token 注入', () => {
  test('store 有 accessToken 时，请求头包含 Bearer token', async () => {
    useAuthStore.setState({ accessToken: TOKENS.access_token });
    let capturedAuth: string | null = null;

    server.use(
      http.get(`${BASE}/api/users/me`, ({ request }) => {
        capturedAuth = request.headers.get('Authorization');
        return HttpResponse.json(USER);
      }),
    );

    await client.get('/api/users/me');
    expect(capturedAuth).toBe(`Bearer ${TOKENS.access_token}`);
  });

  test('store 无 accessToken 时，请求头不含 Authorization', async () => {
    // accessToken is null (set in resetStore)
    let capturedAuth: string | null | undefined = undefined;

    server.use(
      http.get(`${BASE}/api/users/me`, ({ request }) => {
        capturedAuth = request.headers.get('Authorization');
        return HttpResponse.json(USER);
      }),
    );

    await client.get('/api/users/me');
    expect(capturedAuth).toBeNull();
  });
});

// ---------------------------------------------------------------------------
// 响应拦截器 — 401 自动刷新
// ---------------------------------------------------------------------------
describe('响应拦截器 401 自动刷新', () => {
  test('401 触发 doRefresh，刷新成功后重试原始请求', async () => {
    // First call returns 401, retry call returns 200
    let callCount = 0;
    mockGetItemAsync.mockResolvedValue(TOKENS.refresh_token);

    server.use(
      http.get(`${BASE}/api/test`, () => {
        callCount++;
        if (callCount === 1) {
          return HttpResponse.json({}, { status: 401 });
        }
        return HttpResponse.json({ ok: true });
      }),
      http.post(`${BASE}/api/auth/refresh`, async ({ request }) => {
        const body = (await request.json()) as Record<string, string>;
        if (body.refresh_token === TOKENS.refresh_token) {
          return HttpResponse.json(REFRESHED_TOKENS);
        }
        return HttpResponse.json({}, { status: 401 });
      }),
    );

    const response = await client.get('/api/test');
    expect(response.data).toEqual({ ok: true });
    expect(useAuthStore.getState().accessToken).toBe(REFRESHED_TOKENS.access_token);
    expect(mockSetItemAsync).toHaveBeenCalledWith('rt', REFRESHED_TOKENS.refresh_token);
  });

  test('SecureStore 中无 refresh token，调用 authStore.clear() 并 deleteRefreshToken', async () => {
    mockGetItemAsync.mockResolvedValue(null);

    server.use(
      http.get(`${BASE}/api/test`, () => HttpResponse.json({}, { status: 401 })),
    );

    await expect(client.get('/api/test')).rejects.toThrow();
    expect(useAuthStore.getState().accessToken).toBeNull();
    expect(mockDeleteItemAsync).toHaveBeenCalledWith('rt');
  });

  test('refresh 端点返回 401，调用 authStore.clear() 并 deleteRefreshToken', async () => {
    mockGetItemAsync.mockResolvedValue('invalid-refresh-token');

    server.use(
      http.get(`${BASE}/api/test`, () => HttpResponse.json({}, { status: 401 })),
      http.post(`${BASE}/api/auth/refresh`, () => HttpResponse.json({}, { status: 401 })),
    );

    await expect(client.get('/api/test')).rejects.toThrow();
    expect(useAuthStore.getState().accessToken).toBeNull();
    expect(mockDeleteItemAsync).toHaveBeenCalledWith('rt');
  });

  test('非 401 错误（403）直接 reject，不触发刷新', async () => {
    let refreshCalled = false;

    server.use(
      http.get(`${BASE}/api/test`, () => HttpResponse.json({ message: 'Forbidden' }, { status: 403 })),
      http.post(`${BASE}/api/auth/refresh`, () => {
        refreshCalled = true;
        return HttpResponse.json(REFRESHED_TOKENS);
      }),
    );

    await expect(client.get('/api/test')).rejects.toMatchObject({
      response: { status: 403 },
    });
    expect(refreshCalled).toBe(false);
  });

  test('_retry=true 的请求再次 401，不再触发刷新（防循环）', async () => {
    let refreshCallCount = 0;
    mockGetItemAsync.mockResolvedValue(TOKENS.refresh_token);

    server.use(
      // Always return 401 (even after refresh)
      http.get(`${BASE}/api/test`, () => HttpResponse.json({}, { status: 401 })),
      http.post(`${BASE}/api/auth/refresh`, () => {
        refreshCallCount++;
        return HttpResponse.json(REFRESHED_TOKENS);
      }),
    );

    await expect(client.get('/api/test')).rejects.toThrow();
    // Refresh triggered once for first 401, but the retried request also gets 401
    // and _retry=true prevents another refresh cycle
    expect(refreshCallCount).toBe(1);
  });
});

// ---------------------------------------------------------------------------
// 并发 401 只发一次 refresh
// ---------------------------------------------------------------------------
describe('并发 401 只发一次 refresh', () => {
  test('3 个并发请求同时 401，refreshPromise 锁保证只调用一次 POST /refresh', async () => {
    let refreshCallCount = 0;
    mockGetItemAsync.mockResolvedValue(TOKENS.refresh_token);

    server.use(
      http.get(`${BASE}/api/test`, ({ request }) => {
        const auth = request.headers.get('Authorization');
        if (auth === `Bearer ${REFRESHED_TOKENS.access_token}`) {
          return HttpResponse.json({ ok: true });
        }
        return HttpResponse.json({}, { status: 401 });
      }),
      http.post(`${BASE}/api/auth/refresh`, () => {
        refreshCallCount++;
        return HttpResponse.json(REFRESHED_TOKENS);
      }),
    );

    const results = await Promise.allSettled([
      client.get('/api/test'),
      client.get('/api/test'),
      client.get('/api/test'),
    ]);

    expect(refreshCallCount).toBe(1);
    const fulfilled = results.filter((r) => r.status === 'fulfilled');
    expect(fulfilled).toHaveLength(3);
  });

  test('refresh 成功后，所有并发请求全部用新 token 重试成功', async () => {
    mockGetItemAsync.mockResolvedValue(TOKENS.refresh_token);

    server.use(
      http.get(`${BASE}/api/test`, ({ request }) => {
        const auth = request.headers.get('Authorization');
        if (auth === `Bearer ${REFRESHED_TOKENS.access_token}`) {
          return HttpResponse.json({ ok: true });
        }
        return HttpResponse.json({}, { status: 401 });
      }),
      http.post(`${BASE}/api/auth/refresh`, () => HttpResponse.json(REFRESHED_TOKENS)),
    );

    const [r1, r2, r3] = await Promise.all([
      client.get('/api/test'),
      client.get('/api/test'),
      client.get('/api/test'),
    ]);

    expect(r1.data).toEqual({ ok: true });
    expect(r2.data).toEqual({ ok: true });
    expect(r3.data).toEqual({ ok: true });
  });
});
