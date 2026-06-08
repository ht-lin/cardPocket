import { z } from 'zod';

export const CardShareOutputSchema = z.object({
  id: z.string(),
  viewer: z.object({
    id: z.string(),
    userName: z.string(),
  }),
  viewerNickname: z.string().nullable(),
  createdAt: z.string(),
});
export type CardShareOutput = z.infer<typeof CardShareOutputSchema>;

export const CardShareCreateInputSchema = z.object({
  viewerId: z.string(),
});
export type CardShareCreateInput = z.infer<typeof CardShareCreateInputSchema>;

export const CardShareUpdateInputSchema = z.object({
  viewerNickname: z.string().max(100).nullable(),
});
export type CardShareUpdateInput = z.infer<typeof CardShareUpdateInputSchema>;
