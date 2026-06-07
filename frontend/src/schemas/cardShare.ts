import { z } from 'zod';

export const CardShareOutputSchema = z.object({
  id: z.string(),
  cardId: z.string(),
  viewerId: z.string(),
  viewerNickname: z.string().nullable(),
  sharedAt: z.string(),
  updatedAt: z.string(),
});
export type CardShareOutput = z.infer<typeof CardShareOutputSchema>;

export const CardShareCreateInputSchema = z.object({
  viewerEmail: z.string().email(),
});
export type CardShareCreateInput = z.infer<typeof CardShareCreateInputSchema>;

export const CardShareUpdateInputSchema = z.object({
  viewerNickname: z.string().max(100).nullable(),
});
export type CardShareUpdateInput = z.infer<typeof CardShareUpdateInputSchema>;
