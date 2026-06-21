<?php

declare(strict_types=1);

namespace App\Service\Fcm;

interface FcmAccessTokenProviderInterface
{
    /**
     * Returns a valid OAuth2 access token for the FCM HTTP v1 API
     * (scope https://www.googleapis.com/auth/firebase.messaging).
     */
    public function getAccessToken(): string;
}
