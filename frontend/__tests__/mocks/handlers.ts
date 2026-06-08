import { http, HttpResponse } from 'msw';
import type { UserOutput, UserSearchOutput } from '@/schemas/auth';
import type { FriendshipOutput } from '@/schemas/friend';

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

export const FRIEND_USER: UserSearchOutput = {
  id: 'friend-1',
  userName: 'friend_user',
};

export const FRIENDSHIP_ACCEPTED: FriendshipOutput = {
  id: 'fs-1',
  requesterId: 'user-1',
  addresseeId: 'friend-1',
  requesterUserName: 'testuser',
  addresseeUserName: 'friend_user',
  status: 'ACCEPTED',
  createdAt: '2026-06-01T10:00:00Z',
  updatedAt: '2026-06-01T10:00:00Z',
};

export const FRIENDSHIP_PENDING: FriendshipOutput = {
  id: 'fs-2',
  requesterId: 'requester-1',
  addresseeId: 'user-1',
  requesterUserName: 'requester_user',
  addresseeUserName: 'testuser',
  status: 'PENDING',
  createdAt: '2026-06-01T10:00:00Z',
  updatedAt: '2026-06-01T10:00:00Z',
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

  http.get(`${BASE}/api/users/search`, ({ request }) => {
    const q = new URL(request.url).searchParams.get('q') ?? '';
    if (q === FRIEND_USER.userName || q === 'friend@example.com') {
      return HttpResponse.json([FRIEND_USER]);
    }
    return HttpResponse.json([]);
  }),

  http.get(`${BASE}/api/friendships`, () => {
    return HttpResponse.json([FRIENDSHIP_ACCEPTED]);
  }),

  http.get(`${BASE}/api/friendships/requests`, () => {
    return HttpResponse.json([FRIENDSHIP_PENDING]);
  }),

  http.post(`${BASE}/api/friendships`, async ({ request }) => {
    const body = (await request.json()) as Record<string, string>;
    const newFriendship: FriendshipOutput = {
      id: 'fs-new',
      requesterId: USER.id,
      addresseeId: body.addresseeId ?? 'unknown',
      requesterUserName: USER.userName,
      addresseeUserName: FRIEND_USER.userName,
      status: 'PENDING',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    return HttpResponse.json(newFriendship, { status: 201 });
  }),

  http.patch(`${BASE}/api/friendships/:id/accept`, ({ params }) => {
    const accepted: FriendshipOutput = {
      ...FRIENDSHIP_PENDING,
      id: params.id as string,
      status: 'ACCEPTED',
    };
    return HttpResponse.json(accepted);
  }),

  http.delete(`${BASE}/api/friendships/:id`, () => {
    return new HttpResponse(null, { status: 204 });
  }),
];
