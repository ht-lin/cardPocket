<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class UpdateCardTest extends AbstractApiTestCase
{
    use Factories;

    public function testUpdateCardSuccessfully(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user, 'name' => 'Old Name']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/cards/' . $card->getId(),
            $token,
            ['json' => ['name' => 'New Name']],
        );

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('New Name', $response->toArray()['name']);
    }

    public function testUpdateCardFailsForNonOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $token = $this->getToken($client, 'other@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/cards/' . $card->getId(),
            $token,
            ['json' => ['name' => 'Stolen Name']],
        );

        $this->assertResponseStatusCodeSame(403);
    }

    public function testUpdateCardFailsWithoutAuth(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();

        $client->request('PATCH', '/api/cards/' . $card->getId(), [
            'json' => ['name' => 'New Name'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testUpdateCardReturns404ForNonExistentCard(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest(
            $client,
            'PATCH',
            '/api/cards/00000000-0000-0000-0000-000000000000',
            $token,
            ['json' => ['name' => 'Name']],
        );

        $this->assertResponseStatusCodeSame(404);
    }
}
