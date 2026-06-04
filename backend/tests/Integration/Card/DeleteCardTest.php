<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class DeleteCardTest extends AbstractApiTestCase
{
    use Factories;

    public function testDeleteCardSuccessfully(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $card->getId(), $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(204);
    }

    public function testDeleteCardFailsForNonOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $token = $this->getToken($client, 'other@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/' . $card->getId(), $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testDeleteCardFailsWithoutAuth(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();

        $client->request('DELETE', '/api/cards/' . $card->getId(), [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(401);
    }

    public function testDeleteCardReturns404ForNonExistentCard(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'DELETE', '/api/cards/00000000-0000-0000-0000-000000000000', $token, [
            'headers' => ['Accept' => 'application/json'],
        ]);

        $this->assertResponseStatusCodeSame(404);
    }
}
