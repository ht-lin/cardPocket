import { View, Text, StyleSheet } from 'react-native';

export default function CardsScreen() {
  return (
    <View style={styles.container}>
      <Text>我的卡片</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
