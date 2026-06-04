import { router } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { useAuthContext } from '@/context/AuthContext';
import { useAuth } from '@/hooks/useAuth';
import { apiFetch } from '@/services/api';
import { ResendVerificationRequest } from '@/types/api';

function decodeEmailVerified(token: string): boolean {
  try {
    const payload = token.split('.')[1];
    const decoded = JSON.parse(atob(payload)) as Record<string, unknown>;
    return decoded['email_verified'] === true;
  } catch {
    return false;
  }
}

export default function UnverifiedEmailScreen() {
  const { user } = useAuth();
  const { getRefreshToken, setTokens, clearTokens } = useAuthContext();

  const [isSending, setIsSending] = useState(false);
  const [isChecking, setIsChecking] = useState(false);
  const [statusMessage, setStatusMessage] = useState<{ text: string; isError: boolean } | null>(
    null,
  );
  const clearTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (clearTimerRef.current) clearTimeout(clearTimerRef.current);
    };
  }, []);

  const showStatus = (text: string, isError: boolean) => {
    setStatusMessage({ text, isError });
    clearTimerRef.current = setTimeout(() => setStatusMessage(null), 5000);
  };

  const handleResend = async () => {
    const email = user?.email;
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
        showStatus('发送过于频繁，请稍后再试', true);
      } else {
        showStatus('验证邮件已重新发送，请查收收件箱', false);
      }
    } catch {
      showStatus('网络错误，请检查连接后重试', true);
    } finally {
      setIsSending(false);
    }
  };

  const handleCheckVerified = async () => {
    const storedRefreshToken = getRefreshToken();
    if (!storedRefreshToken || isChecking) return;
    setIsChecking(true);
    setStatusMessage(null);

    try {
      const res = await apiFetch('/api/auth/refresh', {
        method: 'POST',
        body: JSON.stringify({ refresh_token: storedRefreshToken }),
      });

      if (!res.ok) {
        showStatus('验证状态检查失败，请重新登录', true);
        return;
      }

      const { access_token, refresh_token } = await res.json();

      if (decodeEmailVerified(access_token)) {
        setTokens(access_token, refresh_token);
        router.replace('/(tabs)');
      } else {
        setTokens(access_token, refresh_token);
        showStatus('邮箱尚未验证，请先点击邮件中的验证链接', true);
      }
    } catch {
      showStatus('网络错误，请检查连接后重试', true);
    } finally {
      setIsChecking(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.emoji}>✉️</Text>
      <Text style={styles.title}>邮箱尚未验证</Text>

      {user?.email ? (
        <Text style={styles.subtitle}>
          请验证以下邮箱后继续使用{'\n'}
          <Text style={styles.emailText}>{user.email}</Text>
        </Text>
      ) : (
        <Text style={styles.subtitle}>请验证你的注册邮箱后继续使用</Text>
      )}

      <Text style={styles.body}>
        验证邮件已发送至你的注册邮箱。{'\n'}
        请点击邮件中的验证链接完成验证。
      </Text>

      {statusMessage ? (
        <Text style={[styles.statusText, statusMessage.isError && styles.statusError]}>
          {statusMessage.text}
        </Text>
      ) : null}

      <TouchableOpacity
        style={[styles.primaryButton, isChecking && styles.buttonDisabled]}
        onPress={handleCheckVerified}
        disabled={isChecking}
        activeOpacity={0.8}
      >
        {isChecking ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.primaryButtonText}>已验证，进入应用</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.secondaryButton, isSending && styles.buttonDisabled]}
        onPress={handleResend}
        disabled={isSending || !user?.email}
        activeOpacity={0.7}
      >
        {isSending ? (
          <ActivityIndicator color="#4A90E2" size="small" />
        ) : (
          <Text style={styles.secondaryButtonText}>重发验证邮件</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity style={styles.logoutLink} onPress={clearTokens} activeOpacity={0.7}>
        <Text style={styles.logoutLinkText}>退出登录</Text>
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
    marginBottom: 16,
    paddingHorizontal: 8,
  },
  statusError: { color: '#e74c3c' },
  primaryButton: {
    backgroundColor: '#4A90E2',
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: 'center',
    width: '100%',
    marginBottom: 12,
  },
  primaryButtonText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  secondaryButton: {
    borderWidth: 1.5,
    borderColor: '#4A90E2',
    borderRadius: 10,
    paddingVertical: 12,
    alignItems: 'center',
    width: '100%',
    marginBottom: 24,
  },
  secondaryButtonText: { color: '#4A90E2', fontSize: 15, fontWeight: '600' },
  buttonDisabled: { opacity: 0.5 },
  logoutLink: { marginTop: 8 },
  logoutLinkText: { color: '#888', fontSize: 14, textDecorationLine: 'underline' },
});
