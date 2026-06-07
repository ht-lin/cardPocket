import { useEffect } from 'react';
import { useAuthStore } from '@/store/authStore';
import { secureStore } from '@/lib/storage/secureStore';
import { rawRefresh } from '@/lib/api/rawRefresh';
import { getMe } from '@/lib/api/endpoints/users';

export function useSessionRestore() {
  const { setAccessToken, setUser, setRestoringDone, clear } = useAuthStore();

  useEffect(() => {
    let cancelled = false;

    async function restore() {
      try {
        const data = await rawRefresh();
        if (cancelled) return;
        setAccessToken(data.access_token);
        await secureStore.setRefreshToken(data.refresh_token);
        const me = await getMe();
        if (cancelled) return;
        setUser(me);
      } catch {
        if (!cancelled) {
          clear();
          await secureStore.deleteRefreshToken();
        }
      } finally {
        if (!cancelled) setRestoringDone();
      }
    }

    restore();
    return () => {
      cancelled = true;
    };
  }, []);
}
