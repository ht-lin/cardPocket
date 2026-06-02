<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use Symfony\Component\Validator\Constraints as Assert;

final class VerifyEmailInput
{
    #[Assert\NotBlank]
    public string $token = '';
}
