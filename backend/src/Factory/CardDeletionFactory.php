<?php

declare(strict_types=1);

namespace App\Factory;

use App\Entity\CardDeletion;
use Symfony\Component\Uid\Uuid;
use Zenstruck\Foundry\Persistence\PersistentObjectFactory;

/**
 * @extends PersistentObjectFactory<CardDeletion>
 */
final class CardDeletionFactory extends PersistentObjectFactory
{
    public static function class(): string
    {
        return CardDeletion::class;
    }

    protected function defaults(): array|callable
    {
        return [
            'userId' => Uuid::v4()->toString(),
            'cardId' => Uuid::v4()->toString(),
        ];
    }

    protected function initialize(): static
    {
        return $this;
    }
}
