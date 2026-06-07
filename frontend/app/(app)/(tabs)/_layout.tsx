import { Tabs } from 'expo-router';

export default function TabLayout() {
  return (
    <Tabs screenOptions={{ headerShown: false }}>
      <Tabs.Screen name="index" options={{ title: '我的卡片' }} />
      <Tabs.Screen name="shared" options={{ title: '共享卡片' }} />
      <Tabs.Screen name="friends" options={{ title: '好友' }} />
      <Tabs.Screen name="settings" options={{ title: '设置' }} />
    </Tabs>
  );
}
