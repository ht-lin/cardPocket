<?php

declare(strict_types=1);

namespace App\Tests\Integration\Push;

use App\Enum\PushPlatform;
use App\Factory\PushTokenFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use App\Tests\Fake\RecordingFcmClient;
use Zenstruck\Foundry\Test\Factories;

/**
 * Async push transport is sync:// in the test env, so SendPushHandler runs inside the request and
 * we can assert against the recording FCM double directly.
 */
final class SendPushTest extends AbstractApiTestCase
{
    use Factories;

    private const string FRIENDSHIPS = '/api/friendships';

    protected function setUp(): void
    {
        parent::setUp();
        RecordingFcmClient::reset();
    }

    public function testFriendRequestPushesToActiveDevicesOnly(): void
    {
        $requester = UserFactory::createOne(['email' => 'req@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addr@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        PushTokenFactory::createOne(['user' => $addressee, 'fcmToken' => 'dev-1', 'platform' => PushPlatform::ANDROID]);
        PushTokenFactory::createOne(['user' => $addressee, 'fcmToken' => 'dev-2', 'platform' => PushPlatform::IOS]);
        PushTokenFactory::createOne(['user' => $addressee, 'fcmToken' => 'dev-old', 'isActive' => false]);

        $client = static::createClient();
        $token  = $this->getToken($client, 'req@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::FRIENDSHIPS, $token, [
            'json' => ['addresseeId' => (string) $addressee->getId()],
        ]);
        $this->assertResponseStatusCodeSame(201);

        $sentTokens = array_column(RecordingFcmClient::$sent, 'token');
        sort($sentTokens);
        $this->assertSame(['dev-1', 'dev-2'], $sentTokens);
        $this->assertSame('New friend request', RecordingFcmClient::$sent[0]['title']);
    }

    public function testUnregisteredTokenIsDeactivated(): void
    {
        $requester = UserFactory::createOne(['email' => 'req@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $addressee = UserFactory::createOne(['email' => 'addr@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        PushTokenFactory::createOne(['user' => $addressee, 'fcmToken' => 'dev-1', 'platform' => PushPlatform::ANDROID]);
        PushTokenFactory::createOne(['user' => $addressee, 'fcmToken' => 'dev-2', 'platform' => PushPlatform::IOS]);

        RecordingFcmClient::$unregisteredTokens = ['dev-2'];

        $client = static::createClient();
        $token  = $this->getToken($client, 'req@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', self::FRIENDSHIPS, $token, [
            'json' => ['addresseeId' => (string) $addressee->getId()],
        ]);
        $this->assertResponseStatusCodeSame(201);

        $conn    = static::getContainer()->get('doctrine')->getConnection();
        $active1 = (int) $conn->fetchOne('SELECT is_active::int FROM app_push_token WHERE fcm_token = ?', ['dev-1']);
        $active2 = (int) $conn->fetchOne('SELECT is_active::int FROM app_push_token WHERE fcm_token = ?', ['dev-2']);
        $this->assertSame(1, $active1);
        $this->assertSame(0, $active2);
    }
}
