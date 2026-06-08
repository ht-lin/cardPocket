import type { CardOwnerOutput, CardViewerOutput } from '@/schemas/card';
import type { CardRow } from '@/lib/storage/db';

export function toCardRow(card: CardOwnerOutput): CardRow {
  return {
    id: card.id,
    name: card.name,
    barcode_type: card.barcodeType,
    barcode_content: card.barcodeContent,
    color: card.color ?? null,
    gradient: card.gradient ? JSON.stringify(card.gradient) : null,
    icon: card.icon ?? null,
    expires_at: card.expiresAt ?? null,
    archived_at: card.archivedAt ?? null,
    created_at: card.createdAt ?? card.updatedAt,
    updated_at: card.updatedAt,
    is_shared: 0,
    share_id: null,
    viewer_nickname: null,
  };
}

export function toViewerCardRow(card: CardViewerOutput): CardRow {
  return {
    id: card.id,
    name: card.name,
    barcode_type: card.barcodeType,
    barcode_content: card.barcodeContent,
    color: card.color ?? null,
    gradient: card.gradient ? JSON.stringify(card.gradient) : null,
    icon: card.icon ?? null,
    expires_at: card.expiresAt ?? null,
    archived_at: card.archivedAt ?? null,
    created_at: card.createdAt ?? card.updatedAt,
    updated_at: card.updatedAt,
    is_shared: 1,
    share_id: card.shareId,
    viewer_nickname: card.viewerNickname,
  };
}
