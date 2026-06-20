<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

use Symfony\Component\Validator\Constraints as Assert;

class CardUpdateInput
{
    #[Assert\Length(max: 255)]
    public ?string $name = null;

    // Nullable: send a value to set the expiry, or explicit null to clear it.
    // The processor distinguishes "key omitted" (keep) from "null" (clear) via the raw payload.
    public ?\DateTimeImmutable $expiresAt = null;
    // barcodeType and barcodeContent are intentionally absent — silently ignored if sent
}
