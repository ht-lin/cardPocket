import { createContext, useContext, useState, type ReactNode } from 'react';

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

  return (
    <AuthContext.Provider
      value={{
        isAuthenticated: accessToken !== null,
        isLoading: false,
        getAccessToken: () => accessToken,
        getRefreshToken: () => refreshToken,
        setTokens: (access, refresh) => {
          setAccessToken(access);
          setRefreshToken(refresh);
        },
        clearTokens: () => {
          setAccessToken(null);
          setRefreshToken(null);
        },
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
