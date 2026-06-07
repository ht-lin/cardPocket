import { http, HttpResponse } from 'msw';
import type { UserOutput } from '@/schemas/auth';

const BASE = 'http://localhost:8000';

export const VALID_LOGIN = { email: 'test@example.com', password: 'Password123' };
export const TOKENS = {
  access_token: 'access-token-123',
  refresh_token: 'refresh-token-abc',
  token_type: 'Bearer',
  expires_in: 900,
};
export const REFRESHED_TOKENS = {
  access_token: 'new-access-token',
  refresh_token: 'new-refresh-token',
  expires_in: 900,
};
export const USER: UserOutput = {
  id: 'user-1',
  email: 'test@example.com',
  userName: 'testuser',
  emailVerifiedAt: null,
};

export const handlers = [
  http.post(`${BASE}/api/auth/login`, async ({ request }) => {
    const body = (await request.json()) as Record<string, string>;
    if (body.email === VALID_LOGIN.email && body.password === VALID_LOGIN.password) {
      return HttpResponse.json(TOKENS, { status: 200 });
    }
    return HttpResponse.json({ message: 'Invalid credentials' }, { status: 401 });
  }),

  http.post(`${BASE}/api/auth/register`, async () => {
    return HttpResponse.json(USER, { status: 201 });
  }),

  http.post(`${BASE}/api/auth/refresh`, async ({ request }) => {
    const body = (await request.json()) as Record<string, string>;
    if (body.refresh_token === TOKENS.refresh_token) {
      return HttpResponse.json(REFRESHED_TOKENS, { status: 200 });
    }
    return HttpResponse.json({ message: 'Invalid refresh token' }, { status: 401 });
  }),

  http.post(`${BASE}/api/auth/logout`, () => {
    return new HttpResponse(null, { status: 204 });
  }),

  http.post(`${BASE}/api/auth/resend-verification`, () => {
    return HttpResponse.json({ message: 'Verification email sent' }, { status: 200 });
  }),

  http.get(`${BASE}/api/users/me`, ({ request }) => {
    const auth = request.headers.get('Authorization');
    if (auth === `Bearer ${TOKENS.access_token}` || auth === `Bearer ${REFRESHED_TOKENS.access_token}`) {
      return HttpResponse.json(USER, { status: 200 });
    }
    return HttpResponse.json({ message: 'Unauthorized' }, { status: 401 });
  }),
];
