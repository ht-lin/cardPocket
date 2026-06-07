import { create } from 'zustand';

export type UserProfile = {
  id: string;
  email: string;
  userName: string;
  emailVerifiedAt: string | null;
};

type AuthState = {
  user: UserProfile | null;
  accessToken: string | null;
  setUser: (user: UserProfile) => void;
  setAccessToken: (token: string | null) => void;
  clear: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  accessToken: null,
  setUser: (user) => set({ user }),
  setAccessToken: (token) => set({ accessToken: token }),
  clear: () => set({ user: null, accessToken: null }),
}));
