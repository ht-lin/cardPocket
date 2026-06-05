<?php

declare(strict_types=1);

namespace App\ApiResource\Friendship;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Post;
use App\State\Processor\FriendSendProcessor;
use App\State\Provider\FriendRequestListProvider;

#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/friendships/requests',
            provider: FriendRequestListProvider::class,
            paginationEnabled: false,
            name: 'api_friendship_requests_list',
        ),
        new Post(
            uriTemplate: '/friendships',
            input: FriendSendInput::class,
            processor: FriendSendProcessor::class,
            status: 201,
            name: 'api_friendship_send',
        ),
    ],
)]
final class FriendRequestOutput
{
    public function __construct(
        public readonly string $id,
        public readonly array $requester,
        public readonly string $status,
        public readonly string $createdAt,
    ) {
    }
}
