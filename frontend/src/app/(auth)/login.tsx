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
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';

import { useAuthContext } from '@/context/AuthContext';
import { loginSchema, LoginFormData } from '@/schemas/auth';
import { apiFetch } from '@/services/api';
import { LoginResponse } from '@/types/api';

export default function LoginScreen() {
  const { setTokens } = useAuthContext();
  const [globalError, setGlobalError] = useState<string | null>(null);

  const {
    control,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '' },
  });

  const emailValue = watch('email');

  const onSubmit = async (data: LoginFormData) => {
    setGlobalError(null);
    try {
      const res = await apiFetch('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify(data),
      });

      if (res.status === 200) {
        const body: LoginResponse = await res.json();
        setTokens(body.access_token, body.refresh_token);
        router.replace('/(tabs)');
        return;
      }

      if (res.status === 401) {
        setGlobalError('邮箱或密码不正确，请检查后重试');
        return;
      }

      if (res.status === 429) {
        setGlobalError('登录请求过于频繁，请稍后再试');
        return;
      }

      setGlobalError('登录失败，请稍后重试');
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
        <Text style={styles.title}>登录</Text>

        {globalError ? (
          <View style={styles.errorBanner}>
            <Text style={styles.errorBannerText}>{globalError}</Text>
            <TouchableOpacity
              style={styles.verifyLink}
              onPress={() =>
                router.push({
                  pathname: '/(auth)/verify-email',
                  params: { email: emailValue },
                })
              }
            >
              <Text style={styles.verifyLinkText}>没有收到验证邮件？点击重新发送</Text>
            </TouchableOpacity>
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
                autoComplete="current-password"
                placeholder="请输入密码"
                placeholderTextColor="#aaa"
              />
            )}
          />
          {errors.password ? (
            <Text style={styles.fieldError}>{errors.password.message}</Text>
          ) : null}
        </View>

        <TouchableOpacity
          style={[styles.button, isSubmitting && styles.buttonDisabled]}
          onPress={handleSubmit(onSubmit)}
          disabled={isSubmitting}
          activeOpacity={0.8}
        >
          {isSubmitting ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>登录</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.registerLink}
          onPress={() => router.replace('/(auth)/register')}
        >
          <Text style={styles.registerLinkText}>还没有账号？去注册</Text>
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
  verifyLink: { marginTop: 8 },
  verifyLinkText: { color: '#4A90E2', fontSize: 13, textDecorationLine: 'underline' },
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
  button: {
    backgroundColor: '#4A90E2',
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 24,
  },
  buttonDisabled: { opacity: 0.6 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  registerLink: { alignItems: 'center', marginTop: 20 },
  registerLinkText: { color: '#4A90E2', fontSize: 14 },
});
