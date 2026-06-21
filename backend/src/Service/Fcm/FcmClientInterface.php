<?php

declare(strict_types=1);

namespace App\Service\Fcm;

use App\Entity\PushToken;

interface FcmClientInterface
{
    /**
     * @param array<string, string> $data
     */
    public function send(PushToken $token, string $title, string $body, array $data = []): FcmSendResult;
}
