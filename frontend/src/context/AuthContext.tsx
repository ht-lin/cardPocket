import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { API_BASE_URL } from '@/constants/env';
import {
  getRefreshToken,
  setRefreshToken as persistRefreshToken,
  deleteRefreshToken,
} from '@/storage/secureStore';

type AuthContextValue = {
  isAuthenticated: boolean;
  isLoading: boolean;
  getAccessToken(): string | null;
  getRefreshToken(): string | null;
  setTokens(accessToken: string, refreshToken: string): void;
  clearTokens(): void;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function bootstrap() {
      const stored = await getRefreshToken();
      if (!stored) return;

      const response = await fetch(`${API_BASE_URL}/api/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: stored }),
      });

      if (response.ok) {
        const { access_token, refresh_token } = await response.json();
        setAccessToken(access_token);
        setRefreshToken(refresh_token);
        await persistRefreshToken(refresh_token);
      } else {
        await deleteRefreshToken();
      }
    }

    bootstrap()
      .catch(console.error)
      .finally(() => setIsLoading(false));
  }, []);

  return (
    <AuthContext.Provider
      value={{
        isAuthenticated: accessToken !== null,
        isLoading,
        getAccessToken: () => accessToken,
        getRefreshToken: () => refreshToken,
        setTokens: (access, refresh) => {
          setAccessToken(access);
          setRefreshToken(refresh);
          persistRefreshToken(refresh).catch(console.error);
        },
        clearTokens: () => {
          setAccessToken(null);
          setRefreshToken(null);
          deleteRefreshToken().catch(console.error);
        },
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuthContext(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuthContext must be used within AuthProvider');
  return ctx;
}
