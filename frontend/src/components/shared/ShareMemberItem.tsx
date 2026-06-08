import { Alert, TouchableOpacity, View, Text, StyleSheet } from 'react-native';
import type { CardShareOutput } from '@/schemas/cardShare';
import { useOwnerRemoveShare } from '@/hooks/useOwnerRemoveShare';
import { colors, spacing, fontSize, radius } from '@/theme';

type Props = {
  share: CardShareOutput;
  cardId: string;
};

export function ShareMemberItem({ share, cardId }: Props) {
  const removeShare = useOwnerRemoveShare(cardId);

  function handleRemove() {
    Alert.alert('移除共享', `确定要移除 ${share.viewer.userName} 的共享权限吗？`, [
      { text: '取消', style: 'cancel' },
      {
        text: '移除',
        style: 'destructive',
        onPress: () => removeShare.mutate(share.id),
      },
    ]);
  }

  return (
    <View style={styles.container}>
      <Text style={styles.name} numberOfLines={1}>
        {share.viewer.userName}
      </Text>
      <TouchableOpacity
        style={styles.removeButton}
        onPress={handleRemove}
        disabled={removeShare.isPending}
        activeOpacity={0.7}
      >
        <Text style={styles.removeText}>移除</Text>
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
