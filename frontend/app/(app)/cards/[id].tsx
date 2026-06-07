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
import { useLocalSearchParams, useFocusEffect } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as Brightness from 'expo-brightness';
import { z } from 'zod';
import { selectCardById } from '@/lib/storage/db';
import { queryKeys } from '@/lib/query/keys';
import { useUpdateCard } from '@/hooks/useUpdateCard';
import { useDeleteCard } from '@/hooks/useDeleteCard';
import { BarcodeDisplay } from '@/components/cards/BarcodeDisplay';
import type { BarcodeType } from '@/schemas/card';
import { colors, spacing, fontSize, radius } from '@/theme';

const EditNameSchema = z.object({
  name: z.string().min(1, '名称不能为空').max(200, '名称最多 200 字'),
});
type EditNameInput = z.infer<typeof EditNameSchema>;

export default function CardDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [editVisible, setEditVisible] = useState(false);

  const { data: card, isLoading } = useQuery({
    queryKey: queryKeys.cards.detail(id),
    queryFn: () => selectCardById(id),
    staleTime: Infinity,
  });

  const updateCard = useUpdateCard();
  const deleteCard = useDeleteCard();

  const { control, handleSubmit, reset, formState: { errors } } = useForm<EditNameInput>({
    resolver: zodResolver(EditNameSchema),
    defaultValues: { name: card?.name ?? '' },
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
    reset({ name: card?.name ?? '' });
    setEditVisible(true);
  };

  const onSubmitEdit = handleSubmit((data) => {
    if (!card) return;
    updateCard.mutate(
      { id: card.id, data: { name: data.name } },
      { onSuccess: () => setEditVisible(false) },
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

  return (
    <>
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.name}>{card.name}</Text>

        <View style={styles.barcodeCard}>
          <BarcodeDisplay
            barcodeType={card.barcode_type as BarcodeType}
            barcodeContent={card.barcode_content}
            size={240}
          />
        </View>

        <View style={styles.actions}>
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
        </View>
      </ScrollView>

      <Modal visible={editVisible} transparent animationType="slide" onRequestClose={() => setEditVisible(false)}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={styles.modalOverlay}
        >
          <View style={styles.modalSheet}>
            <Text style={styles.modalTitle}>编辑名称</Text>

            <Controller
              control={control}
              name="name"
              render={({ field: { value, onChange, onBlur } }) => (
                <TextInput
                  style={[styles.input, errors.name && styles.inputError]}
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
            {errors.name && <Text style={styles.fieldError}>{errors.name.message}</Text>}

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
