import { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, ActivityIndicator, AppState, StyleSheet } from 'react-native';
import { useQueryClient } from '@tanstack/react-query';
import { useFriendships } from '@/hooks/useFriendships';
import { useFriendRequests } from '@/hooks/useFriendRequests';
import { FriendListItem } from '@/components/friends/FriendListItem';
import { FriendRequestItem } from '@/components/friends/FriendRequestItem';
import { UserSearchModal } from '@/components/friends/UserSearchModal';
import { useAuthStore } from '@/store/authStore';
import { queryKeys } from '@/lib/query/keys';
import { colors, spacing, fontSize } from '@/theme';

export default function FriendsScreen() {
  const [searchVisible, setSearchVisible] = useState(false);
  const { friends, isLoading: friendsLoading } = useFriendships();
  const { requests, isLoading: requestsLoading } = useFriendRequests();
  const user = useAuthStore((s) => s.user);
  const queryClient = useQueryClient();

  useEffect(() => {
    const sub = AppState.addEventListener('change', (nextState) => {
      if (nextState === 'active') {
        queryClient.invalidateQueries({ queryKey: queryKeys.friends.all });
        queryClient.invalidateQueries({ queryKey: queryKeys.friends.requests });
      }
    });
    return () => sub.remove();
  }, [queryClient]);

  const isLoading = friendsLoading || requestsLoading;

  return (
    <View style={styles.screen}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>好友</Text>
        <TouchableOpacity style={styles.searchButton} onPress={() => setSearchVisible(true)}>
          <Text style={styles.searchButtonText}>搜索用户</Text>
        </TouchableOpacity>
      </View>

      {isLoading ? (
        <ActivityIndicator style={styles.loader} color={colors.primary} />
      ) : (
        <ScrollView contentContainerStyle={styles.scrollContent}>
          {requests.length > 0 && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>好友请求 ({requests.length})</Text>
              {requests.map((req) => (
                <FriendRequestItem key={req.id} request={req} />
              ))}
            </View>
          )}

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>我的好友</Text>
            {friends.length === 0 ? (
              <Text style={styles.emptyText}>暂无好友，点击右上角搜索添加</Text>
            ) : (
              friends.map((fs) => (
                <FriendListItem key={fs.id} friendship={fs} currentUserId={user?.id ?? ''} />
              ))
            )}
          </View>
        </ScrollView>
      )}

      <UserSearchModal visible={searchVisible} onClose={() => setSearchVisible(false)} />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
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
  searchButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
  },
  searchButtonText: {
    fontSize: fontSize.md,
    color: colors.primary,
    fontWeight: '500',
  },
  loader: {
    marginTop: spacing.xxl,
  },
  scrollContent: {
    padding: spacing.md,
  },
  section: {
    marginBottom: spacing.lg,
  },
  sectionTitle: {
    fontSize: fontSize.sm,
    fontWeight: '600',
    color: colors.textMuted,
    letterSpacing: 0.5,
    marginBottom: spacing.sm,
    textTransform: 'uppercase',
  },
  emptyText: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    textAlign: 'center',
    paddingVertical: spacing.xl,
  },
});
