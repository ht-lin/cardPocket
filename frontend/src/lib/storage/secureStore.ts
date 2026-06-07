import * as SecureStore from 'expo-secure-store';

const KEYS = {
  REFRESH_TOKEN: 'rt',
  LAST_SYNC: 'lastSync',
} as const;

export const secureStore = {
  getRefreshToken: (): Promise<string | null> =>
    SecureStore.getItemAsync(KEYS.REFRESH_TOKEN),

  setRefreshToken: (token: string): Promise<void> =>
    SecureStore.setItemAsync(KEYS.REFRESH_TOKEN, token),

  deleteRefreshToken: (): Promise<void> =>
    SecureStore.deleteItemAsync(KEYS.REFRESH_TOKEN),

  getLastSync: (): Promise<string | null> =>
    SecureStore.getItemAsync(KEYS.LAST_SYNC),

  setLastSync: (ts: string): Promise<void> =>
    SecureStore.setItemAsync(KEYS.LAST_SYNC, ts),
};
