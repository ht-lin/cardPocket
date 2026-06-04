<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Symfony\Component\BrowserKit\AbstractBrowser as Client;
use Zenstruck\Foundry\Test\Factories;

final class SearchTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/search';

    public function testSearchByUserName(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        $target = UserFactory::createOne(['email' => 'target@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT . '?q=' . urlencode($target->getUserName()),
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(200);

        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data[0]['id'],
        );
        $this->assertSame($target->getUserName(), $data[0]['userName']);
        $this->assertArrayNotHasKey('email', $data[0]);
    }

    public function testSearchByEmail(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        $target = UserFactory::createOne(['email' => 'target@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT . '?q=' . urlencode('target@example.com'),
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(200);

        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data[0]['id'],
        );
        $this->assertSame($target->getUserName(), $data[0]['userName']);
        $this->assertArrayNotHasKey('email', $data[0]);
    }

    public function testSearchReturnsEmptyArrayWhenNotFound(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT . '?q=nobody_exists',
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray());
    }

    public function testSearchReturnsEmptyArrayWhenQIsEmpty(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT . '?q=',
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray());
    }

    public function testSearchReturnsEmptyArrayWhenQParamMissing(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT,
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray());
    }

    public function testSearchDoesNotReturnSoftDeletedUser(): void
    {
        UserFactory::createOne([
            'email' => 'searcher@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        $deleted = UserFactory::createOne([
            'email' => 'deleted@example.com',
            'deletedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'searcher@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT . '?q=' . urlencode($deleted->getUserName()),
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray());
    }

    public function testSearchFailsWhenEmailNotVerified(): void
    {
        UserFactory::createOne(['email' => 'unverified@example.com']);

        $client = static::createClient();
        $token = $this->getToken($client, 'unverified@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'GET',
            self::ENDPOINT . '?q=anyone',
            $token,
            ['headers' => ['Accept' => 'application/json']],
        );

        $this->assertResponseStatusCodeSame(403);
    }

    public function testSearchFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $response = $client->request('GET', self::ENDPOINT . '?q=anyone', [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(401);
        $this->assertSame(401, $response->toArray(throw: false)['code']);
    }
}
