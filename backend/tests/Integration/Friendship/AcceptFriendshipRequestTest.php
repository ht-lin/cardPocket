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
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data['id'],
        );
        $this->assertSame('ACCEPTED', $data['status']);
        $this->assertSame((string) $requester->getId(), $data['friend']['id']);
        $this->assertIsString($data['friend']['userName']);
        $this->assertMatchesRegularExpression(
            '/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}$/',
            $data['createdAt'],
        );
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

    public function testAcceptNonExistentRequestReturns404(): void
    {
        UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'addressee@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/friendships/00000000-0000-0000-0000-000000000000/accept',
            $token,
        );

        $this->assertResponseStatusCodeSame(404);
    }

    public function testAcceptReturns404ForMalformedUuid(): void
    {
        UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'addressee@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/friendships/not-a-uuid/accept',
            $token,
        );

        $this->assertResponseStatusCodeSame(404);
    }

    public function testUnauthenticatedRequestReturns401(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/friendships/00000000-0000-0000-0000-000000000000/accept');

        $this->assertResponseStatusCodeSame(401);
    }
}
