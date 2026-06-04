<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

use Symfony\Component\Validator\Constraints as Assert;

class CardUpdateInput
{
    #[Assert\Length(max: 255)]
    public ?string $name = null;
    // barcodeType and barcodeContent are intentionally absent — silently ignored if sent
}
