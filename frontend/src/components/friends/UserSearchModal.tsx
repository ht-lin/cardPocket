import { useState, useEffect, useCallback } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  ActivityIndicator,
  StyleSheet,
} from 'react-native';
import { useSearchUsers } from '@/hooks/useSearchUsers';
import { useSendFriendRequest } from '@/hooks/useSendFriendRequest';
import type { UserSearchOutput } from '@/schemas/auth';
import { colors, spacing, fontSize, radius } from '@/theme';

type Props = {
  visible: boolean;
  onClose: () => void;
};

export function UserSearchModal({ visible, onClose }: Props) {
  const [inputValue, setInputValue] = useState('');
  const [debouncedQuery, setDebouncedQuery] = useState('');
  const [pendingSentIds, setPendingSentIds] = useState<Set<string>>(new Set());

  const { data: results = [], isFetching } = useSearchUsers(debouncedQuery);
  const sendRequest = useSendFriendRequest();

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(inputValue.trim()), 300);
    return () => clearTimeout(timer);
  }, [inputValue]);

  function handleClose() {
    setInputValue('');
    setDebouncedQuery('');
    setPendingSentIds(new Set());
    onClose();
  }

  const handleSend = useCallback(
    (user: UserSearchOutput) => {
      setPendingSentIds((prev) => new Set(prev).add(user.id));
      sendRequest.mutate(
        { addresseeId: user.id },
        {
          onError: () => {
            setPendingSentIds((prev) => {
              const next = new Set(prev);
              next.delete(user.id);
              return next;
            });
          },
        },
      );
    },
    [sendRequest],
  );

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet" onRequestClose={handleClose}>
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>搜索用户</Text>
          <TouchableOpacity onPress={handleClose} style={styles.closeButton}>
            <Text style={styles.closeText}>关闭</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.searchRow}>
          <TextInput
            style={styles.input}
            placeholder="用户名或邮箱（精确匹配）"
            placeholderTextColor={colors.textMuted}
            value={inputValue}
            onChangeText={setInputValue}
            autoCapitalize="none"
            autoCorrect={false}
          />
          {isFetching && <ActivityIndicator size="small" color={colors.primary} style={styles.spinner} />}
        </View>

        <FlatList
          data={results}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          ListEmptyComponent={
            debouncedQuery.length > 0 && !isFetching ? (
              <Text style={styles.emptyText}>未找到匹配用户</Text>
            ) : null
          }
          renderItem={({ item }) => {
            const sent = pendingSentIds.has(item.id);
            return (
              <View style={styles.resultItem}>
                <Text style={styles.resultName}>{item.userName}</Text>
                <TouchableOpacity
                  style={[styles.sendButton, sent && styles.sendButtonDisabled]}
                  onPress={() => handleSend(item)}
                  disabled={sent}
                  activeOpacity={0.7}
                >
                  <Text style={[styles.sendText, sent && styles.sendTextDisabled]}>
                    {sent ? '已发送' : '发送请求'}
                  </Text>
                </TouchableOpacity>
              </View>
            );
          }}
        />
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
  searchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    margin: spacing.md,
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.md,
  },
  input: {
    flex: 1,
    height: 44,
    fontSize: fontSize.md,
    color: colors.text,
  },
  spinner: {
    marginLeft: spacing.sm,
  },
  list: {
    paddingHorizontal: spacing.md,
  },
  emptyText: {
    textAlign: 'center',
    color: colors.textMuted,
    fontSize: fontSize.sm,
    marginTop: spacing.xl,
  },
  resultItem: {
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
  resultName: {
    flex: 1,
    fontSize: fontSize.md,
    fontWeight: '600',
    color: colors.text,
  },
  sendButton: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
    backgroundColor: colors.primary,
  },
  sendButtonDisabled: {
    backgroundColor: colors.border,
  },
  sendText: {
    fontSize: fontSize.sm,
    color: colors.surface,
    fontWeight: '500',
  },
  sendTextDisabled: {
    color: colors.textMuted,
  },
});
