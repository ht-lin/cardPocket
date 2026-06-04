import { useLocalSearchParams, router } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { apiFetch } from '@/services/api';
import { ResendVerificationRequest } from '@/types/api';

export default function VerifyEmailScreen() {
  const { email } = useLocalSearchParams<{ email?: string }>();

  const [isSending, setIsSending] = useState(false);
  const [statusMessage, setStatusMessage] = useState<{ text: string; isError: boolean } | null>(
    null,
  );
  const clearTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (clearTimerRef.current) clearTimeout(clearTimerRef.current);
    };
  }, []);

  const handleResend = async () => {
    if (!email || isSending) return;
    setIsSending(true);
    setStatusMessage(null);

    try {
      const body: ResendVerificationRequest = { email };
      const res = await apiFetch('/api/auth/resend-verification', {
        method: 'POST',
        body: JSON.stringify(body),
      });

      if (res.status === 429) {
        setStatusMessage({ text: '发送过于频繁，请稍后再试', isError: true });
      } else {
        setStatusMessage({ text: '验证邮件已重新发送', isError: false });
      }
    } catch {
      setStatusMessage({ text: '网络错误，请检查连接后重试', isError: true });
    } finally {
      setIsSending(false);
      clearTimerRef.current = setTimeout(() => setStatusMessage(null), 5000);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.emoji}>📧</Text>
      <Text style={styles.title}>验证你的邮箱</Text>

      {email ? (
        <Text style={styles.subtitle}>
          验证邮件已发送至{'\n'}
          <Text style={styles.emailText}>{email}</Text>
        </Text>
      ) : (
        <Text style={styles.subtitle}>验证邮件已发送至你的注册邮箱</Text>
      )}

      <Text style={styles.body}>
        请点击邮件中的验证链接完成注册。{'\n'}验证链接 24 小时内有效。
      </Text>

      {statusMessage ? (
        <Text style={[styles.statusText, statusMessage.isError && styles.statusError]}>
          {statusMessage.text}
        </Text>
      ) : null}

      {email ? (
        <TouchableOpacity
          style={[styles.resendButton, isSending && styles.resendButtonDisabled]}
          onPress={handleResend}
          disabled={isSending}
          activeOpacity={0.7}
        >
          {isSending ? (
            <ActivityIndicator color="#4A90E2" size="small" />
          ) : (
            <Text style={styles.resendButtonText}>重新发送验证邮件</Text>
          )}
        </TouchableOpacity>
      ) : null}

      <TouchableOpacity style={styles.loginLink} onPress={() => router.replace('/(auth)/login')}>
        <Text style={styles.loginLinkText}>已验证？去登录</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
    backgroundColor: '#fff',
  },
  emoji: { fontSize: 48, marginBottom: 16 },
  title: {
    fontSize: 22,
    fontWeight: '700',
    color: '#1a1a1a',
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 15,
    color: '#555',
    textAlign: 'center',
    marginBottom: 12,
    lineHeight: 22,
  },
  emailText: { fontWeight: '600', color: '#1a1a1a' },
  body: {
    fontSize: 14,
    color: '#888',
    textAlign: 'center',
    lineHeight: 22,
    marginBottom: 24,
  },
  statusText: {
    fontSize: 14,
    color: '#27ae60',
    textAlign: 'center',
    marginBottom: 12,
  },
  statusError: { color: '#e74c3c' },
  resendButton: {
    borderWidth: 1.5,
    borderColor: '#4A90E2',
    borderRadius: 10,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: 'center',
    minWidth: 200,
    marginBottom: 16,
  },
  resendButtonDisabled: { opacity: 0.5 },
  resendButtonText: { color: '#4A90E2', fontSize: 15, fontWeight: '600' },
  loginLink: { marginTop: 8 },
  loginLinkText: { color: '#888', fontSize: 14, textDecorationLine: 'underline' },
});
