import { useCallback, useState } from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  FlatList,
  ActivityIndicator,
  StyleSheet,
} from 'react-native';
import { useFriendships } from '@/hooks/useFriendships';
import { useCreateShare } from '@/hooks/useCreateShare';
import { useAuthStore } from '@/store/authStore';
import type { FriendshipOutput } from '@/schemas/friend';
import { colors, spacing, fontSize, radius } from '@/theme';

type Props = {
  visible: boolean;
  cardId: string;
  existingViewerIds: string[];
  onClose: () => void;
};

export function FriendPickerModal({ visible, cardId, existingViewerIds, onClose }: Props) {
  const [pendingIds, setPendingIds] = useState<Set<string>>(new Set());
  const { friends, isLoading } = useFriendships();
  const createShare = useCreateShare(cardId);
  const me = useAuthStore((s) => s.user);

  function friendId(fs: FriendshipOutput): string {
    return fs.requesterId === me?.id ? fs.addresseeId : fs.requesterId;
  }

  function friendName(fs: FriendshipOutput): string {
    return fs.requesterId === me?.id
      ? (fs.addresseeUserName ?? '')
      : (fs.requesterUserName ?? '');
  }

  const available = friends.filter(
    (fs) => !existingViewerIds.includes(friendId(fs)),
  );

  function handleClose() {
    setPendingIds(new Set());
    onClose();
  }

  const handleShare = useCallback(
    (fs: FriendshipOutput) => {
      const id = friendId(fs);
      setPendingIds((prev) => new Set(prev).add(id));
      createShare.mutate(
        { viewerId: id },
        {
          onError: () => {
            setPendingIds((prev) => {
              const next = new Set(prev);
              next.delete(id);
              return next;
            });
          },
        },
      );
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [createShare, me?.id],
  );

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={handleClose}>
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>选择好友共享</Text>
          <TouchableOpacity onPress={handleClose} style={styles.closeButton}>
            <Text style={styles.closeText}>关闭</Text>
          </TouchableOpacity>
        </View>

        {isLoading ? (
          <ActivityIndicator style={styles.loader} color={colors.primary} />
        ) : (
          <FlatList
            data={available}
            keyExtractor={(fs) => fs.id}
            contentContainerStyle={styles.list}
            ListEmptyComponent={
              <Text style={styles.emptyText}>
                {friends.length === 0 ? '暂无好友，请先添加好友' : '所有好友已共享该卡片'}
              </Text>
            }
            renderItem={({ item }) => {
              const id = friendId(item);
              const shared = pendingIds.has(id);
              return (
                <View style={styles.row}>
                  <Text style={styles.name}>{friendName(item)}</Text>
                  <TouchableOpacity
                    style={[styles.shareButton, shared && styles.shareButtonDone]}
                    onPress={() => handleShare(item)}
                    disabled={shared}
                    activeOpacity={0.7}
                  >
                    <Text style={[styles.shareText, shared && styles.shareTextDone]}>
                      {shared ? '已共享' : '共享'}
                    </Text>
                  </TouchableOpacity>
                </View>
              );
            }}
          />
        )}
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
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
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
    backgroundColor: colors.surface,
  },
  title: {
    fontSize: fontSize.lg,
    fontWeight: '700',
    color: colors.text,
  },
  closeButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
  },
  closeText: {
    fontSize: fontSize.md,
    color: colors.primary,
  },
  loader: {
    marginTop: spacing.xxl,
  },
  list: {
    padding: spacing.md,
  },
  emptyText: {
    textAlign: 'center',
    color: colors.textMuted,
    fontSize: fontSize.sm,
    marginTop: spacing.xl,
  },
  row: {
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
  shareButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
    backgroundColor: colors.primary,
  },
  shareButtonDone: {
    backgroundColor: colors.border,
  },
  shareText: {
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: '500',
  },
  shareTextDone: {
    color: colors.textMuted,
  },
});
