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
  isRestoring: boolean;
  setUser: (user: UserProfile) => void;
  setAccessToken: (token: string | null) => void;
  setRestoringDone: () => void;
  clear: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  accessToken: null,
  isRestoring: true,
  setUser: (user) => set({ user }),
  setAccessToken: (token) => set({ accessToken: token }),
  setRestoringDone: () => set({ isRestoring: false }),
  clear: () => set({ user: null, accessToken: null }),
}));
