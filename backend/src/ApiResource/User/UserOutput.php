<?php

declare(strict_types=1);

namespace App\ApiResource\User;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\Patch;
use App\State\Processor\UserUpdateProcessor;
use App\State\Provider\UserMeProvider;

#[ApiResource(
    operations: [
        new Get(
            uriTemplate: '/users/me',
            provider: UserMeProvider::class,
            name: 'api_users_me',
        ),
        new Patch(
            uriTemplate: '/users/me',
            inputFormats: ['json' => ['application/json']],
            input: UserUpdateInput::class,
            processor: UserUpdateProcessor::class,
            name: 'api_users_me_update',
        ),
    ],
)]
final class UserOutput
{
    public function __construct(
        public readonly string $id,
        public readonly string $email,
        public readonly string $userName,
        public readonly bool $emailVerified,
        public readonly string $createdAt,
    ) {
    }
}
