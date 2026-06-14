<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Entity\RefreshToken;
use App\Factory\CardDeletionFactory;
use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\EmailVerificationTokenFactory;
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

    public function testDeleteAccountAnonymizesUserPersonalData(): void
    {
        $user = UserFactory::createOne(['email' => 'user@example.com']);
        $userId = (string) $user->getId();

        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();
        $row = $conn->fetchAssociative(
            'SELECT email, user_name, password FROM app_user WHERE id = ?',
            [$userId],
        );

        $this->assertNotFalse($row);
        $this->assertSame("deleted_{$userId}@deleted.invalid", $row['email']);
        $this->assertSame("deleted_{$userId}", $row['user_name']);
        $this->assertSame('', $row['password']);
    }

    public function testDeleteAccountAnonymizesCardContent(): void
    {
        $user = UserFactory::createOne(['email' => 'user@example.com']);
        CardFactory::createMany(2, ['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();
        $userId = (string) $user->getId();
        $nonEmptyCount = (int) $conn->fetchOne(
            "SELECT COUNT(*) FROM app_card WHERE owner_id = ? AND (name != '' OR barcode_content != '')",
            [$userId],
        );
        $this->assertSame(0, $nonEmptyCount);
    }

    public function testDeleteAccountClearsCardDeletionRecords(): void
    {
        $user = UserFactory::createOne(['email' => 'user@example.com']);
        $userId = (string) $user->getId();
        CardDeletionFactory::createMany(3, ['userId' => $userId]);

        $client = static::createClient();
        $token = $this->getToken($client, 'user@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_deletion WHERE user_id = ?',
            [$userId],
        );
        $this->assertSame(0, $count);
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

    public function testDeleteAccountWritesTombstoneForSharedViewers(): void
    {
        $owner  = UserFactory::createOne(['email' => 'owner@example.com']);
        $viewer = UserFactory::createOne(['email' => 'viewer@example.com']);
        $card   = CardFactory::createOne(['owner' => $owner]);
        CardShareFactory::createOne(['card' => $card, 'viewer' => $viewer]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM app_card_deletion WHERE user_id = ? AND card_id = ?',
            [(string) $viewer->getId(), (string) $card->getId()],
        );
        $this->assertSame(1, $count, 'A tombstone must be written for each viewer of the deleted owner\'s shares');
    }

    public function testDeleteAccountRevokesRefreshTokens(): void
    {
        UserFactory::createOne(['email' => 'revoke@example.com']);

        $client = static::createClient();
        $loginResponse = $client->request('POST', '/api/auth/login', [
            'json' => ['email' => 'revoke@example.com', 'password' => 'Password1!'],
        ]);
        $refreshToken = $loginResponse->toArray()['refresh_token'];

        $token = $this->getToken($client, 'revoke@example.com', 'Password1!');
        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $em = static::getContainer()->get('doctrine')->getManager();
        $remaining = $em->getRepository(RefreshToken::class)->findOneBy(['refreshToken' => $refreshToken]);
        $this->assertNull($remaining, 'Refresh tokens must be revoked when the account is deleted');
    }

    public function testDeleteAccountClearsEmailVerificationTokens(): void
    {
        $user = UserFactory::createOne(['email' => 'evt@example.com']);
        EmailVerificationTokenFactory::createOne(['user' => $user]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'evt@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', self::ENDPOINT, $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);
        $this->assertResponseStatusCodeSame(204);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne(
            'SELECT COUNT(*) FROM email_verification_token WHERE user_id = ?',
            [(string) $user->getId()],
        );
        $this->assertSame(0, $count, 'Email verification tokens must be cleared when the account is deleted');
    }
}
