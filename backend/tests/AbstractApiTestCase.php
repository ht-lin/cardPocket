<?php

declare(strict_types=1);

namespace App\Tests;

use ApiPlatform\Symfony\Bundle\Test\ApiTestCase;
use ApiPlatform\Symfony\Bundle\Test\Client;
use Symfony\Contracts\HttpClient\ResponseInterface;

abstract class AbstractApiTestCase extends ApiTestCase
{
    // Opt into API Platform 5.0 behavior: don't reboot kernel on every createClient() call.
    // Required for DAMA transaction isolation and to suppress deprecation under failOnDeprecation=true.
    protected static ?bool $alwaysBootKernel = false;
    /**
     * Login and return the access token.
     * Reuses the same client to preserve DAMA transaction isolation.
     * Never call createClient() a second time in the same test.
     */
    protected function getToken(Client $client, string $email, string $password): string
    {
        $response = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => $email, 'password' => $password],
        ]);

        return $response->toArray()['access_token'];
    }

    /**
     * Make an authenticated request.
     * Use auth_bearer option — not an Authorization header string — to satisfy API Platform's client.
     */
    protected function authenticatedRequest(
        Client $client,
        string $method,
        string $url,
        string $token,
        array $options = [],
    ): ResponseInterface {
        return $client->request($method, $url, array_merge($options, ['auth_bearer' => $token]));
    }
}
