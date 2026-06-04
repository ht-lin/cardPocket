<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class MeTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/me';

    public function testGetMeSuccessfully(): void
    {
        $user = UserFactory::createOne(['email' => 'me@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);

        $this->assertResponseStatusCodeSame(200);

        $data = $response->toArray();
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data['id'],
        );
        $this->assertSame('me@example.com', $data['email']);
        $this->assertSame($user->getUserName(), $data['userName']);
        $this->assertFalse($data['emailVerified']);
        $this->assertMatchesRegularExpression(
            '/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/',
            $data['createdAt'],
        );
        $this->assertArrayNotHasKey('password', $data);
    }

    public function testGetMeReturnsEmailVerifiedTrueWhenVerified(): void
    {
        UserFactory::createOne([
            'email' => 'verified@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'verified@example.com', 'Password1!');
        $response = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);

        $this->assertResponseStatusCodeSame(200);
        $this->assertTrue($response->toArray()['emailVerified']);
    }

    public function testGetMeFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $response = $client->request('GET', self::ENDPOINT);

        $this->assertResponseStatusCodeSame(401);
        $this->assertSame(401, $response->toArray(throw: false)['code']);
    }
}
