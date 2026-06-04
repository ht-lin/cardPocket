<?php

declare(strict_types=1);

namespace App\Factory;

use App\Entity\CardShare;
use Zenstruck\Foundry\Persistence\PersistentObjectFactory;

/**
 * @extends PersistentObjectFactory<CardShare>
 */
final class CardShareFactory extends PersistentObjectFactory
{
    public static function class(): string
    {
        return CardShare::class;
    }

    protected function defaults(): array|callable
    {
        return [
            'card'            => CardFactory::new(),
            'viewer'          => UserFactory::new(),
            'viewerNickname'  => null,
        ];
    }

    protected function initialize(): static
    {
        return $this;
    }
}
