<?php

declare(strict_types=1);

namespace App\ApiResource\User;

use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Constraints\PasswordStrength;

class UserUpdateInput
{
    #[Assert\Length(min: 2, max: 50)]
    public ?string $userName = null;

    public ?string $currentPassword = null;

    #[Assert\PasswordStrength(
        minScore: PasswordStrength::STRENGTH_MEDIUM,
        message: 'The password is too weak. Try a longer password or mix in numbers, symbols, and upper/lower case letters.',
    )]
    public ?string $newPassword = null;

    #[Assert\IsTrue(message: 'Current password is required to change your password.')]
    public function isCurrentPasswordProvidedWhenChangingPassword(): bool
    {
        return $this->newPassword === null || $this->currentPassword !== null;
    }
}
