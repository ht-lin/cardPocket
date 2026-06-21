<?php

declare(strict_types=1);

namespace App\Service\Fcm;

use Google\Auth\Credentials\ServiceAccountCredentials;

/**
 * Exchanges a Google service-account JSON key for a short-lived OAuth2 access token via google/auth,
 * caching it in-memory until shortly before expiry so a single worker run does not re-sign per push.
 */
final class FcmAccessTokenProvider implements FcmAccessTokenProviderInterface
{
    private const string SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
    private const int EXPIRY_SKEW_SECONDS = 30;

    private ?string $accessToken = null;
    private int $expiresAt = 0;

    public function __construct(
        private readonly string $credentialsPath,
    ) {
    }

    public function getAccessToken(): string
    {
        $now = time();
        if ($this->accessToken !== null && $now < $this->expiresAt) {
            return $this->accessToken;
        }

        $credentials = new ServiceAccountCredentials(self::SCOPE, $this->credentialsPath);
        $token = $credentials->fetchAuthToken();

        if (!isset($token['access_token']) || !is_string($token['access_token'])) {
            throw new \RuntimeException('FCM: failed to obtain an OAuth2 access token.');
        }

        $expiresIn = isset($token['expires_in']) && is_int($token['expires_in']) ? $token['expires_in'] : 3600;
        $this->accessToken = $token['access_token'];
        $this->expiresAt   = $now + $expiresIn - self::EXPIRY_SKEW_SECONDS;

        return $this->accessToken;
    }
}
