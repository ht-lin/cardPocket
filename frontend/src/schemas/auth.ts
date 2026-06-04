import { z } from 'zod';

export const registerSchema = z.object({
  email: z.string().email('请输入有效的邮箱地址'),
  password: z.string().min(8, '密码至少 8 个字符'),
  userName: z
    .string()
    .min(2, '用户名至少 2 个字符')
    .max(50, '用户名不超过 50 个字符'),
  gdprConsent: z.literal(true, {
    error: () => ({ message: '请同意隐私政策与服务条款' }),
  }),
});

export type RegisterFormData = z.infer<typeof registerSchema>;
