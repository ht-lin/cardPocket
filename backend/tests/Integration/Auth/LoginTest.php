<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Entity\RefreshToken;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class LoginTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/login';

    public function testLoginSuccessfully(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(200);

        $data = $response->toArray();
        $this->assertArrayHasKey('access_token', $data);
        $this->assertArrayHasKey('refresh_token', $data);
        $this->assertSame('Bearer', $data['token_type']);
        $this->assertSame(900, $data['expires_in']);
        $this->assertMatchesRegularExpression(
            '/^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$/',
            $data['access_token'],
            'access_token must be a valid JWT',
        );

        $em = static::getContainer()->get('doctrine')->getManager();
        $persisted = $em->getRepository(RefreshToken::class)->findOneBy(['refreshToken' => $data['refresh_token']]);
        $this->assertNotNull($persisted, 'RefreshToken must be persisted in the database');
    }

    public function testJwtContainsEmailVerifiedFalseForUnverifiedUser(): void
    {
        UserFactory::createOne([
            'email' => 'unverified@example.com',
            'emailVerifiedAt' => null,
        ]);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'unverified@example.com', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $payload = $this->decodeJwtPayload($response->toArray()['access_token']);
        $this->assertFalse($payload['email_verified']);
    }

    public function testJwtContainsEmailVerifiedTrueForVerifiedUser(): void
    {
        UserFactory::createOne([
            'email' => 'verified@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'verified@example.com', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $payload = $this->decodeJwtPayload($response->toArray()['access_token']);
        $this->assertTrue($payload['email_verified']);
    }

    public function testLoginFailsWithWrongPassword(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'user@example.com', 'password' => 'WrongPassword!'],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $data = $response->toArray(throw: false);
        $this->assertArrayNotHasKey('access_token', $data);
        $this->assertArrayNotHasKey('refresh_token', $data);
        $this->assertSame('Invalid credentials.', $data['detail'] ?? '');
    }

    public function testLoginFailsWithNonExistentEmail(): void
    {
        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'ghost@example.com', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $data = $response->toArray(throw: false);
        $this->assertArrayNotHasKey('access_token', $data);
        $this->assertArrayNotHasKey('refresh_token', $data);
        $this->assertSame('Invalid credentials.', $data['detail'] ?? '');
    }

    public function testLoginFailsWithSoftDeletedUser(): void
    {
        UserFactory::createOne([
            'email' => 'deleted@example.com',
            'deletedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'deleted@example.com', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $data = $response->toArray(throw: false);
        $this->assertArrayNotHasKey('access_token', $data);
        $this->assertArrayNotHasKey('refresh_token', $data);
        $this->assertSame('Invalid credentials.', $data['detail'] ?? '');
    }

    public function testWrongPasswordAndNonExistentEmailReturnIdenticalResponse(): void
    {
        UserFactory::createOne(['email' => 'existing@example.com']);

        $client = static::createClient();

        $responseWrongPassword = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'existing@example.com', 'password' => 'WrongPassword!'],
        ]);
        $bodyWrongPassword = $responseWrongPassword->toArray(throw: false);

        $responseNoUser = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'ghost@example.com', 'password' => 'Password1!'],
        ]);
        $bodyNoUser = $responseNoUser->toArray(throw: false);

        $this->assertSame(
            $bodyWrongPassword['detail'] ?? null,
            $bodyNoUser['detail'] ?? null,
            'Both 401 responses must return identical error messages to prevent user enumeration',
        );
    }

    public function testLoginFailsWithBlankEmail(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => '', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'email']]]);
    }

    public function testLoginFailsWithInvalidEmailFormat(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'notanemail', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'email']]]);
    }

    public function testLoginFailsWithBlankPassword(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'user@example.com', 'password' => ''],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'password']]]);
    }

    public function testLoginSucceedsWithUnverifiedEmail(): void
    {
        UserFactory::createOne([
            'email' => 'unverified@example.com',
            'emailVerifiedAt' => null,
        ]);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'unverified@example.com', 'password' => 'Password1!'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertArrayHasKey('access_token', $response->toArray());
    }
}
