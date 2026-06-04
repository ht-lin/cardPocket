import { router } from 'expo-router';
import { API_BASE_URL } from '@/constants/env';

export type AuthHandlers = {
  getAccessToken(): string | null;
  getRefreshToken(): string | null;
  setTokens(accessToken: string, refreshToken: string): void;
  clearTokens(): void;
};

type ApiOptions = RequestInit & { _retry?: boolean };

export async function apiFetch(
  path: string,
  options: ApiOptions,
  auth: AuthHandlers,
): Promise<Response> {
  const token = auth.getAccessToken();

  const headers = new Headers(options.headers);
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  headers.set('Content-Type', 'application/json');

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers,
  });

  if (response.status === 401 && !options._retry) {
    const refreshToken = auth.getRefreshToken();
    if (!refreshToken) {
      auth.clearTokens();
      router.replace('/(auth)/login');
      throw new Error('No refresh token available');
    }

    const refreshResponse = await fetch(`${API_BASE_URL}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    if (!refreshResponse.ok) {
      auth.clearTokens();
      router.replace('/(auth)/login');
      throw new Error('Token refresh failed');
    }

    const { access_token, refresh_token } = await refreshResponse.json();
    auth.setTokens(access_token, refresh_token);

    return apiFetch(path, { ...options, _retry: true }, auth);
  }

  return response;
}
