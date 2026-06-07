import axios from 'axios';
import { useAuthStore } from '@/store/authStore';
import { secureStore } from '@/lib/storage/secureStore';

const BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL ?? 'http://localhost:8000';

export const client = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});

client.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

let refreshPromise: Promise<string> | null = null;

async function doRefresh(): Promise<string> {
  const rt = await secureStore.getRefreshToken();
  if (!rt) throw new Error('No refresh token');
  const { data } = await axios.post<{ access_token: string; refresh_token: string }>(
    `${BASE_URL}/api/auth/refresh`,
    { refresh_token: rt },
    { headers: { 'Content-Type': 'application/json' } },
  );
  useAuthStore.getState().setAccessToken(data.access_token);
  await secureStore.setRefreshToken(data.refresh_token);
  return data.access_token;
}

client.interceptors.response.use(
  (response) => response,
  async (error) => {
    const original = error.config;
    if (error.response?.status !== 401 || original._retry) {
      return Promise.reject(error);
    }
    original._retry = true;

    if (!refreshPromise) {
      refreshPromise = doRefresh().finally(() => {
        refreshPromise = null;
      });
    }

    try {
      const token = await refreshPromise;
      original.headers.Authorization = `Bearer ${token}`;
      return client(original);
    } catch {
      useAuthStore.getState().clear();
      await secureStore.deleteRefreshToken();
      return Promise.reject(error);
    }
  },
);
