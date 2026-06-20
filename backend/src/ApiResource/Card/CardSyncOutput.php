<?php

declare(strict_types=1);

namespace App\ApiResource\Card;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use App\State\Provider\CardSyncProvider;

#[ApiResource(
    operations: [
        // Incremental sync delta document. Modeled as a single-resource `Get`
        // (not a collection) so its `updated`/`deleted` arrays serialize as flat
        // JSON-LD arrays instead of nested Hydra collections (`member[]`).
        new Get(
            uriTemplate: '/cards/sync',
            provider: CardSyncProvider::class,
            read: true,
            name: 'api_cards_sync',
        ),
    ],
)]
final class CardSyncOutput
{
    public function __construct(
        // Plain associative arrays (not the resource DTOs) so the JSON-LD item
        // normalizer serializes them inline as flat objects, instead of treating
        // them as related resources and emitting IRIs / failing to resolve a
        // resource class. Shape mirrors CardOwnerOutput / CardViewerOutput.
        /** @var list<array<string, mixed>> */
        public readonly array $updated,
        /** @var string[] */
        public readonly array $deleted,
        // Server-side high-water mark; the client must send this back as `updatedAfter`
        // next time so sync no longer depends on the (possibly skewed) client clock.
        public readonly string $syncedAt,
    ) {
    }
}
