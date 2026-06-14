<?php

declare(strict_types=1);

namespace App\ApiResource\CardShare;

use Symfony\Component\Validator\Constraints as Assert;

final class CardShareUpdateInput
{
    #[Assert\Length(max: 255)]
    public ?string $viewerNickname = null;
}
