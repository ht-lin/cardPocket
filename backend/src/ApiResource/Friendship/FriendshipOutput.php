<?php

declare(strict_types=1);

namespace App\ApiResource\Friendship;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Delete;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use App\Routing\ApiRequirement;
use App\State\Processor\FriendAcceptProcessor;
use App\State\Processor\FriendDeleteProcessor;
use App\State\Provider\FriendshipListProvider;
use App\State\Provider\FriendshipViewProvider;

#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/friendships',
            provider: FriendshipListProvider::class,
            paginationEnabled: false,
            name: 'api_friendship_list',
        ),
        new Patch(
            uriTemplate: '/friendships/{id}/accept',
            requirements: ['id' => ApiRequirement::UUID],
            inputFormats: ['json' => ['application/json']],
            input: false,
            provider: FriendshipViewProvider::class,
            processor: FriendAcceptProcessor::class,
            name: 'api_friendship_accept',
        ),
        new Delete(
            uriTemplate: '/friendships/{id}',
            requirements: ['id' => ApiRequirement::UUID],
            output: false,
            status: 204,
            provider: FriendshipViewProvider::class,
            processor: FriendDeleteProcessor::class,
            name: 'api_friendship_delete',
        ),
    ],
)]
final class FriendshipOutput
{
    public function __construct(
        public readonly string $id,
        public readonly array $friend,
        public readonly string $status,
        public readonly string $createdAt,
    ) {
    }
}
