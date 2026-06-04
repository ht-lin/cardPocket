<?php

declare(strict_types=1);

namespace App\ApiResource\Auth;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Post;
use App\State\Processor\ResendVerificationProcessor;

#[ApiResource(
    operations: [
        new Post(
            uriTemplate: '/auth/resend-verification',
            input: ResendVerificationInput::class,
            output: false,
            processor: ResendVerificationProcessor::class,
            status: 200,
            name: 'api_auth_resend_verification',
        ),
    ],
)]
final class ResendVerificationOutput
{
}
