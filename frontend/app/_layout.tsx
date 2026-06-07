import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { QueryProvider } from '@/lib/query/QueryProvider';
import { initDb } from '@/lib/storage/db';
import { useSessionRestore } from '@/hooks/useSessionRestore';

function SessionRestoreGate({ children }: { children: React.ReactNode }) {
  useSessionRestore();
  return <>{children}</>;
}

export default function RootLayout() {
  useEffect(() => {
    initDb().catch(console.error);
  }, []);

  return (
    <QueryProvider>
      <SessionRestoreGate>
        <Stack screenOptions={{ headerShown: false }} />
      </SessionRestoreGate>
    </QueryProvider>
  );
}
