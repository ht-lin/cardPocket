<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\State\Processor\LoginProcessor;

#[ApiResource(
    operations: [
        new Post(
            uriTemplate: '/auth/login',
            input: LoginInput::class,
            processor: LoginProcessor::class,
            status: 200,
            name: 'api_auth_login',
        ),
    ],
)]
final class LoginOutput
{
    public function __construct(
        public readonly string $access_token,
        public readonly string $refresh_token,
        public readonly string $token_type,
        public readonly int $expires_in,
    ) {
    }
}
