<?php

declare(strict_types=1);

namespace App\Tests\Integration\Auth;

use App\Factory\PushTokenFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class PushTokenTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/auth/push-token';

    public function testRegisterNewTokenReturns200(): void
    {
        UserFactory::createOne(['email' => 'u@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token  = $this->getToken($client, 'u@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['fcmToken' => 'tok-abc', 'platform' => 'ANDROID'],
        ]);

        $this->assertResponseStatusCodeSame(200);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne('SELECT COUNT(*) FROM app_push_token WHERE fcm_token = ?', ['tok-abc']);
        $this->assertSame(1, $count);
    }

    public function testRegisterSameTokenUpsertsWithoutDuplicate(): void
    {
        UserFactory::createOne(['email' => 'u@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token  = $this->getToken($client, 'u@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['fcmToken' => 'tok-abc', 'platform' => 'ANDROID'],
        ]);
        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['fcmToken' => 'tok-abc', 'platform' => 'IOS'],
        ]);
        $this->assertResponseStatusCodeSame(200);

        $conn  = static::getContainer()->get('doctrine')->getConnection();
        $count = (int) $conn->fetchOne('SELECT COUNT(*) FROM app_push_token WHERE fcm_token = ?', ['tok-abc']);
        $this->assertSame(1, $count);
        $platform = $conn->fetchOne('SELECT platform FROM app_push_token WHERE fcm_token = ?', ['tok-abc']);
        $this->assertSame('IOS', $platform);
    }

    public function testRegisterExistingTokenReassignsToNewUser(): void
    {
        $userA = UserFactory::createOne(['email' => 'a@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $userB = UserFactory::createOne(['email' => 'b@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        PushTokenFactory::createOne(['user' => $userA, 'fcmToken' => 'shared-tok']);

        $client = static::createClient();
        $token  = $this->getToken($client, 'b@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['fcmToken' => 'shared-tok', 'platform' => 'ANDROID'],
        ]);
        $this->assertResponseStatusCodeSame(200);

        $conn   = static::getContainer()->get('doctrine')->getConnection();
        $userId = $conn->fetchOne('SELECT user_id FROM app_push_token WHERE fcm_token = ?', ['shared-tok']);
        $this->assertSame((string) $userB->getId(), $userId);
    }

    public function testInvalidPlatformReturns422(): void
    {
        UserFactory::createOne(['email' => 'u@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token  = $this->getToken($client, 'u@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['fcmToken' => 'tok-abc', 'platform' => 'WEB'],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testBlankTokenReturns422(): void
    {
        UserFactory::createOne(['email' => 'u@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token  = $this->getToken($client, 'u@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::ENDPOINT, $token, [
            'json' => ['fcmToken' => '', 'platform' => 'ANDROID'],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testUnauthenticatedReturns401(): void
    {
        $client = static::createClient();
        $client->request('POST', self::ENDPOINT, [
            'json' => ['fcmToken' => 'tok-abc', 'platform' => 'ANDROID'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }
}
