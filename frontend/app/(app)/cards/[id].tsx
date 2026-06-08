import { useCallback, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Modal,
  TextInput,
  Alert,
  ActivityIndicator,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useLocalSearchParams, useFocusEffect, router } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as Brightness from 'expo-brightness';
import { z } from 'zod';
import { selectCardById } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';
import { useUpdateCard } from '@/hooks/useUpdateCard';
import { useDeleteCard } from '@/hooks/useDeleteCard';
import { useGetShares } from '@/hooks/useGetShares';
import { useUpdateShareNickname } from '@/hooks/useUpdateShareNickname';
import { useViewerLeaveShare } from '@/hooks/useViewerLeaveShare';
import { BarcodeDisplay } from '@/components/cards/BarcodeDisplay';
import { ShareMemberItem } from '@/components/shared/ShareMemberItem';
import { FriendPickerModal } from '@/components/shared/FriendPickerModal';
import type { BarcodeType } from '@/schemas/card';
import { colors, spacing, fontSize, radius } from '@/theme';

const EditNameSchema = z.object({
  name: z.string().min(1, '名称不能为空').max(200, '名称最多 200 字'),
});
type EditNameInput = z.infer<typeof EditNameSchema>;

const NicknameSchema = z.object({
  viewerNickname: z.string().max(100, '昵称最多 100 字'),
});
type NicknameInput = z.infer<typeof NicknameSchema>;

