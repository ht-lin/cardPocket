<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\State\Processor\VerifyEmailProcessor;

#[ApiResource(
    operations: [
        new Post(
            uriTemplate: '/auth/verify-email',
            input: VerifyEmailInput::class,
            processor: VerifyEmailProcessor::class,
            status: 200,
            name: 'api_auth_verify_email',
        ),
    ],
)]
final class VerifyEmailOutput
{
    public function __construct(
        public readonly string $message,
    ) {
    }
}
