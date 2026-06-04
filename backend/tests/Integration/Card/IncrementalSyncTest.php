<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Entity\CardDeletion;
use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class IncrementalSyncTest extends AbstractApiTestCase
{
    use Factories;

    private const array JSON_HEADER = ['headers' => ['Accept' => 'application/json']];

    // A fixed timestamp well in the past so any entity created during the test is "after" it.
    private const string PAST_ISO = '2020-01-01T00:00:00+00:00';

    public function testUpdatedAfterReturnsOnlyChangedCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $cardA = CardFactory::createOne(['owner' => $owner, 'name' => 'Old Card']);

        // Backdate cardA so it appears before $since.
        static::getContainer()->get('doctrine.orm.entity_manager')
            ->getConnection()
            ->executeStatement(
                'UPDATE app_card SET updated_at = :past WHERE id = :id',
                ['past' => '2020-01-01 00:00:00', 'id' => (string) $cardA->getId()],
            );

        $since = new \DateTimeImmutable('2025-01-01T00:00:00+00:00');

        $cardB = CardFactory::createOne(['owner' => $owner, 'name' => 'New Card']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards?updatedAfter=' . urlencode($since->format(\DateTimeInterface::ATOM)),
            $token,
            self::JSON_HEADER,
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();

        $this->assertArrayHasKey('updated', $data);
        $this->assertArrayHasKey('deleted', $data);
        $this->assertCount(1, $data['updated']);
        $this->assertSame((string) $cardB->getId(), $data['updated'][0]['id']);
        $this->assertEmpty($data['deleted']);
    }

    public function testDeletedIncludesRemovedCards(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'name' => 'To Be Deleted']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $card->getId(), $token);
        $this->assertResponseStatusCodeSame(204);

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards?updatedAfter=' . urlencode(self::PAST_ISO),
            $token,
            self::JSON_HEADER,
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();

        $this->assertArrayHasKey('deleted', $data);
        $this->assertContains((string) $card->getId(), $data['deleted']);
        $this->assertEmpty($data['updated']);
    }

    public function testDeletedIncludesRevokedShares(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner, 'name' => 'Shared Card']);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $em = static::getContainer()->get('doctrine.orm.entity_manager');
        $deletion = new CardDeletion();
        $deletion->setUserId((string) $viewer->getId());
        $deletion->setCardId((string) $card->getId());
        $em->persist($deletion);
        $em->flush();

        $client = static::createClient();
        $token = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'GET',
            '/api/cards?updatedAfter=' . urlencode(self::PAST_ISO),
            $token,
            self::JSON_HEADER,
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();

        $this->assertArrayHasKey('deleted', $data);
        $this->assertContains((string) $card->getId(), $data['deleted']);
    }
}
