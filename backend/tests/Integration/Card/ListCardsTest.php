<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class ListCardsTest extends AbstractApiTestCase
{
    use Factories;

    private const array JSON_HEADER = ['headers' => ['Accept' => 'application/json']];

    public function testOwnerSeesOwnCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Card 1']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Card 2']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(2, $data);
        foreach ($data as $item) {
            $this->assertTrue($item['isOwner']);
        }
    }

    public function testViewerSeesSharedCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'name' => 'Shared Card']);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertSame((string) $card->getId(), $data[0]['id']);
        $this->assertFalse($data[0]['isOwner']);
    }

    public function testViewerNicknameIsIncludedForViewer(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer, 'viewerNickname' => 'My Custom Label']);

        $client = static::createClient();
        $token = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertSame('My Custom Label', $data[0]['viewerNickname']);
    }

    public function testViewerNicknameIsHiddenFromOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer, 'viewerNickname' => 'Viewer Private Label']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertArrayNotHasKey('viewerNickname', $data[0]);
    }

    public function testListCardsFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/cards', self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testDeletedCardIsHiddenFromOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Active Card']);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Deleted Card', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertSame('Active Card', $data[0]['name']);
    }

    public function testOwnerAndViewerCardsAreMerged(): void
    {
        $user = UserFactory::createOne(['email' => 'user@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $other = UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $user, 'name' => 'My Own Card']);
        $sharedCard = CardFactory::createOne(['owner' => $other, 'name' => 'Shared With Me']);
        CardShareFactory::createOne(['card' => $sharedCard, 'viewer' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(2, $data);

        $ownerItems = array_values(array_filter($data, fn($item) => $item['isOwner'] === true));
        $viewerItems = array_values(array_filter($data, fn($item) => $item['isOwner'] === false));
        $this->assertCount(1, $ownerItems);
        $this->assertCount(1, $viewerItems);
        $this->assertSame('My Own Card', $ownerItems[0]['name']);
        $this->assertSame('Shared With Me', $viewerItems[0]['name']);
    }
}
