<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class SearchCardsTest extends AbstractApiTestCase
{
    use Factories;

    private const array LD_HEADER = ['headers' => ['Accept' => 'application/ld+json']];

    public function testSearchMatchesOwnerCardBySubstring(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Costco 会员卡']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Gym Pass']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?q=cost', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(1, $data);
        $this->assertSame('Costco 会员卡', $data[0]['name']);
    }

    public function testSearchIsCaseInsensitive(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Costco 会员卡']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?q=COST', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(1, $data);
        $this->assertSame('Costco 会员卡', $data[0]['name']);
    }

    public function testSearchMatchesSharedCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'name' => 'Shared Loyalty Card']);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);
        // A second shared card that must not match the query.
        $other = CardFactory::createOne(['owner' => $owner, 'name' => 'Unrelated']);
        CardShareFactory::createOne(['card' => $other, 'viewer' => $viewer]);

        $client = static::createClient();
        $token = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?q=loyalty', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(1, $data);
        $this->assertSame((string) $card->getId(), $data[0]['id']);
        $this->assertFalse($data[0]['isOwner']);
    }

    public function testSearchSpansOwnerAndSharedCards(): void
    {
        $user = UserFactory::createOne(['email' => 'user@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $other = UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $user, 'name' => 'My Travel Card']);
        $sharedCard = CardFactory::createOne(['owner' => $other, 'name' => 'Shared Travel Pass']);
        CardShareFactory::createOne(['card' => $sharedCard, 'viewer' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?q=travel', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(2, $data);
    }

    public function testSearchNoMatchReturnsEmptyCollection(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Costco 会员卡']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?q=nonexistent', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $this->assertEmpty($response->toArray()['member']);
    }

    public function testSearchExcludesDeletedCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Active Costco']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Deleted Costco', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?q=costco', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(1, $data);
        $this->assertSame('Active Costco', $data[0]['name']);
    }

    public function testSearchTreatsWildcardCharsLiterally(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => '50%off']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Regular Card']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        // A bare '%' must not match every card; only the card literally containing '%'.
        $response = $this->authenticatedRequest($client, 'GET', '/api/cards?' . http_build_query(['q' => '%']), $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(1, $data);
        $this->assertSame('50%off', $data[0]['name']);
    }

    public function testNoQueryReturnsAllCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Card 1']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Card 2']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $this->assertCount(2, $response->toArray()['member']);
    }

    public function testSearchFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/cards?q=cost', self::LD_HEADER);

        $this->assertResponseStatusCodeSame(401);
    }
}
