import { View } from 'react-native';
import { Stack, Redirect } from 'expo-router';
import { useAuthStore } from '@/store/authStore';
import { EmailVerificationBanner } from '@/components/auth/EmailVerificationBanner';
import { OfflineBanner } from '@/components/shared/OfflineBanner';

export default function AppLayout() {
  const { accessToken, isRestoring } = useAuthStore((s) => ({
    accessToken: s.accessToken,
    isRestoring: s.isRestoring,
  }));

  if (isRestoring) return null;
  if (!accessToken) return <Redirect href="/login" />;

  return (
    <View style={{ flex: 1 }}>
      <EmailVerificationBanner />
      <OfflineBanner />
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="cards/[id]" options={{ title: '卡片详情' }} />
        <Stack.Screen name="cards/add" options={{ title: '添加卡片' }} />
        <Stack.Screen name="cards/scan" options={{ title: '扫码添加' }} />
      </Stack>
    </View>
  );
}
