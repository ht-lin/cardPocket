<?php

declare(strict_types=1);

namespace App\Service\Fcm;

use App\Entity\PushToken;
use Symfony\Contracts\HttpClient\Exception\TransportExceptionInterface;
use Symfony\Contracts\HttpClient\HttpClientInterface;

/**
 * Sends a single notification through the FCM HTTP v1 API. A 404 / UNREGISTERED / NOT_FOUND
 * response means the device token is dead and should be deactivated; other failures are transient.
 */
final class FcmClient implements FcmClientInterface
{
    public function __construct(
        private readonly HttpClientInterface $httpClient,
        private readonly FcmAccessTokenProviderInterface $accessTokenProvider,
        private readonly string $projectId,
    ) {
    }

    public function send(PushToken $token, string $title, string $body, array $data = []): FcmSendResult
    {
        $endpoint = sprintf('https://fcm.googleapis.com/v1/projects/%s/messages:send', $this->projectId);

        $payload = [
            'message' => [
                'token'        => $token->getFcmToken(),
                'notification' => [
                    'title' => $title,
                    'body'  => $body,
                ],
            ],
        ];
        if ($data !== []) {
            $payload['message']['data'] = $data;
        }

        try {
            $response = $this->httpClient->request('POST', $endpoint, [
                'auth_bearer' => $this->accessTokenProvider->getAccessToken(),
                'json'        => $payload,
            ]);

            $status = $response->getStatusCode();

            if ($status >= 200 && $status < 300) {
                return FcmSendResult::SUCCESS;
            }

            if ($this->isUnregistered($status, $response->getContent(false))) {
                return FcmSendResult::UNREGISTERED;
            }

            return FcmSendResult::TRANSIENT_ERROR;
        } catch (TransportExceptionInterface) {
            return FcmSendResult::TRANSIENT_ERROR;
        }
    }

    private function isUnregistered(int $status, string $body): bool
    {
        if ($status !== 404) {
            return false;
        }

        // FCM v1 returns 404 with error.details[].errorCode == UNREGISTERED, or status NOT_FOUND.
        return str_contains($body, 'UNREGISTERED') || str_contains($body, 'NOT_FOUND');
    }
}
