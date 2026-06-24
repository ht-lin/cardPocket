<?php

declare(strict_types=1);

namespace App\Tests\Integration\User;

use App\Enum\FriendshipStatus;
use App\Factory\CardFactory;
use App\Factory\CardShareFactory;
use App\Factory\FriendshipFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DataExportTest extends AbstractApiTestCase
{
    use Factories;

    private const string ENDPOINT = '/api/users/me/data-export';

    public function testRequiresAuth(): void
    {
        $client = static::createClient();
        $client->request('GET', self::ENDPOINT, [
            'headers' => ['Accept' => 'application/ld+json'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testExportsProfile(): void
    {
        UserFactory::createOne([
            'email' => 'me@example.com',
            'userName' => 'meUser',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);

        $this->assertResponseStatusCodeSame(200);
        $profile = $response->toArray()['profile'];
        $this->assertSame('me@example.com', $profile['email']);
        $this->assertSame('meUser', $profile['userName']);
        $this->assertTrue($profile['discoverable']);
        $this->assertSame('KEEP', $profile['expiryPolicy']);
    }

    public function testExportsOwnedCardsIncludingTrashed(): void
    {
        $me = UserFactory::createOne([
            'email' => 'me@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        CardFactory::createOne(['owner' => $me, 'name' => 'Active Card']);
        CardFactory::createOne(['owner' => $me, 'name' => 'Trashed Card', 'deletedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token);

        $this->assertResponseStatusCodeSame(200);
        $names = array_column($response->toArray()['ownedCards'], 'name');
        $this->assertContains('Active Card', $names);
        $this->assertContains('Trashed Card', $names);
    }

    public function testExportsSharesAndFriends(): void
    {
        $me = UserFactory::createOne([
            'email' => 'me@example.com',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        $friend = UserFactory::createOne([
            'email' => 'friend@example.com',
            'userName' => 'friendUser',
            'emailVerifiedAt' => new \DateTimeImmutable(),
        ]);
        FriendshipFactory::createOne([
            'requester' => $me,
            'addressee' => $friend,
            'status' => FriendshipStatus::ACCEPTED,
        ]);

        // A card I own, shared to my friend (shares I granted).
        $myCard = CardFactory::createOne(['owner' => $me, 'name' => 'My Shared Card']);
        CardShareFactory::createOne(['card' => $myCard, 'viewer' => $friend]);

        // A card shared with me by the friend (shared with me).
        $friendCard = CardFactory::createOne(['owner' => $friend, 'name' => 'Friend Card']);
        CardShareFactory::createOne(['card' => $friendCard, 'viewer' => $me, 'viewerNickname' => 'My Label']);

        $client = static::createClient();
        $token = $this->getToken($client, 'me@example.com', 'Password1!');

        $data = $this->authenticatedRequest($client, 'GET', self::ENDPOINT, $token)->toArray();

        $this->assertResponseStatusCodeSame(200);

        $this->assertSame('friendUser', $data['friends'][0]['userName']);
        $this->assertSame('ACCEPTED', $data['friends'][0]['status']);

        $this->assertSame('friendUser', $data['sharesIGranted'][0]['viewerUsername']);
        $this->assertSame('My Shared Card', $data['sharesIGranted'][0]['cardName']);

        $this->assertSame('Friend Card', $data['sharedWithMe'][0]['name']);
        $this->assertSame('friendUser', $data['sharedWithMe'][0]['ownerUsername']);
        $this->assertSame('My Label', $data['sharedWithMe'][0]['viewerNickname']);
    }
}
