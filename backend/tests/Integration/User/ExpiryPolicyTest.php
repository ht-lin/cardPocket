<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class ExpiryPolicyTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/me';

    public function testDefaultExpiryPolicyIsKeep(): void
    {
        UserFactory::createOne(['email' => 'policy@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'policy@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('KEEP', $response->toArray()['expiryPolicy']);
    }

    public function testSetExpiryPolicyToAutoTrash(): void
    {
        UserFactory::createOne(['email' => 'policy@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'policy@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['expiryPolicy' => 'AUTO_TRASH'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('AUTO_TRASH', $response->toArray()['expiryPolicy']);

        // Persisted: a fresh GET still reports AUTO_TRASH.
        $getResponse = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);
        $this->assertSame('AUTO_TRASH', $getResponse->toArray()['expiryPolicy']);
    }

    public function testInvalidExpiryPolicyFails(): void
    {
        UserFactory::createOne(['email' => 'policy@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'policy@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['expiryPolicy' => 'FOO'],
        ]);

        $this->assertResponseStatusCodeSame(400);
    }

    public function testPatchWithoutExpiryPolicyPreservesValue(): void
    {
        UserFactory::createOne(['email' => 'policy@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'policy@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['expiryPolicy' => 'AUTO_TRASH'],
        ]);

        // A later PATCH that omits expiryPolicy must not reset it to KEEP.
        $response = $this->authenticatedRequest($client, 'PATCH', self::ENDPOINT, $token, [
            'json' => ['userName' => 'renamedUser'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('AUTO_TRASH', $response->toArray()['expiryPolicy']);
    }
}
