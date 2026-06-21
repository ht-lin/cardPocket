<?php

declare(strict_types=1);

namespace App\Tests\Unit\Service\Fcm;

use App\Entity\PushToken;
use App\Enum\PushPlatform;
use App\Service\Fcm\FcmAccessTokenProviderInterface;
use App\Service\Fcm\FcmClient;
use App\Service\Fcm\FcmSendResult;
use PHPUnit\Framework\TestCase;
use Symfony\Component\HttpClient\MockHttpClient;
use Symfony\Component\HttpClient\Response\MockResponse;

final class FcmClientTest extends TestCase
{
    public function testSendSuccessPostsToFcmV1Endpoint(): void
    {
        $captured = null;
        $mock = new MockHttpClient(function (string $method, string $url, array $options) use (&$captured): MockResponse {
            $captured = ['method' => $method, 'url' => $url, 'options' => $options];

            return new MockResponse((string) json_encode(['name' => 'projects/p/messages/1']), ['http_code' => 200]);
        });

        $client = new FcmClient($mock, $this->tokenProvider(), 'my-project');
        $result = $client->send($this->pushToken('dev-1'), 'Hi', 'There', ['k' => 'v']);

        self::assertSame(FcmSendResult::SUCCESS, $result);
        self::assertNotNull($captured);
        self::assertSame('POST', $captured['method']);
        self::assertSame('https://fcm.googleapis.com/v1/projects/my-project/messages:send', $captured['url']);

        $body = (string) $captured['options']['body'];
        self::assertStringContainsString('dev-1', $body);
        self::assertStringContainsString('Hi', $body);

        $headers = (string) json_encode($captured['options']['normalized_headers'] ?? $captured['options']['headers'] ?? []);
        self::assertStringContainsString('Bearer fake-access-token', $headers);
    }

    public function testUnregisteredResponseMapsToUnregistered(): void
    {
        $mock = new MockHttpClient(new MockResponse(
            (string) json_encode(['error' => ['status' => 'NOT_FOUND', 'details' => [['errorCode' => 'UNREGISTERED']]]]),
            ['http_code' => 404],
        ));

        $result = (new FcmClient($mock, $this->tokenProvider(), 'p'))
            ->send($this->pushToken('dead-token'), 'Hi', 'There');

        self::assertSame(FcmSendResult::UNREGISTERED, $result);
    }

    public function testServerErrorMapsToTransientError(): void
    {
        $mock = new MockHttpClient(new MockResponse('upstream error', ['http_code' => 503]));

        $result = (new FcmClient($mock, $this->tokenProvider(), 'p'))
            ->send($this->pushToken('dev-1'), 'Hi', 'There');

        self::assertSame(FcmSendResult::TRANSIENT_ERROR, $result);
    }

    private function tokenProvider(): FcmAccessTokenProviderInterface
    {
        return new class implements FcmAccessTokenProviderInterface {
            public function getAccessToken(): string
            {
                return 'fake-access-token';
            }
        };
    }

    private function pushToken(string $fcmToken): PushToken
    {
        $token = new PushToken();
        $token->setFcmToken($fcmToken);
        $token->setPlatform(PushPlatform::ANDROID);

        return $token;
    }
}
