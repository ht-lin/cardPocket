<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use Symfony\Component\Validator\Constraints as Assert;

final class ResendVerificationInput
{
    #[Assert\NotBlank]
    #[Assert\Email]
    public string $email = '';
}
