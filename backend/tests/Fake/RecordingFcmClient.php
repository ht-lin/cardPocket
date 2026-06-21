<?php

declare(strict_types=1);

namespace App\Tests\Fake;

use App\Entity\PushToken;
use App\Service\Fcm\FcmClientInterface;
use App\Service\Fcm\FcmSendResult;

/**
 * Test double for the FCM client. Records every send and lets a test mark specific fcmTokens as
 * UNREGISTERED. State is static so tests inspect/configure it without resolving the container
 * service (the handler and the test share one process); call reset() per test.
 */
final class RecordingFcmClient implements FcmClientInterface
{
    /** @var list<array{token: string, title: string, body: string, data: array<string, string>}> */
    public static array $sent = [];

    /** @var list<string> fcmTokens that should be reported as UNREGISTERED */
    public static array $unregisteredTokens = [];

    public function send(PushToken $token, string $title, string $body, array $data = []): FcmSendResult
    {
        self::$sent[] = [
            'token' => $token->getFcmToken(),
            'title' => $title,
            'body'  => $body,
            'data'  => $data,
        ];

        return in_array($token->getFcmToken(), self::$unregisteredTokens, true)
            ? FcmSendResult::UNREGISTERED
            : FcmSendResult::SUCCESS;
    }

    public static function reset(): void
    {
        self::$sent = [];
        self::$unregisteredTokens = [];
    }
}
