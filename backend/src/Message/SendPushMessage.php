<?php

declare(strict_types=1);

namespace App\Message;

/**
 * Dispatched when an event should notify a user's devices. Routed async (see messenger.yaml);
 * consumed by SendPushHandler which fans out to the user's active FCM tokens.
 */
final readonly class SendPushMessage
{
    /**
     * @param array<string, string> $data
     */
    public function __construct(
        public string $userId,
        public string $title,
        public string $body,
        public array $data = [],
    ) {
    }
}
