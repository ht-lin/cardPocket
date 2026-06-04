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
    ) {
    }
}
