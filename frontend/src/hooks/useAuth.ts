import { useAuthContext } from '@/context/AuthContext';

type User = { email: string };

function decodeJwtPayload(token: string): User | null {
  try {
    const payload = token.split('.')[1];
    const decoded = JSON.parse(atob(payload)) as Record<string, unknown>;
    const email = (decoded['email'] ?? decoded['sub']) as string | undefined;
    return email ? { email } : null;
  } catch {
    return null;
  }
}

export function useAuth() {
  const auth = useAuthContext();
  return {
    isAuthenticated: auth.isAuthenticated,
    isLoading: auth.isLoading,
    user: auth.isAuthenticated ? decodeJwtPayload(auth.getAccessToken()!) : null,
    login: auth.setTokens,
    logout: auth.clearTokens,
  };
}
