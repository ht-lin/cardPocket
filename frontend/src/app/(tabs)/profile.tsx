import { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Modal,
  StyleSheet,
} from 'react-native';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAuthContext } from '@/context/AuthContext';
import { getMe, updateMe } from '@/services/userService';
import {
  updateUserNameSchema,
  type UpdateUserNameFormData,
  changePasswordSchema,
  type ChangePasswordFormData,
} from '@/schemas/auth';
import type { ApiValidationError } from '@/types/api';

export default function ProfileScreen() {
  const auth = useAuthContext();
  const queryClient = useQueryClient();
  const [userNameModalVisible, setUserNameModalVisible] = useState(false);
  const [passwordModalVisible, setPasswordModalVisible] = useState(false);

  const { data: user, isLoading, isError } = useQuery({
    queryKey: ['users', 'me'],
    queryFn: () => getMe(auth),
  });

  return (
    <View style={styles.container}>
      <View style={styles.info}>
        {isLoading && <ActivityIndicator size="large" />}
        {isError && <Text style={styles.loadError}>加载失败，请重试</Text>}
        {user && (
          <>
            <Text style={styles.userName}>{user.userName}</Text>
            <Text style={styles.email}>{user.email}</Text>
          </>
        )}
      </View>

      <View style={styles.actions}>
        <TouchableOpacity style={styles.button} onPress={() => setUserNameModalVisible(true)}>
          <Text style={styles.buttonText}>修改用户名</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button} onPress={() => setPasswordModalVisible(true)}>
          <Text style={styles.buttonText}>修改密码</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.button, styles.dangerButton]}>
          <Text style={[styles.buttonText, styles.dangerText]}>注销账户</Text>
        </TouchableOpacity>
      </View>

      <UpdateUserNameModal
        visible={userNameModalVisible}
        onClose={() => setUserNameModalVisible(false)}
        onSuccess={async () => {
          await queryClient.invalidateQueries({ queryKey: ['users', 'me'] });
          setUserNameModalVisible(false);
        }}
        auth={auth}
      />

      <ChangePasswordModal
        visible={passwordModalVisible}
        onClose={() => setPasswordModalVisible(false)}
        auth={auth}
      />
    </View>
  );
}

type UpdateUserNameModalProps = {
  visible: boolean;
  onClose: () => void;
  onSuccess: () => Promise<void>;
  auth: ReturnType<typeof useAuthContext>;
};

