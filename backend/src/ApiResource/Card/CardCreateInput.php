<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

use App\Enum\BarcodeType;
use Symfony\Component\Validator\Constraints as Assert;

class CardCreateInput
{
    #[Assert\NotBlank]
    #[Assert\Length(max: 255)]
    public string $name = '';

    #[Assert\NotNull]
    public ?BarcodeType $barcodeType = null;

    #[Assert\NotBlank]
    #[Assert\Length(max: 2048)]
    public string $barcodeContent = '';

    public ?\DateTimeImmutable $expiresAt = null;

    #[Assert\Regex(
        pattern: '/^#[0-9A-Fa-f]{6}$/',
        message: 'color must be a #RRGGBB hex string',
    )]
    public ?string $color = null;
}
