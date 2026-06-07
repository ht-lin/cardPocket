import { Redirect, Slot } from 'expo-router';
import { useAuthStore } from '@/store/authStore';

export default function AppLayout() {
  const accessToken = useAuthStore((s) => s.accessToken);
  if (!accessToken) {
    return <Redirect href="/login" />;
  }
  return <Slot />;
}
