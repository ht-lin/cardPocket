<?php

declare(strict_types=1);

namespace App\Tests\Integration\CardShare;

use App\Enum\FriendshipStatus;
use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class ShareCardTest extends AbstractApiTestCase
{
    use Factories;

    private const array JSON_HEADER = ['headers' => ['Accept' => 'application/json']];

    // ─── Happy path ───────────────────────────────────────────────────────────

    public function testShareCardWithFriendSuccessfully(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        FriendshipFactory::createOne([
            'requester' => $owner,
            'addressee' => $viewer,
            'status'    => FriendshipStatus::ACCEPTED,
        ]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'POST',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            ['json' => ['viewerId' => (string) $viewer->getId()], ...self::JSON_HEADER],
        );

        $this->assertResponseStatusCodeSame(201);
        $data = $response->toArray();
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data['id'],
        );
        $this->assertSame((string) $viewer->getId(), $data['viewer']['id']);
        $this->assertNull($data['viewerNickname']);
        $this->assertArrayHasKey('createdAt', $data);
    }

    public function testGetSharesReturnsEmptyArray(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card  = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            self::JSON_HEADER,
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame([], $response->toArray());
    }

    // ─── Business rule violations ─────────────────────────────────────────────

    public function testShareCardFailsIfNotFriends(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'POST',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            ['json' => ['viewerId' => (string) $viewer->getId()], ...self::JSON_HEADER],
        );

        $this->assertResponseStatusCodeSame(403);
        $this->assertArrayHasKey('detail', $response->toArray(false));
    }

    public function testShareCardFailsIfAlreadyShared(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        FriendshipFactory::createOne([
            'requester' => $owner,
            'addressee' => $viewer,
            'status'    => FriendshipStatus::ACCEPTED,
        ]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'POST',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            ['json' => ['viewerId' => (string) $viewer->getId()], ...self::JSON_HEADER],
        );

        $this->assertResponseStatusCodeSame(422);
        $this->assertArrayHasKey('detail', $response->toArray(false));
    }

    // ─── Privacy isolation ────────────────────────────────────────────────────

    public function testOwnerCannotSeeViewerNickname(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        CardShareFactory::createOne([
            'card'           => $card,
            'viewer'         => $viewer,
            'viewerNickname' => '私有昵称',
        ]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            self::JSON_HEADER,
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertNull($data[0]['viewerNickname']);
    }

    // ─── Authorization ────────────────────────────────────────────────────────

    public function testGetSharesRequiresAuth(): void
    {
        $owner = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $card  = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $client->request('GET', '/api/cards/' . $card->getId() . '/shares', self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testCreateShareRequiresAuth(): void
    {
        $owner  = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $client->request('POST', '/api/cards/' . $card->getId() . '/shares', [
            'json'    => ['viewerId' => (string) $viewer->getId()],
            ...(self::JSON_HEADER),
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testViewerCannotListShares(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            self::JSON_HEADER,
        );

        $this->assertResponseStatusCodeSame(403);
    }

    public function testNonOwnerCannotShareCard(): void
    {
        $owner    = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $outsider = UserFactory::createOne(['email' => 'outsider@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $target   = UserFactory::createOne(['email' => 'target@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card     = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'outsider@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'POST',
            '/api/cards/' . $card->getId() . '/shares',
            $token,
            ['json' => ['viewerId' => (string) $target->getId()], ...self::JSON_HEADER],
        );

        $this->assertResponseStatusCodeSame(403);
    }
}
