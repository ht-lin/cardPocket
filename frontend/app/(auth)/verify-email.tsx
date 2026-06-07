import { View, Text, StyleSheet } from 'react-native';

export default function VerifyEmailScreen() {
  return (
    <View style={styles.container}>
      <Text>Verify Email</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
