import { zodResolver } from '@hookform/resolvers/zod';
import { router } from 'expo-router';
import { useState } from 'react';
import { Controller, useForm } from 'react-hook-form';
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';

import { registerSchema, RegisterFormData } from '@/schemas/auth';
import { apiFetch } from '@/services/api';
import { ApiValidationError } from '@/types/api';

export default function RegisterScreen() {
  const [globalError, setGlobalError] = useState<string | null>(null);

  const {
    control,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      email: '',
      password: '',
      userName: '',
      gdprConsent: undefined,
    },
  });

  const onSubmit = async (data: RegisterFormData) => {
    setGlobalError(null);
    try {
      const res = await apiFetch('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify(data),
      });

      if (res.status === 201) {
        router.replace('/(auth)/verify-email');
        return;
      }

      if (res.status === 422) {
        const body: ApiValidationError = await res.json();
        let hasFieldError = false;
        body.violations?.forEach((v) => {
          const field = v.propertyPath as keyof RegisterFormData;
          if (field in registerSchema.shape) {
            setError(field, { message: v.message });
            hasFieldError = true;
          }
        });
        if (!hasFieldError) {
          setGlobalError('注册失败，请检查输入内容');
        }
        return;
      }

      if (res.status === 429) {
        setGlobalError('请求过于频繁，请稍后再试');
        return;
      }

      setGlobalError('注册失败，请稍后重试');
    } catch {
      setGlobalError('网络错误，请检查连接后重试');
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.flex}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        contentContainerStyle={styles.container}
        keyboardShouldPersistTaps="handled"
      >
        <Text style={styles.title}>创建账号</Text>

        {globalError ? (
          <View style={styles.errorBanner}>
            <Text style={styles.errorBannerText}>{globalError}</Text>
          </View>
        ) : null}

        <View style={styles.field}>
          <Text style={styles.label}>邮箱</Text>
          <Controller
            control={control}
            name="email"
            render={({ field: { onChange, onBlur, value } }) => (
              <TextInput
                style={[styles.input, errors.email && styles.inputError]}
                onBlur={onBlur}
                onChangeText={onChange}
                value={value}
                autoCapitalize="none"
                autoComplete="email"
                keyboardType="email-address"
                placeholder="your@email.com"
                placeholderTextColor="#aaa"
              />
            )}
          />
          {errors.email ? (
            <Text style={styles.fieldError}>{errors.email.message}</Text>
          ) : null}
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>用户名</Text>
          <Controller
            control={control}
            name="userName"
            render={({ field: { onChange, onBlur, value } }) => (
              <TextInput
                style={[styles.input, errors.userName && styles.inputError]}
                onBlur={onBlur}
                onChangeText={onChange}
                value={value}
                autoCapitalize="none"
                autoComplete="username"
                placeholder="2~50 个字符"
                placeholderTextColor="#aaa"
              />
            )}
          />
          {errors.userName ? (
            <Text style={styles.fieldError}>{errors.userName.message}</Text>
          ) : null}
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>密码</Text>
          <Controller
            control={control}
            name="password"
            render={({ field: { onChange, onBlur, value } }) => (
              <TextInput
                style={[styles.input, errors.password && styles.inputError]}
                onBlur={onBlur}
                onChangeText={onChange}
                value={value}
                secureTextEntry
                autoComplete="new-password"
                placeholder="至少 8 个字符"
                placeholderTextColor="#aaa"
              />
            )}
          />
          {errors.password ? (
            <Text style={styles.fieldError}>{errors.password.message}</Text>
          ) : null}
        </View>

        <View style={styles.consentRow}>
          <Controller
            control={control}
            name="gdprConsent"
            render={({ field: { onChange, value } }) => (
              <Switch
                value={value === true}
                onValueChange={(v) => onChange(v || undefined)}
                trackColor={{ true: '#4A90E2' }}
              />
            )}
          />
          <Text style={styles.consentText}>
            我已阅读并同意{' '}
            <Text style={styles.consentLink}>隐私政策与服务条款</Text>
          </Text>
        </View>
        {errors.gdprConsent ? (
          <Text style={[styles.fieldError, styles.consentError]}>
            {errors.gdprConsent.message}
          </Text>
        ) : null}

        <TouchableOpacity
          style={[styles.button, isSubmitting && styles.buttonDisabled]}
          onPress={handleSubmit(onSubmit)}
          disabled={isSubmitting}
          activeOpacity={0.8}
        >
          {isSubmitting ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>注册</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.loginLink}
          onPress={() => router.replace('/(auth)/login')}
        >
          <Text style={styles.loginLinkText}>已有账号？去登录</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1, backgroundColor: '#fff' },
  container: {
    flexGrow: 1,
    padding: 24,
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 32,
    color: '#1a1a1a',
  },
  errorBanner: {
    backgroundColor: '#fdecea',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
  },
  errorBannerText: { color: '#c0392b', fontSize: 14 },
  field: { marginBottom: 16 },
  label: { fontSize: 14, fontWeight: '600', color: '#333', marginBottom: 6 },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 16,
    color: '#1a1a1a',
    backgroundColor: '#fafafa',
  },
  inputError: { borderColor: '#e74c3c' },
  fieldError: { color: '#e74c3c', fontSize: 13, marginTop: 4 },
  consentRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
    gap: 10,
  },
  consentText: { flex: 1, fontSize: 14, color: '#555' },
  consentLink: { color: '#4A90E2', textDecorationLine: 'underline' },
  consentError: { marginBottom: 12 },
  button: {
    backgroundColor: '#4A90E2',
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 24,
  },
  buttonDisabled: { opacity: 0.6 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  loginLink: { alignItems: 'center', marginTop: 20 },
  loginLinkText: { color: '#4A90E2', fontSize: 14 },
});
