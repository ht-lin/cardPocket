<?php

declare(strict_types=1);

namespace App\Factory;

use App\Entity\PushToken;
use App\Enum\PushPlatform;
use Zenstruck\Foundry\Persistence\PersistentObjectFactory;

/**
 * @extends PersistentObjectFactory<PushToken>
 */
final class PushTokenFactory extends PersistentObjectFactory
{
    public static function class(): string
    {
        return PushToken::class;
    }

    protected function defaults(): array|callable
    {
        return [
            'user'     => UserFactory::new(),
            'fcmToken' => self::faker()->unique()->sha256(),
            'platform' => PushPlatform::ANDROID,
            'isActive' => true,
        ];
    }

    protected function initialize(): static
    {
        return $this;
    }
}
