<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\State\Processor\LogoutProcessor;

#[ApiResource(
    operations: [
        new Post(
            uriTemplate: '/auth/logout',
            input: LogoutInput::class,
            output: false,
            processor: LogoutProcessor::class,
            status: 204,
            name: 'api_auth_logout',
        ),
    ],
)]
final class LogoutOutput
{
}
