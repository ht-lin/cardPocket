<?php

declare(strict_types=1);

namespace App\Tests\Integration\Friendship;

use App\Enum\FriendshipStatus;
use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class AcceptFriendshipRequestTest extends AbstractApiTestCase
{
    use Factories;

    public function testAcceptFriendRequestSuccessfully(): void
    {
        $requester = UserFactory::createOne(['email' => 'requester@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $friendship = FriendshipFactory::createOne([
            'requester' => $requester,
            'addressee' => $addressee,
            'status'    => FriendshipStatus::PENDING,
        ]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'addressee@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/friendships/' . $friendship->getId() . '/accept',
            $token,
        );

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('ACCEPTED', $data['status']);
    }

    public function testOnlyAddresseeCanAcceptRequest(): void
    {
        $requester = UserFactory::createOne(['email' => 'requester@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $friendship = FriendshipFactory::createOne([
            'requester' => $requester,
            'addressee' => $addressee,
            'status'    => FriendshipStatus::PENDING,
        ]);

        $client = static::createClient();
        // Requester 尝试接受自己发出的请求 → 403
        $token = $this->getToken($client, 'requester@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/friendships/' . $friendship->getId() . '/accept',
            $token,
        );

        $this->assertResponseStatusCodeSame(403);
    }
}
