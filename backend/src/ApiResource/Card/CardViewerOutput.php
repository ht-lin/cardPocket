<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

final readonly class CardViewerOutput
{
    public function __construct(
        public string $id,
        public string $name,
        public string $barcodeType,
        public string $barcodeContent,
        public bool $isOwner,
        public ?string $viewerNickname,
        public string $createdAt,
        public string $updatedAt,
    ) {
    }
}
