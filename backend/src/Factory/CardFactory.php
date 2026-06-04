<?php

declare(strict_types=1);

namespace App\Factory;

use App\Entity\Card;
use App\Enum\BarcodeType;
use Zenstruck\Foundry\Persistence\PersistentObjectFactory;

/**
 * @extends PersistentObjectFactory<Card>
 */
final class CardFactory extends PersistentObjectFactory
{
    public static function class(): string
    {
        return Card::class;
    }

    protected function defaults(): array|callable
    {
        return [
            'name'           => self::faker()->words(3, true),
            'barcodeType'    => BarcodeType::QR_CODE,
            'barcodeContent' => self::faker()->uuid(),
            'owner'          => UserFactory::new(),
        ];
    }

    protected function initialize(): static
    {
        return $this;
    }
}
