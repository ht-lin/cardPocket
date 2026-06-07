import { client } from '@/lib/api/client';
import type {
  LoginInput,
  RegisterInput,
  AuthResponse,
  RefreshResponse,
  UserOutput,
} from '@/schemas/auth';

export const login = (data: LoginInput): Promise<AuthResponse> =>
  client.post<AuthResponse>('/api/auth/login', data).then((r) => r.data);

export const register = (data: RegisterInput): Promise<UserOutput> =>
  client.post<UserOutput>('/api/auth/register', data).then((r) => r.data);

export const verifyEmail = (token: string): Promise<{ message: string }> =>
  client
    .post<{ message: string }>('/api/auth/verify-email', { token })
    .then((r) => r.data);

export const resendVerification = (email: string): Promise<{ message: string }> =>
  client
    .post<{ message: string }>('/api/auth/resend-verification', { email })
    .then((r) => r.data);

export const refresh = (refreshToken: string): Promise<RefreshResponse> =>
  client
    .post<RefreshResponse>('/api/auth/refresh', { refresh_token: refreshToken })
    .then((r) => r.data);

export const logout = (refreshToken: string): Promise<void> =>
  client
    .post('/api/auth/logout', { refresh_token: refreshToken })
    .then(() => undefined);
