<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\GetCollection;
use App\State\Provider\CardTrashListProvider;

/**
 * Trash listing of the caller's own soft-deleted cards.
 *
 * Same shape as {@see CardOwnerOutput} plus `deletedAt`. Owner-only: shared
 * cards never appear in anyone's trash.
 */
#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/cards/trash',
            provider: CardTrashListProvider::class,
            name: 'api_cards_trash_list',
        ),
    ],
)]
final class CardTrashOutput
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly string $barcodeType,
        public readonly string $barcodeContent,
        public readonly bool $isOwner,
        public readonly string $createdAt,
        public readonly string $updatedAt,
        public readonly ?string $expiresAt,
        public readonly ?string $color,
        public readonly string $deletedAt,
    ) {
    }
}
