<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use App\Enum\PushPlatform;
use Symfony\Component\Validator\Constraints as Assert;

final class PushTokenInput
{
    #[Assert\NotBlank]
    #[Assert\Length(max: 512)]
    public string $fcmToken = '';

    #[Assert\NotBlank]
    #[Assert\Choice(callback: [PushPlatform::class, 'values'], message: 'Invalid platform.')]
    public string $platform = '';
}