function UpdateUserNameModal({ visible, onClose, onSuccess, auth }: UpdateUserNameModalProps) {
  const [globalError, setGlobalError] = useState<string | null>(null);
  const {
    control,
    handleSubmit,
    setError,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<UpdateUserNameFormData>({
    resolver: zodResolver(updateUserNameSchema),
  });

  const handleClose = () => {
    reset();
    setGlobalError(null);
    onClose();
  };

  const onSubmit = async (data: UpdateUserNameFormData) => {
    setGlobalError(null);
    try {
      await updateMe(auth, { userName: data.userName });
      reset();
      await onSuccess();
    } catch (err) {
      if (err instanceof Response && err.status === 422) {
        const body: ApiValidationError = await err.json();
        let hasFieldError = false;
        body.violations?.forEach((v) => {
          if (v.propertyPath === 'userName') {
            setError('userName', { message: v.message });
            hasFieldError = true;
          }
        });
        if (!hasFieldError) setGlobalError('操作失败，请检查输入内容');
      } else {
        setGlobalError('操作失败，请稍后重试');
      }
    }
  };

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={handleClose}>
      <View style={styles.overlay}>
        <View style={styles.sheet}>
          <Text style={styles.sheetTitle}>修改用户名</Text>

          <View style={styles.field}>
            <Text style={styles.label}>新用户名</Text>
            <Controller
              control={control}
              name="userName"
              render={({ field: { onChange, onBlur, value } }) => (
                <TextInput
                  style={[styles.input, errors.userName && styles.inputError]}
                  onChangeText={onChange}
                  onBlur={onBlur}
                  value={value}
                  autoCapitalize="none"
                  autoCorrect={false}
                  placeholder="输入新用户名"
                />
              )}
            />
            {errors.userName ? (
              <Text style={styles.fieldError}>{errors.userName.message}</Text>
            ) : null}
          </View>

          {globalError ? <Text style={styles.fieldError}>{globalError}</Text> : null}

          <TouchableOpacity
            style={[styles.button, styles.submitButton, isSubmitting && styles.buttonDisabled]}
            onPress={handleSubmit(onSubmit)}
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.submitText}>保存</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity style={styles.cancelButton} onPress={handleClose}>
            <Text style={styles.buttonText}>取消</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

type ChangePasswordModalProps = {
  visible: boolean;
  onClose: () => void;
  auth: ReturnType<typeof useAuthContext>;
};

function ChangePasswordModal({ visible, onClose, auth }: ChangePasswordModalProps) {
  const [globalError, setGlobalError] = useState<string | null>(null);
  const {
    control,
    handleSubmit,
    setError,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<ChangePasswordFormData>({
    resolver: zodResolver(changePasswordSchema),
  });

  const handleClose = () => {
    reset();
    setGlobalError(null);
    onClose();
  };

  const onSubmit = async (data: ChangePasswordFormData) => {
    setGlobalError(null);
    try {
      await updateMe(auth, { currentPassword: data.currentPassword, newPassword: data.newPassword });
      reset();
      onClose();
    } catch (err) {
      if (err instanceof Response && err.status === 422) {
        const body: ApiValidationError = await err.json();
        let hasFieldError = false;
        body.violations?.forEach((v) => {
          if (v.propertyPath === 'currentPassword') {
            setError('currentPassword', { message: v.message });
            hasFieldError = true;
          } else if (v.propertyPath === 'newPassword') {
            setError('newPassword', { message: v.message });
            hasFieldError = true;
          }
        });
        if (!hasFieldError) setGlobalError('操作失败，请检查输入内容');
      } else {
        setGlobalError('操作失败，请稍后重试');
      }
    }
  };

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={handleClose}>
      <View style={styles.overlay}>
        <View style={styles.sheet}>
          <Text style={styles.sheetTitle}>修改密码</Text>

          <View style={styles.field}>
            <Text style={styles.label}>当前密码</Text>
            <Controller
              control={control}
              name="currentPassword"
              render={({ field: { onChange, onBlur, value } }) => (
                <TextInput
                  style={[styles.input, errors.currentPassword && styles.inputError]}
                  onChangeText={onChange}
                  onBlur={onBlur}
                  value={value}
                  secureTextEntry
                  placeholder="输入当前密码"
                />
              )}
            />
            {errors.currentPassword ? (
              <Text style={styles.fieldError}>{errors.currentPassword.message}</Text>
            ) : null}
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>新密码</Text>
            <Controller
              control={control}
              name="newPassword"
              render={({ field: { onChange, onBlur, value } }) => (
                <TextInput
                  style={[styles.input, errors.newPassword && styles.inputError]}
                  onChangeText={onChange}
                  onBlur={onBlur}
                  value={value}
                  secureTextEntry
                  placeholder="至少 8 个字符"
                />
              )}
            />
            {errors.newPassword ? (
              <Text style={styles.fieldError}>{errors.newPassword.message}</Text>
            ) : null}
          </View>

          {globalError ? <Text style={styles.fieldError}>{globalError}</Text> : null}

          <TouchableOpacity
            style={[styles.button, styles.submitButton, isSubmitting && styles.buttonDisabled]}
            onPress={handleSubmit(onSubmit)}
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.submitText}>保存</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity style={styles.cancelButton} onPress={handleClose}>
            <Text style={styles.buttonText}>取消</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  info: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  userName: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  email: {
    fontSize: 14,
    color: '#666',
  },
  loadError: {
    color: '#dc2626',
  },
  actions: {
    gap: 12,
  },
  button: {
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#d1d5db',
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 16,
    color: '#111827',
  },
  dangerButton: {
    borderColor: '#dc2626',
  },
  dangerText: {
    color: '#dc2626',
  },
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
    justifyContent: 'flex-end',
  },
  sheet: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    padding: 24,
    gap: 16,
  },
  sheetTitle: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  field: {
    gap: 4,
  },
  label: {
    fontSize: 14,
    color: '#374151',
  },
  input: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 12,
    fontSize: 16,
  },
  inputError: {
    borderColor: '#dc2626',
  },
  fieldError: {
    fontSize: 12,
    color: '#dc2626',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  submitButton: {
    backgroundColor: '#111827',
    borderColor: '#111827',
  },
  submitText: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '600',
  },
  cancelButton: {
    paddingVertical: 14,
    alignItems: 'center',
  },
});
