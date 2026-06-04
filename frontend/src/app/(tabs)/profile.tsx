import { View, Text, TouchableOpacity, ActivityIndicator, StyleSheet } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { useAuthContext } from '@/context/AuthContext';
import { getMe } from '@/services/userService';

export default function ProfileScreen() {
  const auth = useAuthContext();
  const { data: user, isLoading, isError } = useQuery({
    queryKey: ['users', 'me'],
    queryFn: () => getMe(auth),
  });

  return (
    <View style={styles.container}>
      <View style={styles.info}>
        {isLoading && <ActivityIndicator size="large" />}
        {isError && <Text style={styles.error}>加载失败，请重试</Text>}
        {user && (
          <>
            <Text style={styles.userName}>{user.userName}</Text>
            <Text style={styles.email}>{user.email}</Text>
          </>
        )}
      </View>

      <View style={styles.actions}>
        <TouchableOpacity style={styles.button}>
          <Text style={styles.buttonText}>修改用户名</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button}>
          <Text style={styles.buttonText}>修改密码</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.button, styles.dangerButton]}>
          <Text style={[styles.buttonText, styles.dangerText]}>注销账户</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  info: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  email: {
    fontSize: 14,
    color: '#666',
  },
  error: {
    color: '#dc2626',
  },
  actions: {
    gap: 12,
  },
  button: {
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#d1d5db',
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 16,
    color: '#111827',
  },
  dangerButton: {
    borderColor: '#dc2626',
  },
  dangerText: {
    color: '#dc2626',
  },
});
