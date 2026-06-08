import { View, Text, StyleSheet } from 'react-native';
import { useNetInfo } from '@react-native-community/netinfo';
import { colors, spacing, fontSize, fontWeight } from '@/theme';

export function OfflineBanner() {
  const { isConnected } = useNetInfo();

  if (isConnected !== false) return null;

  return (
    <View style={styles.banner}>
      <Text style={styles.message}>无网络连接，显示离线数据</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: {
    backgroundColor: colors.danger,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    alignItems: 'center',
  },
  message: {
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: fontWeight.medium,
  },
});
