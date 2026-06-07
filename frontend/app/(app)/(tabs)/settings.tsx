import { useState } from 'react';
import {
  SafeAreaView,
  ScrollView,
  View,
  Text,
  TextInput,
  Pressable,
  Modal,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { isAxiosError } from 'axios';
import { useAuthStore } from '@/store/authStore';
import { useLogout } from '@/hooks/useLogout';
import { useUpdateUserName } from '@/hooks/useUpdateUserName';
import { useChangePassword } from '@/hooks/useChangePassword';
import { useDeleteAccount } from '@/hooks/useDeleteAccount';
import {
  UpdateUsernameFormSchema,
  type UpdateUsernameFormInput,
  ChangePasswordFormSchema,
  type ChangePasswordFormInput,
} from '@/schemas/auth';
import { colors, spacing, radius, fontSize, fontWeight } from '@/theme';

type ActiveSection = 'username' | 'password' | null;

export default function SettingsScreen() {
  const user = useAuthStore((s) => s.user);
  const [activeSection, setActiveSection] = useState<ActiveSection>(null);
  const [deleteModalVisible, setDeleteModalVisible] = useState(false);
  const [passwordChanged, setPasswordChanged] = useState(false);

  const logout = useLogout();
  const updateUserName = useUpdateUserName();
  const changePassword = useChangePassword();
  const deleteAccount = useDeleteAccount();

  const usernameForm = useForm<UpdateUsernameFormInput>({
    resolver: zodResolver(UpdateUsernameFormSchema),
    defaultValues: { userName: user?.userName ?? '' },
  });

  const passwordForm = useForm<ChangePasswordFormInput>({
    resolver: zodResolver(ChangePasswordFormSchema),
    defaultValues: { currentPassword: '', newPassword: '', confirmNewPassword: '' },
  });

  function toggleSection(section: ActiveSection) {
    setActiveSection((prev) => (prev === section ? null : section));
    if (section === 'username') {
      usernameForm.reset({ userName: user?.userName ?? '' });
      updateUserName.reset();
    }
    if (section === 'password') {
      passwordForm.reset();
      changePassword.reset();
      setPasswordChanged(false);
    }
  }

  function onSubmitUsername(data: UpdateUsernameFormInput) {
    updateUserName.mutate(data.userName, {
      onSuccess: () => setActiveSection(null),
    });
  }

  function onSubmitPassword(data: ChangePasswordFormInput) {
    changePassword.mutate(
      { currentPassword: data.currentPassword, newPassword: data.newPassword },
      {
        onSuccess: () => {
          setPasswordChanged(true);
          passwordForm.reset();
          setActiveSection(null);
        },
      },
    );
  }

  const usernameApiError = isAxiosError(updateUserName.error)
    ? (updateUserName.error.response?.data?.message ?? '修改失败，请重试')
    : null;

  const passwordApiError = isAxiosError(changePassword.error)
    ? (changePassword.error.response?.data?.message ?? '修改失败，请重试')
    : null;

  const deleteApiError = isAxiosError(deleteAccount.error)
    ? (deleteAccount.error.response?.data?.message ?? '注销失败，请重试')
    : null;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text style={styles.pageTitle}>设置</Text>

        {/* Profile Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>个人信息</Text>

          <View style={styles.row}>
            <Text style={styles.rowLabel}>邮箱</Text>
            <Text style={styles.rowValue}>{user?.email}</Text>
          </View>

          <View style={styles.row}>
            <Text style={styles.rowLabel}>用户名</Text>
            <Text style={styles.rowValue}>{user?.userName}</Text>
          </View>

          <Pressable
            style={styles.linkButton}
            onPress={() => toggleSection('username')}
          >
            <Text style={styles.linkButtonText}>
              {activeSection === 'username' ? '取消修改' : '修改用户名'}
            </Text>
          </Pressable>

          {activeSection === 'username' && (
            <View style={styles.inlineForm}>
              <View style={styles.field}>
                <Text style={styles.label}>新用户名</Text>
                <Controller
                  name="userName"
                  control={usernameForm.control}
                  render={({ field: { value, onChange, onBlur } }) => (
                    <TextInput
                      style={[
                        styles.input,
                        usernameForm.formState.errors.userName && styles.inputError,
                      ]}
                      value={value}
                      onChangeText={onChange}
                      onBlur={onBlur}
                      autoCapitalize="none"
                      autoCorrect={false}
                    />
                  )}
                />
                {usernameForm.formState.errors.userName && (
                  <Text style={styles.fieldError}>
                    {usernameForm.formState.errors.userName.message}
                  </Text>
                )}
              </View>

              {usernameApiError && (
                <Text style={styles.apiError}>{usernameApiError}</Text>
              )}

              <Pressable
                style={[styles.button, updateUserName.isPending && styles.buttonDisabled]}
                onPress={usernameForm.handleSubmit(onSubmitUsername)}
                disabled={updateUserName.isPending}
              >
                {updateUserName.isPending ? (
                  <ActivityIndicator color={colors.surface} />
                ) : (
                  <Text style={styles.buttonText}>保存</Text>
                )}
              </Pressable>
            </View>
          )}
        </View>

        {/* Security Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>安全</Text>

          {passwordChanged && (
            <Text style={styles.successText}>密码修改成功</Text>
          )}

          <Pressable
            style={styles.linkButton}
            onPress={() => toggleSection('password')}
          >
            <Text style={styles.linkButtonText}>
              {activeSection === 'password' ? '取消修改' : '修改密码'}
            </Text>
          </Pressable>

          {activeSection === 'password' && (
            <View style={styles.inlineForm}>
              <View style={styles.field}>
                <Text style={styles.label}>当前密码</Text>
                <Controller
                  name="currentPassword"
                  control={passwordForm.control}
                  render={({ field: { value, onChange, onBlur } }) => (
                    <TextInput
                      style={[
                        styles.input,
                        passwordForm.formState.errors.currentPassword && styles.inputError,
                      ]}
                      value={value}
                      onChangeText={onChange}
                      onBlur={onBlur}
                      secureTextEntry
                    />
                  )}
                />
                {passwordForm.formState.errors.currentPassword && (
                  <Text style={styles.fieldError}>
                    {passwordForm.formState.errors.currentPassword.message}
                  </Text>
                )}
              </View>

              <View style={styles.field}>
                <Text style={styles.label}>新密码</Text>
                <Controller
                  name="newPassword"
                  control={passwordForm.control}
                  render={({ field: { value, onChange, onBlur } }) => (
                    <TextInput
                      style={[
                        styles.input,
                        passwordForm.formState.errors.newPassword && styles.inputError,
                      ]}
                      value={value}
                      onChangeText={onChange}
                      onBlur={onBlur}
                      secureTextEntry
                      placeholder="至少 8 位"
                    />
                  )}
                />
                {passwordForm.formState.errors.newPassword && (
                  <Text style={styles.fieldError}>
                    {passwordForm.formState.errors.newPassword.message}
                  </Text>
                )}
              </View>

              <View style={styles.field}>
                <Text style={styles.label}>确认新密码</Text>
                <Controller
                  name="confirmNewPassword"
                  control={passwordForm.control}
                  render={({ field: { value, onChange, onBlur } }) => (
                    <TextInput
                      style={[
                        styles.input,
                        passwordForm.formState.errors.confirmNewPassword && styles.inputError,
                      ]}
                      value={value}
                      onChangeText={onChange}
                      onBlur={onBlur}
                      secureTextEntry
                      placeholder="至少 8 位"
                    />
                  )}
                />
                {passwordForm.formState.errors.confirmNewPassword && (
                  <Text style={styles.fieldError}>
                    {passwordForm.formState.errors.confirmNewPassword.message}
                  </Text>
                )}
              </View>

              {passwordApiError && (
                <Text style={styles.apiError}>{passwordApiError}</Text>
              )}

              <Pressable
                style={[styles.button, changePassword.isPending && styles.buttonDisabled]}
                onPress={passwordForm.handleSubmit(onSubmitPassword)}
                disabled={changePassword.isPending}
              >
                {changePassword.isPending ? (
                  <ActivityIndicator color={colors.surface} />
                ) : (
                  <Text style={styles.buttonText}>保存</Text>
                )}
              </Pressable>
            </View>
          )}
        </View>

        {/* Account Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>账户</Text>

          <Pressable
            style={[styles.button, styles.buttonOutline, logout.isPending && styles.buttonDisabled]}
            onPress={() => logout.mutate()}
            disabled={logout.isPending}
          >
            {logout.isPending ? (
              <ActivityIndicator color={colors.primary} />
            ) : (
              <Text style={styles.buttonOutlineText}>退出登录</Text>
            )}
          </Pressable>

          <Pressable
            style={[styles.button, styles.buttonDanger, { marginTop: spacing.sm }]}
            onPress={() => setDeleteModalVisible(true)}
          >
            <Text style={styles.buttonText}>注销账户</Text>
          </Pressable>
        </View>
      </ScrollView>

      {/* Delete Account Modal */}
      <Modal
        visible={deleteModalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setDeleteModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>确认注销账户？</Text>
            <Text style={styles.modalBody}>
              此操作不可撤销。根据 GDPR 要求，您的所有数据（包括卡片、好友关系及共享记录）将被永久删除。
            </Text>

            {deleteApiError && (
              <Text style={styles.apiError}>{deleteApiError}</Text>
            )}

            <View style={styles.modalActions}>
              <Pressable
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setDeleteModalVisible(false);
                  deleteAccount.reset();
                }}
                disabled={deleteAccount.isPending}
              >
                <Text style={styles.modalButtonCancelText}>取消</Text>
              </Pressable>

              <Pressable
                style={[
                  styles.modalButton,
                  styles.modalButtonDanger,
                  deleteAccount.isPending && styles.buttonDisabled,
                ]}
                onPress={() => deleteAccount.mutate()}
                disabled={deleteAccount.isPending}
              >
                {deleteAccount.isPending ? (
                  <ActivityIndicator color={colors.surface} />
                ) : (
                  <Text style={styles.buttonText}>永久删除</Text>
                )}
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scroll: {
    padding: spacing.lg,
  },
  pageTitle: {
    fontSize: fontSize.xxl,
    fontWeight: fontWeight.bold,
    color: colors.text,
    marginBottom: spacing.xl,
  },
  section: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.lg,
  },
  sectionTitle: {
    fontSize: fontSize.sm,
    fontWeight: fontWeight.semibold,
    color: colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: spacing.md,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  rowLabel: {
    fontSize: fontSize.md,
    color: colors.textMuted,
  },
  rowValue: {
    fontSize: fontSize.md,
    color: colors.text,
    fontWeight: fontWeight.medium,
  },
  linkButton: {
    marginTop: spacing.md,
  },
  linkButtonText: {
    fontSize: fontSize.sm,
    color: colors.primary,
    fontWeight: fontWeight.medium,
  },
  inlineForm: {
    marginTop: spacing.md,
    paddingTop: spacing.md,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  field: {
    marginBottom: spacing.md,
  },
  label: {
    fontSize: fontSize.sm,
    fontWeight: fontWeight.medium,
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
    backgroundColor: colors.background,
  },
  inputError: {
    borderColor: colors.danger,
  },
  fieldError: {
    fontSize: fontSize.xs,
    color: colors.danger,
    marginTop: 4,
  },
  apiError: {
    fontSize: fontSize.sm,
    color: colors.danger,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  successText: {
    fontSize: fontSize.sm,
    color: colors.success,
    marginBottom: spacing.sm,
  },
  button: {
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: colors.surface,
    fontSize: fontSize.md,
    fontWeight: fontWeight.semibold,
  },
  buttonOutline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: colors.primary,
  },
  buttonOutlineText: {
    color: colors.primary,
    fontSize: fontSize.md,
    fontWeight: fontWeight.semibold,
  },
  buttonDanger: {
    backgroundColor: colors.danger,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.lg,
  },
  modalCard: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    padding: spacing.xl,
    width: '100%',
  },
  modalTitle: {
    fontSize: fontSize.lg,
    fontWeight: fontWeight.bold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  modalBody: {
    fontSize: fontSize.sm,
    color: colors.textMuted,
    lineHeight: 22,
    marginBottom: spacing.lg,
  },
  modalActions: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  modalButton: {
    flex: 1,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: 'center',
  },
  modalButtonCancel: {
    backgroundColor: colors.background,
    borderWidth: 1,
    borderColor: colors.border,
  },
  modalButtonCancelText: {
    color: colors.text,
    fontSize: fontSize.md,
    fontWeight: fontWeight.medium,
  },
  modalButtonDanger: {
    backgroundColor: colors.danger,
  },
});
