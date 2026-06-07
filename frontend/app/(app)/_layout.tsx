import { Redirect, Slot } from 'expo-router';
import { View } from 'react-native';
import { useAuthStore } from '@/store/authStore';
import { EmailVerificationBanner } from '@/components/auth/EmailVerificationBanner';

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
      <Slot />
    </View>
  );
}
