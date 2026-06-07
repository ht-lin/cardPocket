import { z } from 'zod';

export const FriendshipStatusSchema = z.enum(['PENDING', 'ACCEPTED', 'REJECTED']);
export type FriendshipStatus = z.infer<typeof FriendshipStatusSchema>;

export const FriendshipOutputSchema = z.object({
  id: z.string(),
  requesterId: z.string(),
  addresseeId: z.string(),
  requesterUserName: z.string().optional(),
  addresseeUserName: z.string().optional(),
  status: FriendshipStatusSchema,
  createdAt: z.string(),
  updatedAt: z.string(),
});
export type FriendshipOutput = z.infer<typeof FriendshipOutputSchema>;

export const FriendshipCreateInputSchema = z.object({
  addresseeEmail: z.string().email(),
});
export type FriendshipCreateInput = z.infer<typeof FriendshipCreateInputSchema>;
