import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
  RefreshControl,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useCards } from '@/hooks/useCards';
import { CardListItem } from '@/components/cards/CardListItem';
import { colors, spacing, fontSize, radius } from '@/theme';

export default function CardsScreen() {
  const router = useRouter();
  const { cards, isLoading, isSyncing, refresh } = useCards();

  if (isLoading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={colors.primary} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={cards}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <CardListItem card={item} />}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl
            refreshing={isSyncing}
            onRefresh={refresh}
            tintColor={colors.primary}
          />
        }
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text style={styles.emptyTitle}>还没有卡片</Text>
            <Text style={styles.emptySubtitle}>点击右下角按钮添加第一张卡片</Text>
          </View>
        }
        ListHeaderComponent={
          <Text style={styles.header}>我的卡片</Text>
        }
      />
      <View style={styles.fab}>
        <TouchableOpacity
          style={styles.fabButton}
          onPress={() => router.push('/cards/scan')}
          activeOpacity={0.8}
        >
          <Text style={styles.fabIcon}>⊡</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.fabButton, styles.fabPrimary]}
          onPress={() => router.push('/cards/add')}
          activeOpacity={0.8}
        >
          <Text style={styles.fabPrimaryIcon}>＋</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.background,
  },
  list: {
    padding: spacing.md,
    paddingBottom: 100,
  },
  header: {
    fontSize: fontSize.xxl,
    fontWeight: '700',
    color: colors.text,
    marginBottom: spacing.md,
  },
  empty: {
    alignItems: 'center',
    paddingTop: spacing.xxl,
  },
  emptyTitle: {
    fontSize: fontSize.lg,
    fontWeight: '600',
    color: colors.text,
    marginBottom: spacing.sm,
  },
  emptySubtitle: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    textAlign: 'center',
  },
  fab: {
    position: 'absolute',
    bottom: spacing.xl,
    right: spacing.lg,
    flexDirection: 'row',
    gap: spacing.sm,
  },
  fabButton: {
    width: 48,
    height: 48,
    borderRadius: radius.full,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  fabPrimary: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  fabIcon: {
    fontSize: 20,
    color: colors.text,
  },
  fabPrimaryIcon: {
    fontSize: 24,
    color: '#fff',
    lineHeight: 28,
  },
});
