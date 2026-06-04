import { Redirect, Tabs } from 'expo-router';
import { useAuth } from '@/context/AuthContext';

export default function TabLayout() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) return null;
  if (!isAuthenticated) return <Redirect href="/(auth)/login" />;

  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: '我的卡片' }} />
      <Tabs.Screen name="shared" options={{ title: '共享给我' }} />
      <Tabs.Screen name="friends" options={{ title: '好友' }} />
    </Tabs>
  );
}
