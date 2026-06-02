<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Factory\EmailVerificationTokenFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class VerifyEmailTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/verify-email';
    private const string INVALID_TOKEN_MESSAGE = 'Invalid or expired token.';

    public function testVerifyEmailSuccessfully(): void
    {
        $client = static::createClient();
        $em = static::getContainer()->get('doctrine')->getManager();

        $user = UserFactory::createOne();
        $tokenEntity = EmailVerificationTokenFactory::createOne([
            'user' => $user,
            'expiresAt' => new \DateTimeImmutable('+24 hours'),
            'usedAt' => null,
        ]);

        $client->request('POST', self::ENDPOINT, [
            'json' => ['token' => $tokenEntity->getToken()],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertJsonContains(['message' => 'Email verified successfully']);

        $em->refresh($user);
        $this->assertNotNull($user->getEmailVerifiedAt());

        $em->refresh($tokenEntity);
        $this->assertNotNull($tokenEntity->getUsedAt());
    }

    public function testVerifyEmailFailsWithExpiredToken(): void
    {
        $client = static::createClient();

        $user = UserFactory::createOne();
        $tokenEntity = EmailVerificationTokenFactory::createOne([
            'user' => $user,
            'expiresAt' => new \DateTimeImmutable('-1 hour'),
            'usedAt' => null,
        ]);

        $client->request('POST', self::ENDPOINT, [
            'json' => ['token' => $tokenEntity->getToken()],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains([
            'violations' => [['propertyPath' => 'token', 'message' => self::INVALID_TOKEN_MESSAGE]],
        ]);
    }

    public function testVerifyEmailFailsWithUsedToken(): void
    {
        $client = static::createClient();

        $user = UserFactory::createOne();
        $tokenEntity = EmailVerificationTokenFactory::createOne([
            'user' => $user,
            'expiresAt' => new \DateTimeImmutable('+24 hours'),
            'usedAt' => new \DateTimeImmutable('-1 minute'),
        ]);

        $client->request('POST', self::ENDPOINT, [
            'json' => ['token' => $tokenEntity->getToken()],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains([
            'violations' => [['propertyPath' => 'token', 'message' => self::INVALID_TOKEN_MESSAGE]],
        ]);
    }

    public function testVerifyEmailFailsWithNonExistentToken(): void
    {
        $client = static::createClient();

        $client->request('POST', self::ENDPOINT, [
            'json' => ['token' => bin2hex(random_bytes(16))],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains([
            'violations' => [['propertyPath' => 'token', 'message' => self::INVALID_TOKEN_MESSAGE]],
        ]);
    }

    public function testVerifyEmailFailsWithBlankToken(): void
    {
        $client = static::createClient();

        $client->request('POST', self::ENDPOINT, [
            'json' => ['token' => ''],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'token']]]);
    }

    public function testVerifyEmailFailsWithMissingTokenField(): void
    {
        $client = static::createClient();

        $client->request('POST', self::ENDPOINT, [
            'json' => [],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'token']]]);
    }
}
