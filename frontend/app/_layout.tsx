import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { QueryProvider } from '@/lib/query/QueryProvider';
import { initDb } from '@/lib/storage/db';

export default function RootLayout() {
  useEffect(() => {
    initDb().catch(console.error);
  }, []);

  return (
    <QueryProvider>
      <Stack screenOptions={{ headerShown: false }} />
    </QueryProvider>
  );
}
