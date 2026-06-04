<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class GetCardTest extends AbstractApiTestCase
{
    use Factories;

    public function testGetCardSuccessfully(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne([
            'owner'          => $user,
            'name'           => 'My Card',
            'barcodeType'    => \App\Enum\BarcodeType::EAN_13,
            'barcodeContent' => '1234567890123',
        ]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards/' . $card->getId(), $token);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame((string) $card->getId(), $data['id']);
        $this->assertSame('My Card', $data['name']);
        $this->assertSame('EAN_13', $data['barcodeType']);
        $this->assertSame('1234567890123', $data['barcodeContent']);
        $this->assertTrue($data['isOwner']);
    }

    public function testGetCardFailsForNonOwner(): void
    {
        $owner = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        UserFactory::createOne(['email' => 'other@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $owner]);

        $client = static::createClient();
        $token = $this->getToken($client, 'other@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'GET', '/api/cards/' . $card->getId(), $token);

        $this->assertResponseStatusCodeSame(403);
    }

    public function testGetCardFailsWithoutAuth(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();

        $client->request('GET', '/api/cards/' . $card->getId());

        $this->assertResponseStatusCodeSame(401);
    }

    public function testGetCardReturns404ForNonExistentCard(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'GET', '/api/cards/00000000-0000-0000-0000-000000000000', $token);

        $this->assertResponseStatusCodeSame(404);
    }
}
