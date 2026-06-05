<?php

declare(strict_types=1);

namespace App\Factory;

use App\Entity\Friendship;
use App\Enum\FriendshipStatus;
use Zenstruck\Foundry\Persistence\PersistentObjectFactory;

/**
 * @extends PersistentObjectFactory<Friendship>
 */
final class FriendshipFactory extends PersistentObjectFactory
{
    public static function class(): string
    {
        return Friendship::class;
    }

    protected function defaults(): array|callable
    {
        return [
            'requester' => UserFactory::new(),
            'addressee' => UserFactory::new(),
            'status'    => FriendshipStatus::PENDING,
        ];
    }

    protected function initialize(): static
    {
        return $this;
    }
}
