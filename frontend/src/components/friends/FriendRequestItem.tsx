import { View, Text, TouchableOpacity, ActivityIndicator, StyleSheet } from 'react-native';
import type { FriendshipOutput } from '@/schemas/friend';
import { useAcceptFriendRequest } from '@/hooks/useAcceptFriendRequest';
import { useRemoveFriend } from '@/hooks/useRemoveFriend';
import { colors, spacing, fontSize, radius } from '@/theme';

type Props = {
  request: FriendshipOutput;
};

export function FriendRequestItem({ request }: Props) {
  const accept = useAcceptFriendRequest();
  const reject = useRemoveFriend();

  const isPending = accept.isPending || reject.isPending;

  return (
    <View style={styles.container}>
      <View style={styles.info}>
        <Text style={styles.name} numberOfLines={1}>
          {request.requesterUserName}
        </Text>
        <Text style={styles.date}>
          {new Date(request.createdAt).toLocaleDateString('zh-CN')}
        </Text>
      </View>
      {isPending ? (
        <ActivityIndicator size="small" color={colors.primary} />
      ) : (
        <View style={styles.actions}>
          <TouchableOpacity
            style={styles.acceptButton}
            onPress={() => accept.mutate(request.id)}
            activeOpacity={0.7}
          >
            <Text style={styles.acceptText}>接受</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.rejectButton}
            onPress={() => reject.mutate(request.id)}
            activeOpacity={0.7}
          >
            <Text style={styles.rejectText}>拒绝</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
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
  info: {
    flex: 1,
  },
  name: {
    fontSize: fontSize.md,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 2,
  },
  date: {
    fontSize: fontSize.xs,
    color: colors.textMuted,
  },
  actions: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  acceptButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
    backgroundColor: colors.primary,
  },
  acceptText: {
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: '500',
  },
  rejectButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
    borderWidth: 1,
    borderColor: colors.danger,
  },
  rejectText: {
    fontSize: fontSize.sm,
    color: colors.danger,
    fontWeight: '500',
  },
});
