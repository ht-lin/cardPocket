<?php

declare(strict_types=1);

namespace App\Tests\Integration\CardShare;

use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class UpdateCardShareTest extends AbstractApiTestCase
{
    use Factories;

    // ─── Happy path ───────────────────────────────────────────────────────────

    public function testViewerCanSetNickname(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/card-shares/' . $share->getId(),
            $token,
            ['json' => ['viewerNickname' => '我的超市卡']],
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('我的超市卡', $data['viewerNickname']);
    }

    public function testNicknameTooLongReturns422(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'viewer@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/card-shares/' . $share->getId(),
            $token,
            ['json' => ['viewerNickname' => str_repeat('a', 256)]],
        );

        $this->assertResponseStatusCodeSame(422);
    }

    // ─── Authorization ────────────────────────────────────────────────────────

    public function testUpdateCardShareRequiresAuth(): void
    {
        $owner  = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $client->request('PATCH', '/api/card-shares/' . $share->getId(), [
            'json' => ['viewerNickname' => 'test'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testOwnerCannotSetViewerNickname(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card   = CardFactory::createOne(['owner' => $owner]);
        $share  = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/card-shares/' . $share->getId(),
            $token,
            ['json' => ['viewerNickname' => 'shouldFail']],
        );

        $this->assertResponseStatusCodeSame(403);
    }

    public function testThirdPartyCannotUpdateShare(): void
    {
        $owner    = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $viewer   = UserFactory::createOne(['email' => 'viewer@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $outsider = UserFactory::createOne(['email' => 'outsider@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card     = CardFactory::createOne(['owner' => $owner]);
        $share    = CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'outsider@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/card-shares/' . $share->getId(),
            $token,
            ['json' => ['viewerNickname' => 'shouldFail']],
        );

        $this->assertResponseStatusCodeSame(403);
    }

    public function testUpdateShareReturns404ForMalformedUuid(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/card-shares/not-a-uuid',
            $token,
            ['json' => ['viewerNickname' => 'x']],
        );

        $this->assertResponseStatusCodeSame(404);
    }
}
