<?php

declare(strict_types=1);

namespace App\Tests\Integration\Friendship;

use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Enum\FriendshipStatus;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class SendFriendshipRequestTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/friendships';

    public function testSendFriendRequestSuccessfully(): void
    {
        $requester = UserFactory::createOne(['email' => 'requester@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addressee@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'requester@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['addresseeId' => (string) $addressee->getId()],
        ]);

        $this->assertResponseStatusCodeSame(201);
        $data = $response->toArray();
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',
            $data['id'],
        );
        $this->assertSame('PENDING', $data['status']);
        $this->assertMatchesRegularExpression(
            '/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}$/',
            $data['createdAt'],
        );
    }

    public function testCannotSendDuplicateRequest(): void
    {
        $requester = UserFactory::createOne(['email' => 'req@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addr@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        FriendshipFactory::createOne([
            'requester' => $requester,
            'addressee' => $addressee,
            'status'    => FriendshipStatus::PENDING,
        ]);

        $client = static::createClient();

        // A 再次发给 B → 422
        $token = $this->getToken($client, 'req@example.com', 'Password1!');
        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['addresseeId' => (string) $addressee->getId()],
        ]);
        $this->assertResponseStatusCodeSame(422);

        // B 发给 A（反向）→ 422
        $token = $this->getToken($client, 'addr@example.com', 'Password1!');
        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['addresseeId' => (string) $requester->getId()],
        ]);
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCannotSendRequestToSelf(): void
    {
        $user = UserFactory::createOne(['email' => 'self@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'self@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['addresseeId' => (string) $user->getId()],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testCannotSendRequestWhenEmailNotVerified(): void
    {
        $requester = UserFactory::createOne(['email' => 'unverified@example.com', 'emailVerifiedAt' => null]);
        $addressee = UserFactory::createOne(['email' => 'target@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'unverified@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['addresseeId' => (string) $addressee->getId()],
        ]);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testCannotSendRequestToNonExistentUser(): void
    {
        UserFactory::createOne(['email' => 'sender@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'sender@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['addresseeId' => '00000000-0000-0000-0000-000000000000'],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }
}
