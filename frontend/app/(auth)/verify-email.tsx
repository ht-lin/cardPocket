import { SafeAreaView, View, Text, Pressable, StyleSheet, ActivityIndicator } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { useMutation } from '@tanstack/react-query';
import { resendVerification } from '@/lib/api/endpoints/auth';
import { colors, spacing, radius, fontSize, fontWeight } from '@/theme';

export default function VerifyEmailScreen() {
  const { email } = useLocalSearchParams<{ email: string }>();

  const { mutate, isPending, isSuccess } = useMutation({
    mutationFn: () => resendVerification(email ?? ''),
  });

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.inner}>
        <Text style={styles.icon}>✉️</Text>
        <Text style={styles.title}>验证您的邮箱</Text>
        <Text style={styles.body}>
          我们已向{'\n'}
          <Text style={styles.email}>{email}</Text>
          {'\n'}发送了验证链接，请检查收件箱。
        </Text>

        {isSuccess ? (
          <View style={styles.successRow}>
            <Text style={styles.successText}>验证邮件已重新发送</Text>
          </View>
        ) : (
          <Pressable
            style={[styles.button, isPending && styles.buttonDisabled]}
            onPress={() => mutate()}
            disabled={isPending}
          >
            {isPending
              ? <ActivityIndicator color={colors.primary} />
              : <Text style={styles.buttonText}>重新发送验证邮件</Text>
            }
          </Pressable>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  inner: {
    flex: 1,
    padding: spacing.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  icon: {
    fontSize: 56,
    marginBottom: spacing.lg,
  },
  title: {
    fontSize: fontSize.xl,
    fontWeight: fontWeight.bold,
    color: colors.text,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  body: {
    fontSize: fontSize.md,
    color: colors.textMuted,
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: spacing.xl,
  },
  email: {
    fontWeight: fontWeight.semibold,
    color: colors.text,
  },
  button: {
    borderWidth: 1.5,
    borderColor: colors.primary,
    borderRadius: radius.md,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    alignItems: 'center',
    minWidth: 200,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: colors.primary,
    fontSize: fontSize.md,
    fontWeight: fontWeight.semibold,
  },
  successRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  successText: {
    fontSize: fontSize.md,
    color: colors.success,
    fontWeight: fontWeight.medium,
  },
});
