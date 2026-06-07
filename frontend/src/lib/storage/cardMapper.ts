import type { CardOwnerOutput } from '@/schemas/card';
import type { CardRow } from '@/lib/storage/db';

export function toCardRow(card: CardOwnerOutput): CardRow {
  return {
    id: card.id,
    name: card.name,
    barcode_type: card.barcodeType,
    barcode_content: card.barcodeContent,
    color: card.color,
    gradient: card.gradient ? JSON.stringify(card.gradient) : null,
    icon: card.icon,
    expires_at: card.expiresAt,
    archived_at: card.archivedAt,
    created_at: card.createdAt,
    updated_at: card.updatedAt,
    is_shared: 0,
    viewer_nickname: null,
  };
}
