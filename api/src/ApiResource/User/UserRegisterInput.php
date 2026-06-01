<?php

declare(strict_types=1);

namespace App\ApiResource\User;

use App\Entity\User;
use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Constraints\PasswordStrength;

#[UniqueEntity(
    fields: ['email'],
    entityClass: User::class,
    errorPath: 'email',
    message: 'This email is already registered.',
)]
#[UniqueEntity(
    fields: ['userName'],
    entityClass: User::class,
    errorPath: 'userName',
    message: 'This username is already taken.',
)]
class UserRegisterInput
{
    #[Assert\NotBlank]
    #[Assert\Email]
    #[Assert\Length(max: 180)]
    public string $email = '';

    #[Assert\NotBlank]
    #[Assert\PasswordStrength(minScore: PasswordStrength::STRENGTH_MEDIUM)]
    public string $password = '';

    #[Assert\NotBlank]
    #[Assert\Length(min: 2, max: 50)]
    public string $userName = '';

    #[Assert\IsTrue(message: 'You must accept the GDPR consent.')]
    public bool $gdprConsent = false;
}
