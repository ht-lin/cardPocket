<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Entity\EmailVerificationToken;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class ResendVerificationTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/resend-verification';

    public function testResendVerificationSuccessfully(): void
    {
        $user = UserFactory::createOne(['emailVerifiedAt' => null]);

        $em = static::getContainer()->get('doctrine')->getManager();
        // UserFactory does not trigger the registration flow, so no token exists yet.
        $this->assertCount(0, $em->getRepository(EmailVerificationToken::class)->findBy(['user' => $user]));

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => $user->getEmail()],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('', $response->getContent());

        $tokens = $em->getRepository(EmailVerificationToken::class)->findBy(['user' => $user]);
        $this->assertCount(1, $tokens, 'Each resend appends a new token; old tokens are not deleted');
        $this->assertGreaterThan(
            new \DateTimeImmutable('+23 hours'),
            $tokens[0]->getExpiresAt(),
            'Token must expire approximately 24 hours from now',
        );
    }

    public function testResendVerificationReturns200ForAlreadyVerifiedUser(): void
    {
        $user = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => $user->getEmail()],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('', $response->getContent());

        $em = static::getContainer()->get('doctrine')->getManager();
        $this->assertCount(
            0,
            $em->getRepository(EmailVerificationToken::class)->findBy(['user' => $user]),
            'No token must be created for an already-verified user',
        );
    }

    public function testResendVerificationReturns200ForNonExistentEmail(): void
    {
        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'ghost@example.com'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('', $response->getContent());
    }

    public function testResendVerificationReturns200ForSoftDeletedUser(): void
    {
        $user = UserFactory::createOne(['deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $response = $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => $user->getEmail()],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('', $response->getContent());

        // Soft-deleted users are filtered out by the Doctrine soft-delete filter,
        // making them indistinguishable from non-existent users in the Processor.
        $em = static::getContainer()->get('doctrine')->getManager();
        $this->assertCount(
            0,
            $em->getRepository(EmailVerificationToken::class)->findBy(['user' => $user]),
            'Soft-deleted users must be treated as non-existent',
        );
    }

    public function testResendVerificationFailsWithBlankEmail(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => ''],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'email']]]);
    }

    public function testResendVerificationFailsWithInvalidEmailFormat(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['email' => 'notanemail'],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'email']]]);
    }

    public function testResendVerificationFailsWithMissingEmailField(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => [],
        ]);

        $this->assertResponseStatusCodeSame(422);
        $this->assertJsonContains(['violations' => [['propertyPath' => 'email']]]);
    }
}
