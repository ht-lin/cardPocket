<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Entity\RefreshToken;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class RefreshTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/refresh';

    public function testRefreshSuccessfully(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $client = static::createClient();
        $loginResponse = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
        ]);
        $oldRefreshToken = $loginResponse->toArray()['refresh_token'];

        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $oldRefreshToken],
        ]);

        $this->assertResponseStatusCodeSame(200);

        $data = $response->toArray();
        $this->assertArrayHasKey('access_token', $data);
        $this->assertArrayHasKey('refresh_token', $data);
        $this->assertArrayHasKey('expires_in', $data);
        $this->assertArrayNotHasKey('token', $data);
        $this->assertArrayNotHasKey('token_type', $data);
        $this->assertSame(900, $data['expires_in']);
        $this->assertMatchesRegularExpression(
            '/^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$/',
            $data['access_token'],
            'access_token must be a valid JWT',
        );
        $this->assertNotSame($oldRefreshToken, $data['refresh_token'], 'New refresh_token must differ from old one');

        $em = static::getContainer()->get('doctrine')->getManager();
        $newToken = $em->getRepository(RefreshToken::class)->findOneBy(['refreshToken' => $data['refresh_token']]);
        $this->assertNotNull($newToken, 'New RefreshToken must be persisted in the database');

        $oldToken = $em->getRepository(RefreshToken::class)->findOneBy(['refreshToken' => $oldRefreshToken]);
        $this->assertNull($oldToken, 'Old RefreshToken must be deleted after rotation');
    }

    public function testRefreshFailsWithExpiredToken(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $em = static::getContainer()->get('doctrine')->getManager();
        $rt = new RefreshToken();
        $rt->setRefreshToken(bin2hex(random_bytes(32)));
        $rt->setUsername('user@example.com');
        $rt->setValid(new \DateTime('-1 second'));
        $em->persist($rt);
        $em->flush();

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $rt->getRefreshToken()],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $data = $response->toArray(throw: false);
        $this->assertArrayNotHasKey('access_token', $data);
        $this->assertArrayNotHasKey('refresh_token', $data);
    }

    public function testRefreshFailsWithNonExistentToken(): void
    {
        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => bin2hex(random_bytes(32))],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $data = $response->toArray(throw: false);
        $this->assertArrayNotHasKey('access_token', $data);
        $this->assertArrayNotHasKey('refresh_token', $data);
    }

    public function testOldRefreshTokenIsRevokedAfterRotation(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $client = static::createClient();
        $loginResponse = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
        ]);
        $oldRefreshToken = $loginResponse->toArray()['refresh_token'];

        $refreshResponse = $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $oldRefreshToken],
        ]);
        $this->assertResponseStatusCodeSame(200);
        $newRefreshToken = $refreshResponse->toArray()['refresh_token'];
        $this->assertNotSame($oldRefreshToken, $newRefreshToken, 'Rotation must issue a new token');

        $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $oldRefreshToken],
        ]);
        $this->assertResponseStatusCodeSame(401);

        $client->request('POST', self::ENDPOINT, [
            'json' => ['refresh_token' => $newRefreshToken],
        ]);
        $this->assertResponseStatusCodeSame(200);
    }
}
