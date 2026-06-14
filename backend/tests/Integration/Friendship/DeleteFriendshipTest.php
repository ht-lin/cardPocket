<?php

declare(strict_types=1);

namespace App\Tests\Integration\Friendship;

use App\Enum\FriendshipStatus;
use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DeleteFriendshipTest extends AbstractApiTestCase
{
    use Factories;

    public function testRejectFriendRequestDeletesRecord(): void
    {
        $requester = UserFactory::createOne(['email' => 'requester@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $friendship = FriendshipFactory::createOne([
            'requester' => $requester,
            'addressee' => $addressee,
            'status'    => FriendshipStatus::PENDING,
        ]);

        $friendshipId = (string) $friendship->getId();

        $client = static::createClient();
        $token  = $this->getToken($client, 'addressee@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/friendships/' . $friendshipId, $token);

        $this->assertResponseStatusCodeSame(204);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = $conn->fetchOne('SELECT COUNT(*) FROM app_friendship WHERE id = ?', [$friendshipId]);
        $this->assertSame('0', (string) $count);
    }

    public function testRemoveFriendshipCascadesAllCardShares(): void
    {
        $userA = UserFactory::createOne(['email' => 'usera@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $userB = UserFactory::createOne(['email' => 'userb@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $friendship = FriendshipFactory::createOne([
            'requester' => $userA,
            'addressee' => $userB,
            'status'    => FriendshipStatus::ACCEPTED,
        ]);

        // A 的 card1, card2 共享给 B（2 条）
        $card1  = CardFactory::createOne(['owner' => $userA]);
        $card2  = CardFactory::createOne(['owner' => $userA]);
        $share1 = CardShareFactory::createOne(['card' => $card1, 'viewer' => $userB]);
        $share2 = CardShareFactory::createOne(['card' => $card2, 'viewer' => $userB]);

        // B 的 card3 共享给 A（1 条）
        $card3  = CardFactory::createOne(['owner' => $userB]);
        $share3 = CardShareFactory::createOne(['card' => $card3, 'viewer' => $userA]);

        $share1Id = (string) $share1->getId();
        $share2Id = (string) $share2->getId();
        $share3Id = (string) $share3->getId();

        $client = static::createClient();
        $token  = $this->getToken($client, 'usera@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/friendships/' . $friendship->getId(), $token);

        $this->assertResponseStatusCodeSame(204);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_share WHERE id IN (?, ?, ?)',
            [$share1Id, $share2Id, $share3Id],
        );
        $this->assertSame('0', (string) $count);
    }

    public function testRemoveFriendshipCreatesCardDeletionForViewer(): void
    {
        $userA = UserFactory::createOne(['email' => 'usera@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $userB = UserFactory::createOne(['email' => 'userb@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $friendship = FriendshipFactory::createOne([
            'requester' => $userA,
            'addressee' => $userB,
            'status'    => FriendshipStatus::ACCEPTED,
        ]);

        // A 的卡片共享给 B
        $cardA = CardFactory::createOne(['owner' => $userA]);
        CardShareFactory::createOne(['card' => $cardA, 'viewer' => $userB]);

        // B 的卡片共享给 A
        $cardB = CardFactory::createOne(['owner' => $userB]);
        CardShareFactory::createOne(['card' => $cardB, 'viewer' => $userA]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'usera@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/friendships/' . $friendship->getId(), $token);

        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();

        // B 失去了 A 的卡片 → CardDeletion(userId=B, cardId=cardA)
        $deletionForB = $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_deletion WHERE user_id = ? AND card_id = ?',
            [(string) $userB->getId(), (string) $cardA->getId()],
        );
        $this->assertSame('1', (string) $deletionForB);

        // A 失去了 B 的卡片 → CardDeletion(userId=A, cardId=cardB)
        $deletionForA = $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_deletion WHERE user_id = ? AND card_id = ?',
            [(string) $userA->getId(), (string) $cardB->getId()],
        );
        $this->assertSame('1', (string) $deletionForA);
    }

    public function testNonParticipantCannotDeleteFriendship(): void
    {
        $requester  = UserFactory::createOne(['email' => 'requester@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee  = UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $outsider   = UserFactory::createOne(['email' => 'outsider@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $friendship = FriendshipFactory::createOne([
            'requester' => $requester,
            'addressee' => $addressee,
            'status'    => FriendshipStatus::ACCEPTED,
        ]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'outsider@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/friendships/' . $friendship->getId(), $token);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testDeleteNonExistentFriendshipReturns404(): void
    {
        UserFactory::createOne(['email' => 'user@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/friendships/00000000-0000-0000-0000-000000000000', $token);

        $this->assertResponseStatusCodeSame(404);
    }

    public function testDeleteReturns404ForMalformedUuid(): void
    {
        UserFactory::createOne(['email' => 'user@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/friendships/not-a-uuid', $token);

        $this->assertResponseStatusCodeSame(404);
    }

    public function testUnauthenticatedRequestReturns401(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/friendships/00000000-0000-0000-0000-000000000000');

        $this->assertResponseStatusCodeSame(401);
    }
}
