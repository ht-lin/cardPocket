<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DeleteAccountTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/me';

    public function testDeleteAccountReturns204(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);
        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(204);
    }

    public function testDeleteAccountFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $client->request('DELETE', self::ENDPOINT, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testDeletedUserCannotLogin(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);
        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(401);
    }
}
