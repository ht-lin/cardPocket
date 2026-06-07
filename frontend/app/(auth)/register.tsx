import {
  SafeAreaView,
  View,
  Text,
  TextInput,
  Pressable,
  StyleSheet,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useRouter } from 'expo-router';
import { isAxiosError } from 'axios';
import { RegisterInputSchema, type RegisterInput } from '@/schemas/auth';
import { useRegister } from '@/hooks/useRegister';
import { colors, spacing, radius, fontSize, fontWeight } from '@/theme';

export default function RegisterScreen() {
  const router = useRouter();
  const { mutate, isPending, error } = useRegister();

  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterInput>({
    resolver: zodResolver(RegisterInputSchema),
    defaultValues: { gdprConsent: false as unknown as true },
  });

  const apiErrorMessage =
    isAxiosError(error) ? (error.response?.data?.message ?? '注册失败，请重试') : null;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.inner} keyboardShouldPersistTaps="handled">
        <Text style={styles.title}>注册</Text>

        <View style={styles.field}>
          <Text style={styles.label}>用户名</Text>
          <Controller
            name="userName"
            control={control}
            render={({ field: { value, onChange, onBlur } }) => (
              <TextInput
                style={[styles.input, errors.userName && styles.inputError]}
                value={value}
                onChangeText={onChange}
                onBlur={onBlur}
                placeholder="3-50 个字符"
                autoCapitalize="none"
                autoCorrect={false}
              />
            )}
          />
          {errors.userName && <Text style={styles.fieldError}>{errors.userName.message}</Text>}
        </View>

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

        <View style={styles.field}>
          <Controller
            name="gdprConsent"
            control={control}
            render={({ field: { value, onChange } }) => (
              <Pressable
                style={styles.checkRow}
                onPress={() => onChange(!value)}
                accessibilityRole="checkbox"
                accessibilityState={{ checked: !!value }}
              >
                <View style={[styles.checkbox, value && styles.checkboxChecked]}>
                  {value && <Text style={styles.checkmark}>✓</Text>}
                </View>
                <Text style={styles.checkLabel}>我已阅读并同意隐私政策和服务条款</Text>
              </Pressable>
            )}
          />
          {errors.gdprConsent && (
            <Text style={styles.fieldError}>必须同意条款才能注册</Text>
          )}
        </View>

        {apiErrorMessage && <Text style={styles.apiError}>{apiErrorMessage}</Text>}

        <Pressable
          style={[styles.button, isPending && styles.buttonDisabled]}
          onPress={handleSubmit((data) => mutate(data))}
          disabled={isPending}
        >
          {isPending
            ? <ActivityIndicator color={colors.surface} />
            : <Text style={styles.buttonText}>注册</Text>
          }
        </Pressable>

        <Pressable onPress={() => router.push('/login')} style={styles.link}>
          <Text style={styles.linkText}>已有账号？登录</Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  inner: {
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  title: {
    fontSize: fontSize.xxl,
    fontWeight: fontWeight.bold,
    color: colors.text,
    marginBottom: spacing.xl,
    textAlign: 'center',
    marginTop: spacing.xl,
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
  checkRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: spacing.sm,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderWidth: 2,
    borderColor: colors.border,
    borderRadius: radius.sm,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 2,
  },
  checkboxChecked: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  checkmark: {
    color: colors.surface,
    fontSize: 12,
    fontWeight: fontWeight.bold,
  },
  checkLabel: {
    flex: 1,
    fontSize: fontSize.sm,
    color: colors.text,
    lineHeight: 20,
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
