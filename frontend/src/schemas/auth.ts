import { z } from 'zod';

export const LoginInputSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
export type LoginInput = z.infer<typeof LoginInputSchema>;

export const RegisterInputSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  userName: z.string().min(3).max(50),
  gdprConsent: z.literal(true),
});
export type RegisterInput = z.infer<typeof RegisterInputSchema>;

export const AuthResponseSchema = z.object({
  access_token: z.string(),
  refresh_token: z.string(),
  token_type: z.string(),
  expires_in: z.number(),
});
export type AuthResponse = z.infer<typeof AuthResponseSchema>;

export const RefreshResponseSchema = z.object({
  access_token: z.string(),
  refresh_token: z.string(),
  expires_in: z.number(),
});
export type RefreshResponse = z.infer<typeof RefreshResponseSchema>;

export const UserOutputSchema = z.object({
  id: z.string(),
  email: z.string(),
  userName: z.string(),
  emailVerifiedAt: z.string().nullable(),
});
export type UserOutput = z.infer<typeof UserOutputSchema>;

export const UserUpdateInputSchema = z.object({
  userName: z.string().min(3).max(50).optional(),
  currentPassword: z.string().optional(),
  newPassword: z.string().min(8).optional(),
});
export type UserUpdateInput = z.infer<typeof UserUpdateInputSchema>;

export const UserSearchOutputSchema = z.object({
  id: z.string(),
  userName: z.string(),
});
export type UserSearchOutput = z.infer<typeof UserSearchOutputSchema>;
