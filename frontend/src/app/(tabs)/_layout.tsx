import { Redirect, Tabs } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';

export default function TabLayout() {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) return null;
  if (!isAuthenticated) return <Redirect href="/(auth)/login" />;
  if (user && !user.emailVerified) return <Redirect href="/(auth)/unverified-email" />;

  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: '我的卡片' }} />
      <Tabs.Screen name="shared" options={{ title: '共享给我' }} />
      <Tabs.Screen name="friends" options={{ title: '好友' }} />
      <Tabs.Screen name="profile" options={{ title: '我的' }} />
    </Tabs>
  );
}
