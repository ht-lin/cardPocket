<?php

declare(strict_types=1);

namespace App\ApiResource\User;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\GetCollection;
use App\State\Provider\UserSearchProvider;

#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/users/search',
            provider: UserSearchProvider::class,
            paginationEnabled: false,
            name: 'api_users_search',
        ),
    ],
)]
final class UserSearchOutput
{
    public function __construct(
        public readonly string $id,
        public readonly string $userName,
    ) {
    }
}
