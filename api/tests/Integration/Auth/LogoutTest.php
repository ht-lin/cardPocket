<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Entity\RefreshToken;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class LogoutTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/logout';

    public function testLogoutSuccessfully(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $client = static::createClient();
        $loginResponse = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
        ]);
        $refreshToken = $loginResponse->toArray()['refresh_token'];

        $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $refreshToken],
        ]);

        $this->assertResponseStatusCodeSame(204);

        $em = static::getContainer()->get('doctrine')->getManager();
        $token = $em->getRepository(RefreshToken::class)->findOneBy(['refreshToken' => $refreshToken]);
        $this->assertNull($token, 'RefreshToken must be deleted after logout');
    }

    public function testRefreshFailsAfterLogout(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $client = static::createClient();
        $loginResponse = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
        ]);
        $refreshToken = $loginResponse->toArray()['refresh_token'];

        $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $refreshToken],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $client->request('POST', '/api/auth/refresh', [
            'json' => ['refresh_token' => $refreshToken],
        ]);
        $this->assertResponseStatusCodeSame(401);
    }

    public function testLogoutWithNonExistentTokenReturns204(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => bin2hex(random_bytes(32))],
        ]);

        $this->assertResponseStatusCodeSame(204);
    }

    public function testLogoutFailsWithBlankRefreshToken(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => ''],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testLogoutFailsWithMissingRefreshToken(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => [],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }
}
