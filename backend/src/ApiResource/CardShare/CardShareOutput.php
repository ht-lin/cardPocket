<?php

declare(strict_types=1);

namespace App\ApiResource\CardShare;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Delete;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Link;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Post;
use App\Entity\Card;
use App\State\Processor\CardShareCreateProcessor;
use App\State\Processor\CardShareDeleteProcessor;
use App\State\Processor\CardShareUpdateProcessor;
use App\State\Provider\CardShareListProvider;
use App\State\Provider\CardShareViewProvider;

#[ApiResource(
    normalizationContext: ['skip_null_values' => false],
    operations: [
        new GetCollection(
            uriTemplate: '/cards/{cardId}/shares',
            uriVariables: [
                'cardId' => new Link(fromClass: Card::class, identifiers: ['id']),
            ],
            provider: CardShareListProvider::class,
            paginationEnabled: false,
            name: 'api_card_share_list',
        ),
        new Post(
            uriTemplate: '/cards/{cardId}/shares',
            uriVariables: [
                'cardId' => new Link(fromClass: Card::class, identifiers: ['id']),
            ],
            input: CardShareCreateInput::class,
            status: 201,
            processor: CardShareCreateProcessor::class,
            name: 'api_card_share_create',
        ),
        new Patch(
            uriTemplate: '/card-shares/{id}',
            inputFormats: ['json' => ['application/json']],
            input: CardShareUpdateInput::class,
            provider: CardShareViewProvider::class,
            processor: CardShareUpdateProcessor::class,
            name: 'api_card_share_update',
        ),
        new Delete(
            uriTemplate: '/card-shares/{id}',
            output: false,
            status: 204,
            provider: CardShareViewProvider::class,
            processor: CardShareDeleteProcessor::class,
            name: 'api_card_share_delete',
        ),
    ]
)]
final class CardShareOutput
{
    public function __construct(
        public readonly string $id,
        public readonly array $viewer,
        public readonly ?string $viewerNickname,
        public readonly string $createdAt,
    ) {
    }
}
