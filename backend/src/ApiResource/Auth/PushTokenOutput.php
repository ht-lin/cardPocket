<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\State\Processor\PushTokenRegisterProcessor;

#[ApiResource(
    operations: [
        // Idempotent device-token registration (upsert by fcmToken): always 200.
        new Post(
            uriTemplate: '/auth/push-token',
            input: PushTokenInput::class,
            output: false,
            processor: PushTokenRegisterProcessor::class,
            status: 200,
            name: 'api_auth_push_token',
        ),
    ],
)]
final class PushTokenOutput
{
}
