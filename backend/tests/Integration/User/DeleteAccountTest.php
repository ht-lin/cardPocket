<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Enum\FriendshipStatus;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DeleteAccountTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/me';

    public function testDeleteAccountReturns204(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);
        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(204);
    }

    public function testDeleteAccountFailsWithoutAuth(): void
    {
        $client = static::createClient();
        $client->request('DELETE', self::ENDPOINT, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testDeleteAccountCascadesCards(): void
    {
        $user = UserFactory::createOne(['email' => 'cascade@example.com']);
        CardFactory::createMany(3, ['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'cascade@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();
        $userId = (string) $user->getId();
        $softDeletedCount = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card WHERE owner_id = ? AND deleted_at IS NOT NULL',
            [$userId],
        );
        $this->assertSame(3, $softDeletedCount);
    }

    public function testDeleteAccountCascadesCardShares(): void
    {
        $user   = UserFactory::createOne(['email' => 'owner@example.com']);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com']);
        $card   = CardFactory::createOne(['owner' => $user]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn       = static::getContainer()->get('doctrine')->getConnection();
        $shareCount = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_share WHERE card_id = ?',
            [(string) $card->getId()],
        );
        $this->assertSame(0, $shareCount);
    }

    public function testDeleteAccountCascadesFriendships(): void
    {
        $user   = UserFactory::createOne(['email' => 'user@example.com']);
        $friend = UserFactory::createOne(['email' => 'friend@example.com']);
        FriendshipFactory::createOne([
            'requester' => $user,
            'addressee' => $friend,
            'status'    => FriendshipStatus::ACCEPTED,
        ]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn            = static::getContainer()->get('doctrine')->getConnection();
        $friendshipCount = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM app_friendship WHERE requester_id = ? OR addressee_id = ?',
            [(string) $user->getId(), (string) $user->getId()],
        );
        $this->assertSame(0, $friendshipCount);
    }

    public function testDeletedUserCannotLogin(): void
    {
        UserFactory::createOne(['email' => 'user@example.com']);
        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'user@example.com', 'password' => 'Password1!'],
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(401);
    }
}
