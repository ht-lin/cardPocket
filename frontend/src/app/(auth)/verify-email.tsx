import { StyleSheet, Text, View } from 'react-native';

export default function VerifyEmailScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.emoji}>📧</Text>
      <Text style={styles.title}>验证你的邮箱</Text>
      <Text style={styles.body}>请去邮箱点击验证链接，完成注册。</Text>
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
  body: { fontSize: 16, color: '#555', textAlign: 'center', lineHeight: 24 },
});
