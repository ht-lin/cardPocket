<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

final class CardSyncOutput
{
    public function __construct(
        /** @var array<CardOwnerOutput|CardViewerOutput> */
        public readonly array $updated,
        /** @var string[] */
        public readonly array $deleted,
        // Server-side high-water mark; the client must send this back as `updatedAfter`
        // next time so sync no longer depends on the (possibly skewed) client clock.
        public readonly string $syncedAt,
    ) {
    }
}
