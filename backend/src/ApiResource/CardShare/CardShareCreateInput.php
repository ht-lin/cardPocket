<?php

declare(strict_types=1);

namespace App\ApiResource\CardShare;

use Symfony\Component\Validator\Constraints as Assert;

final class CardShareCreateInput
{
    #[Assert\NotBlank]
    #[Assert\Uuid]
    public string $viewerId = '';
}
