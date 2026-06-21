<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class TrashCardTest extends AbstractApiTestCase
{
    use Factories;

    private const array LD_HEADER = ['headers' => ['Accept' => 'application/ld+json']];
    private const string PAST_ISO = '2020-01-01T00:00:00+00:00';

    // ─────────────────────────── GET /api/cards/trash ───────────────────────────

    public function testTrashListsOnlySoftDeletedOwnerCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Active Card']);
        $trashed = CardFactory::createOne(['owner' => $owner, 'name' => 'Trashed Card', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards/trash', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray()['member'];
        $this->assertCount(1, $data);
        $this->assertSame((string) $trashed->getId(), $data[0]['id']);
        $this->assertSame('Trashed Card', $data[0]['name']);
        $this->assertArrayHasKey('deletedAt', $data[0]);
        $this->assertNotNull($data[0]['deletedAt']);
        $this->assertTrue($data[0]['isOwner']);
    }

    public function testTrashDoesNotLeakOtherUsersCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $owner, 'name' => 'Owner Trash', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'other@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards/trash', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $this->assertCount(0, $response->toArray()['member']);
    }

    public function testTrashRequiresAuth(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/cards/trash', self::LD_HEADER);

        $this->assertResponseStatusCodeSame(401);
    }

    // ───────────────────────── POST /api/cards/{id}/restore ─────────────────────────

    public function testRestoreBringsCardBackToMainList(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'name' => 'To Restore', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', '/api/cards/' . $card->getId() . '/restore', $token, self::LD_HEADER);
        $this->assertResponseIsSuccessful();

        // No longer in trash.
        $trash = $this->authenticatedRequest($client, 'GET', '/api/cards/trash', $token, self::LD_HEADER);
        $this->assertCount(0, $trash->toArray()['member']);

        // Back in the main list.
        $list = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, self::LD_HEADER);
        $members = $list->toArray()['member'];
        $this->assertCount(1, $members);
        $this->assertSame((string) $card->getId(), $members[0]['id']);
    }

    public function testRestoreShowsUpInIncrementalSyncUpdated(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'name' => 'Synced Restore', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', '/api/cards/' . $card->getId() . '/restore', $token, self::LD_HEADER);
        $this->assertResponseIsSuccessful();

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards/sync?updatedAfter=' . urlencode(self::PAST_ISO),
            $token,
            self::LD_HEADER,
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $ids = array_column($data['updated'], 'id');
        $this->assertContains((string) $card->getId(), $ids);
        $this->assertNotContains((string) $card->getId(), $data['deleted']);
    }

    public function testRestoreFailsForNonOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'other@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', '/api/cards/' . $card->getId() . '/restore', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testRestoreReturns404ForActiveCard(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]); // not in trash

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', '/api/cards/' . $card->getId() . '/restore', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(404);
    }

    public function testRestoreReturns404ForUnknownCard(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'POST',
            '/api/cards/00000000-0000-0000-0000-000000000000/restore',
            $token,
            self::LD_HEADER,
        );

        $this->assertResponseStatusCodeSame(404);
    }

    public function testRestoreRequiresAuth(): void
    {
        $owner = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $client->request('POST', '/api/cards/' . $card->getId() . '/restore', self::LD_HEADER);

        $this->assertResponseStatusCodeSame(401);
    }

    // ──────────────────────── DELETE /api/cards/{id}/permanent ────────────────────────

    public function testPermanentDeleteRemovesCardRow(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);
        $cardId = (string) $card->getId();

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $cardId . '/permanent', $token, self::LD_HEADER);
        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card WHERE id = ?', [$cardId]);
        $this->assertSame(0, $count);
    }

    public function testPermanentDeleteRemovesSharesAndWritesViewerTombstone(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);
        $cardId = (string) $card->getId();

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $cardId . '/permanent', $token, self::LD_HEADER);
        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();
        $shareCount = (int) $conn->fetchOne('SELECT COUNT(*) FROM app_card_share WHERE card_id = ?', [$cardId]);
        $this->assertSame(0, $shareCount);

        // The viewer learns about the removal through their incremental sync `deleted`.
        $viewerToken = $this->getToken($client, 'viewer@example.com', 'Password1!');
        $sync = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards/sync?updatedAfter=' . urlencode(self::PAST_ISO),
            $viewerToken,
            self::LD_HEADER,
        );
        $this->assertContains($cardId, $sync->toArray()['deleted']);
    }

    public function testPermanentDeleteFailsForNonOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'other@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $card->getId() . '/permanent', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testPermanentDeleteReturns404ForActiveCard(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]); // not in trash

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $card->getId() . '/permanent', $token, self::LD_HEADER);

        $this->assertResponseStatusCodeSame(404);
    }

    public function testPermanentDeleteRequiresAuth(): void
    {
        $owner = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $client->request('DELETE', '/api/cards/' . $card->getId() . '/permanent', self::LD_HEADER);

        $this->assertResponseStatusCodeSame(401);
    }
}
