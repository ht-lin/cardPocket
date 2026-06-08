import { Alert, TouchableOpacity, View, Text, StyleSheet } from 'react-native';
import type { FriendshipOutput } from '@/schemas/friend';
import { useRemoveFriend } from '@/hooks/useRemoveFriend';
import { colors, spacing, fontSize, radius } from '@/theme';

type Props = {
  friendship: FriendshipOutput;
  currentUserId: string;
};

export function FriendListItem({ friendship, currentUserId }: Props) {
  const removeFriend = useRemoveFriend();

  const friendName =
    friendship.requesterId === currentUserId
      ? friendship.addresseeUserName
      : friendship.requesterUserName;

  function handleRemove() {
    Alert.alert(
      '解除好友',
      `确定要解除与 ${friendName} 的好友关系吗？\n这将同时撤销所有共享。`,
      [
        { text: '取消', style: 'cancel' },
        {
          text: '解除',
          style: 'destructive',
          onPress: () => removeFriend.mutate(friendship.id),
        },
      ],
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.name} numberOfLines={1}>
        {friendName}
      </Text>
      <TouchableOpacity
        style={styles.removeButton}
        onPress={handleRemove}
        disabled={removeFriend.isPending}
        activeOpacity={0.7}
      >
        <Text style={styles.removeText}>解除</Text>
      </TouchableOpacity>
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
  name: {
    flex: 1,
    fontSize: fontSize.md,
    fontWeight: '600',
    color: colors.text,
  },
  removeButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
    borderWidth: 1,
    borderColor: colors.danger,
  },
  removeText: {
    fontSize: fontSize.sm,
    color: colors.danger,
    fontWeight: '500',
  },
});
