import { View, Text, StyleSheet } from 'react-native';

export default function SharedScreen() {
  return (
    <View style={styles.container}>
      <Text>共享卡片</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
