import axios from 'axios';
import { secureStore } from '@/lib/storage/secureStore';

const BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL ?? 'http://localhost:8000';

export async function rawRefresh(): Promise<{ access_token: string; refresh_token: string }> {
  const rt = await secureStore.getRefreshToken();
  if (!rt) throw new Error('No refresh token');
  const { data } = await axios.post<{ access_token: string; refresh_token: string }>(
    `${BASE_URL}/api/auth/refresh`,
    { refresh_token: rt },
    { headers: { 'Content-Type': 'application/json' } },
  );
  return data;
}
