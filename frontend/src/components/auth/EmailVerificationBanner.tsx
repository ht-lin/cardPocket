import { View, Text, Pressable, StyleSheet, ActivityIndicator } from 'react-native';
import { useMutation } from '@tanstack/react-query';
import { useAuthStore } from '@/store/authStore';
import { resendVerification } from '@/lib/api/endpoints/auth';
import { colors, spacing, fontSize, fontWeight } from '@/theme';

export function EmailVerificationBanner() {
  const user = useAuthStore((s) => s.user);

  const { mutate, isPending, isSuccess } = useMutation({
    mutationFn: () => resendVerification(user!.email),
  });

  if (!user || user.emailVerifiedAt !== null) return null;

  return (
    <View style={styles.banner}>
      <Text style={styles.message}>请验证您的邮箱地址</Text>
      {isSuccess ? (
        <Text style={styles.sent}>邮件已发送</Text>
      ) : (
        <Pressable onPress={() => mutate()} disabled={isPending} style={styles.button}>
          {isPending
            ? <ActivityIndicator color={colors.surface} size="small" />
            : <Text style={styles.buttonText}>重新发送</Text>
          }
        </Pressable>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  banner: {
    backgroundColor: colors.warning,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
  },
  message: {
    flex: 1,
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: fontWeight.medium,
  },
  button: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
  },
  buttonText: {
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: fontWeight.semibold,
    textDecorationLine: 'underline',
  },
  sent: {
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: fontWeight.medium,
  },
});
