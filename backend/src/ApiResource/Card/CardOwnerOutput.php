<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Delete;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Post;
use App\State\Processor\CardCreateProcessor;
use App\State\Processor\CardDeleteProcessor;
use App\State\Processor\CardPermanentDeleteProcessor;
use App\State\Processor\CardRestoreProcessor;
use App\State\Processor\CardUpdateProcessor;
use App\Routing\ApiRequirement;
use App\State\Provider\CardListProvider;
use App\State\Provider\CardTrashItemProvider;
use App\State\Provider\CardViewProvider;

#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/cards',
            provider: CardListProvider::class,
            name: 'api_cards_list',
        ),
        new Post(
            uriTemplate: '/cards',
            input: CardCreateInput::class,
            processor: CardCreateProcessor::class,
            status: 201,
            name: 'api_cards_create',
        ),
        new Get(
            uriTemplate: '/cards/{id}',
            requirements: ['id' => ApiRequirement::UUID],
            provider: CardViewProvider::class,
            name: 'api_cards_get',
        ),
        new Patch(
            uriTemplate: '/cards/{id}',
            requirements: ['id' => ApiRequirement::UUID],
            inputFormats: ['json' => ['application/json']],
            input: CardUpdateInput::class,
            provider: CardViewProvider::class,
            processor: CardUpdateProcessor::class,
            name: 'api_cards_update',
        ),
        new Delete(
            uriTemplate: '/cards/{id}',
            requirements: ['id' => ApiRequirement::UUID],
            output: false,
            status: 204,
            provider: CardViewProvider::class,
            processor: CardDeleteProcessor::class,
            name: 'api_cards_delete',
        ),
        new Post(
            uriTemplate: '/cards/{id}/restore',
            requirements: ['id' => ApiRequirement::UUID],
            input: false,
            read: true,
            provider: CardTrashItemProvider::class,
            processor: CardRestoreProcessor::class,
            name: 'api_cards_restore',
        ),
        new Delete(
            uriTemplate: '/cards/{id}/permanent',
            requirements: ['id' => ApiRequirement::UUID],
            output: false,
            status: 204,
            provider: CardTrashItemProvider::class,
            processor: CardPermanentDeleteProcessor::class,
            name: 'api_cards_permanent_delete',
        ),
    ],
)]
final class CardOwnerOutput
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly string $barcodeType,
        public readonly string $barcodeContent,
        public readonly bool $isOwner,
        public readonly string $createdAt,
        public readonly string $updatedAt,
        public readonly ?string $expiresAt,
        public readonly ?string $color,
    ) {
    }
}
