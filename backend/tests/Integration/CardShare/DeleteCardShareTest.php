<?php

declare(strict_types=1);

namespace App\Tests\Integration\CardShare;

use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DeleteCardShareTest extends AbstractApiTestCase
{
    use Factories;

    // ─── Happy path ───────────────────────────────────────────────────────────

    public function testOwnerCanRemoveViewer(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/card-shares/' . $share->getId(), $token);

        $this->assertResponseStatusCodeSame(204);
    }

    public function testViewerCanLeaveShare(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/card-shares/' . $share->getId(), $token);

        $this->assertResponseStatusCodeSame(204);
    }

    public function testDeleteActuallyRemovesRecord(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);
        $shareId = (string) $share->getId();

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/card-shares/' . $shareId, $token);

        $this->assertResponseStatusCodeSame(204);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_share WHERE id = ?',
            [$shareId],
        );
        $this->assertSame(0, $count);
    }

    // ─── Authorization ────────────────────────────────────────────────────────

    public function testDeleteCardShareRequiresAuth(): void
    {
        $owner  = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $client->request('DELETE', '/api/card-shares/' . $share->getId());

        $this->assertResponseStatusCodeSame(401);
    }

    public function testThirdPartyCannotDeleteShare(): void
    {
        $owner    = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer   = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $outsider = UserFactory::createOne(['email' => 'outsider@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card     = CardFactory::createOne(['owner' => $owner]);
        $share    = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'outsider@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/card-shares/' . $share->getId(), $token);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testDeleteShareReturns404ForMalformedUuid(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/card-shares/not-a-uuid', $token);

        $this->assertResponseStatusCodeSame(404);
    }
}
