<?php

declare(strict_types=1);

namespace App\ApiResource\User;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\State\Processor\UserRegisterProcessor;

#[ApiResource(
    operations: [
        new Post(
            uriTemplate: '/auth/register',
            input: UserRegisterInput::class,
            processor: UserRegisterProcessor::class,
            status: 201,
            name: 'api_auth_register',
        ),
    ],
)]
final class UserRegisterOutput
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
