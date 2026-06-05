<?php

declare(strict_types=1);

namespace App\Tests\Integration\Friendship;

use App\Enum\FriendshipStatus;
use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class ListFriendshipsTest extends AbstractApiTestCase
{
    use Factories;

    private const array JSON_HEADER = ['headers' => ['Accept' => 'application/json']];

    public function testGetAcceptedFriendsList(): void
    {
        $me      = UserFactory::createOne(['email' => 'me@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $friend  = UserFactory::createOne(['email' => 'friend@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $pending = UserFactory::createOne(['email' => 'pending@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        FriendshipFactory::createOne(['requester' => $me, 'addressee' => $friend, 'status' => FriendshipStatus::ACCEPTED]);
        FriendshipFactory::createOne(['requester' => $me, 'addressee' => $pending, 'status' => FriendshipStatus::PENDING]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/friendships', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(1, $data);
        $this->assertSame('ACCEPTED', $data[0]['status']);
        $this->assertArrayHasKey('friend', $data[0]);
        $this->assertSame((string) $friend->getId(), $data[0]['friend']['id']);
    }

    public function testGetPendingRequestsAsAddressee(): void
    {
        $me        = UserFactory::createOne(['email' => 'me@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $sender1   = UserFactory::createOne(['email' => 'sender1@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $sender2   = UserFactory::createOne(['email' => 'sender2@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        // 两条 PENDING 请求发给 me
        FriendshipFactory::createOne(['requester' => $sender1, 'addressee' => $me, 'status' => FriendshipStatus::PENDING]);
        FriendshipFactory::createOne(['requester' => $sender2, 'addressee' => $me, 'status' => FriendshipStatus::PENDING]);
        // me 发出的请求，不应出现在 /requests 中
        $outsider = UserFactory::createOne(['email' => 'outsider@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        FriendshipFactory::createOne(['requester' => $me, 'addressee' => $outsider, 'status' => FriendshipStatus::PENDING]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/friendships/requests', $token, self::JSON_HEADER);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertCount(2, $data);
        $this->assertArrayHasKey('requester', $data[0]);
    }

    public function testUnauthenticatedRequestReturns401(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/friendships');
        $this->assertResponseStatusCodeSame(401);
    }
}
