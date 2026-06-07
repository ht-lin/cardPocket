import { SafeAreaView, View, Text, TextInput, Pressable, StyleSheet, ActivityIndicator } from 'react-native';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useRouter } from 'expo-router';
import { isAxiosError } from 'axios';
import { LoginInputSchema, type LoginInput } from '@/schemas/auth';
import { useLogin } from '@/hooks/useLogin';
import { colors, spacing, radius, fontSize, fontWeight } from '@/theme';

export default function LoginScreen() {
  const router = useRouter();
  const { mutate, isPending, error } = useLogin();

  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginInput>({
    resolver: zodResolver(LoginInputSchema),
  });

  const apiErrorMessage =
    isAxiosError(error) ? (error.response?.data?.message ?? '登录失败，请重试') : null;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.inner}>
        <Text style={styles.title}>登录</Text>

        <View style={styles.field}>
          <Text style={styles.label}>邮箱</Text>
          <Controller
            name="email"
            control={control}
            render={({ field: { value, onChange, onBlur } }) => (
              <TextInput
                style={[styles.input, errors.email && styles.inputError]}
                value={value}
                onChangeText={onChange}
                onBlur={onBlur}
                placeholder="your@email.com"
                keyboardType="email-address"
                autoCapitalize="none"
                autoCorrect={false}
              />
            )}
          />
          {errors.email && <Text style={styles.fieldError}>{errors.email.message}</Text>}
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>密码</Text>
          <Controller
            name="password"
            control={control}
            render={({ field: { value, onChange, onBlur } }) => (
              <TextInput
                style={[styles.input, errors.password && styles.inputError]}
                value={value}
                onChangeText={onChange}
                onBlur={onBlur}
                placeholder="至少 8 位"
                secureTextEntry
              />
            )}
          />
          {errors.password && <Text style={styles.fieldError}>{errors.password.message}</Text>}
        </View>

        {apiErrorMessage && <Text style={styles.apiError}>{apiErrorMessage}</Text>}

        <Pressable
          style={[styles.button, isPending && styles.buttonDisabled]}
          onPress={handleSubmit((data) => mutate(data))}
          disabled={isPending}
        >
          {isPending
            ? <ActivityIndicator color={colors.surface} />
            : <Text style={styles.buttonText}>登录</Text>
          }
        </Pressable>

        <Pressable onPress={() => router.push('/register')} style={styles.link}>
          <Text style={styles.linkText}>没有账号？注册</Text>
        </Pressable>
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
  },
  title: {
    fontSize: fontSize.xxl,
    fontWeight: fontWeight.bold,
    color: colors.text,
    marginBottom: spacing.xl,
    textAlign: 'center',
  },
  field: {
    marginBottom: spacing.md,
  },
  label: {
    fontSize: fontSize.sm,
    fontWeight: fontWeight.medium,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    padding: spacing.md,
    fontSize: fontSize.md,
    color: colors.text,
    backgroundColor: colors.surface,
  },
  inputError: {
    borderColor: colors.danger,
  },
  fieldError: {
    fontSize: fontSize.xs,
    color: colors.danger,
    marginTop: spacing.xs,
  },
  apiError: {
    fontSize: fontSize.sm,
    color: colors.danger,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  button: {
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: 'center',
    marginTop: spacing.sm,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: colors.surface,
    fontSize: fontSize.md,
    fontWeight: fontWeight.semibold,
  },
  link: {
    marginTop: spacing.lg,
    alignItems: 'center',
  },
  linkText: {
    fontSize: fontSize.sm,
    color: colors.primary,
  },
});
