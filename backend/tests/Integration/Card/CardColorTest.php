<?php

declare(strict_types=1);

namespace App\Tests\Integration\Card;

use App\Factory\CardFactory;
use App\Factory\UserFactory;
use App\Tests\AbstractApiTestCase;
use Zenstruck\Foundry\Test\Factories;

final class CardColorTest extends AbstractApiTestCase
{
    use Factories;

    public function testCreateCardWithColor(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'POST', '/api/cards', $token, [
            'json' => [
                'name'           => 'Loyalty',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'ABC123',
                'color'          => '#FF5733',
            ],
        ]);

        $this->assertResponseStatusCodeSame(201);
        $this->assertSame('#FF5733', $response->toArray()['color']);
    }

    public function testCreateCardWithoutColorDefaultsToNull(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'POST', '/api/cards', $token, [
            'json' => [
                'name'           => 'Loyalty',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'ABC123',
            ],
        ]);

        $this->assertResponseStatusCodeSame(201);
        $this->assertNull($response->toArray()['color']);
    }

    public function testPatchSetsColor(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['color' => '#00FF00'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertSame('#00FF00', $response->toArray()['color']);
    }

    public function testPatchWithExplicitNullClearsColor(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user, 'color' => '#123456']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['color' => null],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $this->assertNull($response->toArray()['color']);
    }

    public function testPatchWithoutColorKeyPreservesExistingValue(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user, 'color' => '#ABCDEF']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        // Omitting color must not wipe the previously set value.
        $response = $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['name' => 'Renamed'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $data = $response->toArray();
        $this->assertSame('Renamed', $data['name']);
        $this->assertSame('#ABCDEF', $data['color']);
    }

    public function testCreateWithInvalidColorFormatFails(): void
    {
        UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'POST', '/api/cards', $token, [
            'json' => [
                'name'           => 'Loyalty',
                'barcodeType'    => 'QR_CODE',
                'barcodeContent' => 'ABC123',
                'color'          => 'red',
            ],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testPatchWithInvalidColorFormatFails(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        $card = CardFactory::createOne(['owner' => $user]);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $this->authenticatedRequest($client, 'PATCH', '/api/cards/' . $card->getId(), $token, [
            'json' => ['color' => '#GGGGGG'],
        ]);

        $this->assertResponseStatusCodeSame(422);
    }

    public function testListExposesColor(): void
    {
        $user = UserFactory::createOne(['email' => 'owner@example.com', 'emailVerifiedAt' => new \DateTimeImmutable()]);
        CardFactory::createOne(['owner' => $user, 'color' => '#FF5733']);

        $client = static::createClient();
        $token = $this->getToken($client, 'owner@example.com', 'Password1!');

        $response = $this->authenticatedRequest($client, 'GET', '/api/cards', $token, [
            'headers' => ['Accept' => 'application/ld+json'],
        ]);

        $this->assertResponseStatusCodeSame(200);
        $members = $response->toArray()['member'];
        $this->assertCount(1, $members);
        $this->assertSame('#FF5733', $members[0]['color']);
    }
}
