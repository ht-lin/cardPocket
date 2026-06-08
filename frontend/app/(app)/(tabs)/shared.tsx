import { useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  AppState,
  StyleSheet,
} from 'react-native';
import { router } from 'expo-router';
import { useQueryClient } from '@tanstack/react-query';
import { useSharedCards } from '@/hooks/useSharedCards';
import { queryKeys } from '@/lib/query/keys';
import type { CardRow } from '@/lib/storage/db';
import { colors, spacing, fontSize, radius } from '@/theme';

export default function SharedScreen() {
  const { sharedCards, isLoading } = useSharedCards();
  const queryClient = useQueryClient();

  useEffect(() => {
    const sub = AppState.addEventListener('change', (nextState) => {
      if (nextState === 'active') {
        queryClient.invalidateQueries({ queryKey: queryKeys.cards.all });
      }
    });
    return () => sub.remove();
  }, [queryClient]);

  function renderItem({ item }: { item: CardRow }) {
    const displayName = item.viewer_nickname ?? item.name;
    return (
      <TouchableOpacity
        style={styles.card}
        onPress={() => router.push(`/cards/${item.id}`)}
        activeOpacity={0.7}
      >
        <View style={styles.cardContent}>
          <Text style={styles.cardName} numberOfLines={1}>
            {displayName}
          </Text>
          {item.viewer_nickname && (
            <Text style={styles.cardOriginalName} numberOfLines={1}>
              {item.name}
            </Text>
          )}
        </View>
        <Text style={styles.arrow}>›</Text>
      </TouchableOpacity>
    );
  }

  return (
    <View style={styles.screen}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>共享卡片</Text>
      </View>

      {isLoading ? (
        <ActivityIndicator style={styles.loader} color={colors.primary} />
      ) : (
        <FlatList
          data={sharedCards}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          renderItem={renderItem}
          ListEmptyComponent={
            <Text style={styles.emptyText}>暂无共享给你的卡片</Text>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    paddingHorizontal: spacing.md,
    paddingTop: spacing.lg,
    paddingBottom: spacing.md,
    backgroundColor: colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  headerTitle: {
    fontSize: fontSize.xl,
    fontWeight: '700',
    color: colors.text,
  },
  loader: {
    marginTop: spacing.xxl,
  },
  listContent: {
    padding: spacing.md,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderRadius: radius.card,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    marginBottom: spacing.sm,
    borderWidth: 1,
    borderColor: colors.border,
  },
  cardContent: {
    flex: 1,
  },
  cardName: {
    fontSize: fontSize.md,
    fontWeight: '600',
    color: colors.text,
  },
  cardOriginalName: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    marginTop: 2,
  },
  arrow: {
    fontSize: fontSize.xl,
    color: colors.textMuted,
    marginLeft: spacing.sm,
  },
  emptyText: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    textAlign: 'center',
    paddingVertical: spacing.xl,
  },
});
