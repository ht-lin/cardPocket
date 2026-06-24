<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DiscoverableTest extends AbstractApiTestCase
{
    use Factories;

    private const string ME = '/api/users/me';
    private const string SEARCH = '/api/users/search';

    public function testDefaultDiscoverableIsTrue(): void
    {
        UserFactory::createOne(['email' => 'me@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', self::ME, $token);

        $this->assertResponseStatusCodeSame(200);
        $this->assertTrue($response->toArray()['discoverable']);
    }

    public function testSetDiscoverableToFalsePersists(): void
    {
        UserFactory::createOne(['email' => 'me@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', self::ME, $token, [
            'json' => ['discoverable' => false],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertFalse($response->toArray()['discoverable']);

        $getResponse = $this->authenticatedRequest($client, 'GET', self::ME, $token);
        $this->assertFalse($getResponse->toArray()['discoverable']);
    }

    public function testPatchWithoutDiscoverablePreservesValue(): void
    {
        UserFactory::createOne(['email' => 'me@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', self::ME, $token, [
            'json' => ['discoverable' => false],
        ]);

        // A later PATCH that omits discoverable must not reset it to true.
        $response = $this->authenticatedRequest($client, 'PATCH', self::ME, $token, [
            'json' => ['userName' => 'renamedUser'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertFalse($response->toArray()['discoverable']);
    }

    public function testNonDiscoverableUserNotFoundByUserName(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        $target = UserFactory::createOne([
            'email' => 'hidden@example.com',
            'discoverable' => false,
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::SEARCH . '?q=' . urlencode($target->getUserName()),
            $token,
            ['headers' => ['Accept' => 'application/ld+json']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray()['member']);
    }

    public function testNonDiscoverableUserNotFoundByEmail(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        UserFactory::createOne([
            'email' => 'hidden@example.com',
            'discoverable' => false,
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::SEARCH . '?q=' . urlencode('hidden@example.com'),
            $token,
            ['headers' => ['Accept' => 'application/ld+json']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray()['member']);
    }
}
