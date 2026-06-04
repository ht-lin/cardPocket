<?php

declare(strict_types=1);

namespace App\Factory;

use App\Entity\EmailVerificationToken;
use Zenstruck\Foundry\Persistence\PersistentObjectFactory;

/**
 * @extends PersistentObjectFactory<EmailVerificationToken>
 */
final class EmailVerificationTokenFactory extends PersistentObjectFactory
{
    public static function class(): string
    {
        return EmailVerificationToken::class;
    }

    protected function defaults(): array|callable
    {
        return [
            'token' => bin2hex(random_bytes(16)),
            'expiresAt' => new \DateTimeImmutable('+24 hours'),
            'usedAt' => null,
            'user' => UserFactory::new(),
        ];
    }

    protected function initialize(): static
    {
        return $this;
    }
}
