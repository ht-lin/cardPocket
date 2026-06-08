import { z } from 'zod';

export const BarcodeTypeSchema = z.enum([
  'QR_CODE',
  'CODE_128',
  'EAN_13',
  'CODE_39',
  'PDF_417',
  'AZTEC',
  'EAN_8',
  'UPC_A',
  'DATA_MATRIX',
]);
export type BarcodeType = z.infer<typeof BarcodeTypeSchema>;

export const CardOwnerOutputSchema = z.object({
  id: z.string(),
  name: z.string(),
  barcodeType: BarcodeTypeSchema,
  barcodeContent: z.string(),
  isOwner: z.literal(true),
  color: z.string().nullable().optional(),
  gradient: z.unknown().nullable().optional(),
  icon: z.string().nullable().optional(),
  expiresAt: z.string().nullable().optional(),
  archivedAt: z.string().nullable().optional(),
  createdAt: z.string().optional(),
  updatedAt: z.string(),
});
export type CardOwnerOutput = z.infer<typeof CardOwnerOutputSchema>;

export const CardViewerOutputSchema = z.object({
  id: z.string(),
  name: z.string(),
  barcodeType: BarcodeTypeSchema,
  barcodeContent: z.string(),
  isOwner: z.literal(false),
  shareId: z.string(),
  viewerNickname: z.string().nullable(),
  color: z.string().nullable().optional(),
  gradient: z.unknown().nullable().optional(),
  icon: z.string().nullable().optional(),
  expiresAt: z.string().nullable().optional(),
  archivedAt: z.string().nullable().optional(),
  createdAt: z.string().optional(),
  updatedAt: z.string(),
});
export type CardViewerOutput = z.infer<typeof CardViewerOutputSchema>;

export const CardCreateInputSchema = z.object({
  name: z.string().min(1).max(200),
  barcodeType: BarcodeTypeSchema,
  barcodeContent: z.string().min(1),
  color: z.string().max(7).nullable().optional(),
  icon: z.string().max(50).nullable().optional(),
});
export type CardCreateInput = z.infer<typeof CardCreateInputSchema>;

export const CardUpdateInputSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  color: z.string().max(7).nullable().optional(),
  icon: z.string().max(50).nullable().optional(),
});
export type CardUpdateInput = z.infer<typeof CardUpdateInputSchema>;
