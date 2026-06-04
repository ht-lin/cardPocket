<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use Symfony\Component\Validator\Constraints as Assert;

final class LogoutInput
{
    #[Assert\NotBlank]
    public string $refresh_token = '';
}