export default function CardDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [editVisible, setEditVisible] = useState(false);
  const [nicknameVisible, setNicknameVisible] = useState(false);
  const [friendPickerVisible, setFriendPickerVisible] = useState(false);

  const { data: card, isLoading } = useQuery({
    queryKey: queryKeys.cards.detail(id),
    queryFn: () => selectCardById(id),
    staleTime: Infinity,
  });

  const isOwner = card ? card.is_shared === 0 : true;

  const updateCard = useUpdateCard();
  const deleteCard = useDeleteCard();
  const updateNickname = useUpdateShareNickname();
  const leaveShare = useViewerLeaveShare();

  const { data: shares = [], isLoading: sharesLoading } = useGetShares(
    isOwner && !!card ? card.id : '',
  );

  const { control: nameControl, handleSubmit: handleNameSubmit, reset: resetName, formState: { errors: nameErrors } } =
    useForm<EditNameInput>({
      resolver: zodResolver(EditNameSchema),
      defaultValues: { name: card?.name ?? '' },
    });

  const { control: nickControl, handleSubmit: handleNickSubmit, reset: resetNick, formState: { errors: nickErrors } } =
    useForm<NicknameInput>({
      resolver: zodResolver(NicknameSchema),
      defaultValues: { viewerNickname: card?.viewer_nickname ?? '' },
    });

  useFocusEffect(
    useCallback(() => {
      let original: number;
      Brightness.getBrightnessAsync().then((v) => {
        original = v;
        Brightness.setBrightnessAsync(1.0);
      });
      return () => {
        if (original !== undefined) {
          Brightness.setBrightnessAsync(original);
        }
      };
    }, []),
  );

  const openEdit = () => {
    resetName({ name: card?.name ?? '' });
    setEditVisible(true);
  };

  const onSubmitEdit = handleNameSubmit((data) => {
    if (!card) return;
    updateCard.mutate(
      { id: card.id, data: { name: data.name } },
      { onSuccess: () => setEditVisible(false) },
    );
  });

  const openNickname = () => {
    resetNick({ viewerNickname: card?.viewer_nickname ?? '' });
    setNicknameVisible(true);
  };

  const onSubmitNickname = handleNickSubmit((data) => {
    if (!card?.share_id) return;
    const nickname = data.viewerNickname.trim() || null;
    updateNickname.mutate(
      { shareId: card.share_id, viewerNickname: nickname },
      { onSuccess: () => setNicknameVisible(false) },
    );
  });

  const confirmDelete = () => {
    Alert.alert('删除卡片', '确认删除该卡片？此操作无法撤销。', [
      { text: '取消', style: 'cancel' },
      {
        text: '删除',
        style: 'destructive',
        onPress: () => deleteCard.mutate(id),
      },
    ]);
  };

  const confirmLeave = () => {
    Alert.alert('退出共享', '确认退出该卡片的共享？退出后将无法查看此卡片。', [
      { text: '取消', style: 'cancel' },
      {
        text: '退出',
        style: 'destructive',
        onPress: () => {
          if (!card?.share_id) return;
          leaveShare.mutate(
            { shareId: card.share_id, cardId: card.id },
            { onSuccess: () => router.back() },
          );
        },
      },
    ]);
  };

  if (isLoading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={colors.primary} />
      </View>
    );
  }

  if (!card) {
    return (
      <View style={styles.center}>
        <Text style={styles.notFound}>卡片不存在</Text>
      </View>
    );
  }

  const existingViewerIds = shares.map((s) => s.viewer.id);

  return (
    <>
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.name}>
          {!isOwner && card.viewer_nickname ? card.viewer_nickname : card.name}
        </Text>

        <View style={styles.barcodeCard}>
          <BarcodeDisplay
            barcodeType={card.barcode_type as BarcodeType}
            barcodeContent={card.barcode_content}
            size={240}
          />
        </View>

        <View style={styles.actions}>
          {isOwner ? (
            <>
              <TouchableOpacity style={styles.actionBtn} onPress={openEdit} activeOpacity={0.7}>
                <Text style={styles.actionBtnText}>编辑名称</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.actionBtn, styles.dangerBtn]}
                onPress={confirmDelete}
                activeOpacity={0.7}
              >
                <Text style={[styles.actionBtnText, styles.dangerText]}>删除卡片</Text>
              </TouchableOpacity>
            </>
          ) : (
            <>
              <TouchableOpacity style={styles.actionBtn} onPress={openNickname} activeOpacity={0.7}>
                <Text style={styles.actionBtnText}>设置昵称</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.actionBtn, styles.dangerBtn]}
                onPress={confirmLeave}
                disabled={leaveShare.isPending}
                activeOpacity={0.7}
              >
                <Text style={[styles.actionBtnText, styles.dangerText]}>退出共享</Text>
              </TouchableOpacity>
            </>
          )}
        </View>

        {isOwner && (
          <View style={styles.shareSection}>
            <View style={styles.shareSectionHeader}>
              <Text style={styles.shareSectionTitle}>共享成员</Text>
              <TouchableOpacity
                style={styles.addShareBtn}
                onPress={() => setFriendPickerVisible(true)}
                activeOpacity={0.7}
              >
                <Text style={styles.addShareText}>添加共享</Text>
              </TouchableOpacity>
            </View>

            {sharesLoading ? (
              <ActivityIndicator color={colors.primary} style={styles.sharesLoader} />
            ) : shares.length === 0 ? (
              <Text style={styles.emptyShares}>暂未共享给任何好友</Text>
            ) : (
              shares.map((share) => (
                <ShareMemberItem key={share.id} share={share} cardId={card.id} />
              ))
            )}
          </View>
        )}
      </ScrollView>

      {/* Owner: edit card name */}
      <Modal visible={editVisible} transparent animationType="slide" onRequestClose={() => setEditVisible(false)}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={styles.modalOverlay}
        >
          <View style={styles.modalSheet}>
            <Text style={styles.modalTitle}>编辑名称</Text>

            <Controller
              control={nameControl}
              name="name"
              render={({ field: { value, onChange, onBlur } }) => (
                <TextInput
                  style={[styles.input, nameErrors.name && styles.inputError]}
                  value={value}
                  onChangeText={onChange}
                  onBlur={onBlur}
                  placeholder="卡片名称"
                  autoFocus
                  returnKeyType="done"
                  onSubmitEditing={onSubmitEdit}
                />
              )}
            />
            {nameErrors.name && <Text style={styles.fieldError}>{nameErrors.name.message}</Text>}

            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalBtn, styles.cancelBtn]}
                onPress={() => setEditVisible(false)}
              >
                <Text style={styles.cancelBtnText}>取消</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalBtn, styles.saveBtn]}
                onPress={onSubmitEdit}
                disabled={updateCard.isPending}
              >
                {updateCard.isPending ? (
                  <ActivityIndicator color="#fff" size="small" />
                ) : (
                  <Text style={styles.saveBtnText}>保存</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </KeyboardAvoidingView>
      </Modal>

      {/* Viewer: set nickname */}
      <Modal visible={nicknameVisible} transparent animationType="slide" onRequestClose={() => setNicknameVisible(false)}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={styles.modalOverlay}
        >
          <View style={styles.modalSheet}>
            <Text style={styles.modalTitle}>设置昵称</Text>

            <Controller
              control={nickControl}
              name="viewerNickname"
              render={({ field: { value, onChange, onBlur } }) => (
                <TextInput
                  style={[styles.input, nickErrors.viewerNickname && styles.inputError]}
                  value={value}
                  onChangeText={onChange}
                  onBlur={onBlur}
                  placeholder="私有昵称（留空则使用原名）"
                  autoFocus
                  returnKeyType="done"
                  onSubmitEditing={onSubmitNickname}
                />
              )}
            />
            {nickErrors.viewerNickname && (
              <Text style={styles.fieldError}>{nickErrors.viewerNickname.message}</Text>
            )}

            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalBtn, styles.cancelBtn]}
                onPress={() => setNicknameVisible(false)}
              >
                <Text style={styles.cancelBtnText}>取消</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalBtn, styles.saveBtn]}
                onPress={onSubmitNickname}
                disabled={updateNickname.isPending}
              >
                {updateNickname.isPending ? (
                  <ActivityIndicator color="#fff" size="small" />
                ) : (
                  <Text style={styles.saveBtnText}>保存</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </KeyboardAvoidingView>
      </Modal>

      {/* Owner: pick friend to share with */}
      {isOwner && (
        <FriendPickerModal
          visible={friendPickerVisible}
          cardId={card.id}
          existingViewerIds={existingViewerIds}
          onClose={() => setFriendPickerVisible(false)}
        />
      )}
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.background,
  },
  notFound: {
    fontSize: fontSize.md,
    color: colors.textMuted,
  },
  name: {
    fontSize: fontSize.xl,
    fontWeight: '700',
    color: colors.text,
    marginBottom: spacing.lg,
    textAlign: 'center',
  },
  barcodeCard: {
    backgroundColor: colors.surface,
    borderRadius: radius.card,
    padding: spacing.lg,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: spacing.xl,
  },
  actions: {
    gap: spacing.sm,
  },
  actionBtn: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.border,
  },
  actionBtnText: {
    fontSize: fontSize.md,
    fontWeight: '500',
    color: colors.text,
  },
  dangerBtn: {
    borderColor: colors.danger,
  },
  dangerText: {
    color: colors.danger,
  },
  shareSection: {
    marginTop: spacing.xl,
  },
  shareSectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: spacing.sm,
  },
  shareSectionTitle: {
    fontSize: fontSize.sm,
    fontWeight: '600',
    color: colors.textMuted,
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
  addShareBtn: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
  },
  addShareText: {
    fontSize: fontSize.sm,
    color: colors.primary,
    fontWeight: '500',
  },
  sharesLoader: {
    marginTop: spacing.md,
  },
  emptyShares: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    textAlign: 'center',
    paddingVertical: spacing.md,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
    justifyContent: 'flex-end',
  },
  modalSheet: {
    backgroundColor: colors.surface,
    borderTopLeftRadius: radius.lg,
    borderTopRightRadius: radius.lg,
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  modalTitle: {
    fontSize: fontSize.lg,
    fontWeight: '700',
    color: colors.text,
    marginBottom: spacing.md,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    padding: spacing.md,
    fontSize: fontSize.md,
    color: colors.text,
    backgroundColor: colors.background,
  },
  inputError: {
    borderColor: colors.danger,
  },
  fieldError: {
    color: colors.danger,
    fontSize: fontSize.xs,
    marginTop: spacing.xs,
  },
  modalActions: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginTop: spacing.md,
  },
  modalBtn: {
    flex: 1,
    padding: spacing.md,
    borderRadius: radius.md,
    alignItems: 'center',
  },
  cancelBtn: {
    backgroundColor: colors.background,
    borderWidth: 1,
    borderColor: colors.border,
  },
  cancelBtnText: {
    fontSize: fontSize.md,
    color: colors.textMuted,
  },
  saveBtn: {
    backgroundColor: colors.primary,
  },
  saveBtnText: {
    fontSize: fontSize.md,
    color: '#fff',
    fontWeight: '600',
  },
});
