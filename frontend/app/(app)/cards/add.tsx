import { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Modal,
  FlatList,
  ScrollView,
  ActivityIndicator,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CardCreateInputSchema, BarcodeTypeSchema } from '@/schemas/card';
import type { CardCreateInput, BarcodeType } from '@/schemas/card';
import { useCreateCard } from '@/hooks/useCreateCard';
import { BarcodeDisplay } from '@/components/cards/BarcodeDisplay';
import { colors, spacing, fontSize, radius } from '@/theme';

const BARCODE_TYPES: BarcodeType[] = BarcodeTypeSchema.options;

const BARCODE_LABELS: Record<BarcodeType, string> = {
  QR_CODE: 'QR Code',
  CODE_128: 'Code 128',
  EAN_13: 'EAN-13',
  CODE_39: 'Code 39',
  PDF_417: 'PDF-417',
  AZTEC: 'Aztec',
  EAN_8: 'EAN-8',
  UPC_A: 'UPC-A',
  DATA_MATRIX: 'Data Matrix',
};

export default function AddCardScreen() {
  const router = useRouter();
  const params = useLocalSearchParams<{ barcodeContent?: string; barcodeType?: string }>();
  const [typePickerVisible, setTypePickerVisible] = useState(false);

  const defaultType: BarcodeType = (BARCODE_TYPES.includes(params.barcodeType as BarcodeType)
    ? params.barcodeType
    : 'QR_CODE') as BarcodeType;

  const {
    control,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<CardCreateInput>({
    resolver: zodResolver(CardCreateInputSchema),
    defaultValues: {
      name: '',
      barcodeType: defaultType,
      barcodeContent: params.barcodeContent ?? '',
    },
  });

  const createCard = useCreateCard();
  const [apiError, setApiError] = useState('');

  const watchedType = watch('barcodeType');
  const watchedContent = watch('barcodeContent');

  const onSubmit = handleSubmit((data) => {
    setApiError('');
    createCard.mutate(data, {
      onSuccess: (card) => router.replace(`/cards/${card.id}`),
      onError: (err: unknown) => {
        const msg = (err as { response?: { data?: { message?: string } } }).response?.data?.message;
        setApiError(msg ?? '创建失败，请重试');
      },
    });
  });

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView style={styles.container} contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <View style={styles.field}>
          <Text style={styles.label}>卡片名称</Text>
          <Controller
            control={control}
            name="name"
            render={({ field: { value, onChange, onBlur } }) => (
              <TextInput
                style={[styles.input, errors.name && styles.inputError]}
                value={value}
                onChangeText={onChange}
                onBlur={onBlur}
                placeholder="如：Costco 会员卡"
                returnKeyType="next"
              />
            )}
          />
          {errors.name && <Text style={styles.fieldError}>{errors.name.message}</Text>}
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>条码类型</Text>
          <TouchableOpacity
            style={styles.picker}
            onPress={() => setTypePickerVisible(true)}
            activeOpacity={0.7}
          >
            <Text style={styles.pickerText}>{BARCODE_LABELS[watchedType]}</Text>
            <Text style={styles.pickerChevron}>›</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>条码内容</Text>
          <Controller
            control={control}
            name="barcodeContent"
            render={({ field: { value, onChange, onBlur } }) => (
              <TextInput
                style={[styles.input, errors.barcodeContent && styles.inputError]}
                value={value}
                onChangeText={onChange}
                onBlur={onBlur}
                placeholder="输入或扫码获取"
                autoCapitalize="none"
                autoCorrect={false}
              />
            )}
          />
          {errors.barcodeContent && (
            <Text style={styles.fieldError}>{errors.barcodeContent.message}</Text>
          )}
        </View>

        {watchedContent.length > 0 && (
          <View style={styles.preview}>
            <Text style={styles.previewLabel}>预览</Text>
            <BarcodeDisplay barcodeType={watchedType} barcodeContent={watchedContent} size={180} />
          </View>
        )}

        {apiError ? <Text style={styles.apiError}>{apiError}</Text> : null}

        <TouchableOpacity
          style={[styles.submitBtn, createCard.isPending && styles.submitDisabled]}
          onPress={onSubmit}
          disabled={createCard.isPending}
          activeOpacity={0.8}
        >
          {createCard.isPending ? (
            <ActivityIndicator color="#fff" size="small" />
          ) : (
            <Text style={styles.submitText}>保存</Text>
          )}
        </TouchableOpacity>
      </ScrollView>

      <Modal visible={typePickerVisible} transparent animationType="slide" onRequestClose={() => setTypePickerVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalSheet}>
            <Text style={styles.modalTitle}>选择条码类型</Text>
            <FlatList
              data={BARCODE_TYPES}
              keyExtractor={(item) => item}
              renderItem={({ item }) => (
                <TouchableOpacity
                  style={[styles.typeItem, watchedType === item && styles.typeItemSelected]}
                  onPress={() => {
                    setValue('barcodeType', item);
                    setTypePickerVisible(false);
                  }}
                >
                  <Text style={[styles.typeItemText, watchedType === item && styles.typeItemTextSelected]}>
                    {BARCODE_LABELS[item]}
                  </Text>
                  {watchedType === item && <Text style={styles.checkmark}>✓</Text>}
                </TouchableOpacity>
              )}
            />
          </View>
        </View>
      </Modal>
    </KeyboardAvoidingView>
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
  field: {
    marginBottom: spacing.md,
  },
  label: {
    fontSize: fontSize.sm,
    fontWeight: '600',
    color: colors.text,
    marginBottom: spacing.xs,
  },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    padding: spacing.md,
    fontSize: fontSize.md,
    color: colors.text,
    backgroundColor: colors.surface,
  },
  inputError: {
    borderColor: colors.danger,
  },
  fieldError: {
    color: colors.danger,
    fontSize: fontSize.xs,
    marginTop: spacing.xs,
  },
  picker: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    padding: spacing.md,
    backgroundColor: colors.surface,
  },
  pickerText: {
    flex: 1,
    fontSize: fontSize.md,
    color: colors.text,
  },
  pickerChevron: {
    fontSize: fontSize.xl,
    color: colors.textMuted,
  },
  preview: {
    backgroundColor: colors.surface,
    borderRadius: radius.card,
    padding: spacing.md,
    marginBottom: spacing.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  previewLabel: {
    fontSize: fontSize.xs,
    color: colors.textMuted,
    marginBottom: spacing.sm,
    letterSpacing: 1,
  },
  apiError: {
    color: colors.danger,
    fontSize: fontSize.sm,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  submitBtn: {
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: 'center',
    marginTop: spacing.sm,
  },
  submitDisabled: {
    opacity: 0.6,
  },
  submitText: {
    color: '#fff',
    fontSize: fontSize.md,
    fontWeight: '600',
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
    maxHeight: '70%',
  },
  modalTitle: {
    fontSize: fontSize.lg,
    fontWeight: '700',
    color: colors.text,
    marginBottom: spacing.md,
  },
  typeItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.md,
    borderRadius: radius.md,
    marginBottom: spacing.xs,
  },
  typeItemSelected: {
    backgroundColor: colors.primaryLight,
  },
  typeItemText: {
    flex: 1,
    fontSize: fontSize.md,
    color: colors.text,
  },
  typeItemTextSelected: {
    color: colors.primary,
    fontWeight: '600',
  },
  checkmark: {
    color: colors.primary,
    fontSize: fontSize.md,
    fontWeight: '700',
  },
});
